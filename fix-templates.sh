#!/bin/bash

# Script to fix Spring Boot template issues
echo "Starting Spring Boot template fix..."

# Navigate to project directory
cd "/Users/robbypierson/IdeaProjects/fantasyIA"

echo "1. Starting PostgreSQL database..."
docker-compose up -d db

echo "2. Waiting for database to be ready..."
sleep 15

echo "3. Cleaning Maven project..."
mvn clean

echo "4. Compiling project..."
mvn compile

echo "5. Starting Spring Boot application..."
echo "Application will be available at http://localhost:8080"
echo "Press Ctrl+C to stop the application"
mvn spring-boot:run