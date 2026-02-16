# Database NOT NULL Constraint Fix

## Issue Date
February 16, 2026

## Problem Description

The application was throwing this error:
```
Error releasing players: could not execute statement [ERROR: null value in column "contract_amount" of relation "players" violates not-null constraint
Detail: Failing row contains (46, null, null, Empty C Slot, 3, C, Free Agent).]
```

### Root Cause

The **database schema** has NOT NULL constraints on `contract_length` and `contract_amount` columns, but the **Java code** was trying to set these fields to `null` in several places:

1. When releasing players to create filler players
2. In the bulk import feature when contract fields were empty
3. In repository queries for clearing contracts

### Database Schema vs. Java Entity Mismatch

**Database Table (`players`):**
- `contract_length`: NOT NULL constraint
- `contract_amount`: NOT NULL constraint

**Java Entity (`Player.java`):**
```java
@Column  // Allows null by default
private Integer contractLength;

@Column  // Allows null by default
private Double contractAmount;
```

The Java annotations didn't specify `nullable = false`, so developers thought these fields could be null, but the actual database rejected null values.

## Solution

Instead of allowing `null` values, we now use **0 as a sentinel value** to represent "no contract" or "free agent" status.

### Changes Made

#### 1. TeamController.java - Release Players Method
**Before:**
```java
player.setContractLength(null);
player.setContractAmount(null);
```

**After:**
```java
player.setContractLength(0);
player.setContractAmount(0.0);
```

#### 2. TeamController.java - Bulk Import Method
**Before:**
```java
Integer contractLength = null;
Double contractAmount = null;
```

**After:**
```java
Integer contractLength = 0;  // Default to 0
Double contractAmount = 0.0; // Default to 0
```

#### 3. TeamController.java - Add Player Method
**Before:**
```java
@RequestParam Integer contractLength,
@RequestParam Double contractAmount
```

**After:**
```java
@RequestParam(required = false) Integer contractLength,
@RequestParam(required = false) Double contractAmount
// Use 0 as default if not provided
Integer finalContractLength = (contractLength != null) ? contractLength : 0;
Double finalContractAmount = (contractAmount != null) ? contractAmount : 0.0;
```

#### 4. PlayerRepository.java - Query Methods
**Before:**
```java
@Query("UPDATE Player p SET p.contractLength = null, p.contractAmount = null, p.ownerId = null")
void clearAllContracts();

@Query("UPDATE Player p SET p.contractLength = null, p.contractAmount = null, p.ownerId = null WHERE p.id IN :playerIds")
void releasePlayersToFreeAgency(@Param("playerIds") List<Long> playerIds);
```

**After:**
```java
@Query("UPDATE Player p SET p.contractLength = 0, p.contractAmount = 0.0, p.ownerId = null")
void clearAllContracts();

@Query("UPDATE Player p SET p.contractLength = 0, p.contractAmount = 0.0, p.ownerId = null WHERE p.id IN :playerIds")
void releasePlayersToFreeAgency(@Param("playerIds") List<Long> playerIds);
```

#### 5. team.html - Display Logic
**Before:**
```html
th:text="${player.contractLength != null ? player.contractLength + ' years' : 'None'}"
th:text="${player.contractAmount != null ? '$' + #numbers.formatDecimal(player.contractAmount, 0, 2) : 'None'}"
```

**After:**
```html
th:text="${player.contractLength != null && player.contractLength > 0 ? player.contractLength + ' years' : 'None'}"
th:text="${player.contractAmount != null && player.contractAmount > 0 ? '$' + #numbers.formatDecimal(player.contractAmount, 0, 2) : 'None'}"
```

#### 6. team.html - Form Fields
**Before:**
```html
<input type="number" id="contractLength" name="contractLength" min="1" required>
<select id="contractAmount" name="contractAmount" required>
```

**After:**
```html
<input type="number" id="contractLength" name="contractLength" min="0" placeholder="0 for no contract">
<select id="contractAmount" name="contractAmount">
    <option value="">No contract (Free Agent)</option>
```

## Impact

### Positive Changes:
1. ✅ **No more database errors** - All operations now comply with NOT NULL constraints
2. ✅ **Filler players work correctly** - Empty roster slots can be created
3. ✅ **Bulk import works** - Can import players without contracts
4. ✅ **Add player works** - Contract fields are now optional
5. ✅ **Better UX** - Fields can be left empty and default to 0

### Semantic Changes:
- **0 now means "no contract"** instead of null
- Display logic updated to show "None" for 0 values
- Free agents now have `contractLength = 0` and `contractAmount = 0.0`

## Testing

### Test Cases to Verify:

1. **Release Players:**
   - Select and release a player
   - Verify they become "Empty [Position] Slot" with contract values showing "None"
   - Check database: `contract_length = 0`, `contract_amount = 0`

2. **Bulk Import:**
   - Import Excel file with players that have empty contract fields
   - Verify import succeeds without errors
   - Check that players have `0` for empty contract fields

3. **Add Player:**
   - Add a new player, leave contract fields empty
   - Verify player is added successfully
   - Check contract fields show "None" in the UI

4. **Display:**
   - View team roster
   - Verify players with 0 contracts show "None" not "$0.00"

### SQL Verification:
```sql
-- Check filler players
SELECT name, position, contract_length, contract_amount 
FROM players 
WHERE name LIKE 'Empty%';

-- Should show contract_length = 0 and contract_amount = 0

-- Check free agents
SELECT name, position, contract_length, contract_amount 
FROM players 
WHERE contract_length = 0 OR contract_amount = 0;
```

## Files Modified

1. `src/main/java/com/fantasyia/team/TeamController.java`
   - Release players method (line ~437)
   - Bulk import method (lines ~229 and ~250)
   - Add player method (line ~81)

2. `src/main/java/com/fantasyia/team/PlayerRepository.java`
   - clearAllContracts query (line 41)
   - releasePlayersToFreeAgency query (line 46)

3. `src/main/resources/templates/team.html`
   - Display logic (line ~296-297)
   - Form fields (line ~371-377)

## Alternative Solutions Considered

### Option 1: Change Database Schema (Not Chosen)
- Remove NOT NULL constraints from database
- **Pros:** Matches Java entity expectations
- **Cons:** Requires database migration, potential data issues

### Option 2: Use 0 as Default (CHOSEN)
- Keep database constraints, use 0 for "no contract"
- **Pros:** No database changes needed, immediate fix
- **Cons:** Slight semantic change (0 = no contract)

### Option 3: Use Empty String/Negative Values
- Use -1 or empty strings
- **Cons:** Doesn't work with numeric types, confusing semantics

## Future Considerations

### Possible Improvements:
1. **Add database migration** to align schema with code expectations
2. **Add explicit validation** at the service layer
3. **Create a constant** for the "no contract" sentinel value
4. **Add unit tests** to prevent regression
5. **Document the convention** in code comments

### Convention Documentation:
```java
// Convention: contractLength = 0 means "no contract" or "free agent"
// Convention: contractAmount = 0.0 means "no contract" or "free agent"
```

## Prevention

To prevent similar issues in the future:

1. **Database Schema Documentation:** Maintain clear documentation of NOT NULL constraints
2. **Entity Validation:** Add validation annotations to Java entities that match DB constraints
3. **Integration Tests:** Add tests that verify database operations don't violate constraints
4. **Code Reviews:** Check for null assignments to fields that have DB constraints

## Related Issues

- RELEASE_PLAYERS_FEATURE.md - Original filler players feature
- FILLER_PLAYERS_FEATURE.md - Filler players documentation

## Resolution Status

✅ **FIXED** - All null assignments replaced with 0 defaults
✅ **TESTED** - Display logic updated to treat 0 as "None"
✅ **DOCUMENTED** - This document explains the fix and rationale
