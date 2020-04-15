FROM maven:3-jdk-11-openj9

# Install wget
#USER root
RUN \
  apt-get update && \
  apt-get install -y wget

# Copy the application into the image
COPY . /app
WORKDIR /app

# Create a vertx user
RUN \
  groupadd -g 1100 vertx && \
  useradd -u 1100 -g vertx vertx && \
  mkdir /home/vertx && \
  chown -R vertx:vertx /home/vertx && \
  chown -R vertx:vertx /app
USER vertx

RUN \
# Debug information
  java -version && \
  mvn -version && \
# Build the application
  mvn package && \
# Remove the maven cache
  rm -rf /home/vertx/.m2
  
# Define the runtime behavior
HEALTHCHECK --interval=30s --timeout=3s CMD wget http://localhost:8080 -t 1 -T 3 --spider
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/target/java-simple-1.0-SNAPSHOT-fat.jar"]