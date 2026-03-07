package com.fantasyia.team;

import com.fantasyia.user.UserAccount;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

/**
 * Integration test to verify salary calculation functionality
 */
public class SalaryCalculationTest {

    @Test
    public void testSalaryCalculation() {
        // Create test user
        UserAccount user = new UserAccount();
        user.setId(1L);
        user.setSalaryCap(125.0);
        user.setCurrentSalaryUsed(0.0);
        
        // Create test players
        Player player1 = new Player("Test Player 1", "OF", "LAD", 3, 15000000.0, 1L);
        player1.setAverageAnnualSalary(5000000.0); // $5M
        
        Player player2 = new Player("Test Player 2", "SP", "NYY", 5, 50000000.0, 1L);
        player2.setAverageAnnualSalary(10000000.0); // $10M
        
        // Test available cap space calculation
        double expectedAvailableSpace = user.getSalaryCap() - user.getCurrentSalaryUsed();
        assertEquals(125.0, expectedAvailableSpace, 0.1);
        
        // Test can afford player
        assertTrue(user.canAffordPlayer(5.0)); // Can afford $5M player
        assertTrue(user.canAffordPlayer(10.0)); // Can afford $10M player
        assertFalse(user.canAffordPlayer(130.0)); // Cannot afford $130M player
        
        System.out.println("✓ Salary calculation tests passed");
    }
    
    @Test
    public void testRosterSpaceCalculation() {
        UserAccount user = new UserAccount();
        user.setMajorLeagueRosterCount(35);
        user.setMinorLeagueRosterCount(20);
        
        // Test roster space availability
        assertTrue(user.hasRosterSpace(false)); // Has space for MLB player (35 < 40)
        assertTrue(user.hasRosterSpace(true));  // Has space for minor league player (20 < 25)
        
        user.setMajorLeagueRosterCount(40);
        user.setMinorLeagueRosterCount(25);
        
        assertFalse(user.hasRosterSpace(false)); // No space for MLB player (40 = 40)
        assertFalse(user.hasRosterSpace(true));  // No space for minor league player (25 = 25)
        
        System.out.println("✓ Roster space calculation tests passed");
    }
}