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
    private String position; // Baseball positions: C, 1B, 2B, 3B, SS, OF, SP, RP, DH

    @Column(nullable = false)
    private String team; // MLB team

    @Column(nullable = false)
    private Integer contractLength; // in years

    @Column(nullable = false)
    private Double contractAmount; // salary amount

    @Column
    private Long ownerId; // foreign key to UserAccount

    // Constructors
    public Player() {}

    public Player(String name, String position, String team, Integer contractLength, Double contractAmount, Long ownerId) {
        this.name = name;
        this.position = position;
        this.team = team;
        this.contractLength = contractLength;
        this.contractAmount = contractAmount;
        this.ownerId = ownerId;
    }

    // Getters and Setters
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

    public Long getOwnerId() { return ownerId; }
    public void setOwnerId(Long ownerId) { this.ownerId = ownerId; }
}