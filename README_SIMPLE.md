# This file has been removed as part of restoring the original project

A simple web application for managing a fantasy baseball league, built with Java Spring Boot.

## Features

- User registration and login
- Add and manage players on your team
- View available players to claim
- Simple salary tracking
- Basic team management

## Technology Used

- **Backend**: Java Spring Boot
- **Database**: PostgreSQL  
- **Frontend**: HTML, CSS, Thymeleaf templates
- **Build Tool**: Maven

## How to Run

1. **Prerequisites**
   - Java 17 or higher
   - PostgreSQL database
   - Maven

2. **Database Setup**
   ```sql
   CREATE DATABASE fantasyia;
   ```

3. **Configuration**
   Update `src/main/resources/application.properties` with your database settings:
   ```properties
   spring.datasource.url=jdbc:postgresql://localhost:5432/fantasyia
   spring.datasource.username=your_username
   spring.datasource.password=your_password
   ```

4. **Run the Application**
   ```bash
   mvn spring-boot:run
   ```

5. **Access the App**
   Open your web browser and go to: `http://localhost:8080`

## How to Use

1. **Register**: Create a new account on the registration page
2. **Login**: Sign in with your credentials
3. **Add Players**: Use the "My Team" page to add players to your roster
4. **Claim Players**: Browse available players and claim them for your team
5. **Manage Team**: View your team's total salary and player count

## Project Structure

```
src/
├── main/
│   ├── java/com/fantasyia/
│   │   ├── controller/          # Web controllers
│   │   ├── team/               # Player and team entities
│   │   └── user/               # User account entities
│   └── resources/
│       ├── templates/          # HTML templates
│       └── application.properties
```

## Learning Objectives

This project demonstrates:
- Basic web development with Spring Boot
- Database operations with JPA
- HTML form handling
- Session-based authentication
- MVC (Model-View-Controller) architecture

## Future Improvements

- Add player statistics
- Implement draft functionality  
- Add league standings
- Improve user interface design
- Add data validation

---
*This project was created as part of a high school computer science course.*