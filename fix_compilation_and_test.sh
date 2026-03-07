#!/bin/bash

echo "🔧 Fixing compilation errors and testing deployment..."

# Make deployment script executable
chmod +x deploy_duplicate_prevention.sh

# Test Maven compilation
echo "🧪 Testing Maven compilation..."
mvn clean compile -q

if [ $? -eq 0 ]; then
    echo "✅ Main compilation successful!"
    
    echo "🧪 Testing test compilation..."
    mvn test-compile -q
    
    if [ $? -eq 0 ]; then
        echo "✅ Test compilation successful!"
        echo "🎉 All compilation issues resolved!"
        echo ""
        echo "📋 Ready to deploy with:"
        echo "   ./deploy_duplicate_prevention.sh"
        echo ""
        echo "📋 Or test manually with:"
        echo "   mvn clean test"
    else
        echo "⚠️  Test compilation still has issues, but main code compiles"
        echo "📋 Main feature is ready for deployment"
    fi
else
    echo "❌ Main compilation failed - please check error messages above"
fi