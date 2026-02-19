#!/bin/bash

echo "╔═══════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                           ║"
echo "║              🛠️  DATABASE MANAGEMENT TOOLS                                ║"
echo "║                                                                           ║"
echo "╚═══════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "What would you like to do?"
echo ""
echo "1)  View database status"
echo "2)  Backup database"
echo "3)  Export players to CSV"
echo "4)  Export released queue to CSV"
echo "5)  View database size"
echo "6)  View table sizes"
echo "7)  Clean released queue (non-pending)"
echo "8)  Remove orphaned auction items"
echo "9)  View all table names"
echo "10) Connect to database (interactive)"
echo "11) Exit"
echo ""
read -p "Enter choice (1-11): " choice

case $choice in
    1)
        echo ""
        echo "📊 DATABASE STATUS:"
        docker-compose ps db
        ;;
    2)
        BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).sql"
        echo ""
        echo "💾 Creating backup: $BACKUP_FILE"
        docker exec fantasyia-db-1 pg_dump -U fantasyia fantasyia > "$BACKUP_FILE"
        echo "✅ Backup created: $BACKUP_FILE"
        ;;
    3)
        CSV_FILE="players_$(date +%Y%m%d_%H%M%S).csv"
        echo ""
        echo "📊 Exporting players to CSV: $CSV_FILE"
        docker exec fantasyia-db-1 psql -U fantasyia -d fantasyia -c "\COPY (SELECT * FROM players ORDER BY name) TO STDOUT WITH CSV HEADER" > "$CSV_FILE"
        echo "✅ Exported to: $CSV_FILE"
        ;;
    4)
        CSV_FILE="released_queue_$(date +%Y%m%d_%H%M%S).csv"
        echo ""
        echo "📊 Exporting released queue to CSV: $CSV_FILE"
        docker exec fantasyia-db-1 psql -U fantasyia -d fantasyia -c "\COPY (SELECT * FROM released_players_queue ORDER BY released_at DESC) TO STDOUT WITH CSV HEADER" > "$CSV_FILE"
        echo "✅ Exported to: $CSV_FILE"
        ;;
    5)
        echo ""
        echo "📊 DATABASE SIZE:"
        docker exec fantasyia-db-1 psql -U fantasyia -d fantasyia -c "SELECT pg_size_pretty(pg_database_size('fantasyia')) as database_size;"
        ;;
    6)
        echo ""
        echo "📊 TABLE SIZES:"
        docker exec fantasyia-db-1 psql -U fantasyia -d fantasyia -c "
        SELECT 
            tablename,
            pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
        FROM pg_tables
        WHERE schemaname = 'public'
        ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;"
        ;;
    7)
        echo ""
        echo "🧹 Cleaning released players queue (removing non-pending)..."
        docker exec fantasyia-db-1 psql -U fantasyia -d fantasyia -c "
        DELETE FROM released_players_queue WHERE status != 'PENDING';
        SELECT COUNT(*) as remaining_pending FROM released_players_queue WHERE status = 'PENDING';"
        echo "✅ Cleanup complete!"
        ;;
    8)
        echo ""
        echo "🧹 Removing orphaned auction items..."
        docker exec fantasyia-db-1 psql -U fantasyia -d fantasyia -c "
        DELETE FROM auction_items 
        WHERE player_id NOT IN (SELECT id FROM players);
        SELECT COUNT(*) as remaining_items FROM auction_items WHERE status = 'ACTIVE';"
        echo "✅ Cleanup complete!"
        ;;
    9)
        echo ""
        echo "📋 ALL TABLES:"
        docker exec fantasyia-db-1 psql -U fantasyia -d fantasyia -c "\dt"
        ;;
    10)
        echo ""
        echo "🔌 Connecting to database..."
        echo "Type \q to exit when done"
        echo ""
        docker exec -it fantasyia-db-1 psql -U fantasyia -d fantasyia
        ;;
    11)
        echo "Goodbye!"
        exit 0
        ;;
    *)
        echo "Invalid choice!"
        exit 1
        ;;
esac

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Run './db_tools.sh' again for more options"
echo ""
