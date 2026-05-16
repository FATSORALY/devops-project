#!/bin/bash
echo "=== Installation Jenkins via Docker ==="

docker run -d --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --restart unless-stopped \
  jenkins/jenkins:lts-jdk17

echo "Jenkins démarré !"
echo "Accède à http://localhost:8080"
echo "Pour récupérer le mot de passe admin :"
echo "docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"