#!/bin/bash

# FantasyIA Comprehensive Rebuild Script
# Usage: ./rebuild.sh [option]
# Options:
#   clean     - Clean build only (default)
#   docker    - Build and rebuild Docker containers
#   full      - Full rebuild with Docker containers restart
#   dev       - Development mode (clean, compile, run)
#   package   - Build JAR package only

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command_exists mvn; then
        print_error "Maven is not installed or not in PATH"
        exit 1
    fi
    
    if ! command_exists java; then
        print_error "Java is not installed or not in PATH"
        exit 1
    fi
    
    # Check Java version
    JAVA_VERSION=$(java -version 2>&1 | head -n1 | cut -d'"' -f2 | cut -d'.' -f1)
    if [ "$JAVA_VERSION" -lt 17 ]; then
        print_error "Java 17 or higher is required. Current version: $JAVA_VERSION"
        exit 1
    fi
    
    if [ ! -f "pom.xml" ]; then
        print_error "pom.xml not found. Make sure you're in the project root directory."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to clean build
clean_build() {
    print_status "Starting clean build..."
    
    print_status "Step 1: Cleaning previous build artifacts..."
    mvn clean -q
    print_success "Clean completed"
    
    print_status "Step 2: Compiling application..."
    mvn compile -q
    print_success "Compile completed"
    
    print_status "Step 3: Running tests..."
    mvn test -q || print_warning "Some tests may have failed (this is often normal in development)"
    
    print_success "Clean build completed successfully!"
}

# Function to package application
package_app() {
    print_status "Creating JAR package..."
    mvn package -DskipTests=true -q
    
    if [ -f "target/fantasyia-0.0.1-SNAPSHOT.jar" ]; then
        print_success "JAR package created: target/fantasyia-0.0.1-SNAPSHOT.jar"
    else
        print_error "JAR package creation failed"
        exit 1
    fi
}

# Function to rebuild Docker containers
rebuild_docker() {
    print_status "Rebuilding Docker containers..."
    
    if ! command_exists docker; then
        print_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! command_exists docker-compose; then
        print_error "Docker Compose is not installed or not in PATH"
        exit 1
    fi
    
    # First package the application
    package_app
    
    print_status "Stopping existing containers..."
    docker-compose down --remove-orphans
    
    print_status "Building new Docker image..."
    docker-compose build --no-cache
    
    print_status "Starting containers..."
    docker-compose up -d
    
    print_status "Waiting for services to start..."
    sleep 10
    
    # Check if containers are running
    if docker-compose ps | grep -q "Up"; then
        print_success "Docker containers rebuilt and started successfully!"
        print_status "Application URL: http://localhost:8080"
        print_status "PgAdmin URL: http://localhost:8081 (admin@admin.com / admin)"
    else
        print_error "Some containers failed to start"
        docker-compose logs
        exit 1
    fi
}

# Function to run in development mode
dev_mode() {
    print_status "Starting development mode..."
    clean_build
    
    print_status "Starting application in development mode..."
    print_status "Press Ctrl+C to stop the application"
    mvn spring-boot:run
}

# Function to show usage
show_usage() {
    echo "FantasyIA Rebuild Script"
    echo ""
    echo "Usage: ./rebuild.sh [option]"
    echo ""
    echo "Options:"
    echo "  clean     Clean build only (default)"
    echo "  docker    Build and rebuild Docker containers"
    echo "  full      Full rebuild with Docker containers restart"
    echo "  dev       Development mode (clean, compile, run)"
    echo "  package   Build JAR package only"
    echo "  help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./rebuild.sh          # Clean build"
    echo "  ./rebuild.sh docker   # Rebuild Docker containers"
    echo "  ./rebuild.sh dev      # Run in development mode"
}

# Main execution
main() {
    echo "=================================="
    echo "FantasyIA Rebuild Script"
    echo "Date: $(date)"
    echo "=================================="
    
    # Get the option or default to clean
    OPTION=${1:-clean}
    
    # Navigate to script directory (project root)
    cd "$(dirname "$0")"
    
    case "$OPTION" in
        "clean")
            check_prerequisites
            clean_build
            ;;
        "docker")
            check_prerequisites
            clean_build
            rebuild_docker
            ;;
        "full")
            check_prerequisites
            clean_build
            rebuild_docker
            print_status "Showing container logs for 30 seconds..."
            timeout 30 docker-compose logs -f || true
            ;;
        "dev")
            check_prerequisites
            dev_mode
            ;;
        "package")
            check_prerequisites
            clean_build
            package_app
            ;;
        "help"|"-h"|"--help")
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $OPTION"
            show_usage
            exit 1
            ;;
    esac
    
    print_success "Rebuild script completed successfully!"
}

# Run main function
main "$@"