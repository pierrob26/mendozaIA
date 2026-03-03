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
        if (!userAccountRepository.existsByUsername("testuser")) {
            UserAccount testUser = new UserAccount();
            testUser.setUsername("testuser");
            testUser.setPassword(passwordEncoder.encode("password"));
            testUser.setRole("MEMBER");
            testUser.setSalaryCap(125.0);
            testUser.setCurrentSalaryUsed(0.0);
            testUser.setMajorLeagueRosterCount(0);
            testUser.setMinorLeagueRosterCount(0);
            userAccountRepository.save(testUser);
            
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
            
            Player[] freeAgents = {
                new Player("Mike Trout", "OF", "Los Angeles Angels", 0, 0.0, null),
                new Player("Aaron Judge", "OF", "New York Yankees", 0, 0.0, null),
                new Player("Freddie Freeman", "1B", "Los Angeles Dodgers", 0, 0.0, null),
                new Player("Max Scherzer", "SP", "New York Mets", 0, 0.0, null),
                new Player("Nolan Arenado", "3B", "St. Louis Cardinals", 0, 0.0, null),
                new Player("Trea Turner", "SS", "Philadelphia Phillies", 0, 0.0, null),
                new Player("Yordan Alvarez", "DH", "Houston Astros", 0, 0.0, null),
                new Player("Shane Bieber", "SP", "Cleveland Guardians", 0, 0.0, null),
                new Player("J.T. Realmuto", "C", "Philadelphia Phillies", 0, 0.0, null),
                new Player("Edwin Diaz", "RP", "New York Mets", 0, 0.0, null)
            };
            
            for (Player freeAgent : freeAgents) {
                playerRepository.save(freeAgent);
            }
        }
        createTestCommissioners();
        createAdditionalTestUsers();
    }
    
    private void createTestCommissioners() {
        if (!userAccountRepository.existsByUsername("commissioner")) {
            UserAccount commissioner = new UserAccount();
            commissioner.setUsername("commissioner");
            commissioner.setPassword(passwordEncoder.encode("admin123"));
            commissioner.setRole("COMMISSIONER");
            commissioner.setSalaryCap(125.0);
            commissioner.setCurrentSalaryUsed(0.0);
            commissioner.setMajorLeagueRosterCount(0);
            commissioner.setMinorLeagueRosterCount(0);
            userAccountRepository.save(commissioner);
        }
        
        if (!userAccountRepository.existsByUsername("admin")) {
            UserAccount admin = new UserAccount();
            admin.setUsername("admin");
            admin.setPassword(passwordEncoder.encode("password"));
            admin.setRole("COMMISSIONER");
            admin.setSalaryCap(125.0);
            admin.setCurrentSalaryUsed(0.0);
            admin.setMajorLeagueRosterCount(0);
            admin.setMinorLeagueRosterCount(0);
            userAccountRepository.save(admin);
        }
        if (!userAccountRepository.existsByUsername("commish")) {
            UserAccount commish = new UserAccount();
            commish.setUsername("commish");
            commish.setPassword(passwordEncoder.encode("commish"));
            commish.setRole("COMMISSIONER");
            commish.setSalaryCap(125.0);
            commish.setCurrentSalaryUsed(0.0);
            commish.setMajorLeagueRosterCount(0);
            commish.setMinorLeagueRosterCount(0);
            userAccountRepository.save(commish);
        }
        
        if (!userAccountRepository.existsByUsername("dasGoat")) {
            UserAccount dasGoat = new UserAccount();
            dasGoat.setUsername("dasGoat");
            dasGoat.setPassword(passwordEncoder.encode("goat123"));
            dasGoat.setRole("COMMISSIONER");
            dasGoat.setSalaryCap(125.0);
            dasGoat.setCurrentSalaryUsed(0.0);
            dasGoat.setMajorLeagueRosterCount(0);
            dasGoat.setMinorLeagueRosterCount(0);
            userAccountRepository.save(dasGoat);
        }
    }
    
    private void createAdditionalTestUsers() {
        String[] testManagers = {"manager1", "manager2", "team1", "team2", "owner1"};
        
        for (String username : testManagers) {
            if (!userAccountRepository.existsByUsername(username)) {
                UserAccount user = new UserAccount();
                user.setUsername(username);
                user.setPassword(passwordEncoder.encode("password"));
                user.setRole("MANAGER");
                user.setSalaryCap(125.0);
                user.setCurrentSalaryUsed(0.0);
                user.setMajorLeagueRosterCount(0);
                user.setMinorLeagueRosterCount(0);
                userAccountRepository.save(user);
            }
        }
    }
}