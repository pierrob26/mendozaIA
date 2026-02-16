package com.fantasyia.auction;

import com.fantasyia.team.Player;
import com.fantasyia.team.PlayerRepository;
import com.fantasyia.user.UserAccount;
import com.fantasyia.user.UserAccountRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@Controller
@RequestMapping("/auction")
public class AuctionController {

    @Autowired
    private AuctionRepository auctionRepository;
    
    @Autowired
    private PlayerRepository playerRepository;
    
    @Autowired
    private UserAccountRepository userAccountRepository;

    @GetMapping("/manage")
    public String manageAuctions(Model model) {
        // Get current authenticated user
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        UserAccount user = userAccountRepository.findByUsername(username).orElse(null);
        
        if (user == null || !"COMMISSIONER".equals(user.getRole())) {
            return "redirect:/";
        }

        // Get auctions created by this commissioner
        List<Auction> auctions = auctionRepository.findByCreatedByCommissionerId(user.getId());
        
        // Get free agents for new auctions
        List<Player> freeAgents = playerRepository.findByOwnerIdIsNull();
        
        model.addAttribute("auctions", auctions);
        model.addAttribute("freeAgents", freeAgents);
        model.addAttribute("currentDateTime", LocalDateTime.now());
        
        return "auction-manage";
    }

    @PostMapping("/create")
    public String createAuction(@RequestParam String name,
                               @RequestParam String description,
                               @RequestParam int durationHours,
                               @RequestParam(required = false) List<Long> selectedPlayers) {
        
        // Get current authenticated user
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        UserAccount user = userAccountRepository.findByUsername(username).orElse(null);
        
        if (user == null || !"COMMISSIONER".equals(user.getRole())) {
            return "redirect:/";
        }

        // Create auction
        LocalDateTime startTime = LocalDateTime.now();
        LocalDateTime endTime = startTime.plusHours(durationHours);
        
        Auction auction = new Auction(name, startTime, endTime, user.getId(), description);
        auctionRepository.save(auction);
        
        return "redirect:/auction/manage";
    }

    @GetMapping("/view/{id}")
    public String viewAuction(@PathVariable Long id, Model model) {
        Auction auction = auctionRepository.findById(id).orElse(null);
        if (auction == null) {
            return "redirect:/auction/manage";
        }
        
        // Get free agents for this auction
        List<Player> freeAgents = playerRepository.findByOwnerIdIsNull();
        
        model.addAttribute("auction", auction);
        model.addAttribute("freeAgents", freeAgents);
        model.addAttribute("currentDateTime", LocalDateTime.now());
        
        return "auction-view";
    }
    
    @PostMapping("/end/{id}")
    public String endAuction(@PathVariable Long id) {
        // Get current authenticated user
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        UserAccount user = userAccountRepository.findByUsername(username).orElse(null);
        
        if (user == null || !"COMMISSIONER".equals(user.getRole())) {
            return "redirect:/";
        }
        
        Auction auction = auctionRepository.findById(id).orElse(null);
        if (auction != null && auction.getCreatedByCommissionerId().equals(user.getId())) {
            auction.setStatus("COMPLETED");
            auction.setEndTime(LocalDateTime.now());
            auctionRepository.save(auction);
        }
        
        return "redirect:/auction/manage";
    }
}