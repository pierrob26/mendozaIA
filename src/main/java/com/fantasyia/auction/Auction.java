package com.fantasyia.auction;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "auctions")
public class Auction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "auction_name", nullable = false)
    private String name;

    @Column(name = "auction_type")
    private String auctionType = "IN_SEASON";

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "created_by")
    private Long createdBy;

    @Column(name = "is_active")
    private Boolean isActive = true;

    @Column
    private LocalDateTime startTime;

    @Column
    private LocalDateTime endTime;

    @Column(name = "auction_status")
    private String status = "ACTIVE";

    @Column
    private String description;

    public Auction() {
        this.createdAt = LocalDateTime.now();
        this.isActive = true;
    }

    public Auction(String name, LocalDateTime startTime, LocalDateTime endTime, Long createdBy, String description) {
        this.name = name;
        this.startTime = startTime;
        this.endTime = endTime;
        this.createdBy = createdBy;
        this.description = description;
        this.createdAt = LocalDateTime.now();
        this.isActive = true;
        this.status = "ACTIVE";
        this.auctionType = "IN_SEASON";
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getAuctionType() { return auctionType; }
    public void setAuctionType(String auctionType) { this.auctionType = auctionType; }

    public String getType() { return auctionType; }
    public void setType(String type) { this.auctionType = type; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public Long getCreatedBy() { return createdBy; }
    public void setCreatedBy(Long createdBy) { this.createdBy = createdBy; }

    public Long getCreatedByCommissionerId() { return createdBy; }
    public void setCreatedByCommissionerId(Long createdBy) { this.createdBy = createdBy; }

    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean isActive) { this.isActive = isActive; }

    public LocalDateTime getStartTime() { return startTime; }
    public void setStartTime(LocalDateTime startTime) { this.startTime = startTime; }

    public LocalDateTime getEndTime() { return endTime; }
    public void setEndTime(LocalDateTime endTime) { this.endTime = endTime; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}