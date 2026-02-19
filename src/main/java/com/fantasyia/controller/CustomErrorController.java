package com.fantasyia.controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.boot.web.servlet.error.ErrorController;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class CustomErrorController implements ErrorController {

    @RequestMapping("/error")
    public String handleError(HttpServletRequest request, Model model) {
        Object status = request.getAttribute(RequestDispatcher.ERROR_STATUS_CODE);
        Object exception = request.getAttribute(RequestDispatcher.ERROR_EXCEPTION);
        Object message = request.getAttribute(RequestDispatcher.ERROR_MESSAGE);
        
        if (status != null) {
            Integer statusCode = Integer.valueOf(status.toString());
            model.addAttribute("statusCode", statusCode);
            
            if (statusCode == 404) {
                model.addAttribute("errorTitle", "Page Not Found");
                model.addAttribute("errorMessage", "The page you are looking for does not exist.");
            } else if (statusCode == 500) {
                model.addAttribute("errorTitle", "Internal Server Error");
                model.addAttribute("errorMessage", "An unexpected error occurred. Please try again.");
                
                // Log the actual error for debugging
                if (exception != null) {
                    System.err.println("=== 500 ERROR ===");
                    System.err.println("Exception: " + exception);
                    if (exception instanceof Exception) {
                        ((Exception) exception).printStackTrace();
                    }
                }
                if (message != null) {
                    System.err.println("Error Message: " + message);
                }
            } else {
                model.addAttribute("errorTitle", "Error " + statusCode);
                model.addAttribute("errorMessage", "An error occurred.");
            }
        }
        
        return "error";
    }
}
