package com.fantasyia.team;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "released_players_queue")
public class ReleasedPlayer {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String playerName;

    @Column(nullable = false)
    private String position;

    @Column(nullable = false)
    private String mlbTeam;

    @Column
    private Integer previousContractLength;

    @Column
    private Double previousContractAmount;

    @Column
    private Long previousOwnerId;

    @Column(nullable = false)
    private LocalDateTime releasedAt;

    @Column(nullable = false)
    private String status; // "PENDING", "ADDED_TO_AUCTION", "REJECTED"

    // Constructors
    public ReleasedPlayer() {
        this.releasedAt = LocalDateTime.now();
        this.status = "PENDING";
    }

    public ReleasedPlayer(String playerName, String position, String mlbTeam, 
                         Integer previousContractLength, Double previousContractAmount, 
                         Long previousOwnerId) {
        this.playerName = playerName;
        this.position = position;
        this.mlbTeam = mlbTeam;
        this.previousContractLength = previousContractLength;
        this.previousContractAmount = previousContractAmount;
        this.previousOwnerId = previousOwnerId;
        this.releasedAt = LocalDateTime.now();
        this.status = "PENDING";
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getPlayerName() { return playerName; }
    public void setPlayerName(String playerName) { this.playerName = playerName; }

    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position; }

    public String getMlbTeam() { return mlbTeam; }
    public void setMlbTeam(String mlbTeam) { this.mlbTeam = mlbTeam; }

    public Integer getPreviousContractLength() { return previousContractLength; }
    public void setPreviousContractLength(Integer previousContractLength) { 
        this.previousContractLength = previousContractLength; 
    }

    public Double getPreviousContractAmount() { return previousContractAmount; }
    public void setPreviousContractAmount(Double previousContractAmount) { 
        this.previousContractAmount = previousContractAmount; 
    }

    public Long getPreviousOwnerId() { return previousOwnerId; }
    public void setPreviousOwnerId(Long previousOwnerId) { this.previousOwnerId = previousOwnerId; }

    public LocalDateTime getReleasedAt() { return releasedAt; }
    public void setReleasedAt(LocalDateTime releasedAt) { this.releasedAt = releasedAt; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
