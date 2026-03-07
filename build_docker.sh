#!/bin/bash

echo "🐳 Building Docker container for Fantasy Baseball App..."

# Check if we're in the correct directory
if [ ! -f "pom.xml" ] || [ ! -f "Dockerfile" ]; then
    echo "❌ Error: Run this script from the fantasyIA project root directory"
    echo "   Missing pom.xml or Dockerfile"
    exit 1
fi

echo "✅ Project directory confirmed"

# Step 1: Build the JAR file
echo "📦 Step 1: Building JAR file..."
if ./build_jar.sh; then
    echo "✅ JAR build successful"
else
    echo "❌ JAR build failed - cannot proceed with Docker build"
    exit 1
fi

# Step 2: Build Docker container
echo "🐳 Step 2: Building Docker container..."
echo "   Using JAR: target/fantasyia-0.0.1-SNAPSHOT.jar"

if docker build -t fantasyia:latest .; then
    echo "✅ Docker build successful!"
    echo ""
    echo "🎉 Container built successfully with tag: fantasyia:latest"
    echo ""
    echo "🚀 Deployment Options:"
    echo "   1. Run locally:"
    echo "      docker run -p 8080:8080 fantasyia:latest"
    echo ""
    echo "   2. Run with environment variables:"
    echo "      docker run -p 8080:8080 -e SPRING_PROFILES_ACTIVE=prod fantasyia:latest"
    echo ""
    echo "   3. Run in background:"
    echo "      docker run -d -p 8080:8080 --name fantasyia-app fantasyia:latest"
    echo ""
    echo "🔍 Container Information:"
    docker images fantasyia:latest
    echo ""
    echo "📋 New Features Included:"
    echo "   ✅ Duplicate player prevention in manual entry"
    echo "   ✅ Duplicate detection in bulk import"
    echo "   ✅ Enhanced user feedback with warnings"
    echo "   ✅ Case-insensitive name matching"
    echo "   ✅ Comprehensive error reporting"
    
else
    echo "❌ Docker build failed"
    echo ""
    echo "🔍 Troubleshooting tips:"
    echo "   1. Check if Docker is running:"
    echo "      docker version"
    echo ""
    echo "   2. Verify JAR file exists:"
    echo "      ls -la target/fantasyia-0.0.1-SNAPSHOT.jar"
    echo ""
    echo "   3. Check Dockerfile syntax:"
    echo "      docker build --no-cache -t fantasyia:latest ."
    echo ""
    echo "   4. Alternative: Run JAR directly:"
    echo "      java -jar target/fantasyia-0.0.1-SNAPSHOT.jar"
    exit 1
fi

echo "🎉 Docker deployment ready!"