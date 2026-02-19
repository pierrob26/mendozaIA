package com.fantasyia.user;

import jakarta.persistence.*;

@Entity
@Table(name = "users", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"username"})
})
public class UserAccount {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String username;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    private String role; // Role to be selected during registration

    @Column
    private Double salaryCap; // $100M salary cap

    @Column
    private Double currentSalaryUsed; // Current salary committed

    @Column
    private Integer majorLeagueRosterCount; // Count of players on 40-man roster (max 40)

    @Column
    private Integer minorLeagueRosterCount; // Count of minor league players (max 25)

    // Basic getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public Double getSalaryCap() { 
        return salaryCap != null ? salaryCap : 100.0; 
    }
    public void setSalaryCap(Double salaryCap) { this.salaryCap = salaryCap; }

    public Double getCurrentSalaryUsed() { 
        return currentSalaryUsed != null ? currentSalaryUsed : 0.0; 
    }
    public void setCurrentSalaryUsed(Double currentSalaryUsed) { this.currentSalaryUsed = currentSalaryUsed; }

    public Integer getMajorLeagueRosterCount() { 
        return majorLeagueRosterCount != null ? majorLeagueRosterCount : 0; 
    }
    public void setMajorLeagueRosterCount(Integer majorLeagueRosterCount) { this.majorLeagueRosterCount = majorLeagueRosterCount; }

    public Integer getMinorLeagueRosterCount() { 
        return minorLeagueRosterCount != null ? minorLeagueRosterCount : 0; 
    }
    public void setMinorLeagueRosterCount(Integer minorLeagueRosterCount) { this.minorLeagueRosterCount = minorLeagueRosterCount; }

    public Double getAvailableCapSpace() {
        return getSalaryCap() - getCurrentSalaryUsed();
    }

    public boolean canAffordPlayer(Double aas) {
        return aas != null && getAvailableCapSpace() >= aas;
    }

    public boolean hasRosterSpace(boolean isMinorLeaguer) {
        if (isMinorLeaguer) {
            return getMinorLeagueRosterCount() < 25;
        } else {
            return getMajorLeagueRosterCount() < 40;
        }
    }
}
