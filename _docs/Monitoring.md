## Monitoring avec Docker

### Aperçu\
Ce projet implémente une solution de monitoring complète utilisant Docker pour déployer et gérer des conteneurs de monitoring et de gestion de logs. Les outils utilisés incluent Uptime-Kuma, Promtail, Prometheus, Node Exporter, MySQL Exporter, Loki, Grafana et Alertmanager.

### Conteneurs Utilisés\
- **Uptime-Kuma** : Surveillance de la disponibilité des services.\
- **Promtail** : Collecte des logs pour Loki.\
- **Prometheus** : Surveillance des métriques.\
- **Node Exporter** : Exportation des métriques système.\
- **MySQL Exporter** : Exportation des métriques MySQL.\
- **Loki** : Gestion centralisée des logs.\
- **Grafana** : Visualisation des métriques et des logs.\
- **Alertmanager** : Gestion des alertes.

### Détails du Workflow\
1\. **Configuration de Docker Compose** : Définition des services dans un fichier `docker-compose.yml`.\
2\. **Déploiement des Conteneurs** : Lancement des conteneurs définis dans le fichier `docker-compose.yml`.\
3\. **Configuration des Tableaux de Bord et des Alertes** : Mise en place des dashboards dans Grafana et des règles d'alerte dans Alertmanager.

### Exemple de Fichier `docker-compose.yml`\
```yaml\
version: '3'\
services:\
  prometheus:\
    image: prom/prometheus\
    container_name: prometheus\
    volumes:\
      - ./lostOps/prometheus/:/etc/prometheus/\
      - prometheus_data:/prometheus\
    command:\
      - '--config.file=/etc/prometheus/prometheus.yml'\
      - '--storage.tsdb.path=/prometheus'\
      - '--storage.tsdb.retention.size=256MB'\
    labels:\
      - "traefik.http.routers.prometheus.service=prometheus"\
      - "traefik.http.services.prometheus.loadbalancer.server.port=9090"\
    ports:\
      - "9090:9090"\
    networks:\
      - monitoring-net\
    restart: unless-stopped

  grafana:\
    image: grafana/grafana\
    container_name: grafana\
    depends_on:\
      - prometheus\
      - loki\
    volumes:\
      - grafana_data:/var/lib/grafana\
      - ./lostOps/grafana/provisioning/datasources:/etc/grafana/provisioning/datasources/\
      - ./lostOps/grafana/provisioning/dashboards:/etc/grafana/provisioning/dashboards/\
      - ./lostOps/grafana/provisioning/dashboards/prometheus:/var/lib/grafana/dashboards/prometheus/\
      - ./lostOps/grafana/provisioning/dashboards/loki:/var/lib/grafana/dashboards/loki/\
    environment:\
      GF_INSTALL_PLUGINS: grafana-piechart-panel\
      GF_SECURITY_ADMIN_PASSWORD: admin\
      GF_SECURITY_ADMIN_USER: admin\
      GF_DASHBOARDS_DEFAULT_HOME_DASHBOARD_PATH: '/var/lib/grafana/dashboards/prometheus/mysql-exporter.json'\
    labels:\
      - "traefik.http.routers.grafana.service=grafana"\
      - "traefik.http.services.grafana.loadbalancer.server.port=3000"\
    ports:\
      - "3000:3000"\
    networks:\
      - monitoring-net

  node-exporter:\
    image: prom/node-exporter\
    container_name: node-exporter\
    networks:\
      - monitoring-net\
    ports:\
      - 9100:9100

  alert-manager:\
    image: prom/alertmanager\
    container_name: alert-manager\
    volumes:\
      - "./lostOps/alertmanager:/config"\
      - alertmanager-data:/data\
    command: --config.file=/config/email.yml --log.level=debug\
    networks:\
      - monitoring-net\
    ports:\
      - 9093:9093

  loki:\
    image: grafana/loki:latest\
    container_name: loki\
    user: "root"\
    volumes:\
      - "./lostOps/loki:/etc/loki"\
      - loki-data:/data\
    command:\
      - '-config.file=/etc/loki/loki-config.yml'\
    ports:\
      - "3100:3100"\
    networks:\
      - monitoring-net

  promtail:\
    image: grafana/promtail:latest\
    container_name: promtail\
    volumes:\
      - "./lostOps/promtail:/etc/promtail"\
      - /var/lib/docker/containers:/var/lib/docker/containers:ro\
      - /var/run/docker.sock:/var/run/docker.sock\
      - promtail-data:/data\
    command:\
      - '-config.file=/etc/promtail/promtail-config.yml'\
    networks:\
      - monitoring-net\
    depends_on:\
      - loki

  mysql-exporter:\
    build:\
      context: ./lostOps/mysqlExporter/\
      dockerfile: Dockerfile\
    container_name: mysql-exporter\
    user: "root"\
    volumes:\
      - "./lostOps/mysqlExporter/.my.cnf:/etc/.my.cnf"\
      - mysql-exporter-data:/data\
    environment:\
      DATA_SOURCE_NAME: "root:app_root_password@(db:3306)/"\
    command:\
      - "--collect.info_schema.processlist"\
      - "--collect.info_schema.innodb_metrics"\
      - "--collect.info_schema.tablestats"\
      - "--collect.info_schema.tables"\
      - "--collect.info_schema.userstats"\
      - "--collect.engine_innodb_status"\
      - "--config.my-cnf=/etc/.my.cnf"\
    ports:\
      - "9104:9104"\
    networks:\
        - monitoring-net\
    restart: always

  kuma:\
    image: louislam/uptime-kuma:1\
    container_name: uptime-kuma\
    volumes:\
      - ./kuma:/app/kuma\
      - kuma-data:/data\
    ports:\
      - 3001:3001\
    labels:\
      - "traefik.enable=true"\
      - "traefik.http.routers.uptime-kuma.rule=Host(`uptime-kuma`)"\
      - "traefik.http.routers.uptime-kuma.entrypoints=http"\
      - "traefik.http.services.uptime-kuma.loadBalancer.server.port=3001"\
    networks:\
        - monitoring-net\
    restart: unless-stopped

volumes:\
  prometheus_data:\
  grafana_data:\
  alertmanager-data:\
  loki-data:\
  promtail-data:\
  mysql-exporter-data:\
  kuma-data:

networks:\
  monitoring-net:\
    driver: bridge\
```

### Configuration des Fichiers\
- **Prometheus** : `prometheus.yml`\
- **Promtail** : `promtail-config.yml`\
- **Loki** : `loki-config.yml`\
- **Alertmanager** : `alertmanager.yml`

### Configuration\
1\. Créez un répertoire `lostOps` à la racine du dépôt et placez-y les fichiers de configuration nécessaires (`prometheus.yml`, `promtail-config.yml`, `loki-config.yml`, `alertmanager.yml`).\
2\. Mettez à jour les volumes dans le `docker-compose.yml` pour pointer vers les fichiers de configuration.\
3\. Lancez les conteneurs avec `docker-compose up -d`.

### Identifiants par Défaut\
- **Grafana** : utilisateur `admin` et mot de passe `admin`.\
- **Uptime-Kuma** : utilisateur `admin` et mot de passe `admin1`.

### Avantages de cette Configuration\
- **Surveillance complète** : Visibilité sur l'état et les performances des systèmes et applications.\
- **Gestion centralisée des logs** : Collecte et gestion des logs à partir de différentes sources.\
- **Alertes et notifications** : Configuration des alertes pour réagir rapidement aux incidents.\
- **Visualisation puissante** : Utilisation de Grafana pour créer des tableaux de bord interactifs et informatifs.

### Conclusion\
Cette solution de monitoring avec Docker offre une approche intégrée et automatisée pour surveiller, collecter et analyser les métriques et les logs, facilitant ainsi la gestion proactive des infrastructures et des applications.