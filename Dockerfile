# Dockerfile
FROM node:18-alpine

# Install necessary tools for SonarQube and other pipeline steps
RUN apk add --no-cache unzip wget bash curl

# Optional: Install sonar-scanner globally (if not done via Jenkins)
# RUN wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.0.2856-linux.zip \
#     && unzip sonar-scanner-cli-4.8.0.2856-linux.zip \
#     && mv sonar-scanner-4.8.0.2856-linux /opt/sonar-scanner \
#     && ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner \
#     && rm sonar-scanner-cli-4.8.0.2856-linux.zip

RUN apk add --no-cache unzip wget \
    && wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip \
    && unzip sonar-scanner-cli-*.zip -d /opt \
    && ln -s /opt/sonar-scanner-*/bin/sonar-scanner /usr/local/bin/sonar-scanner


WORKDIR /app
COPY . .

RUN npm install
