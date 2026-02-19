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
import java.util.List;

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
                           @RequestParam(required = false) Integer contractLength,
                           @RequestParam(required = false) Double contractAmount,
                           RedirectAttributes redirectAttributes) {
        
        // Get current authenticated user
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        UserAccount user = userAccountRepository.findByUsername(username).orElse(null);
        
        if (user == null) {
            return "redirect:/login";
        }

        // Validate required fields
        if (name == null || name.trim().isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Player name is required");
            return "redirect:/team";
        }
        
        if (position == null || position.trim().isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Player position is required");
            return "redirect:/team";
        }
        
        if (team == null || team.trim().isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "MLB team is required");
            return "redirect:/team";
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
            redirectAttributes.addFlashAttribute("error", "Invalid position. Valid positions: C, 1B, 2B, 3B, SS, OF, DH, SP, RP");
            return "redirect:/team";
        }

        Integer finalContractLength = (contractLength != null && contractLength > 0) ? contractLength : 0;
        Double finalContractAmount = (contractAmount != null && contractAmount > 0) ? contractAmount : 0.0;
        
        try {
            Player player = new Player(name.trim(), position, team.trim(), finalContractLength, finalContractAmount, user.getId());
            
            // Calculate Average Annual Salary for salary cap purposes
            if (finalContractLength > 0 && finalContractAmount > 0) {
                player.setAverageAnnualSalary(finalContractAmount / finalContractLength);
            } else {
                player.setAverageAnnualSalary(0.0);
            }
            
            playerRepository.save(player);
            redirectAttributes.addFlashAttribute("success", "Player " + name.trim() + " added successfully!");
            
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Error adding player: " + e.getMessage());
        }
        
        return "redirect:/team";
    }

    @PostMapping("/team/bulk-import")
    public String bulkImportPlayers(@RequestParam("file") MultipartFile file, 
                                   RedirectAttributes redirectAttributes) {
        

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

            if (file.getOriginalFilename().endsWith(".xlsx")) {
                workbook = new XSSFWorkbook(file.getInputStream());
            } else if (file.getOriginalFilename().endsWith(".xls")) {
                workbook = new HSSFWorkbook(file.getInputStream());
            } else {
                throw new IllegalArgumentException("Unsupported file format. Please use .xlsx or .xls files.");
            }
            Sheet sheet = workbook.getSheetAt(0);
            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                if (row == null) continue;
                
                try {
                    Player player = parsePlayerFromRow(row, ownerId);
                    if (player != null) {
                        players.add(player);
                    }
                } catch (Exception e) {
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
        if (row.getLastCellNum() < 3) {
            return null;
        }
        
        String name = getCellValueAsString(row.getCell(0));
        String position = getCellValueAsString(row.getCell(1));
        String team = getCellValueAsString(row.getCell(2));
        
        if (name.isEmpty() || position.isEmpty() || team.isEmpty()) {
            return null;
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
        Integer contractLength = 0; // Default to 0 instead of null
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
                            return null;
                        }
                    }
                }
            }
        }

        Double contractAmount = 0.0;
        if (row.getLastCellNum() > 4) {
            Cell contractAmountCell = row.getCell(4);
            if (contractAmountCell != null && contractAmountCell.getCellType() != CellType.BLANK) {
                if (contractAmountCell.getCellType() == CellType.NUMERIC) {
                    contractAmount = contractAmountCell.getNumericCellValue();
                } else {
                    String contractAmountStr = getCellValueAsString(contractAmountCell);
                    if (!contractAmountStr.isEmpty()) {
                        try {
                            contractAmountStr = contractAmountStr.replaceAll("[$,]", "").trim();
                            contractAmount = Double.parseDouble(contractAmountStr);
                        } catch (NumberFormatException e) {
                            return null;
                        }
                    }
                }
            }
        }
        
        Player player = new Player(name, position, team, contractLength, contractAmount, ownerId);
        
        // Calculate Average Annual Salary for salary cap purposes
        if (contractLength > 0 && contractAmount > 0) {
            player.setAverageAnnualSalary(contractAmount / contractLength);
        } else {
            player.setAverageAnnualSalary(0.0);
        }
        
        return player;
    }
    
    private String getCellValueAsString(Cell cell) {
        if (cell == null) return "";
        
        switch (cell.getCellType()) {
            case STRING:
                return cell.getStringCellValue().trim();
            case NUMERIC:
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
        Row header = sheet.createRow(0);
        header.createCell(0).setCellValue("Name");
        header.createCell(1).setCellValue("Position");
        header.createCell(2).setCellValue("MLB Team");
        header.createCell(3).setCellValue("Contract Length");
        header.createCell(4).setCellValue("Contract Amount");
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
    private int addPlayersToAuction(List<Player> playersToAdd) {
        try {
            Auction mainAuction = getOrCreateMainAuction();
            if (mainAuction == null) {
                return 0;
            }
            
            int addedCount = 0;
            for (Player player : playersToAdd) {
                AuctionItem existingItem = auctionItemRepository.findByPlayerIdAndStatus(player.getId(), "ACTIVE");
                if (existingItem == null) {
                    // Set starting bid based on player type: $500K for MLB, $100K for minors
                    double startingBid = (player.getIsMinorLeaguer() || player.getIsRookie()) ? 0.1 : 0.5;
                    AuctionItem auctionItem = new AuctionItem(player.getId(), mainAuction.getId(), startingBid);
                    auctionItemRepository.save(auctionItem);
                    addedCount++;
                }
            }
            
            return addedCount;
        } catch (Exception e) {
            System.err.println("Error adding players to auction: " + e.getMessage());
            return 0;
        }
    }
    private Auction getOrCreateMainAuction() {
        try {
            List<Auction> activeAuctions = auctionRepository.findByStatus("ACTIVE");
            if (!activeAuctions.isEmpty()) {
                return activeAuctions.get(0);
            }
            
            // Create new main auction if none exists
            Auction mainAuction = new Auction();
            mainAuction.setName("Main Player Auction");
            mainAuction.setDescription("Always-running player auction. Players are available for bidding with minimum 24-hour periods after first bid.");
            mainAuction.setStartTime(LocalDateTime.now());
            mainAuction.setEndTime(LocalDateTime.now().plusYears(1));
            mainAuction.setCreatedByCommissionerId(1L); // Default to admin user
            mainAuction.setStatus("ACTIVE");
            mainAuction.setAuctionType("IN_SEASON"); // Default type
            
            return auctionRepository.save(mainAuction);
        } catch (Exception e) {
            System.err.println("Error creating/getting main auction: " + e.getMessage());
            return null;
        }
    }
    
    @PostMapping("/team/release-players")
    public String releaseSelectedPlayers(@RequestParam(value = "selectedPlayers", required = false) List<Long> selectedPlayerIds,
                                       RedirectAttributes redirectAttributes) {
        System.out.println("=== RELEASE PLAYERS CALLED ===");
        System.out.println("Selected IDs: " + selectedPlayerIds);
        if (selectedPlayerIds == null || selectedPlayerIds.isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "No players selected for release.");
            return "redirect:/team";
        }
        
        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            String username = auth.getName();
            UserAccount user = userAccountRepository.findByUsername(username).orElse(null);
            
            if (user == null) {
                return "redirect:/login";
            }
            
            System.out.println("User: " + username + " (ID: " + user.getId() + ")");
            List<Player> playersToRelease = playerRepository.findAllById(selectedPlayerIds);
            boolean isCommissioner = "COMMISSIONER".equals(user.getRole());
            
            for (Player player : playersToRelease) {
                if (!isCommissioner && !user.getId().equals(player.getOwnerId())) {
                    redirectAttributes.addFlashAttribute("error", "You can only release your own players.");
                    return "redirect:/team";
                }
            }
            
            System.out.println("Releasing " + playersToRelease.size() + " players...");
            int queuedCount = 0;
            double releasedSalary = 0.0;
            
            for (Player player : playersToRelease) {
                String position = player.getPosition();
                String originalName = player.getName();
                
                // Track released salary for cap adjustment
                if (player.getAverageAnnualSalary() != null) {
                    releasedSalary += player.getAverageAnnualSalary();
                }
                
                ReleasedPlayer releasedPlayer = new ReleasedPlayer(
                    originalName,
                    player.getPosition(),
                    player.getTeam(),
                    player.getContractLength(),
                    player.getContractAmount(),
                    player.getOwnerId()
                );
                releasedPlayerRepository.save(releasedPlayer);
                
                // Replace with generic filler player
                player.setName("Empty " + position + " Slot");
                player.setTeam("Free Agent");
                player.setContractLength(0);
                player.setContractAmount(0.0);
                player.setAverageAnnualSalary(0.0);
                // Keep the ownerId so the slot stays with the user
                
                playerRepository.save(player);
                queuedCount++;
                System.out.println("Released to queue: " + originalName + " -> replaced with " + player.getName());
            }
            
            // Update user's salary cap usage
            if (releasedSalary > 0) {
                double currentSalary = user.getCurrentSalaryUsed() != null ? user.getCurrentSalaryUsed() : 0.0;
                user.setCurrentSalaryUsed(Math.max(0.0, currentSalary - releasedSalary));
                userAccountRepository.save(user);
            }
            
            redirectAttributes.addFlashAttribute("success", 
                "Successfully released " + queuedCount + " player(s). They have been added to the commissioner queue for auction review.");
            System.out.println("=== RELEASE COMPLETED ===");
            
        } catch (Exception e) {
            System.err.println("=== ERROR ===");
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", "Error releasing players: " + e.getMessage());
        }
        
        return "redirect:/team";
    }

}