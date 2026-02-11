package com.fantasyia.user;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.security.crypto.password.PasswordEncoder;

@Controller
public class RegistrationController {

    private final UserAccountRepository repo;
    private final PasswordEncoder passwordEncoder;

    public RegistrationController(UserAccountRepository repo, PasswordEncoder passwordEncoder) {
        this.repo = repo;
        this.passwordEncoder = passwordEncoder;
    }

    @GetMapping("/register")
    public String showForm(Model model) {
        model.addAttribute("user", new UserAccount());
        return "register";
    }

    @PostMapping("/register")
    public String register(@ModelAttribute("user") UserAccount user, Model model) {
        if (repo.existsByUsername(user.getUsername())) {
            model.addAttribute("error", "Username already exists");
            return "register";
        }
        
        // Validate role
        if (user.getRole() == null || 
            (!user.getRole().equals("MEMBER") && !user.getRole().equals("COMMISSIONER"))) {
            model.addAttribute("error", "Please select a valid role");
            return "register";
        }
        
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        repo.save(user);
        return "redirect:/login";
    }
}
