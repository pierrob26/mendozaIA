cd /Users/robbypierson/IdeaProjects/fantasyIA

echo "Stopping containers..."
docker-compose down

echo "Rebuilding application..."
mvn clean package -DskipTests

echo "Starting with privacy changes..."
docker-compose up --build -d

echo "Privacy deployment complete - check http://localhost:8080"