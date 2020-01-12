# Dockerfile com multi stage
# Imagem base
FROM tomcat:8.5-jdk8-openjdk AS base

WORKDIR /app

# Imagem de build com maven

FROM maven:3-jdk-8-slim as build

WORKDIR /build

COPY pom.xml .
RUN mvn dependency:go-offline

COPY src/ /build/src/

ARG ADDITIONAL_TASK_MAVEN

RUN \
    mvn clean install ${ADDITIONAL_TASK_MAVEN} && \
    mv /build/target/*.war app.war

# Imagem da execução da aplicação

FROM base AS exec

EXPOSE 8080

COPY --from=build /build/*.war /usr/local/tomcat/webapps/

CMD ["catalina.sh", "run"]
