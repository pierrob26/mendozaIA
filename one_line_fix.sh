#!/usr/bin/env zsh
# ONE-LINE FIX - The simplest possible solution

cd "$(dirname "$0")" && docker compose down && mvn clean package -DskipTests && docker compose up --build -d && echo "" && echo "✅ Done! Waiting 20 seconds..." && sleep 20 && echo "" && echo "Check status:" && docker compose ps && echo "" && echo "Visit: http://localhost:8080" && echo "Logs: docker compose logs -f app"
