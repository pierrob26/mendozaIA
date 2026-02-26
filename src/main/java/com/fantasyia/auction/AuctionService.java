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
     * Updated Rules:
     * - All players: $500K minimum increase
     */
    public double calculateMinimumBidIncrement(AuctionItem item, String auctionType) {
        if (item.getLastBidTime() == null) {
            return 0.0; // No increment for first bid
        }

        // All players now use $500K increment
        return 0.5;  // $500K for all players
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
    public BidValidationResult validateBid(Long auctionItemId, Long bidderId, Double bidAmount) {
        AuctionItem item = auctionItemRepository.findById(auctionItemId).orElse(null);
        if (item == null) {
            return new BidValidationResult(false, "Auction item not found");
        }

        if (!"ACTIVE".equals(item.getStatus())) {
            return new BidValidationResult(false, "This auction is no longer active");
        }

        Auction auction = auctionRepository.findById(item.getAuctionId()).orElse(null);
        if (auction == null) {
            return new BidValidationResult(false, "Auction not found");
        }

        UserAccount user = userAccountRepository.findById(bidderId).orElse(null);
        if (user == null) {
            return new BidValidationResult(false, "User not found");
        }

        if (!user.canAffordPlayer(bidAmount)) {
            return new BidValidationResult(false, 
                String.format("INVALID BID: This bid would exceed the $100M salary cap. Your available cap space is $%.1fM. " +
                             "Current salary: $%.1fM, Bid amount: $%.1fM", 
                    user.getAvailableCapSpace(), user.getCurrentSalaryUsed(), bidAmount));
        }

        if (!user.hasRosterSpace(item.getIsMinorLeaguer())) {
            String rosterType = item.getIsMinorLeaguer() ? "minor league (25 max)" : "major league (40 max)";
            return new BidValidationResult(false, 
                "You have reached the " + rosterType + " roster limit. You must make room before bidding.");
        }

        double minBid = getMinimumNextBid(item, auction.getAuctionType());
        if (bidAmount < minBid) {
            String playerType = item.getIsMinorLeaguer() ? "minor league" : "MLB";
            
            if (item.getCurrentBid() == null) {
                return new BidValidationResult(false, 
                    String.format("Minimum starting bid for %s players is $%.1fM", playerType, minBid));
            } else {
                return new BidValidationResult(false, 
                    String.format("Minimum bid is $%.1fM (current bid $%.1fM + $500K increment)", 
                        minBid, item.getCurrentBid()));
            }
        }

        return new BidValidationResult(true, "Bid is valid");
    }

    @Transactional
    public BidResult placeBid(Long auctionItemId, Long bidderId, Double bidAmount) {
        // Validate bid
        BidValidationResult validation = validateBid(auctionItemId, bidderId, bidAmount);
        if (!validation.isValid()) {
            return new BidResult(false, validation.getMessage(), null);
        }

        AuctionItem item = auctionItemRepository.findById(auctionItemId).orElse(null);
        Auction auction = auctionRepository.findById(item.getAuctionId()).orElse(null);
        Player player = playerRepository.findById(item.getPlayerId()).orElse(null);

        Bid bid = new Bid(auctionItemId, bidderId, bidAmount);
        bidRepository.save(bid);

        // Update auction item
        LocalDateTime now = LocalDateTime.now();
        
        if (item.getFirstBidTime() == null) {
            item.setFirstBidTime(now);
            // Rule 6: Once bid is placed, cannot delete
            item.setCanDeleteBid(false);
        }

        item.setLastBidTime(now);
        int requiredHours = "IN_SEASON".equals(auction.getAuctionType()) ? 24 : 72;
        item.setEndTime(now.plusHours(requiredHours));
        
        item.setCurrentBid(bidAmount);
        item.setCurrentBidderId(bidderId);
        
        item.setCurrentMinimumIncrement(calculateMinimumBidIncrement(item, auction.getAuctionType()));
        
        auctionItemRepository.save(item);

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

    public boolean isReadyToWin(AuctionItem item, String auctionType) {
        if (item.getLastBidTime() == null) {
            return false;
        }

        long hoursElapsed = Duration.between(item.getLastBidTime(), LocalDateTime.now()).toHours();
        int requiredHours = "IN_SEASON".equals(auctionType) ? 24 : 72;
        
        return hoursElapsed >= requiredHours;
    }

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

        PendingContract pendingContract = new PendingContract(
            item.getId(),
            player.getId(),
            item.getCurrentBidderId(),
            item.getCurrentBid(),
            item.getIsMinorLeaguer()
        );
        pendingContractRepository.save(pendingContract);

        item.setStatus("AWAITING_CONTRACT");
        item.setContractDeadline(LocalDateTime.now().plusHours(48));

        int complianceHours = "IN_SEASON".equals(auction.getAuctionType()) ? 24 : 48;
        item.setRosterComplianceDeadline(LocalDateTime.now().plusHours(complianceHours));
        
        auctionItemRepository.save(item);

        String message = String.format("Player %s awarded to %s for $%.1fM AAS. Contract must be posted within 48 hours or buyout fee of $%.1fM will apply.",
            player.getName(), winner.getUsername(), item.getCurrentBid(), item.getCurrentBid() / 2.0);
        return new ContractResult(true, message);
    }

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

    public ContractValidationResult validateContractLength(PendingContract contract, Integer years, Auction auction) {
        if (years < 1 || years > 5) {
            return new ContractValidationResult(false, "Contract must be between 1 and 5 years");
        }

        if (contract.getWinningBid() < 0.75 && years > 2) {
            return new ContractValidationResult(false, 
                "Players signed under $750K can only receive max 2-year contracts");
        }

        return new ContractValidationResult(true, "Contract length is valid");
    }

    @Transactional
    public ContractResult postContract(Long pendingContractId, Long userId, Integer contractYears) {
        PendingContract contract = pendingContractRepository.findById(pendingContractId).orElse(null);
        if (contract == null) {
            return new ContractResult(false, "Pending contract not found");
        }

        if (!userId.equals(contract.getWinnerId())) {
            return new ContractResult(false, "You are not the winner of this auction");
        }

        if (contract.isDeadlinePassed()) {
            applyBuyoutFee(contract);
            return new ContractResult(false, 
                "Contract deadline has passed. Buyout fee of $" + 
                String.format("%.1fM", contract.getBuyoutFee()) + " has been applied to your cap.");
        }

        AuctionItem item = auctionItemRepository.findById(contract.getAuctionItemId()).orElse(null);
        Auction auction = item != null ? auctionRepository.findById(item.getAuctionId()).orElse(null) : null;
        
        if (auction == null) {
            return new ContractResult(false, "Auction not found");
        }

        ContractValidationResult validation = validateContractLength(contract, contractYears, auction);
        if (!validation.isValid()) {
            return new ContractResult(false, validation.getMessage());
        }

        Player player = playerRepository.findById(contract.getPlayerId()).orElse(null);
        if (player == null) {
            return new ContractResult(false, "Player not found");
        }

        UserAccount user = userAccountRepository.findById(userId).orElse(null);
        if (user == null) {
            return new ContractResult(false, "User not found");
        }

        player.setOwnerId(user.getId());
        player.setContractLength(contractYears);
        player.setContractAmount(contract.getWinningBid() * contractYears);
        player.setAverageAnnualSalary(contract.getWinningBid());
        player.setContractYear(1);
        playerRepository.save(player);

        user.setCurrentSalaryUsed(user.getCurrentSalaryUsed() + contract.getWinningBid());
        if (contract.getIsMinorLeaguer()) {
            user.setMinorLeagueRosterCount(user.getMinorLeagueRosterCount() + 1);
        } else {
            user.setMajorLeagueRosterCount(user.getMajorLeagueRosterCount() + 1);
        }
        userAccountRepository.save(user);

        contract.setStatus("POSTED");
        contract.setContractYears(contractYears);
        pendingContractRepository.save(contract);

        if (item != null) {
            item.setStatus("SOLD");
            auctionItemRepository.save(item);
        }

        String rosterWarning = checkRosterLimits(user, contract.getIsMinorLeaguer(), auction.getAuctionType());

        String message = String.format("Contract posted for %s: %d years at $%.1fM AAS (Total: $%.1fM). %s",
            player.getName(), contractYears, contract.getWinningBid(), 
            contract.getWinningBid() * contractYears, rosterWarning);
        return new ContractResult(true, message);
    }

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

        Player player = playerRepository.findById(contract.getPlayerId()).orElse(null);
        if (player != null) {
            player.setOwnerId(null);
            playerRepository.save(player);
        }
    }

    @Transactional
    public ContractResult buyoutPlayer(Long pendingContractId, Long userId) {
        PendingContract contract = pendingContractRepository.findById(pendingContractId).orElse(null);
        if (contract == null) {
            return new ContractResult(false, "Pending contract not found");
        }

        if (!userId.equals(contract.getWinnerId())) {
            return new ContractResult(false, "You are not the winner of this auction");
        }

        UserAccount user = userAccountRepository.findById(userId).orElse(null);
        if (user == null) {
            return new ContractResult(false, "User not found");
        }

        double buyoutFee = contract.getBuyoutFee();
        user.setCurrentSalaryUsed(user.getCurrentSalaryUsed() + buyoutFee);
        userAccountRepository.save(user);

        contract.setStatus("BOUGHT_OUT");
        pendingContractRepository.save(contract);

        AuctionItem item = auctionItemRepository.findById(contract.getAuctionItemId()).orElse(null);
        if (item != null) {
            item.setStatus("BOUGHT_OUT");
            auctionItemRepository.save(item);
        }
        Player player = playerRepository.findById(contract.getPlayerId()).orElse(null);
        String playerName = player != null ? player.getName() : "Player";

        String message = String.format("%s bought out. Fee of $%.1fM applied to your cap. Player returned to free agency.",
            playerName, buyoutFee);
        return new ContractResult(true, message);
    }

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
