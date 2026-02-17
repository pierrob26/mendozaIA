package com.fantasyia.team;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReleasedPlayerRepository extends JpaRepository<ReleasedPlayer, Long> {
    
    // Find all pending released players (not yet added to auction)
    List<ReleasedPlayer> findByStatusOrderByReleasedAtDesc(String status);
    
    // Count pending released players
    long countByStatus(String status);
}
