package com.fantasyia.auction;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;


@Component
public class AuctionScheduledTasks {

    @Autowired
    private AuctionService auctionService;


    @Scheduled(fixedRate = 3600000) // Run every hour (3600000 ms)
    public void processExpiredContracts() {
        try {
            auctionService.processExpiredContracts();
        } catch (Exception e) {
            System.err.println("Error processing expired contracts: " + e.getMessage());
            e.printStackTrace();
        }
    }


    @Scheduled(fixedRate = 1800000)
    public void autoAwardExpiredAuctions() {
        try {
            auctionService.autoAwardExpiredAuctions();
        } catch (Exception e) {
            System.err.println("Error auto-awarding expired auctions: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
