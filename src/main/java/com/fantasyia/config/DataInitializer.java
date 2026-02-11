package com.fantasyia.config;

import com.fantasyia.team.Player;
import com.fantasyia.team.PlayerRepository;
import com.fantasyia.user.UserAccount;
import com.fantasyia.user.UserAccountRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private UserAccountRepository userAccountRepository;
    
    @Autowired
    private PlayerRepository playerRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        // Create a test user if it doesn't exist
        if (!userAccountRepository.existsByUsername("testuser")) {
            UserAccount testUser = new UserAccount();
            testUser.setUsername("testuser");
            testUser.setPassword(passwordEncoder.encode("password"));
            testUser.setRole("USER");
            userAccountRepository.save(testUser);
            
            // Add some sample baseball players for the test user
            Player[] samplePlayers = {
                new Player("Mookie Betts", "OF", "LAD", 4, 36500000.0, testUser.getId()),
                new Player("Ronald Acuña Jr.", "OF", "ATL", 5, 20000000.0, testUser.getId()),
                new Player("José Altuve", "2B", "HOU", 3, 29166666.0, testUser.getId()),
                new Player("Manny Machado", "3B", "SD", 4, 30000000.0, testUser.getId()),
                new Player("Francisco Lindor", "SS", "NYM", 6, 34100000.0, testUser.getId()),
                new Player("Vladimir Guerrero Jr.", "1B", "TOR", 2, 19900000.0, testUser.getId()),
                new Player("Salvador Perez", "C", "KC", 2, 20000000.0, testUser.getId()),
                new Player("Shohei Ohtani", "DH", "LAA", 1, 30000000.0, testUser.getId()),
                new Player("Jacob deGrom", "SP", "TEX", 3, 37000000.0, testUser.getId()),
                new Player("Josh Hader", "RP", "SD", 2, 19250000.0, testUser.getId()),
                new Player("Gerrit Cole", "SP", "NYY", 4, 36000000.0, testUser.getId()),
                new Player("Fernando Tatis Jr.", "SS", "SD", 5, 28571428.0, testUser.getId()),
                new Player("Pete Alonso", "1B", "NYM", 2, 20500000.0, testUser.getId()),
                new Player("Juan Soto", "OF", "SD", 1, 23000000.0, testUser.getId())
            };
            
            for (Player player : samplePlayers) {
                playerRepository.save(player);
            }
        }
    }
}