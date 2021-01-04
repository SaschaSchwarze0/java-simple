FROM maven:3-jdk-11-openj9 AS builder

COPY . /app
WORKDIR /app

RUN \
# Debug information
  java -version && \
  mvn -version && \
# Build the application
  MAVEN_OPTS="-Dmaven.wagon.http.retryhandler.class=standard -Dmaven.wagon.http.retryhandler.requestSentEnabled=true" mvn package

FROM adoptopenjdk:11-openj9

USER root
RUN \
# Install wget
  apt-get update && \
  apt-get install -y wget && \
# Create a vertx user
  groupadd -g 1100 vertx && \
  useradd -u 1100 -g vertx vertx && \
  mkdir /home/vertx && \
  chown -R vertx:vertx /home/vertx && \
# Debug information
  java -version

# Copy the application into the image

WORKDIR /app
COPY --chown=vertx:vertx --from=builder /app/target/java-simple-1.0-SNAPSHOT-fat.jar .

USER vertx:vertx

# Define the runtime behavior
HEALTHCHECK --interval=30s --timeout=3s CMD wget http://localhost:8080 -t 1 -T 3 --spider
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/java-simple-1.0-SNAPSHOT-fat.jar"]