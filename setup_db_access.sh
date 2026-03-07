#!/bin/bash

# Setup Database Access for FantasyIA
echo "🗄️  Setting up FantasyIA Database Access..."

# Make database access scripts executable
echo "🔧 Making database scripts executable..."

chmod +x access_db.sh
echo "✅ access_db.sh is now executable"

chmod +x db_connect.sh
echo "✅ db_connect.sh is now executable"

chmod +x setup_db_access.sh
echo "✅ setup_db_access.sh is now executable"

chmod +x check_postgres_container.sh
echo "✅ check_postgres_container.sh is now executable"

chmod +x start_pgadmin.sh
echo "✅ start_pgadmin.sh is now executable"

echo ""
echo "🚀 Database access is now ready!"
echo ""
echo "Available options:"
echo ""
echo "1. 🖥️  Interactive Menu:"
echo "   ./access_db.sh"
echo "   (Provides GUI access via PgAdmin, command line, and common queries)"
echo ""
echo "2. 💻 Direct Command Line:"
echo "   ./db_connect.sh"
echo "   (Direct PostgreSQL psql connection)"
echo ""
echo "3. 🌐 PgAdmin Web Interface (RECOMMENDED FOR VIEWING DATA):"
echo "   ./start_pgadmin.sh"
echo "   (Starts PgAdmin and opens in browser - best for viewing tables and data)"
echo ""
echo "4. 🐳 Container Status:"
echo "   ./check_postgres_container.sh"
echo "   (Check Docker container status and details)"
echo ""
echo "5. 📱 Quick Queries:"
echo "   docker compose exec db psql -U fantasyia -d fantasyia -c \"SELECT * FROM users;\""
echo ""
echo "📚 For detailed guides, see:"
echo "   - DATABASE_ACCESS_GUIDE.md"
echo "   - PGADMIN_SETUP_GUIDE.md"