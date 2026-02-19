# FantasyIA Docker Container Setup

## 🚀 Quick Start

To get your FantasyIA web application running in Docker containers:

```bash
# Make the setup script executable and run it
chmod +x setup_and_run.sh && ./setup_and_run.sh
```

That's it! The script will handle everything automatically.

## 🐳 What Gets Created

### Container Services

1. **fantasyia_app** (Port 8080)
   - Your Spring Boot web application
   - Built from local Dockerfile
   - Automatically connects to database

2. **fantasyia_postgres** (Port 5432) 
   - PostgreSQL 15 database
   - Initialized with your database schema
   - Persistent data storage

3. **fantasyia_pgadmin** (Port 8081)
   - Web-based database administration
   - Login: admin@admin.com / admin

### Networks & Volumes

- **fantasyia-network**: Isolated network for all services
- **pgdata**: Persistent PostgreSQL data
- **pgadmin_data**: Persistent PgAdmin configuration

## 🌐 Access Your Application

Once running, access these URLs:

| Service | URL | Purpose |
|---------|-----|---------|
| **Main App** | http://localhost:8080 | Fantasy baseball application |
| **Auction Manager** | http://localhost:8080/auction/manage | Manage auctions |
| **Team Manager** | http://localhost:8080/team | Manage teams |
| **Database Admin** | http://localhost:8081 | PgAdmin interface |

## 🛠️ Management Commands

### Start/Stop Services
```bash
# Start all services
./start_webapp.sh

# Stop all services  
docker-compose down

# Restart services
docker-compose restart

# Stop and remove everything (including data)
docker-compose down -v
```

### Monitor Services
```bash
# Check health of all services
./check_health.sh

# View live application logs
docker-compose logs -f app

# View all service logs
docker-compose logs -f

# Check container status
docker-compose ps
```

### Rebuild Services
```bash
# Rebuild everything from scratch
./rebuild_docker_containers.sh

# Rebuild just the application
docker-compose up -d --build app
```

## 🔧 Configuration

### Environment Variables
The application uses these key environment variables (set in docker-compose.yml):

```yaml
SPRING_DATASOURCE_URL: jdbc:postgresql://db:5432/fantasyia
SPRING_DATASOURCE_USERNAME: fantasyia
SPRING_DATASOURCE_PASSWORD: fantasyia
SPRING_PROFILES_ACTIVE: docker
```

### Database Connection
- **Host**: db (internal) / localhost:5432 (external)
- **Database**: fantasyia
- **Username**: fantasyia  
- **Password**: fantasyia

### PgAdmin Connection
1. Open http://localhost:8081
2. Login with admin@admin.com / admin
3. Add server with these settings:
   - Host: db
   - Port: 5432
   - Database: fantasyia
   - Username: fantasyia
   - Password: fantasyia

## 🐛 Troubleshooting

### Application Won't Start
```bash
# Check logs
docker-compose logs app

# Restart application
docker-compose restart app

# Rebuild application
docker-compose up -d --build app
```

### Database Issues
```bash
# Check database status
docker-compose exec db pg_isready -U fantasyia

# View database logs
docker-compose logs db

# Reset database (⚠️ loses all data)
docker-compose down -v
docker-compose up -d db
```

### Port Conflicts
If ports 8080, 5432, or 8081 are in use:

1. Stop conflicting services
2. Or modify ports in docker-compose.yml:
   ```yaml
   ports:
     - "8090:8080"  # Change 8080 to 8090
   ```

### Memory Issues
If containers fail due to memory:

1. Increase Docker Desktop memory allocation
2. Or modify Dockerfile memory settings:
   ```dockerfile
   ENTRYPOINT ["java", "-XX:MaxRAMPercentage=50.0", "-jar", "app.jar"]
   ```

### Complete Reset
If nothing works:
```bash
# Nuclear option - removes everything
docker-compose down -v
docker system prune -af
./start_webapp.sh
```

## 📁 File Structure

```
fantasyIA/
├── docker-compose.yml      # Main container orchestration
├── Dockerfile             # Application container build
├── init-db.sql            # Database initialization
├── .dockerignore          # Docker build exclusions
├── start_webapp.sh        # Main startup script ⭐
├── check_health.sh        # Health monitoring
├── rebuild_docker_containers.sh  # Full rebuild
└── setup_and_run.sh       # One-command setup ⭐
```

## ⚡ Performance Tips

1. **First Run**: Takes 3-5 minutes to download images and build
2. **Subsequent Runs**: Takes 30-60 seconds to start
3. **Memory Usage**: ~1-2GB RAM for all containers
4. **Disk Usage**: ~500MB-1GB for images and data

## 🔒 Security Notes

- Database uses default credentials (change for production)
- PgAdmin uses default credentials (change for production)  
- Application runs as non-root user in container
- All services isolated in Docker network
- No sensitive data in version control

---

## 🆘 Need Help?

1. **Check health**: `./check_health.sh`
2. **View logs**: `docker-compose logs -f app`
3. **Full reset**: `docker-compose down -v && ./start_webapp.sh`
4. **Check this file**: `DOCKER_SETUP_README.md`

Your FantasyIA web application should now be running at http://localhost:8080! 🎉