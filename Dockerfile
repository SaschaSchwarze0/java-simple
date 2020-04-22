FROM maven:3-jdk-11-openj9

USER root
RUN \
# Try to kill a process
  apt-get update && \
  apt-get install -y vim && \
  echo "TEST" > /tmp/test.txt && \
  nohup bash -c "vi /tmp/test.txt &" && \
  sleep 4 && \
  kill -9 $(pidof vi) && \
# Install wget
  apt-get update && \
  apt-get install -y wget && \
# Create a vertx user
  groupadd -g 1100 vertx && \
  useradd -u 1100 -g vertx vertx && \
  mkdir /home/vertx && \
  chown -R vertx:vertx /home/vertx

# Copy the application into the image
COPY --chown=vertx:vertx . /app
WORKDIR /app

USER vertx:vertx

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