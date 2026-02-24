# TEST COMMISSIONER LOGIN CREDENTIALS

## 🏆 Commissioner Accounts Created

I have created several test commissioner accounts for you to use:

### Primary Commissioner Account
- **Username:** `commissioner`
- **Password:** `admin123`
- **Role:** COMMISSIONER
- **Features:** Full access to auction management, user management, and all administrative features

### Alternative Commissioner Accounts

#### Easy Login
- **Username:** `commish`
- **Password:** `commish`
- **Role:** COMMISSIONER

#### Admin Account
- **Username:** `admin` 
- **Password:** `password`
- **Role:** COMMISSIONER

## 🚀 How to Use

1. **Start the application** (if not already running):
   ```bash
   docker-compose up -d
   ```

2. **Access the login page**: http://localhost:8080/login

3. **Use any of the commissioner credentials above**

4. **Commissioner Features Available:**
   - Auction Management: http://localhost:8080/auction/manage
   - Add players to auction
   - Remove players from auction
   - Change auction types (In-Season/Off-Season)
   - View all team management features
   - Access administrative functions

## 🎯 Test Manager Accounts (Also Created)

For testing purposes, I also created regular manager accounts:
- **Usernames:** `manager1`, `manager2`, `team1`, `team2`, `owner1`
- **Password:** `password` (for all)
- **Role:** MANAGER

## 🔧 Technical Details

The commissioner accounts are created automatically when the application starts via the `DataInitializer` component. They have:

- **Full salary cap:** $100M
- **Clean rosters:** 0 players initially
- **Administrative privileges:** Access to all commissioner-only endpoints
- **Secure passwords:** BCrypt encoded for security

## ✅ Verification

To verify the accounts exist, you can:

1. Check the database directly
2. Try logging in with any of the credentials
3. Access commissioner-only pages like `/auction/manage`

The accounts will be created automatically the next time the application starts.