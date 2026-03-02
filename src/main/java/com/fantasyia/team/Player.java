package com.fantasyia.team;

import jakarta.persistence.*;

@Entity
@Table(name = "players")
public class Player {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String position;

    @Column(name = "mlb_team", nullable = false)
    private String team;

    @Column
    private Integer contractLength;

    @Column
    private Double contractAmount;

    @Column
    private Double averageAnnualSalary;

    @Column(name = "owner_id")
    private Long ownerId;

    @Column
    private Boolean isMinorLeaguer;

    @Column
    private Boolean isRookie;

    @Column
    private Integer atBats;

    @Column
    private Integer inningsPitched;

    @Column
    private Boolean isOnFortyManRoster;

    @Column
    private Integer contractYear;

    public Player() {}

    public Player(String name, String position, String team, Integer contractLength, Double contractAmount, Long ownerId) {
        this.name = name;
        this.position = position;
        this.team = team;
        this.contractLength = contractLength;
        this.contractAmount = contractAmount;
        this.ownerId = ownerId;
        this.isMinorLeaguer = false;
        this.isRookie = false;
        this.isOnFortyManRoster = false;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position; }

    public String getTeam() { return team; }
    public void setTeam(String team) { this.team = team; }

    public Integer getContractLength() { return contractLength; }
    public void setContractLength(Integer contractLength) { this.contractLength = contractLength; }

    public Double getContractAmount() { return contractAmount; }
    public void setContractAmount(Double contractAmount) { this.contractAmount = contractAmount; }

    public Double getAverageAnnualSalary() { return averageAnnualSalary; }
    public void setAverageAnnualSalary(Double averageAnnualSalary) { this.averageAnnualSalary = averageAnnualSalary; }

    public Long getOwnerId() { return ownerId; }
    public void setOwnerId(Long ownerId) { this.ownerId = ownerId; }

    public Boolean getIsMinorLeaguer() { 
        return isMinorLeaguer != null ? isMinorLeaguer : false; 
    }
    public void setIsMinorLeaguer(Boolean isMinorLeaguer) { this.isMinorLeaguer = isMinorLeaguer; }

    public Boolean getIsRookie() { 
        return isRookie != null ? isRookie : false; 
    }
    public void setIsRookie(Boolean isRookie) { this.isRookie = isRookie; }

    public Integer getAtBats() { 
        return atBats != null ? atBats : 0; 
    }
    public void setAtBats(Integer atBats) { this.atBats = atBats; }

    public Integer getInningsPitched() { 
        return inningsPitched != null ? inningsPitched : 0; 
    }
    public void setInningsPitched(Integer inningsPitched) { this.inningsPitched = inningsPitched; }

    public Boolean getIsOnFortyManRoster() { 
        return isOnFortyManRoster != null ? isOnFortyManRoster : false; 
    }
    public void setIsOnFortyManRoster(Boolean isOnFortyManRoster) { this.isOnFortyManRoster = isOnFortyManRoster; }

    public Integer getContractYear() { 
        return contractYear != null ? contractYear : 0; 
    }
    public void setContractYear(Integer contractYear) { this.contractYear = contractYear; }

    // Helper methods
    public boolean hasEclipsedRookieStats() {
        return (atBats != null && atBats >= 130) || (inningsPitched != null && inningsPitched >= 50);
    }
}