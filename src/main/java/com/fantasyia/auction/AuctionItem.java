package com.fantasyia.auction;

import jakarta.persistence.*;
import java.time.LocalDateTime;

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
    private Double startingBid = 1.0; // Minimum bid amount

    @Column
    private Double currentBid;

    @Column
    private Long currentBidderId; // User who placed the highest bid

    @Column(nullable = false)
    private LocalDateTime addedTime;

    @Column
    private LocalDateTime firstBidTime; // When the first bid was placed

    @Column(nullable = false)
    private String status = "ACTIVE"; // ACTIVE, SOLD, REMOVED

    @Column
    private LocalDateTime endTime; // 24 hours after first bid

    // Constructors
    public AuctionItem() {}

    public AuctionItem(Long playerId, Long auctionId, Double startingBid) {
        this.playerId = playerId;
        this.auctionId = auctionId;
        this.startingBid = startingBid;
        this.addedTime = LocalDateTime.now();
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

    public LocalDateTime getAddedTime() { return addedTime; }
    public void setAddedTime(LocalDateTime addedTime) { this.addedTime = addedTime; }

    public LocalDateTime getFirstBidTime() { return firstBidTime; }
    public void setFirstBidTime(LocalDateTime firstBidTime) { this.firstBidTime = firstBidTime; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getEndTime() { return endTime; }
    public void setEndTime(LocalDateTime endTime) { this.endTime = endTime; }

    // Helper methods
    public boolean hasMinimumTimeElapsed() {
        return firstBidTime != null && LocalDateTime.now().isAfter(firstBidTime.plusHours(24));
    }

    public boolean canBeRemoved() {
        return firstBidTime != null && hasMinimumTimeElapsed();
    }

    public long getTimeRemainingHours() {
        if (firstBidTime == null) return -1; // No bids yet
        LocalDateTime endTime = firstBidTime.plusHours(24);
        if (LocalDateTime.now().isAfter(endTime)) return 0;
        return java.time.Duration.between(LocalDateTime.now(), endTime).toHours();
    }
}