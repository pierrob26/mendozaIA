package com.fantasyia.controller;

import com.fantasyia.team.ReleasedPlayerRepository;
import com.fantasyia.team.PlayerRepository;
import com.fantasyia.team.Player;
import com.fantasyia.user.UserAccount;
import com.fantasyia.user.UserAccountRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.Arrays;
import java.util.List;

@Controller
public class HomeController {

    @Autowired
    private UserAccountRepository userAccountRepository;

    @Autowired
    private ReleasedPlayerRepository releasedPlayerRepository;

    @Autowired
    private PlayerRepository playerRepository;

    @GetMapping("/")
    public String home(Model model) {

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.isAuthenticated() && !auth.getName().equals("anonymousUser")) {
            String username = auth.getName();
            UserAccount user = userAccountRepository.findByUsername(username).orElse(null);
            model.addAttribute("currentUser", user);

            if (user != null) {
                // Update salary and roster counts before displaying
                updateUserSalaryAndCounts(user);
                
                // Refresh user data after update
                user = userAccountRepository.findById(user.getId()).orElse(user);
                model.addAttribute("currentUser", user);
                
                // Show salary information for all authenticated users
                List<UserAccount> currentUserTeam = Arrays.asList(user);
                model.addAttribute("teams", currentUserTeam);

                // Commissioner-specific features
                if ("COMMISSIONER".equals(user.getRole())) {
                    long pendingCount = releasedPlayerRepository.countByStatus("PENDING");
                    model.addAttribute("pendingReleasedPlayersCount", pendingCount);
                }
            }
        }

        return "home";
    }

    @GetMapping("/login")
    public String login() {
        return "login";
    }
    
    private void updateUserSalaryAndCounts(UserAccount user) {
        List<Player> userPlayers = playerRepository.findByOwnerId(user.getId());
        
        double totalSalary = userPlayers.stream()
            .filter(p -> p.getAverageAnnualSalary() != null)
            .mapToDouble(Player::getAverageAnnualSalary)
            .sum();
            
        int majorLeagueCount = (int) userPlayers.stream()
            .filter(p -> p.getIsMinorLeaguer() != null && !p.getIsMinorLeaguer())
            .count();
            
        int minorLeagueCount = (int) userPlayers.stream()
            .filter(p -> p.getIsMinorLeaguer() != null && p.getIsMinorLeaguer())
            .count();
        
        user.setCurrentSalaryUsed(totalSalary / 1000000.0); // Convert to millions
        user.setMajorLeagueRosterCount(majorLeagueCount);
        user.setMinorLeagueRosterCount(minorLeagueCount);
        
        userAccountRepository.save(user);
    }
}