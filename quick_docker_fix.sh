#!/bin/bash

echo "🚀 Quick Docker Fix - Building JAR and Testing Docker"
echo "=================================================="

# Make scripts executable
chmod +x build_jar.sh
chmod +x build_docker.sh
chmod +x deploy_master.sh

echo "✅ Scripts made executable"

# Test JAR build first
echo ""
echo "📦 Testing JAR build..."
if mvn clean package -DskipTests -q; then
    echo "✅ JAR build successful!"
    
    if [ -f "target/fantasyia-0.0.1-SNAPSHOT.jar" ]; then
        echo "✅ JAR file created: target/fantasyia-0.0.1-SNAPSHOT.jar"
        echo "📊 Size: $(du -h target/fantasyia-0.0.1-SNAPSHOT.jar | cut -f1)"
        
        # Now test Docker build
        echo ""
        echo "🐳 Testing Docker build..."
        if docker build -t fantasyia:latest . >/dev/null 2>&1; then
            echo "✅ Docker build successful!"
            echo "🎉 PROBLEM SOLVED! Container is ready."
            echo ""
            echo "🚀 To run your app:"
            echo "   docker run -p 8080:8080 fantasyia:latest"
            echo ""
            echo "📋 Your duplicate player prevention feature is now containerized and ready!"
        else
            echo "❌ Docker build still failing - but JAR works"
            echo "💡 You can run directly with:"
            echo "   java -jar target/fantasyia-0.0.1-SNAPSHOT.jar"
            echo ""
            echo "🐳 For Docker debugging, try:"
            echo "   docker build -t fantasyia:latest ."
        fi
    else
        echo "❌ JAR file not found after build"
        ls -la target/ 2>/dev/null || echo "Target directory missing"
    fi
else
    echo "❌ JAR build failed"
    echo "🔍 Try with verbose output:"
    echo "   mvn clean package -DskipTests -X"
fi