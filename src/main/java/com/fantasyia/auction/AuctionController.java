package com.fantasyia.auction;

import com.fantasyia.team.Player;
import com.fantasyia.team.PlayerRepository;
import com.fantasyia.user.UserAccount;
import com.fantasyia.user.UserAccountRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/auction")
public class AuctionController {

    @Autowired
    private AuctionRepository auctionRepository;
    
    @Autowired
    private AuctionItemRepository auctionItemRepository;
    
    @Autowired
    private BidRepository bidRepository;
    
    @Autowired
    private PlayerRepository playerRepository;
    
    @Autowired
    private UserAccountRepository userAccountRepository;

    @GetMapping("/manage")
    public String manageAuctions(Model model) {
        // Get current authenticated user
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        UserAccount user = userAccountRepository.findByUsername(username).orElse(null);
        
        if (user == null || !"COMMISSIONER".equals(user.getRole())) {
            return "redirect:/";
        }

        // Get or create the main auction
        Auction mainAuction = getOrCreateMainAuction(user.getId());
        
        // Get all auction items for this auction
        List<AuctionItem> activeItems = auctionItemRepository.findByAuctionIdAndStatus(mainAuction.getId(), "ACTIVE");
        List<AuctionItem> expiredItems = auctionItemRepository.findExpiredItems(mainAuction.getId(), LocalDateTime.now().minusHours(24));
        
        // Get free agents available for adding to auction
        List<Player> freeAgents = playerRepository.findByOwnerIdIsNull();
        
        // Remove players already in auction
        List<Long> auctionPlayerIds = activeItems.stream()
            .map(AuctionItem::getPlayerId)
            .collect(Collectors.toList());
        freeAgents = freeAgents.stream()
            .filter(player -> !auctionPlayerIds.contains(player.getId()))
            .collect(Collectors.toList());
        
        // Get players and their details for active items
        Map<Long, Player> playersMap = playerRepository.findAllById(
            activeItems.stream().map(AuctionItem::getPlayerId).collect(Collectors.toList())
        ).stream().collect(Collectors.toMap(Player::getId, player -> player));
        
        // Get highest bids for each item
        Map<Long, Bid> highestBids = activeItems.stream()
            .collect(Collectors.toMap(
                AuctionItem::getId,
                item -> {
                    Bid highestBid = bidRepository.findHighestBidForItem(item.getId());
                    return highestBid; // Can be null if no bids
                }
            ));
        
        model.addAttribute("auction", mainAuction);
        model.addAttribute("activeItems", activeItems);
        model.addAttribute("expiredItems", expiredItems);
        model.addAttribute("freeAgents", freeAgents);
        model.addAttribute("playersMap", playersMap);
        model.addAttribute("highestBids", highestBids);
        model.addAttribute("currentDateTime", LocalDateTime.now());
        
        return "auction-manage";
    }

    @GetMapping("/view")
    public String viewAuction(Model model) {
        // Get or create the main auction (commissioners can create, others just view)
        Auction mainAuction = getMainAuction();
        if (mainAuction == null) {
            // Create a default auction if none exists
            mainAuction = new Auction(
                "Main Player Auction", 
                LocalDateTime.now(), 
                LocalDateTime.now().plusYears(1), // Always running
                1L, // Default commissioner ID
                "Always-running player auction. Players are available for bidding with minimum 24-hour periods after first bid."
            );
            mainAuction = auctionRepository.save(mainAuction);
        }
        
        // Get current user
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        UserAccount user = userAccountRepository.findByUsername(username).orElse(null);
        
        // Get active auction items
        List<AuctionItem> activeItems = auctionItemRepository.findByAuctionIdAndStatus(mainAuction.getId(), "ACTIVE");
        
        // Get players and their details
        Map<Long, Player> playersMap = playerRepository.findAllById(
            activeItems.stream().map(AuctionItem::getPlayerId).collect(Collectors.toList())
        ).stream().collect(Collectors.toMap(Player::getId, player -> player));
        
        // Get highest bids and bid counts
        Map<Long, Bid> highestBids = activeItems.stream()
            .collect(Collectors.toMap(
                AuctionItem::getId,
                item -> {
                    Bid highestBid = bidRepository.findHighestBidForItem(item.getId());
                    return highestBid; // Can be null if no bids
                }
            ));
        
        Map<Long, Long> bidCounts = activeItems.stream()
            .collect(Collectors.toMap(
                AuctionItem::getId,
                item -> bidRepository.countBidsForItem(item.getId())
            ));
        
        // Calculate total bids
        long totalBids = bidCounts.values().stream().mapToLong(Long::longValue).sum();
        
        // Get user's recent bids if logged in
        Map<Long, List<Bid>> userBids = null;
        if (user != null) {
            userBids = activeItems.stream()
                .collect(Collectors.toMap(
                    AuctionItem::getId,
                    item -> bidRepository.findBidsByUserForItem(item.getId(), user.getId())
                ));
        }
        
        model.addAttribute("auction", mainAuction);
        model.addAttribute("activeItems", activeItems);
        model.addAttribute("playersMap", playersMap);
        model.addAttribute("highestBids", highestBids);
        model.addAttribute("bidCounts", bidCounts);
        model.addAttribute("totalBids", totalBids);
        model.addAttribute("userBids", userBids);
        model.addAttribute("currentUser", user);
        model.addAttribute("currentDateTime", LocalDateTime.now());
        
        return "auction-view";
    }

    @PostMapping("/add-player")
    public String addPlayerToAuction(@RequestParam Long playerId,
                                   @RequestParam(defaultValue = "1.0") Double startingBid,
                                   RedirectAttributes redirectAttributes) {
        
        // Check commissioner permissions
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        UserAccount user = userAccountRepository.findByUsername(username).orElse(null);
        
        if (user == null || !"COMMISSIONER".equals(user.getRole())) {
            redirectAttributes.addFlashAttribute("error", "Only commissioners can add players to auction");
            return "redirect:/auction/manage";
        }

        try {
            // Get or create main auction
            Auction mainAuction = getOrCreateMainAuction(user.getId());
            
            // Check if player is already in auction
            AuctionItem existingItem = auctionItemRepository.findByPlayerIdAndStatus(playerId, "ACTIVE");
            if (existingItem != null) {
                redirectAttributes.addFlashAttribute("error", "Player is already in auction");
                return "redirect:/auction/manage";
            }
            
            // Check if player is free agent
            Player player = playerRepository.findById(playerId).orElse(null);
            if (player == null || player.getOwnerId() != null) {
                redirectAttributes.addFlashAttribute("error", "Player is not a free agent");
                return "redirect:/auction/manage";
            }
            
            // Create auction item
            AuctionItem auctionItem = new AuctionItem(playerId, mainAuction.getId(), startingBid);
            auctionItemRepository.save(auctionItem);
            
            redirectAttributes.addFlashAttribute("success", 
                "Player " + player.getName() + " added to auction with starting bid $" + startingBid);
            
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Error adding player to auction: " + e.getMessage());
        }
        
        return "redirect:/auction/manage";
    }

    @PostMapping("/place-bid")
    public String placeBid(@RequestParam Long auctionItemId,
                          @RequestParam Double bidAmount,
                          RedirectAttributes redirectAttributes) {
        
        // Get current user
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        UserAccount user = userAccountRepository.findByUsername(username).orElse(null);
        
        if (user == null) {
            return "redirect:/login";
        }

        try {
            // Get auction item
            AuctionItem auctionItem = auctionItemRepository.findById(auctionItemId).orElse(null);
            if (auctionItem == null || !"ACTIVE".equals(auctionItem.getStatus())) {
                redirectAttributes.addFlashAttribute("error", "Auction item not found or not active");
                return "redirect:/auction/view";
            }
            
            // Check minimum bid
            Double minBid = auctionItem.getCurrentBid() != null ? 
                auctionItem.getCurrentBid() + 1.0 : auctionItem.getStartingBid();
            
            if (bidAmount < minBid) {
                redirectAttributes.addFlashAttribute("error", 
                    "Bid must be at least $" + minBid);
                return "redirect:/auction/view";
            }
            
            // Create bid
            Bid bid = new Bid(auctionItemId, user.getId(), bidAmount);
            bidRepository.save(bid);
            
            // Update auction item
            if (auctionItem.getFirstBidTime() == null) {
                auctionItem.setFirstBidTime(LocalDateTime.now());
                auctionItem.setEndTime(LocalDateTime.now().plusHours(24));
            }
            auctionItem.setCurrentBid(bidAmount);
            auctionItem.setCurrentBidderId(user.getId());
            auctionItemRepository.save(auctionItem);
            
            // Mark previous bids as outbid
            List<Bid> previousBids = bidRepository.findByAuctionItemIdOrderByAmountDesc(auctionItemId);
            for (Bid prevBid : previousBids) {
                if (!prevBid.getId().equals(bid.getId())) {
                    prevBid.setStatus("OUTBID");
                    bidRepository.save(prevBid);
                }
            }
            bid.setStatus("WINNING");
            bidRepository.save(bid);
            
            Player player = playerRepository.findById(auctionItem.getPlayerId()).orElse(null);
            redirectAttributes.addFlashAttribute("success", 
                "Bid placed successfully for " + (player != null ? player.getName() : "player") + 
                " - $" + bidAmount);
            
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Error placing bid: " + e.getMessage());
        }
        
        return "redirect:/auction/view";
    }

    @PostMapping("/remove-player/{itemId}")
    public String removePlayerFromAuction(@PathVariable Long itemId,
                                        RedirectAttributes redirectAttributes) {
        
        // Check commissioner permissions
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        UserAccount user = userAccountRepository.findByUsername(username).orElse(null);
        
        if (user == null || !"COMMISSIONER".equals(user.getRole())) {
            redirectAttributes.addFlashAttribute("error", "Only commissioners can remove players from auction");
            return "redirect:/auction/manage";
        }

        try {
            AuctionItem auctionItem = auctionItemRepository.findById(itemId).orElse(null);
            if (auctionItem == null) {
                redirectAttributes.addFlashAttribute("error", "Auction item not found");
                return "redirect:/auction/manage";
            }
            
            // Check if minimum time has elapsed since first bid
            if (auctionItem.getFirstBidTime() != null && !auctionItem.canBeRemoved()) {
                long hoursRemaining = auctionItem.getTimeRemainingHours();
                redirectAttributes.addFlashAttribute("error", 
                    "Cannot remove player yet. Must wait " + hoursRemaining + " more hours after first bid.");
                return "redirect:/auction/manage";
            }
            
            // If there were bids, award player to highest bidder
            if (auctionItem.getCurrentBidderId() != null) {
                Player player = playerRepository.findById(auctionItem.getPlayerId()).orElse(null);
                if (player != null) {
                    player.setOwnerId(auctionItem.getCurrentBidderId());
                    player.setContractLength(1); // Default 1 year contract
                    player.setContractAmount(auctionItem.getCurrentBid());
                    playerRepository.save(player);
                }
                auctionItem.setStatus("SOLD");
                redirectAttributes.addFlashAttribute("success", 
                    "Player awarded to highest bidder for $" + auctionItem.getCurrentBid());
            } else {
                auctionItem.setStatus("REMOVED");
                redirectAttributes.addFlashAttribute("success", "Player removed from auction (no bids)");
            }
            
            auctionItemRepository.save(auctionItem);
            
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Error removing player: " + e.getMessage());
        }
        
        return "redirect:/auction/manage";
    }

    // Helper methods
    private Auction getOrCreateMainAuction(Long commissionerId) {
        List<Auction> activeAuctions = auctionRepository.findByStatus("ACTIVE");
        if (!activeAuctions.isEmpty()) {
            return activeAuctions.get(0);
        }
        
        // Create main auction
        Auction mainAuction = new Auction(
            "Main Player Auction", 
            LocalDateTime.now(), 
            LocalDateTime.now().plusYears(1), // Always running
            commissionerId,
            "Always-running player auction. Players are available for bidding with minimum 24-hour periods after first bid."
        );
        return auctionRepository.save(mainAuction);
    }
    
    private Auction getMainAuction() {
        List<Auction> activeAuctions = auctionRepository.findByStatus("ACTIVE");
        return activeAuctions.isEmpty() ? null : activeAuctions.get(0);
    }
}