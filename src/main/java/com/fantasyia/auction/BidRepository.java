package com.fantasyia.auction;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BidRepository extends JpaRepository<Bid, Long> {
    
    List<Bid> findByAuctionItemIdOrderByAmountDesc(Long auctionItemId);
    
    List<Bid> findByAuctionItemIdOrderByBidTimeDesc(Long auctionItemId);
    
    List<Bid> findByBidderIdOrderByBidTimeDesc(Long bidderId);
    
    @Query("SELECT b FROM Bid b WHERE b.auctionItemId = :auctionItemId AND b.amount = " +
           "(SELECT MAX(b2.amount) FROM Bid b2 WHERE b2.auctionItemId = :auctionItemId)")
    Bid findHighestBidForItem(@Param("auctionItemId") Long auctionItemId);
    
    @Query("SELECT COUNT(b) FROM Bid b WHERE b.auctionItemId = :auctionItemId")
    long countBidsForItem(@Param("auctionItemId") Long auctionItemId);
    
    @Query("SELECT b FROM Bid b WHERE b.auctionItemId = :auctionItemId AND b.bidderId = :bidderId " +
           "ORDER BY b.bidTime DESC")
    List<Bid> findBidsByUserForItem(@Param("auctionItemId") Long auctionItemId, 
                                   @Param("bidderId") Long bidderId);
}