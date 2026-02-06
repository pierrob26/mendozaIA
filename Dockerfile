# Use OpenJDK 17 as base image
FROM eclipse-temurin:17-jdk
VOLUME /tmp
COPY target/fantasyia-0.0.1-SNAPSHOT.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]