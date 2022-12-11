# https://www.docker.com/blog/9-tips-for-containerizing-your-spring-boot-code/

FROM eclipse-temurin:17-jdk-jammy as builder
WORKDIR /opt/app
COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:go-offline
COPY ./src ./src
RUN ./mvnw clean install

FROM eclipse-temurin:17-jre-jammy
WORKDIR /opt/app
EXPOSE 2222
COPY --from=builder /opt/app/target/*.jar /opt/app/*.jar
ENTRYPOINT ["java", "-jar", "/opt/app/*.jar" ]

# (if needed) docker network create var-net
# docker build -t varnish-demo-app .
# docker run --rm --name app1 -p 2222:2222 varnish-demo-app