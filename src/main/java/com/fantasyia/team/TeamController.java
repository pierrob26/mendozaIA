package com.fantasyia.team;

import com.fantasyia.user.UserAccount;
import com.fantasyia.user.UserAccountRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
public class TeamController {

    @Autowired
    private PlayerRepository playerRepository;
    
    @Autowired
    private UserAccountRepository userAccountRepository;

    @GetMapping("/team")
    public String team(Model model,
                      @RequestParam(required = false) String position,
                      @RequestParam(required = false) Integer minContract,
                      @RequestParam(required = false) Integer maxContract,
                      @RequestParam(required = false) Double minSalary,
                      @RequestParam(required = false) Double maxSalary) {
        
        // Get current authenticated user
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        UserAccount user = userAccountRepository.findByUsername(username).orElse(null);
        
        if (user == null) {
            return "redirect:/login";
        }

        // Get players with filters
        List<Player> players = playerRepository.findPlayersWithFilters(
            user.getId(), position, minContract, maxContract, minSalary, maxSalary
        );
        
        model.addAttribute("players", players);
        model.addAttribute("selectedPosition", position);
        model.addAttribute("minContract", minContract);
        model.addAttribute("maxContract", maxContract);
        model.addAttribute("minSalary", minSalary);
        model.addAttribute("maxSalary", maxSalary);
        
        return "team";
    }

    @PostMapping("/team/add-player")
    public String addPlayer(@RequestParam String name,
                           @RequestParam String position,
                           @RequestParam String team,
                           @RequestParam Integer contractLength,
                           @RequestParam Double contractAmount) {
        
        // Get current authenticated user
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        UserAccount user = userAccountRepository.findByUsername(username).orElse(null);
        
        if (user == null) {
            return "redirect:/login";
        }

        Player player = new Player(name, position, team, contractLength, contractAmount, user.getId());
        playerRepository.save(player);
        
        return "redirect:/team";
    }
}