package com.fantasyia.auction;

import com.fantasyia.team.Player;
import com.fantasyia.team.PlayerRepository;
import com.fantasyia.user.UserAccount;
import com.fantasyia.user.UserAccountRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.Duration;
import java.util.List;

/**
 * Service to handle Free Agency Auction business logic according to league rules.
 * Supports both In-Season and Off-Season Free Agency with dynamic bid increments.
 */
@Service
public class AuctionService {

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
    private PendingContractRepository pendingContractRepository;

    /**
     * Calculate the current minimum bid increment.
     * 
     * Simple Rules:
     * - MLB players: $1M minimum increase
     * - Minor league players: $100K minimum increase
     */
    public double calculateMinimumBidIncrement(AuctionItem item, String auctionType) {
        if (item.getLastBidTime() == null) {
            return 0.0; // No increment for first bid
        }

        boolean isMinorLeaguer = item.getIsMinorLeaguer();
        
        if (isMinorLeaguer) {
            return 0.1;  // $100K for minor leaguers
        } else {
            return 1.0;  // $1M for MLB players
        }
    }

    /**
     * Get the minimum next bid for an auction item.
     * MLB players start at $500K minimum, minor leaguers at $100K
     */
    public double getMinimumNextBid(AuctionItem item, String auctionType) {
        if (item.getCurrentBid() == null) {
            // Set minimum starting bid based on player type
            if (item.getIsMinorLeaguer()) {
                return 0.1; // $100K for minor leaguers
            } else {
                return 0.5; // $500K for MLB players
            }
        }
        return item.getCurrentBid() + calculateMinimumBidIncrement(item, auctionType);
    }

    /**
     * Validate if a bid meets all requirements.
     * Rule xi: Bids cannot be made that put team over $100M salary cap
     * Rule xi(1): Such bids will be disregarded
     */
    public BidValidationResult validateBid(Long auctionItemId, Long bidderId, Double bidAmount) {
        // Get auction item
        AuctionItem item = auctionItemRepository.findById(auctionItemId).orElse(null);
        if (item == null) {
            return new BidValidationResult(false, "Auction item not found");
        }

        if (!"ACTIVE".equals(item.getStatus())) {
            return new BidValidationResult(false, "This auction is no longer active");
        }

        // Get auction
        Auction auction = auctionRepository.findById(item.getAuctionId()).orElse(null);
        if (auction == null) {
            return new BidValidationResult(false, "Auction not found");
        }

        // Get user
        UserAccount user = userAccountRepository.findById(bidderId).orElse(null);
        if (user == null) {
            return new BidValidationResult(false, "User not found");
        }

        // Rule xi: Check if bid would put user over salary cap ($100M)
        // This bid will count against cap space, so check available space
        if (!user.canAffordPlayer(bidAmount)) {
            return new BidValidationResult(false, 
                String.format("INVALID BID: This bid would exceed the $100M salary cap. Your available cap space is $%.1fM. " +
                             "Current salary: $%.1fM, Bid amount: $%.1fM", 
                    user.getAvailableCapSpace(), user.getCurrentSalaryUsed(), bidAmount));
        }

        // Check roster space (Rule 8(f)(i) and Rule x)
        if (!user.hasRosterSpace(item.getIsMinorLeaguer())) {
            String rosterType = item.getIsMinorLeaguer() ? "minor league (25 max)" : "major league (40 max)";
            return new BidValidationResult(false, 
                "You have reached the " + rosterType + " roster limit. You must make room before bidding.");
        }

        // Check minimum bid (Simple increment: $1M for MLB, $100K for minors)
        double minBid = getMinimumNextBid(item, auction.getAuctionType());
        if (bidAmount < minBid) {
            String playerType = item.getIsMinorLeaguer() ? "minor league" : "MLB";
            String increment = item.getIsMinorLeaguer() ? "$100K" : "$1M";
            
            if (item.getCurrentBid() == null) {
                return new BidValidationResult(false, 
                    String.format("Minimum starting bid for %s players is $%.1fM", playerType, minBid));
            } else {
                return new BidValidationResult(false, 
                    String.format("Minimum bid is $%.1fM (current bid $%.1fM + %s increment)", 
                        minBid, item.getCurrentBid(), increment));
            }
        }

        return new BidValidationResult(true, "Bid is valid");
    }

    /**
     * Place a bid on an auction item.
     * Rule 6: Cannot delete bid once placed
     * Each bid resets the timer - auction must stand for full period after LAST bid
     */
    @Transactional
    public BidResult placeBid(Long auctionItemId, Long bidderId, Double bidAmount) {
        // Validate bid
        BidValidationResult validation = validateBid(auctionItemId, bidderId, bidAmount);
        if (!validation.isValid()) {
            return new BidResult(false, validation.getMessage(), null);
        }

        // Get entities
        AuctionItem item = auctionItemRepository.findById(auctionItemId).orElse(null);
        Auction auction = auctionRepository.findById(item.getAuctionId()).orElse(null);
        Player player = playerRepository.findById(item.getPlayerId()).orElse(null);

        // Create bid
        Bid bid = new Bid(auctionItemId, bidderId, bidAmount);
        bidRepository.save(bid);

        // Update auction item
        LocalDateTime now = LocalDateTime.now();
        
        if (item.getFirstBidTime() == null) {
            item.setFirstBidTime(now);
            // Rule 6: Once bid is placed, cannot delete
            item.setCanDeleteBid(false);
        }
        
        // CRITICAL: Each new bid resets the timer
        // Rule 7 (In-Season): Must stand 24 hours after LAST bid
        // Rule vii (Off-Season): Must stand 72 hours after LAST bid
        item.setLastBidTime(now);
        int requiredHours = "IN_SEASON".equals(auction.getAuctionType()) ? 24 : 72;
        item.setEndTime(now.plusHours(requiredHours));
        
        item.setCurrentBid(bidAmount);
        item.setCurrentBidderId(bidderId);
        
        // Set the fixed minimum increment (no need to track changes)
        item.setCurrentMinimumIncrement(calculateMinimumBidIncrement(item, auction.getAuctionType()));
        
        auctionItemRepository.save(item);

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

        String message = String.format("Bid placed successfully for %s - $%.1fM. Auction ends at %s if no new bids.", 
            player.getName(), bidAmount, item.getEndTime().toString());
        return new BidResult(true, message, bid);
    }

    /**
     * Check if an auction item is ready to be won (minimum time elapsed since LAST bid).
     * Rule 7: In-Season = 24 hours after LAST bid
     * Rule vii: Off-Season = 72 hours after LAST bid
     */
    public boolean isReadyToWin(AuctionItem item, String auctionType) {
        if (item.getLastBidTime() == null) {
            return false; // No bids yet
        }

        long hoursElapsed = Duration.between(item.getLastBidTime(), LocalDateTime.now()).toHours();
        int requiredHours = "IN_SEASON".equals(auctionType) ? 24 : 72;
        
        return hoursElapsed >= requiredHours;
    }

    /**
     * Award player to winning bidder and create pending contract.
     * Rule 7: Winner has 48 hours to post contract
     * Rule 8(f)(i): If roster over limit, winner has 24h (in-season) or 48h (off-season) to comply
     */
    @Transactional
    public ContractResult awardPlayer(Long auctionItemId) {
        AuctionItem item = auctionItemRepository.findById(auctionItemId).orElse(null);
        if (item == null) {
            return new ContractResult(false, "Auction item not found");
        }

        Auction auction = auctionRepository.findById(item.getAuctionId()).orElse(null);
        if (auction == null) {
            return new ContractResult(false, "Auction not found");
        }

        // Check if ready to win (Rule 7: 24h in-season, Rule vii: 72h off-season)
        if (!isReadyToWin(item, auction.getAuctionType())) {
            long hoursRemaining = calculateHoursRemaining(item, auction.getAuctionType());
            return new ContractResult(false, 
                String.format("Player cannot be awarded yet. %d hours remaining since last bid.", hoursRemaining));
        }

        if (item.getCurrentBidderId() == null) {
            return new ContractResult(false, "No bids placed on this item");
        }

        Player player = playerRepository.findById(item.getPlayerId()).orElse(null);
        if (player == null) {
            return new ContractResult(false, "Player not found");
        }

        UserAccount winner = userAccountRepository.findById(item.getCurrentBidderId()).orElse(null);
        if (winner == null) {
            return new ContractResult(false, "Winner not found");
        }

        // Create pending contract (Rule 7: 48 hours to post)
        PendingContract pendingContract = new PendingContract(
            item.getId(),
            player.getId(),
            item.getCurrentBidderId(),
            item.getCurrentBid(),
            item.getIsMinorLeaguer()
        );
        pendingContractRepository.save(pendingContract);

        // Update auction item status
        item.setStatus("AWAITING_CONTRACT");
        item.setContractDeadline(LocalDateTime.now().plusHours(48)); // Rule 7: 48 hours to post contract
        
        // Set roster compliance deadline (Rule 8(f)(i) and Rule x)
        // In-season: 24 hours to fix roster
        // Off-season: 48 hours to fix roster
        int complianceHours = "IN_SEASON".equals(auction.getAuctionType()) ? 24 : 48;
        item.setRosterComplianceDeadline(LocalDateTime.now().plusHours(complianceHours));
        
        auctionItemRepository.save(item);

        String message = String.format("Player %s awarded to %s for $%.1fM AAS. Contract must be posted within 48 hours or buyout fee of $%.1fM will apply.",
            player.getName(), winner.getUsername(), item.getCurrentBid(), item.getCurrentBid() / 2.0);
        return new ContractResult(true, message);
    }

    /**
     * Calculate hours remaining until auction can be won.
     */
    public long calculateHoursRemaining(AuctionItem item, String auctionType) {
        if (item.getLastBidTime() == null) {
            return -1;
        }

        int requiredHours = "IN_SEASON".equals(auctionType) ? 24 : 72;
        LocalDateTime calculatedEndTime = item.getLastBidTime().plusHours(requiredHours);
        
        if (LocalDateTime.now().isAfter(calculatedEndTime)) {
            return 0;
        }
        
        return Duration.between(LocalDateTime.now(), calculatedEndTime).toHours();
    }

    /**
     * Validate contract length based on rules.
     */
    public ContractValidationResult validateContractLength(PendingContract contract, Integer years, Auction auction) {
        // Rule 8: 1-5 years
        if (years < 1 || years > 5) {
            return new ContractValidationResult(false, "Contract must be between 1 and 5 years");
        }

        // Rule 8(a): Players under $750K can only get 2 years max
        if (contract.getWinningBid() < 0.75 && years > 2) {
            return new ContractValidationResult(false, 
                "Players signed under $750K can only receive max 2-year contracts");
        }

        // Rule 8(f): Players after buyout deadline can only get 1 year
        // TODO: Implement buyout deadline tracking
        
        return new ContractValidationResult(true, "Contract length is valid");
    }

    /**
     * Post a contract for a won player.
     * Rule 8: 1-5 years, with restrictions
     * Rule 8(a): Players under $750K can only get 2-year max contracts
     */
    @Transactional
    public ContractResult postContract(Long pendingContractId, Long userId, Integer contractYears) {
        PendingContract contract = pendingContractRepository.findById(pendingContractId).orElse(null);
        if (contract == null) {
            return new ContractResult(false, "Pending contract not found");
        }

        // Check if user is the winner
        if (!userId.equals(contract.getWinnerId())) {
            return new ContractResult(false, "You are not the winner of this auction");
        }

        // Check if deadline passed (Rule 7(a): buyout fee = half of winning bid)
        if (contract.isDeadlinePassed()) {
            // Apply buyout fee automatically
            applyBuyoutFee(contract);
            return new ContractResult(false, 
                "Contract deadline has passed. Buyout fee of $" + 
                String.format("%.1fM", contract.getBuyoutFee()) + " has been applied to your cap.");
        }

        // Get auction to check type
        AuctionItem item = auctionItemRepository.findById(contract.getAuctionItemId()).orElse(null);
        Auction auction = item != null ? auctionRepository.findById(item.getAuctionId()).orElse(null) : null;
        
        if (auction == null) {
            return new ContractResult(false, "Auction not found");
        }

        // Validate contract length
        ContractValidationResult validation = validateContractLength(contract, contractYears, auction);
        if (!validation.isValid()) {
            return new ContractResult(false, validation.getMessage());
        }

        // Get player
        Player player = playerRepository.findById(contract.getPlayerId()).orElse(null);
        if (player == null) {
            return new ContractResult(false, "Player not found");
        }

        // Get user
        UserAccount user = userAccountRepository.findById(userId).orElse(null);
        if (user == null) {
            return new ContractResult(false, "User not found");
        }

        // Assign player to winner
        player.setOwnerId(user.getId());
        player.setContractLength(contractYears);
        player.setContractAmount(contract.getWinningBid() * contractYears); // Total contract value
        player.setAverageAnnualSalary(contract.getWinningBid()); // AAS for cap purposes
        player.setContractYear(1);
        playerRepository.save(player);

        // Update user salary and roster counts
        user.setCurrentSalaryUsed(user.getCurrentSalaryUsed() + contract.getWinningBid());
        if (contract.getIsMinorLeaguer()) {
            user.setMinorLeagueRosterCount(user.getMinorLeagueRosterCount() + 1);
        } else {
            user.setMajorLeagueRosterCount(user.getMajorLeagueRosterCount() + 1);
        }
        userAccountRepository.save(user);

        // Update pending contract
        contract.setStatus("POSTED");
        contract.setContractYears(contractYears);
        pendingContractRepository.save(contract);

        // Update auction item
        if (item != null) {
            item.setStatus("SOLD");
            auctionItemRepository.save(item);
        }

        // Check for roster violations after contract (Rule 8(f)(i) and Rule x)
        String rosterWarning = checkRosterLimits(user, contract.getIsMinorLeaguer(), auction.getAuctionType());

        String message = String.format("Contract posted for %s: %d years at $%.1fM AAS (Total: $%.1fM). %s",
            player.getName(), contractYears, contract.getWinningBid(), 
            contract.getWinningBid() * contractYears, rosterWarning);
        return new ContractResult(true, message);
    }

    /**
     * Apply buyout fee when contract not posted in time (Rule 7(a) and vii(1)).
     */
    @Transactional
    public void applyBuyoutFee(PendingContract contract) {
        UserAccount winner = userAccountRepository.findById(contract.getWinnerId()).orElse(null);
        if (winner != null) {
            winner.setCurrentSalaryUsed(winner.getCurrentSalaryUsed() + contract.getBuyoutFee());
            userAccountRepository.save(winner);
        }

        contract.setStatus("EXPIRED");
        pendingContractRepository.save(contract);

        AuctionItem item = auctionItemRepository.findById(contract.getAuctionItemId()).orElse(null);
        if (item != null) {
            item.setStatus("CONTRACT_EXPIRED");
            auctionItemRepository.save(item);
        }

        // Player goes back to free agency
        Player player = playerRepository.findById(contract.getPlayerId()).orElse(null);
        if (player != null) {
            player.setOwnerId(null);
            playerRepository.save(player);
        }
    }

    /**
     * Process buyout of won player (Rule 6 and vi).
     */
    @Transactional
    public ContractResult buyoutPlayer(Long pendingContractId, Long userId) {
        PendingContract contract = pendingContractRepository.findById(pendingContractId).orElse(null);
        if (contract == null) {
            return new ContractResult(false, "Pending contract not found");
        }

        if (!userId.equals(contract.getWinnerId())) {
            return new ContractResult(false, "You are not the winner of this auction");
        }

        // Apply buyout fee (half of winning bid)
        UserAccount user = userAccountRepository.findById(userId).orElse(null);
        if (user == null) {
            return new ContractResult(false, "User not found");
        }

        double buyoutFee = contract.getBuyoutFee();
        user.setCurrentSalaryUsed(user.getCurrentSalaryUsed() + buyoutFee);
        userAccountRepository.save(user);

        // Update contract status
        contract.setStatus("BOUGHT_OUT");
        pendingContractRepository.save(contract);

        // Update auction item
        AuctionItem item = auctionItemRepository.findById(contract.getAuctionItemId()).orElse(null);
        if (item != null) {
            item.setStatus("BOUGHT_OUT");
            auctionItemRepository.save(item);
        }

        // Player returns to free agency
        Player player = playerRepository.findById(contract.getPlayerId()).orElse(null);
        String playerName = player != null ? player.getName() : "Player";

        String message = String.format("%s bought out. Fee of $%.1fM applied to your cap. Player returned to free agency.",
            playerName, buyoutFee);
        return new ContractResult(true, message);
    }

    /**
     * Check if user has exceeded roster limits.
     * Rule 8(f)(i): In-Season = 24 hours to fix roster
     * Rule x: Off-Season = 48 hours to fix roster
     */
    private String checkRosterLimits(UserAccount user, boolean isMinorLeaguer, String auctionType) {
        int complianceHours = "IN_SEASON".equals(auctionType) ? 24 : 48;
        
        if (isMinorLeaguer && user.getMinorLeagueRosterCount() > 25) {
            return String.format("WARNING: You now have %d minor league players (max 25). You have %d hours to make roster legal or automatic buyout will occur.",
                   user.getMinorLeagueRosterCount(), complianceHours);
        } else if (!isMinorLeaguer && user.getMajorLeagueRosterCount() > 40) {
            return String.format("WARNING: You now have %d major league players (max 40). You have %d hours to make roster legal or automatic buyout will occur.",
                   user.getMajorLeagueRosterCount(), complianceHours);
        }
        return "";
    }

    /**
     * Process expired contracts and apply penalties.
     */
    @Transactional
    public void processExpiredContracts() {
        List<PendingContract> expiredContracts = pendingContractRepository.findExpiredContracts(LocalDateTime.now());
        
        for (PendingContract contract : expiredContracts) {
            if ("PENDING".equals(contract.getStatus())) {
                applyBuyoutFee(contract);
                System.out.println("Contract expired for auction item " + contract.getAuctionItemId() + 
                    ". Buyout fee of $" + String.format("%.1fM", contract.getBuyoutFee()) + " applied.");
            }
        }
    }

    /**
     * Auto-award players whose auction time has elapsed.
     */
    @Transactional
    public void autoAwardExpiredAuctions() {
        List<Auction> activeAuctions = auctionRepository.findByStatus("ACTIVE");
        
        for (Auction auction : activeAuctions) {
            List<AuctionItem> items = auctionItemRepository.findByAuctionIdAndStatus(auction.getId(), "ACTIVE");
            
            for (AuctionItem item : items) {
                if (isReadyToWin(item, auction.getAuctionType()) && item.getCurrentBidderId() != null) {
                    awardPlayer(item.getId());
                }
            }
        }
    }

    // Result classes
    public static class BidValidationResult {
        private final boolean valid;
        private final String message;

        public BidValidationResult(boolean valid, String message) {
            this.valid = valid;
            this.message = message;
        }

        public boolean isValid() { return valid; }
        public String getMessage() { return message; }
    }

    public static class BidResult {
        private final boolean success;
        private final String message;
        private final Bid bid;

        public BidResult(boolean success, String message, Bid bid) {
            this.success = success;
            this.message = message;
            this.bid = bid;
        }

        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
        public Bid getBid() { return bid; }
    }

    public static class ContractResult {
        private final boolean success;
        private final String message;

        public ContractResult(boolean success, String message) {
            this.success = success;
            this.message = message;
        }

        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
    }

    public static class ContractValidationResult {
        private final boolean valid;
        private final String message;

        public ContractValidationResult(boolean valid, String message) {
            this.valid = valid;
            this.message = message;
        }

        public boolean isValid() { return valid; }
        public String getMessage() { return message; }
    }
}
