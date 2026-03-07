#!/bin/bash

# Script to revert the temporary testing changes for auction player removal

echo "🔄 Reverting temporary auction removal changes..."

# Backup files with original methods for easy restoration
echo "Creating backup files with original methods..."

# Original hasMinimumTimeElapsed method for AuctionItem.java
cat > /tmp/hasMinimumTimeElapsed_original.java << 'EOF'
    public boolean hasMinimumTimeElapsed(String auctionType) {
        if (firstBidTime == null) return false;
        
        long hoursElapsed = Duration.between(firstBidTime, LocalDateTime.now()).toHours();
        
        if ("IN_SEASON".equals(auctionType)) {
            return hoursElapsed >= 24;
        } else {
            return hoursElapsed >= 72;
        }
    }
EOF

# Original canBeRemoved method for AuctionItem.java
cat > /tmp/canBeRemoved_original.java << 'EOF'
    public boolean canBeRemoved(String auctionType) {
        return firstBidTime != null && hasMinimumTimeElapsed(auctionType);
    }
EOF

# Original getTimeRemainingHours method for AuctionItem.java  
cat > /tmp/getTimeRemainingHours_original.java << 'EOF'
    public long getTimeRemainingHours(String auctionType) {
        if (firstBidTime == null) return -1;
        
        int requiredHours = "IN_SEASON".equals(auctionType) ? 24 : 72;
        LocalDateTime calculatedEndTime = firstBidTime.plusHours(requiredHours);
        
        if (LocalDateTime.now().isAfter(calculatedEndTime)) return 0;
        return Duration.between(LocalDateTime.now(), calculatedEndTime).toHours();
    }
EOF

# Original isReadyToWin method for AuctionService.java
cat > /tmp/isReadyToWin_original.java << 'EOF'
    public boolean isReadyToWin(AuctionItem item, String auctionType) {
        if (item.getLastBidTime() == null) {
            return false;
        }

        long hoursElapsed = Duration.between(item.getLastBidTime(), LocalDateTime.now()).toHours();
        int requiredHours = "IN_SEASON".equals(auctionType) ? 24 : 72;
        
        return hoursElapsed >= requiredHours;
    }
EOF

# Original awardPlayer method for AuctionService.java
cat > /tmp/awardPlayer_original.java << 'EOF'
        PendingContract pendingContract = new PendingContract(
            item.getId(),
            player.getId(),
            item.getCurrentBidderId(),
            item.getCurrentBid(),
            item.getIsMinorLeaguer()
        );
        pendingContractRepository.save(pendingContract);

        item.setStatus("AWAITING_CONTRACT");
        item.setContractDeadline(LocalDateTime.now().plusHours(48));

        int complianceHours = "IN_SEASON".equals(auction.getAuctionType()) ? 24 : 48;
        item.setRosterComplianceDeadline(LocalDateTime.now().plusHours(complianceHours));
        
        auctionItemRepository.save(item);

        String message = String.format("Player %s awarded to %s for $%.1fM AAS. Contract must be posted within 48 hours or buyout fee of $%.1fM will apply.",
            player.getName(), winner.getUsername(), item.getCurrentBid(), item.getCurrentBid() / 2.0);
        return new ContractResult(true, message);
EOF
cat > /tmp/calculateHoursRemaining_original.java << 'EOF'
    public long calculateHoursRemaining(AuctionItem item, String auctionType) {
        if (item.getLastBidTime() == null) {
            return -1;
        }

        int requiredHours = "IN_SEASON".equals(auctionType) ? 24 : 72;
        LocalDateTime calculatedEndTime = item.getLastBidTime().plusHours(requiredHours);
        
        if (LocalDateTime.now().isAfter(calculatedEndTime)) {
            return 0;
        }
        
        return Duration.between(LocalDateTime.now(), calculatedEndTime).toHours();
    }
EOF

echo "✅ Backup files created in /tmp/"
echo ""
echo "📝 MANUAL STEPS TO REVERT:"
echo "================================"
echo "1. RESTORE AuctionItem.java methods:"
echo "   File: src/main/java/com/fantasyia/auction/AuctionItem.java"
echo "   - Replace hasMinimumTimeElapsed() with /tmp/hasMinimumTimeElapsed_original.java"
echo "   - Replace canBeRemoved(String) with /tmp/canBeRemoved_original.java"  
echo "   - REMOVE the parameterless canBeRemoved() method"
echo "   - Replace getTimeRemainingHours() with /tmp/getTimeRemainingHours_original.java"
echo ""
echo "2. RESTORE AuctionService.java methods:"
echo "   File: src/main/java/com/fantasyia/auction/AuctionService.java"
echo "   - Replace isReadyToWin() with /tmp/isReadyToWin_original.java"
echo "   - Replace calculateHoursRemaining() with /tmp/calculateHoursRemaining_original.java"
echo "   - Replace awardPlayer() logic with /tmp/awardPlayer_original.java"
echo ""
echo "3. REBUILD AND REDEPLOY:"
echo "   ./gradlew build && docker compose up --build -d"
echo ""
echo "🚀 After reverting, the original timing restrictions will be restored:"
echo "   - IN_SEASON: 24 hour wait after last bid"
echo "   - OFF_SEASON: 72 hour wait after last bid"