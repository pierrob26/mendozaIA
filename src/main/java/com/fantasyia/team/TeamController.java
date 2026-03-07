package com.fantasyia.team;

import com.fantasyia.auction.AuctionRepository;
import com.fantasyia.user.UserAccount;
import com.fantasyia.user.UserAccountRepository;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
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
    public String team(
            Model model,
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
        
        // Update salary and roster counts before displaying
        updateUserSalaryAndCounts(user);
        
        // Refresh user data after update
        user = userAccountRepository.findById(user.getId()).orElse(user);

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
    }

    @GetMapping("/team/export")
    public ResponseEntity<byte[]> exportPlayersToExcel() throws IOException {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        UserAccount user = userAccountRepository.findByUsername(username).orElse(null);

        if (user == null) {
            return ResponseEntity.badRequest().build();
        }

        List<Player> players = playerRepository.findByOwnerId(user.getId());

        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("My Players");

        Row headerRow = sheet.createRow(0);
        String[] headers = {"Name", "Position", "MLB Team", "Contract Length", "Contract Amount", "AAV", "Minor Leaguer", "Rookie", "At Bats", "Innings Pitched"};

        for (int i = 0; i < headers.length; i++) {
            Cell cell = headerRow.createCell(i);
            cell.setCellValue(headers[i]);

            CellStyle headerStyle = workbook.createCellStyle();
            Font font = workbook.createFont();
            font.setBold(true);
            headerStyle.setFont(font);
            cell.setCellStyle(headerStyle);
        }

        int rowNum = 1;
        for (Player player : players) {
            Row row = sheet.createRow(rowNum++);

            row.createCell(0).setCellValue(player.getName() != null ? player.getName() : "");
            row.createCell(1).setCellValue(player.getPosition() != null ? player.getPosition() : "");
            row.createCell(2).setCellValue(player.getTeam() != null ? player.getTeam() : "");
            row.createCell(3).setCellValue(player.getContractLength() != null ? player.getContractLength() : 0);
            row.createCell(4).setCellValue(player.getContractAmount() != null ? player.getContractAmount() : 0.0);
            row.createCell(5).setCellValue(player.getAverageAnnualSalary() != null ? player.getAverageAnnualSalary() : 0.0);
            row.createCell(6).setCellValue(player.getIsMinorLeaguer() != null ? player.getIsMinorLeaguer() : false);
            row.createCell(7).setCellValue(player.getIsRookie() != null ? player.getIsRookie() : false);
            row.createCell(8).setCellValue(player.getAtBats() != null ? player.getAtBats() : 0);
            row.createCell(9).setCellValue(player.getInningsPitched() != null ? player.getInningsPitched() : 0);
        }

        for (int i = 0; i < headers.length; i++) {
            sheet.autoSizeColumn(i);
        }

        ByteArrayOutputStream out = new ByteArrayOutputStream();
        workbook.write(out);
        workbook.close();

        String filename = user.getUsername() + "_players_" + LocalDateTime.now().toString().substring(0, 10) + ".xlsx";

        return ResponseEntity.ok()
                             .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
                             .contentType(MediaType.APPLICATION_OCTET_STREAM)
                             .body(out.toByteArray());
    }

    @GetMapping("/team/import")
    public String showImportPage(Model model) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        UserAccount user = userAccountRepository.findByUsername(username).orElse(null);

        if (user == null) {
            return "redirect:/login";
        }

        model.addAttribute("currentUser", user);
        return "import-players";
    }

    @PostMapping("/team/import")
    @Transactional
    public String importPlayersFromFile(
            @RequestParam("file") MultipartFile file,
            RedirectAttributes redirectAttributes) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        UserAccount user = userAccountRepository.findByUsername(username).orElse(null);

        if (user == null) {
            redirectAttributes.addFlashAttribute("error", "User not found");
            return "redirect:/login";
        }

        if (file.isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Please select a file to upload");
            return "redirect:/team/import";
        }

        try {
            String filename = file.getOriginalFilename();
            if (filename == null) {
                redirectAttributes.addFlashAttribute("error", "Invalid file");
                return "redirect:/team/import";
            }

            List<Player> playersToImport = new ArrayList<>();

            if (filename.toLowerCase().endsWith(".csv")) {
                playersToImport = parseCSVFile(file, user.getId());
            }
            else if (filename.toLowerCase().endsWith(".xlsx") || filename.toLowerCase().endsWith(".xls")) {
                playersToImport = parseExcelFile(file, user.getId());
            }
            else {
                redirectAttributes.addFlashAttribute("error", "Only CSV and Excel files are supported");
                return "redirect:/team/import";
            }

            int importedCount = 0;
            int skippedCount = 0;

            for (Player player : playersToImport) {
                List<Player> existingPlayers = playerRepository.findByNameIgnoreCaseExcludingEmptySlots(player.getName());
                boolean playerExists = existingPlayers.stream()
                                                      .anyMatch(p -> p.getOwnerId() != null && p.getOwnerId().equals(user.getId()));

                if (!playerExists) {
                    playerRepository.save(player);
                    importedCount++;
                }
                else {
                    skippedCount++;
                }
            }
            
            // Update user salary and roster counts after import
            if (importedCount > 0) {
                updateUserSalaryAndCounts(user);
            }

            if (importedCount > 0) {
                redirectAttributes.addFlashAttribute(
                        "success",
                        "Successfully imported " + importedCount + " players" +
                                (skippedCount > 0 ? " (skipped " + skippedCount + " duplicates)" : ""));
            }
            else if (skippedCount > 0) {
                redirectAttributes.addFlashAttribute("warning", "All " + skippedCount + " players were duplicates and skipped");
            }
            else {
                redirectAttributes.addFlashAttribute("error", "No players were imported");
            }

        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", "Error importing file: " + e.getMessage());
        }

        return "redirect:/team";
    }

    private List<Player> parseCSVFile(MultipartFile file, Long ownerId) throws IOException {
        List<Player> players = new ArrayList<>();

        try (InputStream inputStream = file.getInputStream()) {
            String content = new String(inputStream.readAllBytes());
            String[] lines = content.split("\n");

            for (int i = 1; i < lines.length; i++) {
                String line = lines[i].trim();
                if (!line.isEmpty()) {
                    String[] fields = line.split(",");

                    if (fields.length >= 5) {
                        Player player = new Player();
                        player.setName(fields[0].trim().replace("\"", ""));
                        player.setPosition(fields[1].trim().replace("\"", ""));
                        player.setTeam(fields[2].trim().replace("\"", ""));

                        try {
                            player.setContractLength(Integer.parseInt(fields[3].trim()));
                        } catch (NumberFormatException e) {
                            player.setContractLength(1);
                        }

                        try {
                            player.setContractAmount(Double.parseDouble(fields[4].trim()));
                            player.setAverageAnnualSalary(player.getContractAmount() / player.getContractLength());
                        } catch (NumberFormatException e) {
                            player.setContractAmount(0.0);
                            player.setAverageAnnualSalary(0.0);
                        }

                        player.setOwnerId(ownerId);
                        player.setIsMinorLeaguer(false);
                        player.setIsRookie(false);
                        players.add(player);
                    }
                }
            }
        }

        return players;
    }

    private List<Player> parseExcelFile(MultipartFile file, Long ownerId) throws IOException {
        List<Player> players = new ArrayList<>();

        try (InputStream inputStream = file.getInputStream();
             Workbook workbook = WorkbookFactory.create(inputStream)) {

            Sheet sheet = workbook.getSheetAt(0);

            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                if (row != null) {
                    Player player = new Player();

                    Cell nameCell = row.getCell(0);
                    if (nameCell != null) {
                        player.setName(getCellValueAsString(nameCell));
                    }

                    Cell positionCell = row.getCell(1);
                    if (positionCell != null) {
                        player.setPosition(getCellValueAsString(positionCell));
                    }

                    Cell teamCell = row.getCell(2);
                    if (teamCell != null) {
                        player.setTeam(getCellValueAsString(teamCell));
                    }

                    Cell contractLengthCell = row.getCell(3);
                    if (contractLengthCell != null) {
                        try {
                            player.setContractLength((int) contractLengthCell.getNumericCellValue());
                        } catch (Exception e) {
                            player.setContractLength(1);
                        }
                    }

                    Cell contractAmountCell = row.getCell(4);
                    if (contractAmountCell != null) {
                        try {
                            double amount = contractAmountCell.getNumericCellValue();
                            player.setContractAmount(amount);
                            if (player.getContractLength() != null && player.getContractLength() > 0) {
                                player.setAverageAnnualSalary(amount / player.getContractLength());
                            }
                        } catch (Exception e) {
                            player.setContractAmount(0.0);
                            player.setAverageAnnualSalary(0.0);
                        }
                    }

                    player.setOwnerId(ownerId);
                    player.setIsMinorLeaguer(false);
                    player.setIsRookie(false);

                    if (player.getName() != null && !player.getName().trim().isEmpty()) {
                        players.add(player);
                    }
                }
            }
        }

        return players;
    }

    private String getCellValueAsString(Cell cell) {
        if (cell == null) {
            return "";
        }

        switch (cell.getCellType()) {
            case STRING:
                return cell.getStringCellValue().trim();
            case NUMERIC:
                if (DateUtil.isCellDateFormatted(cell)) {
                    return cell.getDateCellValue().toString();
                }
                else {
                    return String.valueOf((long) cell.getNumericCellValue());
                }
            case BOOLEAN:
                return String.valueOf(cell.getBooleanCellValue());
            case FORMULA:
                return cell.getCellFormula();
            default:
                return "";
        }
    }

    @GetMapping("/sample_players.csv")
    public ResponseEntity<byte[]> downloadSampleCSV() {
        String csvContent = """
                Name,Position,MLB Team,Contract Length,Contract Amount
                Mike Trout,OF,Los Angeles Angels,10,35000000
                Aaron Judge,OF,New York Yankees,9,40000000
                Mookie Betts,OF,Los Angeles Dodgers,12,30000000
                Ronald Acuna Jr.,OF,Atlanta Braves,8,17000000
                Vladimir Guerrero Jr.,1B,Toronto Blue Jays,5,19500000
                Fernando Tatis Jr.,SS,San Diego Padres,14,28000000
                Juan Soto,OF,Washington Nationals,2,31000000
                Jacob deGrom,SP,Texas Rangers,5,37000000
                Gerrit Cole,SP,New York Yankees,9,36000000
                Shohei Ohtani,DH,Los Angeles Angels,1,30000000
                Francisco Lindor,SS,New York Mets,10,34100000
                Manny Machado,3B,San Diego Padres,11,30000000
                """;

        return ResponseEntity.ok()
                             .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"sample_players.csv\"")
                             .contentType(MediaType.TEXT_PLAIN)
                             .body(csvContent.getBytes());
    }

    @GetMapping("/team/clear-filters")
    public String clearFilters() {
        return "redirect:/team";
    }

    @PostMapping("/team/release-player")
    @Transactional
    public String releasePlayer(@RequestParam Long playerId, RedirectAttributes redirectAttributes) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        UserAccount user = userAccountRepository.findByUsername(username).orElse(null);
        
        if (user == null) {
            redirectAttributes.addFlashAttribute("error", "User not authenticated");
            return "redirect:/login";
        }
        
        Player player = playerRepository.findById(playerId).orElse(null);
        if (player == null || !user.getId().equals(player.getOwnerId())) {
            redirectAttributes.addFlashAttribute("error", "Player not found or not owned by you");
            return "redirect:/team";
        }
        
        try {
            // Create released player record
            ReleasedPlayer releasedPlayer = new ReleasedPlayer();
            releasedPlayer.setPlayerName(player.getName());
            releasedPlayer.setPosition(player.getPosition());
            releasedPlayer.setMlbTeam(player.getTeam());
            releasedPlayer.setPreviousContractLength(player.getContractLength());
            releasedPlayer.setPreviousContractAmount(player.getContractAmount());
            releasedPlayer.setPreviousOwnerId(user.getId());
            releasedPlayer.setStatus("PENDING");
            releasedPlayer.setReleasedAt(LocalDateTime.now());
            
            releasedPlayerRepository.save(releasedPlayer);
            
            // Release the player (clear ownership)
            player.setOwnerId(null);
            player.setContractLength(0);
            player.setContractAmount(0.0);
            player.setAverageAnnualSalary(0.0);
            playerRepository.save(player);
            
            // Update user salary and roster counts
            updateUserSalaryAndCounts(user);
            
            redirectAttributes.addFlashAttribute("success", 
                "Player " + player.getName() + " has been released and is pending commissioner approval");
                
        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", "Error releasing player: " + e.getMessage());
        }
        
        return "redirect:/team";
    }
    
    @PostMapping("/team/remove/{playerId}")
    @Transactional
    public String removePlayer(@PathVariable Long playerId, RedirectAttributes redirectAttributes) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        UserAccount user = userAccountRepository.findByUsername(username).orElse(null);
        
        if (user == null) {
            redirectAttributes.addFlashAttribute("error", "User not authenticated");
            return "redirect:/login";
        }
        
        Player player = playerRepository.findById(playerId).orElse(null);
        if (player == null || !user.getId().equals(player.getOwnerId())) {
            redirectAttributes.addFlashAttribute("error", "Player not found or not owned by you");
            return "redirect:/team";
        }
        
        try {
            // Remove player completely (for commissioners or testing)
            String playerName = player.getName();
            playerRepository.delete(player);
            
            // Update user salary and roster counts
            updateUserSalaryAndCounts(user);
            
            redirectAttributes.addFlashAttribute("success", 
                "Player " + playerName + " has been removed from the database");
                
        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", "Error removing player: " + e.getMessage());
        }
        
        return "redirect:/team";
    }
    
    private void updateUserSalaryAndCounts(UserAccount user) {
        List<Player> userPlayers = playerRepository.findByOwnerId(user.getId());
        
        double totalSalary = userPlayers.stream()
            .filter(p -> p.getAverageAnnualSalary() != null)
            .mapToDouble(Player::getAverageAnnualSalary)
            .sum();
            
        int majorLeagueCount = (int) userPlayers.stream()
            .filter(p -> p.getIsMinorLeaguer() != null && !p.getIsMinorLeaguer())
            .count();
            
        int minorLeagueCount = (int) userPlayers.stream()
            .filter(p -> p.getIsMinorLeaguer() != null && p.getIsMinorLeaguer())
            .count();
        
        user.setCurrentSalaryUsed(totalSalary / 1000000.0); // Convert to millions
        user.setMajorLeagueRosterCount(majorLeagueCount);
        user.setMinorLeagueRosterCount(minorLeagueCount);
        
        userAccountRepository.save(user);
    }
}
