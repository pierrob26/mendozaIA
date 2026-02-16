# Filler Players Feature

## Overview
When players are released from a team, they are replaced with generic "filler" players instead of being removed. This maintains roster structure and provides clear visual feedback about available roster slots.

## Implementation Date
February 16, 2026

## How It Works

### Release Process
1. User selects players to release using checkboxes
2. Clicks "Release Selected Players" button
3. Confirms the action in a dialog box
4. Backend processes the release:
   - Validates user authentication and ownership
   - For each selected player:
     - Changes name to "Empty [Position] Slot"
     - Sets MLB team to "Free Agent"
     - Clears contract fields (sets to null)
     - **Keeps the owner ID** (slot remains with the user)
   - Saves the modified player records
5. User sees success message and modified roster

### Filler Player Format

**Original Player:**
- Name: "Mike Trout"
- Position: "OF"
- Team: "Los Angeles Angels"
- Contract Length: 10 years
- Contract Amount: $35,000,000

**After Release (Filler Player):**
- Name: "Empty OF Slot"
- Position: "OF" (unchanged)
- Team: "Free Agent"
- Contract Length: None
- Contract Amount: None
- Owner: Same user (unchanged)

### Filler Player Examples
- `Empty C Slot` - Catcher position
- `Empty 1B Slot` - First Base position
- `Empty 2B Slot` - Second Base position
- `Empty 3B Slot` - Third Base position
- `Empty SS Slot` - Shortstop position
- `Empty OF Slot` - Outfield position
- `Empty DH Slot` - Designated Hitter position
- `Empty SP Slot` - Starting Pitcher position
- `Empty RP Slot` - Relief Pitcher position

## Benefits

### 1. Roster Structure Preservation
- Team always maintains the same number of roster entries
- No confusion about "disappearing" players
- Roster doesn't visually shrink

### 2. Clear Visual Feedback
- "Empty [Position] Slot" name clearly indicates an available position
- Easy to identify which positions need to be filled
- Distinguishable from actual players at a glance

### 3. Simplified Management
- Users can see all roster slots at once
- No need to track how many players were removed
- Easier to plan roster additions

### 4. Database Integrity
- No deletion of player records
- Maintains referential integrity
- Preserves historical data structure

### 5. User Experience
- Predictable behavior (slots don't disappear)
- Clear indication of available roster spots
- Reduced confusion

## User Interface

### Release Section
```
┌─────────────────────────────────────────────────────────┐
│ Release Players                                         │
│                                                         │
│ Select players from your roster to release them.       │
│ They will be replaced with empty roster slots.         │
│                                                         │
│ [📤 Release Selected Players (2)] [Select All] [Clear All] │
│                                                         │
│ 💡 Tip: Released players will be replaced with generic │
│    "Empty [Position] Slot" placeholders with no contract. │
└─────────────────────────────────────────────────────────┘
```

### Confirmation Dialog
```
Are you sure you want to release 2 player(s)?

Players to be released:
Mike Trout
Aaron Judge

They will be replaced with empty roster slots 
(e.g., "Empty C Slot", "Empty OF Slot").

[Cancel] [OK]
```

### Success Message
```
✓ Successfully released 2 player(s). They have been 
  replaced with empty roster slots.
```

## Roster View Example

### Before Release:
| Name        | Position | MLB Team           | Contract Length | Contract Amount |
|-------------|----------|--------------------|-----------------|-----------------|
| Mike Trout  | OF       | Los Angeles Angels | 10 years        | $35,000,000     |
| Aaron Judge | OF       | New York Yankees   | 9 years         | $40,000,000     |
| Shohei Ohtani | DH     | Los Angeles Dodgers| 10 years        | $70,000,000     |

### After Releasing Mike Trout and Aaron Judge:
| Name          | Position | MLB Team    | Contract Length | Contract Amount |
|---------------|----------|-------------|-----------------|-----------------|
| Empty OF Slot | OF       | Free Agent  | None            | None            |
| Empty OF Slot | OF       | Free Agent  | None            | None            |
| Shohei Ohtani | DH       | Los Angeles Dodgers | 10 years | $70,000,000     |

## Technical Details

### Code Location
- **Controller**: `src/main/java/com/fantasyia/team/TeamController.java`
  - Method: `releaseSelectedPlayers()` (lines ~397-465)
- **Template**: `src/main/resources/templates/team.html`
  - JavaScript: `releaseSelectedPlayers()` function (lines ~141-174)
  - UI Section: Release players section (lines ~235-270)

### Database Changes
- Player record is **updated**, not deleted
- Fields modified:
  - `name`: Changed to "Empty [Position] Slot"
  - `team`: Changed to "Free Agent"
  - `contract_length`: Set to NULL
  - `contract_amount`: Set to NULL
- Fields preserved:
  - `id`: Unchanged
  - `position`: Unchanged
  - `owner_id`: Unchanged (keeps ownership)

### Security
- Users can only release their own players
- Commissioners can release any player
- Ownership validation performed before release
- CSRF protection disabled (for testing)

## Future Enhancements

### Potential Improvements:
1. **Automatic Cleanup**: Option to auto-delete filler players when adding new players
2. **Bulk Replacement**: Allow replacing multiple filler slots at once
3. **Custom Naming**: Let users customize filler player names
4. **Position Filtering**: Filter roster view to show only filler players
5. **Statistics Tracking**: Track how many players have been released/replaced
6. **Auction Integration**: Automatically add released players to auction (future phase)

## Related Features
- **Add Player**: Users can manually add players to replace filler slots
- **Bulk Import**: Users can import players via Excel to replace multiple fillers
- **Team View Filters**: Filter by position to find specific filler slots

## Testing

### Manual Test Procedure:
1. Log in to the application
2. Navigate to "My Team" page
3. Select one or more players
4. Click "Release Selected Players"
5. Confirm the action
6. Verify:
   - Success message appears
   - Players are replaced with "Empty [Position] Slot"
   - Contract fields show "None"
   - Team shows "Free Agent"
   - Total roster count unchanged

### Expected Log Output:
```
=== RELEASE PLAYERS CALLED ===
Selected IDs: [1, 2]
User: testuser (ID: 1)
Releasing 2 players...
Replaced: Mike Trout -> Empty OF Slot
Replaced: Aaron Judge -> Empty OF Slot
=== RELEASE COMPLETED ===
```

## Notes
- This feature was implemented to address the issue where released players were disappearing from rosters
- The filler player approach provides better UX and maintains roster structure
- Auction integration is planned for a future release
- Filler players can be identified by their "Empty X Slot" naming convention
