package com.fantasyia.controller;

import com.fantasyia.team.ReleasedPlayerRepository;
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

    @GetMapping("/")
    public String home(Model model) {

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.isAuthenticated() && !auth.getName().equals("anonymousUser")) {
            String username = auth.getName();
            UserAccount user = userAccountRepository.findByUsername(username).orElse(null);
            model.addAttribute("currentUser", user);

            if (user != null && "COMMISSIONER".equals(user.getRole())) {
                long pendingCount = releasedPlayerRepository.countByStatus("PENDING");
                model.addAttribute("pendingReleasedPlayersCount", pendingCount);
                
                // Commissioners see only their own salary information on home page
                // (they can see all teams via the manage auction page if needed)
                List<UserAccount> currentUserTeam = Arrays.asList(user);
                model.addAttribute("teams", currentUserTeam);
            } else if (user != null && "MANAGER".equals(user.getRole())) {
                // Regular managers only see their own salary information
                List<UserAccount> currentUserTeam = Arrays.asList(user);
                model.addAttribute("teams", currentUserTeam);
            }
        }
        
        return "home";
    }

    @GetMapping("/login")
    public String login() {
        return "login";
    }
}
