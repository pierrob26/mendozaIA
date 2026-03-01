# FantasyIA Rebuild Script - Quick Reference

## Overview
The `rebuild.sh` script is a comprehensive build automation tool for the FantasyIA Spring Boot application. It handles different build scenarios and includes Docker support.

## Prerequisites
- Java 17 or higher
- Maven 3.x
- Docker & Docker Compose (for Docker options)

## Usage

### Make Script Executable (First Time)
```bash
chmod +x rebuild.sh
```

### Basic Commands

#### Clean Build (Default)
```bash
./rebuild.sh
# or
./rebuild.sh clean
```
- Cleans previous build artifacts
- Compiles the application
- Runs tests
- Perfect for after code changes

#### Development Mode
```bash
./rebuild.sh dev
```
- Performs clean build
- Starts the application in development mode
- Runs on http://localhost:8080
- Press Ctrl+C to stop

#### Package JAR
```bash
./rebuild.sh package
```
- Creates a JAR file in target/ directory
- Useful for deployment

#### Docker Rebuild
```bash
./rebuild.sh docker
```
- Builds JAR package
- Rebuilds Docker containers
- Starts all services (app, database, pgadmin)

#### Full Rebuild with Logs
```bash
./rebuild.sh full
```
- Complete rebuild with Docker
- Shows container logs for 30 seconds
- Best for troubleshooting

#### Help
```bash
./rebuild.sh help
```

## What Each Mode Does

### Clean Build
1. ✅ Validates Java 17+ and Maven
2. ✅ Runs `mvn clean`
3. ✅ Runs `mvn compile`
4. ✅ Runs `mvn test`

### Docker Mode
1. ✅ All clean build steps
2. ✅ Creates JAR package (`mvn package`)
3. ✅ Stops existing containers
4. ✅ Builds new Docker image
5. ✅ Starts all services

### Development Mode
1. ✅ All clean build steps
2. ✅ Starts app with `mvn spring-boot:run`
3. ✅ Hot reload enabled

## Service URLs (Docker Mode)
- **Application**: http://localhost:8080
- **PgAdmin**: http://localhost:8081
  - Email: admin@admin.com
  - Password: admin

## Troubleshooting

### Common Issues
1. **Permission Denied**: Run `chmod +x rebuild.sh`
2. **Java Version Error**: Ensure Java 17+ is installed
3. **Maven Not Found**: Install Maven or add to PATH
4. **Docker Issues**: Ensure Docker Desktop is running

### Logs
- Application logs: `docker-compose logs app`
- Database logs: `docker-compose logs db`
- All logs: `docker-compose logs`

### Clean Slate
If you need to completely reset:
```bash
docker-compose down --volumes --remove-orphans
./rebuild.sh full
```

## File Locations
- JAR file: `target/fantasyia-0.0.1-SNAPSHOT.jar`
- Docker compose: `docker-compose.yml`
- Database init: `init-db.sql`

## Tips
- Use `./rebuild.sh dev` for active development
- Use `./rebuild.sh docker` for testing full deployment
- Use `./rebuild.sh clean` after template/code changes
- The script automatically checks prerequisites before running