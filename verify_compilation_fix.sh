#!/bin/bash

echo "🔍 VERIFYING COMPILATION FIX"
echo "============================"
echo ""

echo "🧪 Quick compilation test..."
mvn compile -q

if [ $? -eq 0 ]; then
    echo "✅ COMPILATION SUCCESSFUL!"
    echo ""
    echo "The TeamController compilation errors have been fixed:"
    echo "  ✓ setTitle() → setName()"  
    echo "  ✓ setCreatorId() → setCreatedByCommissionerId()"
    echo ""
    echo "🚀 Ready to build and deploy!"
    echo ""
    echo "Next steps:"
    echo "  1. Full build: mvn clean package -DskipTests"
    echo "  2. Deploy: docker-compose up -d --build"
    echo "  3. Or run: ./fix_compilation_and_deploy.sh"
else
    echo "❌ COMPILATION STILL HAS ERRORS"
    echo ""
    echo "Detailed errors:"
    mvn compile
fi