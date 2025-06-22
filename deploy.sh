#!/bin/bash
set -e

# 1. Установка Docker и git (Debian)
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common git ufw

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
echo \
  "deb [arch=amd64] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-compose

# 2. Открытие портов (80, 9090, 9091, 9093)
sudo ufw allow 80
sudo ufw allow 22
sudo ufw allow 20
sudo ufw allow 9090
sudo ufw allow 9091
sudo ufw allow 9093
sudo ufw --force enable

# 3. Добавление пользователя в группу docker
sudo usermod -aG docker $USER

# 4. Клонирование репозитория (замени ссылку на свой репозиторий)
REPO_URL="https://github.com/Krasnon/6.4-docker-andrey-bahaev.git"
REPO_DIR="6.4-docker-andrey-bahaev"
if [ ! -d "$REPO_DIR" ]; then
  git clone "$REPO_URL"
fi
cd "$REPO_DIR"

# 5. Создание docker-сети (если требуется)
docker network create bahaev-as-my-netology-hw || true

# 6. Запуск всех сервисов
docker compose -f docker-compose.yml \
  -f docker-compose-pushgateway.yml \
  -f docker-compose-grafana.yml \
  -f docker-compose-alertmanager.yml up -d

# 7. Проверка статуса контейнеров
echo -e "\nСтатус контейнеров:"
docker ps

echo -e "\nИнфраструктура успешно развернута!"
echo -e "\nВыйдите из системы и войдите снова, чтобы применить права docker-группы для пользователя $USER."
