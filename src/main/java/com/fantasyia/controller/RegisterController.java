package com.fantasyia.controller;

import com.fantasyia.user.UserAccount;
import com.fantasyia.user.UserAccountRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
public class RegisterController {

    @Autowired
    private UserAccountRepository userAccountRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @GetMapping("/register")
    public String showRegisterForm(Model model) {
        return "register";
    }

    @PostMapping("/register")
    public String registerUser(@RequestParam String username,
                              @RequestParam String password,
                              @RequestParam String role,
                              RedirectAttributes redirectAttributes) {
        try {
            // Check if username already exists
            if (userAccountRepository.findByUsername(username).isPresent()) {
                redirectAttributes.addFlashAttribute("error", "Username already exists");
                return "redirect:/register";
            }

            // Validate role
            if (!role.equals("MANAGER") && !role.equals("COMMISSIONER")) {
                redirectAttributes.addFlashAttribute("error", "Invalid role selected");
                return "redirect:/register";
            }

            // Create new user account
            UserAccount newUser = new UserAccount();
            newUser.setUsername(username);
            newUser.setPassword(passwordEncoder.encode(password));
            newUser.setRole(role);
            
            // Initialize salary cap and roster counts
            newUser.setSalaryCap(100.0); // $100M default
            newUser.setCurrentSalaryUsed(0.0);
            newUser.setMajorLeagueRosterCount(0);
            newUser.setMinorLeagueRosterCount(0);

            userAccountRepository.save(newUser);

            redirectAttributes.addFlashAttribute("success", "Registration successful! Please login.");
            return "redirect:/login";

        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Registration failed: " + e.getMessage());
            return "redirect:/register";
        }
    }
}
