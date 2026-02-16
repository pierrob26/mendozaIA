package com.fantasyia.auction;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface AuctionRepository extends JpaRepository<Auction, Long> {
    
    List<Auction> findByCreatedByCommissionerId(Long commissionerId);
    
    List<Auction> findByStatus(String status);
    
    @Query("SELECT a FROM Auction a WHERE a.status = 'ACTIVE' AND a.endTime > :currentTime")
    List<Auction> findActiveAuctions(LocalDateTime currentTime);
    
    @Query("SELECT a FROM Auction a WHERE a.status = 'ACTIVE' AND a.endTime <= :currentTime")
    List<Auction> findExpiredAuctions(LocalDateTime currentTime);
}