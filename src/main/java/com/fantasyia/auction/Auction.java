package com.fantasyia.auction;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "auctions")
public class Auction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private LocalDateTime startTime;

    @Column(nullable = false)
    private LocalDateTime endTime;

    @Column(nullable = false)
    private Long createdByCommissionerId;

    @Column(nullable = false)
    private String status = "ACTIVE"; // ACTIVE, COMPLETED, CANCELLED

    @Column
    private String description;

    // Constructors
    public Auction() {}

    public Auction(String name, LocalDateTime startTime, LocalDateTime endTime, Long createdByCommissionerId, String description) {
        this.name = name;
        this.startTime = startTime;
        this.endTime = endTime;
        this.createdByCommissionerId = createdByCommissionerId;
        this.description = description;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public LocalDateTime getStartTime() { return startTime; }
    public void setStartTime(LocalDateTime startTime) { this.startTime = startTime; }

    public LocalDateTime getEndTime() { return endTime; }
    public void setEndTime(LocalDateTime endTime) { this.endTime = endTime; }

    public Long getCreatedByCommissionerId() { return createdByCommissionerId; }
    public void setCreatedByCommissionerId(Long createdByCommissionerId) { this.createdByCommissionerId = createdByCommissionerId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}