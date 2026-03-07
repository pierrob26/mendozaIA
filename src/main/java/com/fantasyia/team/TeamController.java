package com.fantasyia.team;

import com.fantasyia.user.UserAccount;
import com.fantasyia.user.UserAccountRepository;
import com.fantasyia.auction.Auction;
import com.fantasyia.auction.AuctionRepository;
import com.fantasyia.auction.AuctionItem;
import com.fantasyia.auction.AuctionItemRepository;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

import jakarta.servlet.http.HttpServletResponse;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Controller
public class TeamController {

    @Autowired
    private PlayerRepository playerRepository;
    
    @Autowired
    private UserAccountRepository userAccountRepository;
    
    @Autowired
    private AuctionRepository auctionRepository;
    
    @Autowired
    private AuctionItemRepository auctionItemRepository;
    
    @Autowired
    private ReleasedPlayerRepository releasedPlayerRepository;

    private static final LinkedHashMap<String, Integer> REQUIRED_ROSTER_TEMPLATE = new LinkedHashMap<>();
    static {
        REQUIRED_ROSTER_TEMPLATE.put("C", 1);
        REQUIRED_ROSTER_TEMPLATE.put("1B", 1);
        REQUIRED_ROSTER_TEMPLATE.put("2B", 1);
        REQUIRED_ROSTER_TEMPLATE.put("3B", 1);
        REQUIRED_ROSTER_TEMPLATE.put("SS", 1);
        REQUIRED_ROSTER_TEMPLATE.put("OF", 3);
        REQUIRED_ROSTER_TEMPLATE.put("DH", 1);
        REQUIRED_ROSTER_TEMPLATE.put("SP", 5);
        REQUIRED_ROSTER_TEMPLATE.put("RP", 3);
    }

    @GetMapping("/team")
    public String team(Model model,
                      @RequestParam(required = false) String position,
                      @RequestParam(required = false) Integer minContract,
                      @RequestParam(required = false) Integer maxContract,
                      @RequestParam(required = false) Double minSalary,
                      @RequestParam(required = false) Double maxSalary) {

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        UserAccount user = userAccountRepository.findByUsername(username).orElse(null);
        
        if (user == null) {
            return "redirect:/login";
        }

        ensureRosterPlaceholders(user.getId());

        List<Player> players = playerRepository.findPlayersWithFilters(
            user.getId(), position, minContract, maxContract, minSalary, maxSalary
        );
        
        model.addAttribute("players", players);
        model.addAttribute("currentUser", user);
        model.addAttribute("selectedPosition", position);
        model.addAttribute("minContract", minContract);
        model.addAttribute("maxContract", maxContract);
        model.addAttribute("minSalary", minSalary);
        model.addAttribute("maxSalary", maxSalary);
        
        return "team";
    }

    private void ensureRosterPlaceholders(Long userId) {
        // ...existing complex roster management logic...
    }
    
    // ...rest of complex TeamController methods...
}