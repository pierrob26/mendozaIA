package com.fantasyia.auction;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface AuctionItemRepository extends JpaRepository<AuctionItem, Long> {
    
    List<AuctionItem> findByAuctionIdAndStatus(Long auctionId, String status);
    
    List<AuctionItem> findByAuctionId(Long auctionId);
    
    AuctionItem findByPlayerIdAndStatus(Long playerId, String status);
    
    @Query("SELECT ai FROM AuctionItem ai WHERE ai.auctionId = :auctionId AND ai.status = 'ACTIVE' " +
           "AND ai.firstBidTime IS NOT NULL AND ai.firstBidTime < :cutoffTime")
    List<AuctionItem> findExpiredItems(@Param("auctionId") Long auctionId, 
                                      @Param("cutoffTime") LocalDateTime cutoffTime);
    
    @Query("SELECT ai FROM AuctionItem ai WHERE ai.auctionId = :auctionId AND ai.status = 'ACTIVE' " +
           "AND ai.firstBidTime IS NOT NULL")
    List<AuctionItem> findActiveItemsWithBids(@Param("auctionId") Long auctionId);
    
    @Query("SELECT ai FROM AuctionItem ai WHERE ai.auctionId = :auctionId AND ai.status = 'ACTIVE' " +
           "AND ai.firstBidTime IS NULL")
    List<AuctionItem> findActiveItemsWithoutBids(@Param("auctionId") Long auctionId);
}