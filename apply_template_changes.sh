#!/bin/bash

echo "🔄 Applying HTML template changes to FantasyIA..."
echo "Removed 'M' suffix from contract amounts in My Team page"
echo "Time: $(date)"
echo ""

# Navigate to project directory
cd /Users/robbypierson/IdeaProjects/fantasyIA

# Make build script executable
chmod +x build_app.sh

# Stop containers first
echo "1. Stopping existing Docker containers..."
docker-compose down

# Build the application with updated templates
echo ""
echo "2. Building application with updated templates..."
./build_app.sh

# Check if build was successful
if [ $? -ne 0 ]; then
    echo "❌ Build failed. Please check the errors above."
    exit 1
fi

# Rebuild Docker containers with the new JAR
echo ""
echo "3. Rebuilding Docker containers with updated JAR..."
docker-compose build --no-cache app

# Start the application
echo ""
echo "4. Starting application with updated templates..."
docker-compose up -d

# Wait for startup
echo ""
echo "5. Waiting for application startup (20 seconds)..."
sleep 20

# Check container status
echo ""
echo "6. Checking container status..."
docker-compose ps

echo ""
echo "✅ Template changes have been applied successfully!"
echo "🌐 Application is now available at: http://localhost:8080"
echo "📝 The 'M' suffix has been removed from contract amounts on the My Team page"
echo ""
echo "To verify the changes:"
echo "1. Login to the application"
echo "2. Go to 'My Team' page"
echo "3. Contract amounts should now display without the 'M' suffix (e.g., '$5.50' instead of '$5.50M')"