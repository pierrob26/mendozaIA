package com.fantasyia.team;

import com.fantasyia.user.UserAccount;
import com.fantasyia.user.UserAccountRepository;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
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
import java.util.ArrayList;
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
        model.addAttribute("currentUser", user);
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

    @PostMapping("/team/bulk-import")
    public String bulkImportPlayers(@RequestParam("file") MultipartFile file, 
                                   RedirectAttributes redirectAttributes) {
        
        // Get current authenticated user
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        UserAccount user = userAccountRepository.findByUsername(username).orElse(null);
        
        if (user == null) {
            return "redirect:/login";
        }

        if (file.isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Please select a file to upload");
            return "redirect:/team";
        }

        // Check file size (10MB limit)
        if (file.getSize() > 10 * 1024 * 1024) {
            redirectAttributes.addFlashAttribute("error", "File size too large. Please use files under 10MB.");
            return "redirect:/team";
        }

        // Check file extension
        String fileName = file.getOriginalFilename();
        if (fileName == null || (!fileName.toLowerCase().endsWith(".xlsx") && !fileName.toLowerCase().endsWith(".xls"))) {
            redirectAttributes.addFlashAttribute("error", "Invalid file format. Please use .xlsx or .xls files only.");
            return "redirect:/team";
        }

        try {
            List<Player> playersToAdd = parseExcelFile(file, user.getId());
            
            if (playersToAdd.isEmpty()) {
                redirectAttributes.addFlashAttribute("error", 
                    "No valid players found in the file. Please check the format and ensure required fields (Name, Position, MLB Team) are filled.");
                return "redirect:/team";
            }

            // Save all players
            playerRepository.saveAll(playersToAdd);
            
            redirectAttributes.addFlashAttribute("success", 
                "Successfully imported " + playersToAdd.size() + " players!");
            
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", 
                "Error processing file: " + e.getMessage() + ". Please check your file format and try again.");
        }
        
        return "redirect:/team";
    }
    
    private List<Player> parseExcelFile(MultipartFile file, Long ownerId) throws IOException {
        List<Player> players = new ArrayList<>();
        
        Workbook workbook = null;
        try {
            // Support both .xlsx and .xls files
            if (file.getOriginalFilename().endsWith(".xlsx")) {
                workbook = new XSSFWorkbook(file.getInputStream());
            } else if (file.getOriginalFilename().endsWith(".xls")) {
                workbook = new HSSFWorkbook(file.getInputStream());
            } else {
                throw new IllegalArgumentException("Unsupported file format. Please use .xlsx or .xls files.");
            }
            
            Sheet sheet = workbook.getSheetAt(0); // Get first sheet
            
            // Skip header row and process data rows
            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                if (row == null) continue;
                
                try {
                    Player player = parsePlayerFromRow(row, ownerId);
                    if (player != null) {
                        players.add(player);
                    }
                } catch (Exception e) {
                    // Log error for this row but continue processing others
                    System.err.println("Error processing row " + (i + 1) + ": " + e.getMessage());
                }
            }
            
        } finally {
            if (workbook != null) {
                workbook.close();
            }
        }
        
        return players;
    }
    
    private Player parsePlayerFromRow(Row row, Long ownerId) {
        // Expected columns: Name, Position, MLB Team, Contract Length, Contract Amount
        if (row.getLastCellNum() < 3) {
            return null; // Not enough columns for required fields
        }
        
        String name = getCellValueAsString(row.getCell(0));
        String position = getCellValueAsString(row.getCell(1));
        String team = getCellValueAsString(row.getCell(2));
        
        if (name.isEmpty() || position.isEmpty() || team.isEmpty()) {
            return null; // Required fields missing
        }
        
        // Validate position
        String[] validPositions = {"C", "1B", "2B", "3B", "SS", "OF", "DH", "SP", "RP"};
        boolean validPosition = false;
        for (String validPos : validPositions) {
            if (validPos.equalsIgnoreCase(position.trim())) {
                position = validPos; // Normalize case
                validPosition = true;
                break;
            }
        }
        if (!validPosition) {
            return null; // Invalid position
        }
        
        // Parse contract length
        Integer contractLength = null;
        if (row.getLastCellNum() > 3) {
            Cell contractLengthCell = row.getCell(3);
            if (contractLengthCell != null && contractLengthCell.getCellType() != CellType.BLANK) {
                if (contractLengthCell.getCellType() == CellType.NUMERIC) {
                    contractLength = (int) contractLengthCell.getNumericCellValue();
                } else {
                    String contractLengthStr = getCellValueAsString(contractLengthCell);
                    if (!contractLengthStr.isEmpty()) {
                        try {
                            contractLength = Integer.parseInt(contractLengthStr.trim());
                        } catch (NumberFormatException e) {
                            // Invalid contract length, skip this player
                            return null;
                        }
                    }
                }
            }
        }
        
        // Parse contract amount
        Double contractAmount = null;
        if (row.getLastCellNum() > 4) {
            Cell contractAmountCell = row.getCell(4);
            if (contractAmountCell != null && contractAmountCell.getCellType() != CellType.BLANK) {
                if (contractAmountCell.getCellType() == CellType.NUMERIC) {
                    contractAmount = contractAmountCell.getNumericCellValue();
                } else {
                    String contractAmountStr = getCellValueAsString(contractAmountCell);
                    if (!contractAmountStr.isEmpty()) {
                        try {
                            // Remove dollar signs and commas
                            contractAmountStr = contractAmountStr.replaceAll("[$,]", "").trim();
                            contractAmount = Double.parseDouble(contractAmountStr);
                        } catch (NumberFormatException e) {
                            // Invalid contract amount, skip this player
                            return null;
                        }
                    }
                }
            }
        }
        
        return new Player(name, position, team, contractLength, contractAmount, ownerId);
    }
    
    private String getCellValueAsString(Cell cell) {
        if (cell == null) return "";
        
        switch (cell.getCellType()) {
            case STRING:
                return cell.getStringCellValue().trim();
            case NUMERIC:
                // Handle numbers that might be stored as numeric but should be strings
                return String.valueOf((long) cell.getNumericCellValue());
            case BOOLEAN:
                return String.valueOf(cell.getBooleanCellValue());
            case FORMULA:
                return cell.getCellFormula();
            default:
                return "";
        }
    }
    
    @GetMapping("/team/download-template")
    public ResponseEntity<byte[]> downloadTemplate() throws IOException {
        XSSFWorkbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("Players");
        
        // Create header row
        Row header = sheet.createRow(0);
        header.createCell(0).setCellValue("Name");
        header.createCell(1).setCellValue("Position");
        header.createCell(2).setCellValue("MLB Team");
        header.createCell(3).setCellValue("Contract Length");
        header.createCell(4).setCellValue("Contract Amount");
        
        // Create sample data rows
        Row sampleRow1 = sheet.createRow(1);
        sampleRow1.createCell(0).setCellValue("Mike Trout");
        sampleRow1.createCell(1).setCellValue("OF");
        sampleRow1.createCell(2).setCellValue("Los Angeles Angels");
        sampleRow1.createCell(3).setCellValue(10);
        sampleRow1.createCell(4).setCellValue(35000000);
        
        Row sampleRow2 = sheet.createRow(2);
        sampleRow2.createCell(0).setCellValue("John Doe");
        sampleRow2.createCell(1).setCellValue("C");
        sampleRow2.createCell(2).setCellValue("Boston Red Sox");
        sampleRow2.createCell(3).setCellValue(""); // Free agent
        sampleRow2.createCell(4).setCellValue(""); // Free agent
        
        // Auto-size columns
        for (int i = 0; i < 5; i++) {
            sheet.autoSizeColumn(i);
        }
        
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        workbook.write(outputStream);
        workbook.close();
        
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        headers.setContentDispositionFormData("attachment", "player_import_template.xlsx");
        
        return ResponseEntity.ok()
                .headers(headers)
                .body(outputStream.toByteArray());
    }
    
    @PostMapping("/team/release-players")
    public String releaseSelectedPlayers(@RequestParam("selectedPlayers") List<Long> selectedPlayerIds,
                                       RedirectAttributes redirectAttributes) {
        // Get current authenticated user
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        UserAccount user = userAccountRepository.findByUsername(username).orElse(null);
        
        if (user == null) {
            return "redirect:/login";
        }
        
        if (selectedPlayerIds == null || selectedPlayerIds.isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "No players selected for release.");
            return "redirect:/team";
        }
        
        try {
            // Verify ownership - only allow releasing players owned by the current user or if user is commissioner
            List<Player> playersToRelease = playerRepository.findAllById(selectedPlayerIds);
            boolean isCommissioner = "COMMISSIONER".equals(user.getRole());
            
            for (Player player : playersToRelease) {
                if (!isCommissioner && !user.getId().equals(player.getOwnerId())) {
                    redirectAttributes.addFlashAttribute("error", 
                        "You can only release your own players.");
                    return "redirect:/team";
                }
            }
            
            // Release the selected players
            playerRepository.releasePlayersToFreeAgency(selectedPlayerIds);
            
            String message = String.format("Successfully released %d player(s) to auction. They are now free agents available for bidding!", 
                selectedPlayerIds.size());
            redirectAttributes.addFlashAttribute("success", message);
            
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", 
                "Error releasing players: " + e.getMessage());
        }
        
        return "redirect:/team";
    }

    @PostMapping("/team/clear-all-contracts")
    public String clearAllContracts(RedirectAttributes redirectAttributes) {
        try {
            playerRepository.clearAllContracts();
            redirectAttributes.addFlashAttribute("success", 
                "All player contracts have been cleared. All players are now free agents available for auction!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", 
                "Error clearing contracts: " + e.getMessage());
        }
        
        return "redirect:/team";
    }
}