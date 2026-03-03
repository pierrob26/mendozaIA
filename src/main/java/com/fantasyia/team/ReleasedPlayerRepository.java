package com.fantasyia.team;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReleasedPlayerRepository extends JpaRepository<ReleasedPlayer, Long> {
    
    List<ReleasedPlayer> findByStatusOrderByReleasedAtDesc(String status);
    
    long countByStatus(String status);
}
