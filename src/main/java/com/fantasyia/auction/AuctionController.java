package com.fantasyia.auction;

import com.fantasyia.team.Player;
import com.fantasyia.team.PlayerRepository;
import com.fantasyia.team.ReleasedPlayer;
import com.fantasyia.team.ReleasedPlayerRepository;
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
import java.time.Duration;
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
    
    @Autowired
    private ReleasedPlayerRepository releasedPlayerRepository;

    @Autowired
    private PendingContractRepository pendingContractRepository;

    @Autowired
    private AuctionService auctionService;

    @GetMapping("/manage")
    public String manageAuctions(Model model) {
        try {
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
            
            // Get pending released players from the queue
            List<ReleasedPlayer> releasedPlayersQueue = releasedPlayerRepository.findByStatusOrderByReleasedAtDesc("PENDING");
            
            // Get pending contracts
            List<PendingContract> pendingContracts = pendingContractRepository.findByStatus("PENDING");
            
            // Check for expired contracts and handle them
            handleExpiredContracts();
            
            // Get players and their details for active items - with null check
            Map<Long, Player> playersMap = new java.util.HashMap<>();
            if (!activeItems.isEmpty()) {
                List<Long> playerIds = activeItems.stream()
                    .map(AuctionItem::getPlayerId)
                    .collect(Collectors.toList());
                
                List<Player> players = playerRepository.findAllById(playerIds);
                for (Player player : players) {
                    playersMap.put(player.getId(), player);
                }
                
                // Filter out auction items for players that don't exist
                List<AuctionItem> validItems = activeItems.stream()
                    .filter(item -> playersMap.containsKey(item.getPlayerId()))
                    .collect(Collectors.toList());
                activeItems = validItems;
            }
            
            // Get highest bids and minimum next bid for each item
            Map<Long, Bid> highestBids = new java.util.HashMap<>();
            Map<Long, Double> minimumNextBids = new java.util.HashMap<>();
            for (AuctionItem item : activeItems) {
                Bid highestBid = bidRepository.findHighestBidForItem(item.getId());
                highestBids.put(item.getId(), highestBid);
                minimumNextBids.put(item.getId(), item.getMinimumNextBid(mainAuction.getAuctionType()));
            }
            
            model.addAttribute("auction", mainAuction);
            model.addAttribute("activeItems", activeItems);
            model.addAttribute("expiredItems", expiredItems);
            model.addAttribute("freeAgents", freeAgents);
            model.addAttribute("releasedPlayersQueue", releasedPlayersQueue);
            model.addAttribute("pendingContracts", pendingContracts);
            model.addAttribute("playersMap", playersMap);
            model.addAttribute("highestBids", highestBids);
            model.addAttribute("minimumNextBids", minimumNextBids);
            model.addAttribute("currentDateTime", LocalDateTime.now());
            
            return "auction-manage";
        } catch (Exception e) {
            System.err.println("=== ERROR IN MANAGE AUCTIONS ===");
            e.printStackTrace();
            model.addAttribute("error", "Error loading auction management page: " + e.getMessage());
            return "auction-manage";
        }
    }

    @GetMapping("/view")
    public String viewAuction(Model model) {
        try {
            // Get or create the main auction (commissioners can create, others just view)
            Auction mainAuction = getMainAuction();
            if (mainAuction == null) {
                // Create a default auction if none exists
                mainAuction = new Auction(
                    "Main Player Auction", 
                    LocalDateTime.now(), 
                    LocalDateTime.now().plusYears(1), // Always running
                    1L, // Default commissioner ID
                    "In-Season Free Agency: Players require 24 hours after first bid. Dynamic minimum bid increments."
                );
                mainAuction.setAuctionType("IN_SEASON");
                mainAuction = auctionRepository.save(mainAuction);
            }
            
            // Get current user
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            String username = auth.getName();
            UserAccount user = userAccountRepository.findByUsername(username).orElse(null);
            
            // Get active auction items
            List<AuctionItem> activeItems = auctionItemRepository.findByAuctionIdAndStatus(mainAuction.getId(), "ACTIVE");
            
            // Get players and their details - with null check
            Map<Long, Player> playersMap = new java.util.HashMap<>();
            if (!activeItems.isEmpty()) {
                List<Long> playerIds = activeItems.stream()
                    .map(AuctionItem::getPlayerId)
                    .collect(Collectors.toList());
                
                List<Player> players = playerRepository.findAllById(playerIds);
                for (Player player : players) {
                    playersMap.put(player.getId(), player);
                }
                
                // Filter out auction items for players that don't exist
                List<AuctionItem> validItems = activeItems.stream()
                    .filter(item -> playersMap.containsKey(item.getPlayerId()))
                    .collect(Collectors.toList());
                activeItems = validItems;
            }
            
            // Get highest bids, bid counts, and minimum next bids
            Map<Long, Bid> highestBids = new java.util.HashMap<>();
            Map<Long, Long> bidCounts = new java.util.HashMap<>();
            Map<Long, Double> minimumNextBids = new java.util.HashMap<>();
            long totalBids = 0;
            
            for (AuctionItem item : activeItems) {
                Bid highestBid = bidRepository.findHighestBidForItem(item.getId());
                highestBids.put(item.getId(), highestBid);
                
                Long count = bidRepository.countBidsForItem(item.getId());
                bidCounts.put(item.getId(), count);
                totalBids += count;
                
                minimumNextBids.put(item.getId(), item.getMinimumNextBid(mainAuction.getAuctionType()));
            }
            
            // Get user's recent bids if logged in
            Map<Long, List<Bid>> userBids = new java.util.HashMap<>();
            List<PendingContract> userPendingContracts = new java.util.ArrayList<>();
            if (user != null) {
                if (!activeItems.isEmpty()) {
                    for (AuctionItem item : activeItems) {
                        List<Bid> bids = bidRepository.findBidsByUserForItem(item.getId(), user.getId());
                        userBids.put(item.getId(), bids);
                    }
                }
                
                // Get user's pending contracts
                userPendingContracts = pendingContractRepository.findByWinnerIdAndStatus(user.getId(), "PENDING");
            }
            
            model.addAttribute("auction", mainAuction);
            model.addAttribute("activeItems", activeItems);
            model.addAttribute("playersMap", playersMap);
            model.addAttribute("highestBids", highestBids);
            model.addAttribute("bidCounts", bidCounts);
            model.addAttribute("totalBids", totalBids);
            model.addAttribute("minimumNextBids", minimumNextBids);
            model.addAttribute("userBids", userBids);
            model.addAttribute("userPendingContracts", userPendingContracts);
            model.addAttribute("currentUser", user);
            model.addAttribute("currentDateTime", LocalDateTime.now());
            
            return "auction-view";
        } catch (Exception e) {
            System.err.println("=== ERROR IN VIEW AUCTION ===");
            e.printStackTrace();
            model.addAttribute("error", "Error loading auction view: " + e.getMessage());
            return "auction-view";
        }
    }

    @PostMapping("/add-player")
    public String addPlayerToAuction(@RequestParam Long playerId,
                                   @RequestParam(defaultValue = "0.5") Double startingBid,
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
            
            // Set minimum bid based on player type
            boolean isMinorLeaguer = player.getIsMinorLeaguer() || player.getIsRookie();
            double minBid = isMinorLeaguer ? 0.1 : 0.5; // $100K for minors, $500K for MLB
            
            if (startingBid < minBid) {
                startingBid = minBid;
            }
            
            // Create auction item
            AuctionItem auctionItem = new AuctionItem(playerId, mainAuction.getId(), startingBid, isMinorLeaguer, user.getId());
            auctionItemRepository.save(auctionItem);
            
            redirectAttributes.addFlashAttribute("success", 
                "Player " + player.getName() + " added to auction with starting bid $" + 
                String.format("%.1fM", startingBid));
            
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
            // Use the service to place bid with all validation
            AuctionService.BidResult result = auctionService.placeBid(auctionItemId, user.getId(), bidAmount);
            
            if (result.isSuccess()) {
                redirectAttributes.addFlashAttribute("success", result.getMessage());
            } else {
                redirectAttributes.addFlashAttribute("error", result.getMessage());
            }
            
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Error placing bid: " + e.getMessage());
            e.printStackTrace();
        }
        
        return "redirect:/auction/view";
    }

    @PostMapping("/add-released-player")
    public String addReleasedPlayerToAuction(@RequestParam Long releasedPlayerId,
                                            @RequestParam(defaultValue = "1.0") Double startingBid,
                                            RedirectAttributes redirectAttributes) {
        
        System.out.println("=== ADD RELEASED PLAYER TO AUCTION ===");
        System.out.println("Released Player ID: " + releasedPlayerId);
        System.out.println("Starting Bid: " + startingBid);
        
        // Check commissioner permissions
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        UserAccount user = userAccountRepository.findByUsername(username).orElse(null);
        
        if (user == null || !"COMMISSIONER".equals(user.getRole())) {
            redirectAttributes.addFlashAttribute("error", "Only commissioners can add players to auction");
            return "redirect:/auction/manage";
        }

        try {
            // Get released player from queue
            ReleasedPlayer releasedPlayer = releasedPlayerRepository.findById(releasedPlayerId).orElse(null);
            if (releasedPlayer == null) {
                redirectAttributes.addFlashAttribute("error", "Released player not found");
                return "redirect:/auction/manage";
            }
            
            if (!"PENDING".equals(releasedPlayer.getStatus())) {
                redirectAttributes.addFlashAttribute("error", "Released player already processed (status: " + releasedPlayer.getStatus() + ")");
                return "redirect:/auction/manage";
            }
            
            System.out.println("Found released player: " + releasedPlayer.getPlayerName());
            
            // Get or create main auction
            Auction mainAuction = getOrCreateMainAuction(user.getId());
            System.out.println("Main auction ID: " + mainAuction.getId());
            
            // Create new player as free agent
            Player player = new Player(
                releasedPlayer.getPlayerName(),
                releasedPlayer.getPosition(),
                releasedPlayer.getMlbTeam(),
                Integer.valueOf(0),
                Double.valueOf(0.0),
                null  // Free agent (no owner)
            );
            
            System.out.println("Saving player: " + player.getName());
            player = playerRepository.save(player);
            System.out.println("Player saved with ID: " + player.getId());
            
            // Add player to auction
            AuctionItem auctionItem = new AuctionItem(player.getId(), mainAuction.getId(), startingBid);
            auctionItemRepository.save(auctionItem);
            System.out.println("Auction item created");
            
            // Update released player status
            releasedPlayer.setStatus("ADDED_TO_AUCTION");
            releasedPlayerRepository.save(releasedPlayer);
            System.out.println("Released player status updated");
            
            redirectAttributes.addFlashAttribute("success", 
                "Player " + releasedPlayer.getPlayerName() + " added to auction with starting bid $" + startingBid);
            
            System.out.println("=== SUCCESS ===");
            
        } catch (Exception e) {
            System.err.println("=== ERROR ===");
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", "Error adding released player to auction: " + e.getMessage());
        }
        
        return "redirect:/auction/manage";
    }

    @PostMapping("/reject-released-player")
    public String rejectReleasedPlayer(@RequestParam Long releasedPlayerId,
                                      RedirectAttributes redirectAttributes) {
        
        System.out.println("=== REJECT RELEASED PLAYER ===");
        System.out.println("Released Player ID: " + releasedPlayerId);
        
        // Check commissioner permissions
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        UserAccount user = userAccountRepository.findByUsername(username).orElse(null);
        
        if (user == null || !"COMMISSIONER".equals(user.getRole())) {
            redirectAttributes.addFlashAttribute("error", "Only commissioners can manage the release queue");
            return "redirect:/auction/manage";
        }

        try {
            ReleasedPlayer releasedPlayer = releasedPlayerRepository.findById(releasedPlayerId).orElse(null);
            if (releasedPlayer == null) {
                redirectAttributes.addFlashAttribute("error", "Released player not found");
                return "redirect:/auction/manage";
            }
            
            if (!"PENDING".equals(releasedPlayer.getStatus())) {
                redirectAttributes.addFlashAttribute("error", "Released player already processed (status: " + releasedPlayer.getStatus() + ")");
                return "redirect:/auction/manage";
            }
            
            System.out.println("Rejecting player: " + releasedPlayer.getPlayerName());
            
            // Mark as rejected
            releasedPlayer.setStatus("REJECTED");
            releasedPlayerRepository.save(releasedPlayer);
            
            redirectAttributes.addFlashAttribute("success", 
                "Player " + releasedPlayer.getPlayerName() + " rejected from auction queue");
            
            System.out.println("=== SUCCESS ===");
            
        } catch (Exception e) {
            System.err.println("=== ERROR ===");
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", "Error rejecting released player: " + e.getMessage());
        }
        
        return "redirect:/auction/manage";
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
            
            // Get auction to check type
            Auction auction = auctionRepository.findById(auctionItem.getAuctionId()).orElse(null);
            if (auction == null) {
                redirectAttributes.addFlashAttribute("error", "Auction not found");
                return "redirect:/auction/manage";
            }
            
            // Use service to award player (validates timing rules)
            if (auctionItem.getCurrentBidderId() != null) {
                AuctionService.ContractResult result = auctionService.awardPlayer(itemId);
                
                if (result.isSuccess()) {
                    redirectAttributes.addFlashAttribute("success", result.getMessage());
                } else {
                    redirectAttributes.addFlashAttribute("error", result.getMessage());
                }
            } else {
                // No bids, just remove
                auctionItem.setStatus("REMOVED");
                auctionItemRepository.save(auctionItem);
                redirectAttributes.addFlashAttribute("success", "Player removed from auction (no bids)");
            }
            
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Error removing player: " + e.getMessage());
            e.printStackTrace();
        }
        
        return "redirect:/auction/manage";
    }

    @PostMapping("/post-contract")
    public String postContract(@RequestParam Long pendingContractId,
                              @RequestParam Integer contractYears,
                              RedirectAttributes redirectAttributes) {
        
        // Get current user
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        UserAccount user = userAccountRepository.findByUsername(username).orElse(null);
        
        if (user == null) {
            return "redirect:/login";
        }

        try {
            // Use service to post contract with all validation
            AuctionService.ContractResult result = auctionService.postContract(pendingContractId, user.getId(), contractYears);
            
            if (result.isSuccess()) {
                redirectAttributes.addFlashAttribute("success", result.getMessage());
            } else {
                redirectAttributes.addFlashAttribute("error", result.getMessage());
            }
            
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Error posting contract: " + e.getMessage());
            e.printStackTrace();
        }
        
        return "redirect:/auction/view";
    }

    @PostMapping("/buyout-player")
    public String buyoutPlayer(@RequestParam Long pendingContractId,
                              RedirectAttributes redirectAttributes) {
        
        // Get current user
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        UserAccount user = userAccountRepository.findByUsername(username).orElse(null);
        
        if (user == null) {
            return "redirect:/login";
        }

        try {
            // Use service to process buyout
            AuctionService.ContractResult result = auctionService.buyoutPlayer(pendingContractId, user.getId());
            
            if (result.isSuccess()) {
                redirectAttributes.addFlashAttribute("success", result.getMessage());
            } else {
                redirectAttributes.addFlashAttribute("error", result.getMessage());
            }
            
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Error processing buyout: " + e.getMessage());
            e.printStackTrace();
        }
        
        return "redirect:/auction/view";
    }

    // Helper methods
    private void handleExpiredContracts() {
        auctionService.processExpiredContracts();
    }

    // Helper methods
    private Auction getOrCreateMainAuction(Long commissionerId) {
        List<Auction> activeAuctions = auctionRepository.findByStatus("ACTIVE");
        if (!activeAuctions.isEmpty()) {
            return activeAuctions.get(0);
        }
        
        // Create main auction - default to IN_SEASON
        Auction mainAuction = new Auction(
            "Main Player Auction", 
            LocalDateTime.now(), 
            LocalDateTime.now().plusYears(1), // Always running
            commissionerId,
            "In-Season Free Agency: Players require 24 hours after first bid. Dynamic minimum bid increments based on time elapsed."
        );
        mainAuction.setAuctionType("IN_SEASON");
        return auctionRepository.save(mainAuction);
    }
    
    private Auction getMainAuction() {
        List<Auction> activeAuctions = auctionRepository.findByStatus("ACTIVE");
        return activeAuctions.isEmpty() ? null : activeAuctions.get(0);
    }

    @PostMapping("/toggle-auction-type")
    public String toggleAuctionType(RedirectAttributes redirectAttributes) {
        // Check commissioner permissions
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        UserAccount user = userAccountRepository.findByUsername(username).orElse(null);
        
        if (user == null || !"COMMISSIONER".equals(user.getRole())) {
            redirectAttributes.addFlashAttribute("error", "Only commissioners can change auction type");
            return "redirect:/auction/manage";
        }

        try {
            Auction mainAuction = getOrCreateMainAuction(user.getId());
            
            // Toggle between IN_SEASON and OFF_SEASON
            if ("IN_SEASON".equals(mainAuction.getAuctionType())) {
                mainAuction.setAuctionType("OFF_SEASON");
                mainAuction.setDescription("Off-Season Free Agency: Players require 72 hours after first bid. Extended minimum bid increments.");
                redirectAttributes.addFlashAttribute("success", "Auction type changed to Off-Season Free Agency");
            } else {
                mainAuction.setAuctionType("IN_SEASON");
                mainAuction.setDescription("In-Season Free Agency: Players require 24 hours after first bid. Dynamic minimum bid increments based on time elapsed.");
                redirectAttributes.addFlashAttribute("success", "Auction type changed to In-Season Free Agency");
            }
            
            auctionRepository.save(mainAuction);
            
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Error changing auction type: " + e.getMessage());
            e.printStackTrace();
        }
        
        return "redirect:/auction/manage";
    }
}