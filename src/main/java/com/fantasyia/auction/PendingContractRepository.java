package com.fantasyia.auction;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface PendingContractRepository extends JpaRepository<PendingContract, Long> {
    
    List<PendingContract> findByWinnerIdAndStatus(Long winnerId, String status);
    
    List<PendingContract> findByStatus(String status);
    
    @Query("SELECT p FROM PendingContract p WHERE p.status = 'PENDING' AND p.contractDeadline < :currentTime")
    List<PendingContract> findExpiredContracts(@Param("currentTime") LocalDateTime currentTime);
    
    PendingContract findByAuctionItemIdAndStatus(Long auctionItemId, String status);
}
