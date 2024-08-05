FROM maven:3.9.6-eclipse-temurin-21-alpine AS builder

WORKDIR /home/app

COPY pom.xml .
COPY src ./src

RUN mvn dependency:go-offline
RUN mvn package -DskipTests

WORKDIR /home/app/extracted
RUN java -Djarmode=layertools -jar /home/app/target/*.jar extract

FROM eclipse-temurin:21-jre-alpine AS runtime

RUN addgroup -S aaagroup && adduser -S aaauser -G aaagroup
USER aaauser

COPY --from=builder /home/app/extracted/dependencies/ ./dependencies/
COPY --from=builder /home/app/extracted/spring-boot-loader/ ./spring-boot-loader/
COPY --from=builder /home/app/extracted/snapshot-dependencies/ ./snapshot-dependencies/
COPY --from=builder /home/app/extracted/application/ ./application/

EXPOSE 8761
ENTRYPOINT ["java","org.springframework.boot.loader.launch.JarLauncher"]
#docker build -t antonio3a/aaa-eureka-server:0.0.1 .