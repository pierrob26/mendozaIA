#!/bin/bash

echo "🗄️  QUICK DATABASE QUERIES"
echo ""
echo "Choose what you want to see:"
echo ""
echo "1) All players"
echo "2) Players by owner"
echo "3) Free agents"
echo "4) Released players queue"
echo "5) Active auctions"
echo "6) Database statistics"
echo "7) All tables"
echo "8) Exit"
echo ""
read -p "Enter choice (1-8): " choice

case $choice in
    1)
        echo ""
        echo "📊 ALL PLAYERS:"
        docker exec fantasyia-db-1 psql -U fantasyia -d fantasyia -c "
        SELECT id, name, position, team, contract_length, contract_amount, owner_id 
        FROM players 
        ORDER BY name;"
        ;;
    2)
        echo ""
        echo "📊 PLAYERS BY OWNER:"
        docker exec fantasyia-db-1 psql -U fantasyia -d fantasyia -c "
        SELECT u.username, COUNT(p.id) as player_count
        FROM users u
        LEFT JOIN players p ON u.id = p.owner_id
        GROUP BY u.username;"
        ;;
    3)
        echo ""
        echo "📊 FREE AGENTS:"
        docker exec fantasyia-db-1 psql -U fantasyia -d fantasyia -c "
        SELECT id, name, position, team
        FROM players
        WHERE owner_id IS NULL
        ORDER BY position, name;"
        ;;
    4)
        echo ""
        echo "📊 RELEASED PLAYERS QUEUE:"
        docker exec fantasyia-db-1 psql -U fantasyia -d fantasyia -c "
        SELECT id, player_name, position, mlb_team, status, released_at
        FROM released_players_queue
        ORDER BY released_at DESC;"
        ;;
    5)
        echo ""
        echo "📊 ACTIVE AUCTIONS:"
        docker exec fantasyia-db-1 psql -U fantasyia -d fantasyia -c "
        SELECT ai.id, p.name as player_name, p.position, ai.current_bid, ai.status
        FROM auction_items ai
        JOIN players p ON ai.player_id = p.id
        WHERE ai.status = 'ACTIVE';"
        ;;
    6)
        echo ""
        echo "📊 DATABASE STATISTICS:"
        docker exec fantasyia-db-1 psql -U fantasyia -d fantasyia -c "
        SELECT 
            (SELECT COUNT(*) FROM players) as total_players,
            (SELECT COUNT(*) FROM players WHERE owner_id IS NULL) as free_agents,
            (SELECT COUNT(*) FROM released_players_queue WHERE status = 'PENDING') as pending_releases,
            (SELECT COUNT(*) FROM auction_items WHERE status = 'ACTIVE') as active_auctions,
            (SELECT COUNT(*) FROM users) as total_users;"
        ;;
    7)
        echo ""
        echo "📊 ALL TABLES:"
        docker exec fantasyia-db-1 psql -U fantasyia -d fantasyia -c "\dt"
        ;;
    8)
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
echo "Want to run custom queries? Use:"
echo "  ./access_db.sh"
echo ""
