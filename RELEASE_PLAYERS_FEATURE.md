# Release Players to Auction Feature

## Overview
The clear contracts button has been completely reworked into a selective player release system that allows users to choose specific players to release to the auction, rather than clearing all contracts in the system.

## New Functionality

### For Regular Users:
- **Select Individual Players**: Checkboxes next to each player in the roster
- **Bulk Selection**: "Select All" and "Clear All" buttons for convenience
- **Smart Release Button**: Shows count of selected players and is only enabled when players are selected
- **Confirmation Dialog**: Lists all players to be released before confirmation
- **Ownership Validation**: Users can only release their own players

### For Commissioners:
- **All Regular Features**: Same player selection and release functionality
- **Override Ownership**: Can release any player from any team
- **Emergency Reset**: Access to the old "Clear All Contracts" function as a separate commissioner-only feature

## User Interface Changes

### Player Table:
- Added checkbox column with "Select All" functionality
- Interactive selection with visual feedback
- Updated colspan for empty state message

### Release Section:
- Clean, user-friendly design with blue theme (vs. warning yellow)
- Real-time counter showing selected players
- Helper buttons for bulk selection/deselection
- Informative tip about what happens to released players

### Commissioner Section:
- Separate section only visible to commissioners
- Maintains the original "Clear All Contracts" functionality
- Clear warning styling (yellow/red theme)
- Labeled as "Emergency Reset" to indicate its severity

## Backend Implementation

### New Repository Method:
```java
@Modifying
@Transactional
@Query("UPDATE Player p SET p.contractLength = null, p.contractAmount = null, p.ownerId = null WHERE p.id IN :playerIds")
void releasePlayersToFreeAgency(@Param("playerIds") List<Long> playerIds);
```

### New Controller Method:
```java
@PostMapping("/team/release-players")
public String releaseSelectedPlayers(@RequestParam("selectedPlayers") List<Long> selectedPlayerIds, ...)
```

### Security Features:
- **Ownership Verification**: Non-commissioners can only release their own players
- **Commissioner Override**: Commissioners can release any player
- **Input Validation**: Ensures selected player IDs are valid and owned by the user
- **Error Handling**: Comprehensive error messages for various scenarios

## JavaScript Functionality

### Selection Management:
- `toggleAllPlayers()`: Handles select all/none functionality
- `updateReleaseButton()`: Updates button state and counter
- `selectAllOwnedPlayers()` & `clearAllSelections()`: Bulk selection helpers

### User Experience:
- Real-time visual feedback for button states
- Detailed confirmation dialog showing player names
- Disabled states when no players selected
- Auto-updates selection counter

## How It Works

1. **Player Selection**: Users check boxes next to players they want to release
2. **Visual Feedback**: Release button updates with count and enabled state
3. **Confirmation**: Detailed dialog shows exactly which players will be released
4. **Backend Processing**: Selected players have contracts cleared and ownership removed
5. **Auction Availability**: Released players immediately become free agents available for auction
6. **Success Feedback**: Confirmation message with count of released players

## Benefits Over Previous System

### More Granular Control:
- Release specific players instead of everyone
- Maintain roster while releasing unwanted players
- Strategic team management

### Better User Experience:
- Visual selection with checkboxes
- Clear confirmation of actions
- Helpful guidance and tips

### Enhanced Security:
- Users can only affect their own players (unless commissioner)
- Separate emergency function for commissioners only
- Clear distinction between regular and administrative actions

### Auction Integration:
- Released players immediately available for auction
- Seamless integration with the auction system
- No need to manually add released players to auction

## Usage Examples

### Regular User Workflow:
1. Go to "My Team" page
2. Use checkboxes to select unwanted players
3. Click "Release Selected Players (X)" button
4. Confirm in the dialog box
5. Players are immediately available in the auction

### Commissioner Workflow:
1. Same as regular user for selective releases
2. Additionally has access to "Clear All Contracts (Emergency Reset)"
3. Can release players from any team
4. Use emergency reset only for league resets/special situations

This new system provides much more flexibility and control while maintaining the ability for league-wide resets when needed by commissioners.