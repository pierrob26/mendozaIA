package com.fantasyia.auction;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * Scheduled tasks for auction management.
 * Handles automatic processing of expired auctions and contracts.
 */
@Component
public class AuctionScheduledTasks {

    @Autowired
    private AuctionService auctionService;

    /**
     * Check for expired contracts every hour and apply buyout fees.
     * Rule 7(a) and vii(1): If contract not posted within 48 hours, apply buyout fee.
     */
    @Scheduled(fixedRate = 3600000) // Run every hour (3600000 ms)
    public void processExpiredContracts() {
        try {
            auctionService.processExpiredContracts();
        } catch (Exception e) {
            System.err.println("Error processing expired contracts: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Check for auctions ready to be won every 30 minutes and auto-award them.
     * Rule 5 and vii: Bids must stand for 24 hours (in-season) or 72 hours (off-season).
     */
    @Scheduled(fixedRate = 1800000) // Run every 30 minutes (1800000 ms)
    public void autoAwardExpiredAuctions() {
        try {
            auctionService.autoAwardExpiredAuctions();
        } catch (Exception e) {
            System.err.println("Error auto-awarding expired auctions: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
