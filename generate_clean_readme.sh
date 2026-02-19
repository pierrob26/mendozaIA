#!/bin/bash

# Keep only essential documentation files
# This consolidates all the information into clean, organized docs

echo "# FantasyIA - Fantasy Baseball Dynasty League Application

A Spring Boot application for managing a fantasy baseball dynasty league with an always-running free agency auction system.

## 🚀 Quick Start

### Prerequisites
- Docker Desktop installed and running
- Java 17
- Maven 3.x

### Running the Application

1. **Start Docker and build the application:**
   \`\`\`bash
   chmod +x build_complete_fix.sh
   ./build_complete_fix.sh
   \`\`\`

2. **Start Docker containers:**
   \`\`\`bash
   docker-compose up -d --build
   \`\`\`

3. **Access the application:**
   - Main App: http://localhost:8080
   - Auction Manage: http://localhost:8080/auction/manage
   - Auction View: http://localhost:8080/auction/view
   - PgAdmin: http://localhost:8081
     - Email: admin@admin.com
     - Password: admin

### Useful Commands

- **Rebuild and restart:** \`./rebuild_and_restart.sh\`
- **Start Docker only:** \`./start_docker.sh\`
- **View logs:** \`docker-compose logs -f app\`
- **Stop containers:** \`docker-compose down\`
- **Clean build:** \`mvn clean package\`

## 📁 Project Structure

\`\`\`
fantasyIA/
├── src/main/
│   ├── java/com/fantasyia/
│   │   ├── auction/          # Auction system (bids, contracts, scheduling)
│   │   ├── config/           # Security and data initialization
│   │   ├── controller/       # Web controllers (home, register, errors)
│   │   ├── team/             # Player and team management
│   │   └── user/             # User accounts and authentication
│   └── resources/
│       ├── templates/        # Thymeleaf HTML templates
│       ├── static/css/       # Stylesheets
│       └── application.properties
├── docker-compose.yml        # Docker services configuration
├── Dockerfile               # Application container
└── pom.xml                  # Maven dependencies
\`\`\`

## 🎯 Core Features

### Free Agency Auction System
- **Always-running auction** with In-Season and Off-Season modes
- **Dynamic bid increments** based on time elapsed
- **24-hour minimum** for in-season (72 hours for off-season)
- **Contract posting system** with 48-hour deadline
- **Released player queue** for commissioner approval

### Team Management
- Salary cap tracking (\$150M default)
- Roster management (40 players max)
- Player release system with automatic auction integration
- Contract year tracking

### User Roles
- **Commissioners:** Full auction and league management
- **Members:** Bid on players, manage their team

## 🔧 Technology Stack

- **Backend:** Spring Boot 3.2.0, Java 17
- **Database:** PostgreSQL 15
- **Frontend:** Thymeleaf, HTML/CSS
- **Security:** Spring Security
- **Container:** Docker & Docker Compose
- **Build:** Maven

## 📚 Key Documentation

- **AUCTION_MANAGE_FIX.md** - Recent bug fixes and improvements
- **FREE_AGENCY_SYSTEM.md** - Detailed auction rules and mechanics
- **FREE_AGENCY_RULES.md** - League rules for free agency
- **IMPLEMENTATION_SUMMARY.md** - System architecture overview
- **EXCEL_TESTING_GUIDE.md** - Player data import instructions

## 🐛 Troubleshooting

### Application won't start
- Ensure Docker is running
- Check if ports 8080, 5432, 8081 are available
- Try: \`docker-compose down && docker-compose up -d --build\`

### Build fails
- Clean Maven cache: \`mvn clean\`
- Check Java version: \`java -version\` (should be 17)
- Verify pom.xml has no errors

### Database issues
- Check PostgreSQL container: \`docker-compose ps\`
- View database logs: \`docker-compose logs db\`
- Restart database: \`docker-compose restart db\`

### 500 Errors
- Check application logs: \`docker-compose logs -f app\`
- Verify all templates are present
- Ensure database is initialized

## 🎨 Development

### Adding New Features
1. Create/modify Java classes in appropriate package
2. Update templates if needed
3. Add/update database entities
4. Test locally
5. Build: \`mvn clean package\`
6. Deploy: \`docker-compose up -d --build\`

### Database Migrations
- Modify entity classes
- Spring JPA will auto-update schema (development mode)
- For production, create explicit migration scripts

## 📝 License

MIT License - See LICENSE file for details

## 👥 Contributing

1. Create feature branch
2. Make changes
3. Test thoroughly
4. Submit pull request with clear description

---

**Last Updated:** February 19, 2026
**Version:** 0.0.1-SNAPSHOT
" > README_NEW.md
