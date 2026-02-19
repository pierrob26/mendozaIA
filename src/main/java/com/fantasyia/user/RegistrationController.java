package com.fantasyia.user;

/**
 * DISABLED - DO NOT USE
 * 
 * This controller has been replaced by RegisterController in the controller package.
 * RegisterController has more complete functionality including salary cap and roster initialization.
 * 
 * This file is kept for reference only and is not loaded by Spring (no @Controller annotation).
 * 
 * @deprecated Use com.fantasyia.controller.RegisterController instead
 */
@Deprecated
class RegistrationController_DISABLED_BACKUP {

    // ALL CODE DISABLED - USE RegisterController INSTEAD
    
    /*
    private final UserAccountRepository repo;
    private final PasswordEncoder passwordEncoder;

    public RegistrationController_DISABLED_BACKUP(UserAccountRepository repo, PasswordEncoder passwordEncoder) {
        this.repo = repo;
        this.passwordEncoder = passwordEncoder;
    }

    public String showForm(Model model) {
        model.addAttribute("user", new UserAccount());
        return "register";
    }

    public String register(UserAccount user, Model model) {
        if (repo.existsByUsername(user.getUsername())) {
            model.addAttribute("error", "Username already exists");
            return "register";
        }
        
        if (user.getRole() == null || 
            (!user.getRole().equals("MEMBER") && !user.getRole().equals("COMMISSIONER"))) {
            model.addAttribute("error", "Please select a valid role");
            return "register";
        }
        
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        repo.save(user);
        return "redirect:/login";
    }
    */
}
