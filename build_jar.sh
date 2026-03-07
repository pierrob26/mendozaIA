#!/bin/bash

echo "📦 Building JAR file for Docker deployment..."

# Check if we're in the correct directory
if [ ! -f "pom.xml" ]; then
    echo "❌ Error: Run this script from the fantasyIA project root directory"
    exit 1
fi

echo "✅ Project directory confirmed"

# Clean and package
echo "🧹 Cleaning previous builds..."
mvn clean -q

echo "📦 Creating JAR package (skipping tests for speed)..."
if mvn package -DskipTests; then
    echo "✅ JAR package created successfully"
    
    # List what was created
    echo "📋 Files created in target directory:"
    ls -la target/*.jar 2>/dev/null || echo "   No JAR files found"
    
    # Check for the expected JAR file
    if [ -f "target/fantasyia-0.0.1-SNAPSHOT.jar" ]; then
        echo "✅ Expected JAR file found: target/fantasyia-0.0.1-SNAPSHOT.jar"
        echo "📊 JAR file size: $(du -h target/fantasyia-0.0.1-SNAPSHOT.jar)"
        echo ""
        echo "🐳 Ready for Docker build! Run:"
        echo "   docker build -t fantasyia:latest ."
        echo ""
        echo "🚀 Or run directly with:"
        echo "   java -jar target/fantasyia-0.0.1-SNAPSHOT.jar"
    else
        echo "❌ Expected JAR file not found"
        echo "📋 Available files in target:"
        ls -la target/ 2>/dev/null || echo "   Target directory is empty or doesn't exist"
        exit 1
    fi
else
    echo "❌ JAR packaging failed"
    echo "💡 Try running with verbose output:"
    echo "   mvn package -DskipTests -X"
    exit 1
fi

echo "🎉 JAR build completed successfully!"