package com.fantasyia.auction;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "pending_contracts")
public class PendingContract {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long auctionItemId;

    @Column(nullable = false)
    private Long playerId;

    @Column(nullable = false)
    private Long winnerId;

    @Column(nullable = false)
    private Double winningBid;

    @Column(nullable = false)
    private LocalDateTime wonTime;

    @Column(nullable = false)
    private LocalDateTime contractDeadline; // 48 hours after won

    @Column
    private Integer contractYears; // 1-5 years

    @Column
    private String status = "PENDING"; // PENDING, POSTED, EXPIRED

    @Column
    private Double buyoutFee; // Half of winning bid if contract not posted

    @Column
    private Boolean isMinorLeaguer;

    // Constructors
    public PendingContract() {}

    public PendingContract(Long auctionItemId, Long playerId, Long winnerId, Double winningBid, Boolean isMinorLeaguer) {
        this.auctionItemId = auctionItemId;
        this.playerId = playerId;
        this.winnerId = winnerId;
        this.winningBid = winningBid;
        this.wonTime = LocalDateTime.now();
        this.contractDeadline = LocalDateTime.now().plusHours(48);
        this.buyoutFee = winningBid / 2.0;
        this.isMinorLeaguer = isMinorLeaguer;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getAuctionItemId() { return auctionItemId; }
    public void setAuctionItemId(Long auctionItemId) { this.auctionItemId = auctionItemId; }

    public Long getPlayerId() { return playerId; }
    public void setPlayerId(Long playerId) { this.playerId = playerId; }

    public Long getWinnerId() { return winnerId; }
    public void setWinnerId(Long winnerId) { this.winnerId = winnerId; }

    public Double getWinningBid() { return winningBid; }
    public void setWinningBid(Double winningBid) { this.winningBid = winningBid; }

    public LocalDateTime getWonTime() { return wonTime; }
    public void setWonTime(LocalDateTime wonTime) { this.wonTime = wonTime; }

    public LocalDateTime getContractDeadline() { return contractDeadline; }
    public void setContractDeadline(LocalDateTime contractDeadline) { this.contractDeadline = contractDeadline; }

    public Integer getContractYears() { return contractYears; }
    public void setContractYears(Integer contractYears) { this.contractYears = contractYears; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Double getBuyoutFee() { return buyoutFee; }
    public void setBuyoutFee(Double buyoutFee) { this.buyoutFee = buyoutFee; }

    public Boolean getIsMinorLeaguer() { 
        return isMinorLeaguer != null ? isMinorLeaguer : false; 
    }
    public void setIsMinorLeaguer(Boolean isMinorLeaguer) { this.isMinorLeaguer = isMinorLeaguer; }

    // Helper methods
    public boolean isDeadlinePassed() {
        return LocalDateTime.now().isAfter(contractDeadline);
    }

    public boolean isValidContractLength() {
        if (contractYears == null) return false;
        
        // Players under $750K can only get max 2 years
        if (winningBid < 0.75 && contractYears > 2) {
            return false;
        }
        
        // All contracts: 1-5 years
        return contractYears >= 1 && contractYears <= 5;
    }
}
