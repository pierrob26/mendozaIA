package com.fantasyia.controller;

import com.fantasyia.user.UserAccount;
import com.fantasyia.user.UserAccountRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    @Autowired
    private UserAccountRepository userAccountRepository;

    @GetMapping("/")
    public String home(Model model) {
        // Get current authenticated user
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.isAuthenticated() && !auth.getName().equals("anonymousUser")) {
            String username = auth.getName();
            UserAccount user = userAccountRepository.findByUsername(username).orElse(null);
            model.addAttribute("currentUser", user);
        }
        return "home";
    }

    @GetMapping("/login")
    public String login() {
        return "login";
    }
}
