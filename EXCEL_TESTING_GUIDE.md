# Excel Bulk Import Testing Guide

## Quick Start
1. **Download Template**: Visit `/team/download-template` to get a pre-formatted Excel template
2. **Create Test File**: Use the sample data below to create your own Excel file for testing

## Sample Excel Data Structure

Create an Excel file (.xlsx or .xls) with these columns in order:
| Name | Position | MLB Team | Contract Length | Contract Amount |

### Test Data Examples:

**Row 1 (Header):**
Name | Position | MLB Team | Contract Length | Contract Amount

**Row 2 (Contracted Player):**
Mike Trout | OF | Los Angeles Angels | 10 | 35000000

**Row 3 (Another Contracted Player):**
Aaron Judge | OF | New York Yankees | 9 | 40000000

**Row 4 (Free Agent - empty contract fields):**
Free Agent Player | C | Boston Red Sox | | 

**Row 5 (Invalid Position - should be skipped):**
Invalid Player | INVALID | Tampa Bay Rays | 2 | 1000000

**Row 6 (Missing Required Field - should be skipped):**
| SS | Miami Marlins | 3 | 5000000

## Valid Positions:
- C (Catcher)
- 1B (First Base)
- 2B (Second Base)  
- 3B (Third Base)
- SS (Shortstop)
- OF (Outfield)
- DH (Designated Hitter)
- SP (Starting Pitcher)
- RP (Relief Pitcher)

## Testing Scenarios:

### 1. Valid File Test:
- Create Excel with 5-10 valid players
- Mix of contracted players and free agents
- Different positions and teams
- Expected: All valid players imported successfully

### 2. Mixed Valid/Invalid Test:
- Include some invalid positions
- Include rows with missing required fields (Name, Position, or MLB Team)
- Include malformed contract data
- Expected: Only valid players imported, others skipped

### 3. File Format Tests:
- Test .xlsx file
- Test .xls file  
- Test invalid file types (.csv, .txt)
- Expected: Excel files work, others rejected

### 4. Edge Cases:
- Empty file
- File with only headers
- Very large file (near 10MB limit)
- Special characters in names
- Contract amounts with $ and commas (e.g., "$1,000,000")

## Expected Behaviors:

✅ **Success Cases:**
- Valid players are imported and appear in team listing
- Success message shows number of players imported
- Players are associated with the logged-in user

❌ **Error Cases:**
- Invalid file formats show clear error messages
- Files over 10MB are rejected
- Empty or malformed files show helpful error messages
- Duplicate players are handled gracefully

## Quick Excel File Creation:

If you don't have Excel, you can:
1. Use Google Sheets and export as .xlsx
2. Use LibreOffice Calc and save as Excel format
3. Use the built-in template download feature in the app

## Testing Steps:

1. Build the project: `mvn clean package`
2. Run the application: `java -jar target/fantasyia-0.0.1-SNAPSHOT.jar`
3. Navigate to the team page: `http://localhost:8080/team`
4. Look for the "Bulk Import Players from Excel" section
5. Download the template or create your own Excel file
6. Test the upload functionality with various scenarios