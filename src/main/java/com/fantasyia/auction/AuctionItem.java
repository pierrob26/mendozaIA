package com.fantasyia.auction;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.time.Duration;

@Entity
@Table(name = "auction_items")
public class AuctionItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long playerId;

    @Column(nullable = false)
    private Long auctionId;

    @Column(nullable = false)
    private Double startingBid = 0.5; // $500K for MLB, $100K for prospects

    @Column
    private Double currentBid;

    @Column
    private Long currentBidderId; // User who placed the highest bid

    @Column
    private Long nominatedByUserId; // User who nominated player (cannot delete)

    @Column(nullable = false)
    private LocalDateTime addedTime;

    @Column
    private LocalDateTime firstBidTime; // When the first bid was placed

    @Column
    private LocalDateTime lastBidTime; // When the most recent bid was placed

    @Column(nullable = false)
    private String status = "ACTIVE"; // ACTIVE, SOLD, REMOVED, AWAITING_CONTRACT

    @Column
    private LocalDateTime endTime; // Time when bidding closes

    @Column
    private Boolean isMinorLeaguer; // Track if this is a minor league prospect

    @Column
    private LocalDateTime contractDeadline; // 48 hours after winning to post contract

    @Column
    private Boolean canDeleteBid; // Rule 6: Once bid/nominated, cannot delete

    @Column
    private LocalDateTime rosterComplianceDeadline; // 24 hours (in-season) or 48 hours (off-season) to fix roster

    @Column
    private Boolean isBuyoutDeadlinePassed; // Track if after buyout deadline (affects contract length)

    @Column
    private Double currentMinimumIncrement; // Track locked-in minimum increment (Rule 5)

    // Constructors
    public AuctionItem() {}

    public AuctionItem(Long playerId, Long auctionId, Double startingBid) {
        this.playerId = playerId;
        this.auctionId = auctionId;
        this.startingBid = startingBid;
        this.addedTime = LocalDateTime.now();
        this.canDeleteBid = true; // Can delete until first bid
        this.currentMinimumIncrement = 0.0;
    }

    public AuctionItem(Long playerId, Long auctionId, Double startingBid, Boolean isMinorLeaguer, Long nominatedByUserId) {
        this.playerId = playerId;
        this.auctionId = auctionId;
        this.startingBid = startingBid;
        this.addedTime = LocalDateTime.now();
        this.isMinorLeaguer = isMinorLeaguer;
        this.nominatedByUserId = nominatedByUserId;
        this.canDeleteBid = false; // Nomination = cannot delete (Rule 6)
        this.currentMinimumIncrement = 0.0;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getPlayerId() { return playerId; }
    public void setPlayerId(Long playerId) { this.playerId = playerId; }

    public Long getAuctionId() { return auctionId; }
    public void setAuctionId(Long auctionId) { this.auctionId = auctionId; }

    public Double getStartingBid() { return startingBid; }
    public void setStartingBid(Double startingBid) { this.startingBid = startingBid; }

    public Double getCurrentBid() { return currentBid; }
    public void setCurrentBid(Double currentBid) { this.currentBid = currentBid; }

    public Long getCurrentBidderId() { return currentBidderId; }
    public void setCurrentBidderId(Long currentBidderId) { this.currentBidderId = currentBidderId; }

    public Long getNominatedByUserId() { return nominatedByUserId; }
    public void setNominatedByUserId(Long nominatedByUserId) { this.nominatedByUserId = nominatedByUserId; }

    public LocalDateTime getAddedTime() { return addedTime; }
    public void setAddedTime(LocalDateTime addedTime) { this.addedTime = addedTime; }

    public LocalDateTime getFirstBidTime() { return firstBidTime; }
    public void setFirstBidTime(LocalDateTime firstBidTime) { this.firstBidTime = firstBidTime; }

    public LocalDateTime getLastBidTime() { return lastBidTime; }
    public void setLastBidTime(LocalDateTime lastBidTime) { this.lastBidTime = lastBidTime; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getEndTime() { return endTime; }
    public void setEndTime(LocalDateTime endTime) { this.endTime = endTime; }

    public Boolean getIsMinorLeaguer() { 
        return isMinorLeaguer != null ? isMinorLeaguer : false; 
    }
    public void setIsMinorLeaguer(Boolean isMinorLeaguer) { this.isMinorLeaguer = isMinorLeaguer; }

    public LocalDateTime getContractDeadline() { return contractDeadline; }
    public void setContractDeadline(LocalDateTime contractDeadline) { this.contractDeadline = contractDeadline; }

    public Boolean getCanDeleteBid() { 
        return canDeleteBid != null ? canDeleteBid : false; 
    }
    public void setCanDeleteBid(Boolean canDeleteBid) { this.canDeleteBid = canDeleteBid; }

    public LocalDateTime getRosterComplianceDeadline() { return rosterComplianceDeadline; }
    public void setRosterComplianceDeadline(LocalDateTime rosterComplianceDeadline) { 
        this.rosterComplianceDeadline = rosterComplianceDeadline; 
    }

    public Boolean getIsBuyoutDeadlinePassed() { 
        return isBuyoutDeadlinePassed != null ? isBuyoutDeadlinePassed : false; 
    }
    public void setIsBuyoutDeadlinePassed(Boolean isBuyoutDeadlinePassed) { 
        this.isBuyoutDeadlinePassed = isBuyoutDeadlinePassed; 
    }

    public Double getCurrentMinimumIncrement() { 
        return currentMinimumIncrement != null ? currentMinimumIncrement : 0.0; 
    }
    public void setCurrentMinimumIncrement(Double currentMinimumIncrement) { 
        this.currentMinimumIncrement = currentMinimumIncrement; 
    }

    // Helper methods to calculate minimum bid increment - $500K for all players
    public Double getMinimumBidIncrement(String auctionType) {
        if (lastBidTime == null) {
            return 0.0; // No increment needed if no bids yet
        }

        // All players now use $500K increment
        return 0.5; // $500K for all players
    }

    public void updateMinimumIncrement(String auctionType) {
        // With fixed $500K increments, set consistent increment
        double newIncrement = getMinimumBidIncrement(auctionType);
        this.currentMinimumIncrement = newIncrement;
    }

    public Double getMinimumNextBid(String auctionType) {
        if (currentBid == null) {
            // Set starting bid based on player type
            if (getIsMinorLeaguer()) {
                return 0.1; // $100K for minor leaguers
            } else {
                return 0.5; // $500K for MLB players
            }
        }
        return currentBid + getMinimumBidIncrement(auctionType);
    }

    public boolean hasMinimumTimeElapsed(String auctionType) {
        if (firstBidTime == null) return false;
        
        long hoursElapsed = Duration.between(firstBidTime, LocalDateTime.now()).toHours();
        
        if ("IN_SEASON".equals(auctionType)) {
            return hoursElapsed >= 24; // 24 hours for in-season
        } else {
            return hoursElapsed >= 72; // 72 hours for off-season
        }
    }

    public boolean canBeRemoved(String auctionType) {
        return firstBidTime != null && hasMinimumTimeElapsed(auctionType);
    }

    public long getTimeRemainingHours(String auctionType) {
        if (firstBidTime == null) return -1; // No bids yet
        
        int requiredHours = "IN_SEASON".equals(auctionType) ? 24 : 72;
        LocalDateTime calculatedEndTime = firstBidTime.plusHours(requiredHours);
        
        if (LocalDateTime.now().isAfter(calculatedEndTime)) return 0;
        return Duration.between(LocalDateTime.now(), calculatedEndTime).toHours();
    }

    public boolean isContractDeadlinePassed() {
        return contractDeadline != null && LocalDateTime.now().isAfter(contractDeadline);
    }
}