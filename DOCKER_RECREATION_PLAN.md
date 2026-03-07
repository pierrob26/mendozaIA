# Docker Container Recreation - March 6, 2026 🐳

## 🎯 Objective
Clean up messy Docker containers and create fresh ones for the Fantasy Baseball application.

## 📋 What Will Be Done

### 1. **Complete Cleanup** 🧹
- Stop all running FantasyIA containers
- Remove containers: `fantasyia_app`, `fantasyia_postgres`, `fantasyia_pgadmin`
- Remove project-specific Docker images
- Remove volumes for clean database start
- Clean up Docker system (dangling images, unused containers)

### 2. **Fresh Build** 🔨
- Build Spring Boot JAR: `mvn clean package -DskipTests`
- Build fresh Docker images using Dockerfile
- Create new containers with docker-compose

### 3. **Services Created** 🚀
- **fantasyia_postgres**: PostgreSQL 15 database
  - Port: 5432
  - Database: fantasyia
  - User/Pass: fantasyia/fantasyia
  
- **fantasyia_app**: Spring Boot application
  - Port: 8080
  - Connects to postgres container
  - Health checks enabled
  
- **fantasyia_pgadmin**: Database management
  - Port: 8081
  - Email: admin@admin.com
  - Password: admin

### 4. **Network & Volumes** 🌐
- **Network**: fantasyia-network (bridge)
- **Volumes**: 
  - pgdata (PostgreSQL data)
  - pgadmin_data (PgAdmin settings)

## 📁 Files Created/Updated

### Scripts:
- `recreate-docker-containers.sh` - Full cleanup and recreation
- `quick-docker-reset.sh` - Quick restart without rebuild  
- `cleanup-docker.sh` - Cleanup only
- `run-docker-setup.sh` - Make executable and run

### Configuration:
- `docker-compose.yml` - Service definitions (existing)
- `Dockerfile` - App container build (existing)
- `init-db.sql` - Database initialization (existing)

## 🔧 Usage Commands

```bash
# Full recreation (recommended for messy containers)
./recreate-docker-containers.sh

# Quick reset (just restart)
./quick-docker-reset.sh

# Manual commands
docker-compose down -v --remove-orphans  # Stop & clean
docker-compose up --build -d             # Build & start
docker-compose ps                         # Check status
docker-compose logs -f                    # View logs
```

## 🌐 Access Points After Recreation
- **Fantasy Baseball App**: http://localhost:8080
- **Database Admin**: http://localhost:8081
- **PostgreSQL**: localhost:5432

## 📊 Expected Outcome
- Clean, fresh Docker environment
- All containers healthy and running
- Database initialized with proper schema
- Application accessible and functional
- No port conflicts or volume issues

Ready to execute the cleanup and recreation process! 🚀