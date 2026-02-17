# Released Players Queue Feature

## Overview
This feature implements a commissioner-controlled queue system for managing players that have been released by their owners. When players are released, they are added to a queue that only commissioners can access, allowing them to review and approve players before adding them to the auction.

## How It Works

### 1. Player Release Process
When a team owner releases players:
- The selected players are added to the "Released Players Queue" 
- The player information is preserved (name, position, MLB team, previous contract details)
- The roster slot is replaced with an "Empty [Position] Slot" filler player
- The owner's roster remains the same size

### 2. Commissioner Queue Management
Commissioners can view the queue at `/auction/manage`:
- All pending released players are displayed in a highlighted yellow section
- Each entry shows:
  - Player name, position, and MLB team
  - Release date/time
  - Previous contract details (if any)
- A notification badge appears on the home page showing the count of pending players

### 3. Commissioner Actions
For each player in the queue, commissioners can:

#### Add to Auction
- Set a starting bid amount (default $1)
- Creates a new free agent player in the database
- Adds the player to the active auction
- Marks the queue entry as "ADDED_TO_AUCTION"

#### Reject
- Removes the player from the queue without adding to auction
- Marks the queue entry as "REJECTED"
- Player is permanently removed from the system

## Database Schema

### Table: `released_players_queue`
```sql
CREATE TABLE released_players_queue (
    id BIGSERIAL PRIMARY KEY,
    player_name VARCHAR(255) NOT NULL,
    position VARCHAR(255) NOT NULL,
    mlb_team VARCHAR(255) NOT NULL,
    previous_contract_length INTEGER,
    previous_contract_amount DOUBLE PRECISION,
    previous_owner_id BIGINT,
    released_at TIMESTAMP NOT NULL,
    status VARCHAR(255) NOT NULL  -- 'PENDING', 'ADDED_TO_AUCTION', 'REJECTED'
);
```

## API Endpoints

### POST /team/release-players
**Description**: Release selected players to the commissioner queue  
**Access**: Team owners (for their own players) or Commissioners  
**Parameters**:
- `selectedPlayers`: List of player IDs to release

**Success Response**: 
```
"Successfully released X player(s). They have been added to the commissioner queue for auction review."
```

### POST /auction/add-released-player
**Description**: Add a released player from the queue to the auction  
**Access**: Commissioners only  
**Parameters**:
- `releasedPlayerId`: ID of the released player in the queue
- `startingBid`: Starting bid amount for the auction (default: 1.0)

**Success Response**: 
```
"Player [Name] added to auction with starting bid $X"
```

### POST /auction/reject-released-player
**Description**: Reject a released player and remove from queue  
**Access**: Commissioners only  
**Parameters**:
- `releasedPlayerId`: ID of the released player in the queue

**Success Response**: 
```
"Player [Name] rejected from auction queue"
```

## Status Values

### Released Player Status
- **PENDING**: Player is waiting for commissioner review
- **ADDED_TO_AUCTION**: Player was approved and added to auction
- **REJECTED**: Player was rejected by commissioner

## User Interface

### Home Page (Commissioner View)
- Badge notification showing count of pending released players
- Visual indicator on "Manage Auction" button
- Alert message when players are pending

### Auction Management Page
- "Released Players Queue" section with yellow highlight
- Displays when there are pending players
- Shows player details and previous contract info
- Inline forms for each player with:
  - Starting bid input field
  - "Add to Auction" button (green)
  - "Reject" button (red)

### Team Page
- Release players functionality continues to work as before
- Updated success message mentions commissioner queue

## Benefits

1. **Quality Control**: Commissioners can review releases before they hit the auction
2. **Fraud Prevention**: Prevents accidental or strategic dumps of players
3. **Fair Play**: Ensures all players entering auction are appropriate
4. **Audit Trail**: Maintains history of all player releases
5. **Flexibility**: Commissioners can reject inappropriate releases

## Example Workflow

1. **Owner releases players**:
   ```
   User "Team1" selects 3 players and clicks "Release Selected Players"
   → Players added to queue with status "PENDING"
   → Owner's roster shows "Empty [Position] Slot" for each
   ```

2. **Commissioner notification**:
   ```
   Commissioner sees badge with "3" on home page
   → Clicks "Manage Auction"
   → Sees yellow section with 3 pending players
   ```

3. **Commissioner reviews**:
   ```
   Player 1: Mike Trout (OF, Angels) - Add to auction for $50
   Player 2: Joe Random (C, Free Agent) - Reject (not suitable)
   Player 3: Juan Soto (OF, Padres) - Add to auction for $40
   ```

4. **Result**:
   ```
   → Mike Trout and Juan Soto appear in active auction
   → Joe Random is removed from system
   → Queue is clear
   ```

## Files Modified/Created

### New Files
- `src/main/java/com/fantasyia/team/ReleasedPlayer.java` - Entity for queue
- `src/main/java/com/fantasyia/team/ReleasedPlayerRepository.java` - Repository

### Modified Files
- `src/main/java/com/fantasyia/team/TeamController.java` - Updated release logic
- `src/main/java/com/fantasyia/auction/AuctionController.java` - Added queue endpoints
- `src/main/java/com/fantasyia/controller/HomeController.java` - Added notification
- `src/main/resources/templates/home.html` - Added badge
- `src/main/resources/templates/auction-manage.html` - Added queue section

## Testing Checklist

- [ ] Release players as regular owner
- [ ] Verify players appear in commissioner queue
- [ ] Verify notification badge appears on home page
- [ ] Add player from queue to auction with custom starting bid
- [ ] Verify player appears in auction as free agent
- [ ] Reject player from queue
- [ ] Verify rejected player doesn't appear in auction
- [ ] Verify only commissioners can access queue
- [ ] Verify queue persists across server restarts
- [ ] Test with multiple commissioners
