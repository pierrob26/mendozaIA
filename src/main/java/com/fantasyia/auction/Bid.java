package com.fantasyia.auction;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "bids")
public class Bid {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long auctionItemId;

    @Column(nullable = false)
    private Long bidderId; // User who placed the bid

    @Column(nullable = false)
    private Double amount;

    @Column(nullable = false)
    private LocalDateTime bidTime;

    @Column(nullable = false)
    private String status = "ACTIVE"; // ACTIVE, OUTBID, WINNING

    // Constructors
    public Bid() {}

    public Bid(Long auctionItemId, Long bidderId, Double amount) {
        this.auctionItemId = auctionItemId;
        this.bidderId = bidderId;
        this.amount = amount;
        this.bidTime = LocalDateTime.now();
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getAuctionItemId() { return auctionItemId; }
    public void setAuctionItemId(Long auctionItemId) { this.auctionItemId = auctionItemId; }

    public Long getBidderId() { return bidderId; }
    public void setBidderId(Long bidderId) { this.bidderId = bidderId; }

    public Double getAmount() { return amount; }
    public void setAmount(Double amount) { this.amount = amount; }

    public LocalDateTime getBidTime() { return bidTime; }
    public void setBidTime(LocalDateTime bidTime) { this.bidTime = bidTime; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}