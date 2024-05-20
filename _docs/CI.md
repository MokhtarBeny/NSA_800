## Workflow de Scan de Sécurité avec Trivy

### Aperçu
Ce workflow GitHub Actions intègre Trivy, un scanner de sécurité open-source, pour détecter automatiquement les vulnérabilités dans les images Docker et le système de fichiers du dépôt à chaque push sur la branche principale `master`. Il garantit que les vulnérabilités de sécurité sont identifiées et traitées en temps opportun.

### Détails du Workflow
- **Déclencheur** : Activé à chaque événement `push` sur `master`.
- **Jobs** :
  1. **Checkout** : Récupère le code le plus récent du dépôt.
  2. **Construction de l'Image** : Construit une image Docker à partir du Dockerfile et le SHA du commit actuel.
  3. **Scan de Vulnérabilités de l'Image** : Analyse l'image Docker pour détecter les vulnérabilités, les résultats sont affichés sous forme de tableau.
  4. **Scan du Système de Fichiers** : Analyse le système de fichiers à la racine du dépôt, produit un fichier SARIF.
  5. **Upload du Fichier SARIF** : Télécharge le fichier SARIF dans l'onglet Sécurité de GitHub pour le suivi et la résolution des problèmes de sécurité.

### Configuration
1. Placez le fichier de workflow sous `.github/workflows/security_scan.yml`.
2. Assurez-vous que le Dockerfile se trouve à la racine de votre dépôt.

### Avantages de l'Utilisation de Trivy
- Haute précision et efficacité dans la détection des vulnérabilités.
- Supporte divers formats d'images de conteneurs.
- Intégration transparente avec GitHub Actions pour une sécurité continue.

## Workflow de Construction et Publication sur Docker Hub

### Aperçu
Ce workflow GitHub Actions est conçu pour automatiser la construction et la publication d'images Docker à Docker Hub à chaque modification du dépôt. Ce processus garantit que chaque nouvelle version de l'application est rapidement disponible pour le déploiement ou d'autres utilisations.

### Détails du Workflow
- **Déclencheur** : Se lance à chaque `push` dans le dépôt sur `master`.
- **Jobs** :
  1. **Checkout** : Récupère le code source du dépôt pour accéder au Dockerfile et aux autres fichiers nécessaires.
  2. **Construction de l'Image** : Construit une image Docker en utilisant `docker-compose`, facilitant la gestion de configurations multiples.
  3. **Étiquetage de l'Image** : Marque l'image nouvellement construite avec le SHA du commit Git pour une traçabilité améliorée.
  4. **Connexion à Docker Hub** : Utilise l'action `docker/login-action` pour se connecter à Docker Hub, préparant le système pour la publication.
  5. **Publication de l'Image** : Publie l'image sur Docker Hub sous le tag correspondant au SHA du commit.

### Configuration
1. Assurez-vous que le fichier de workflow est placé dans `.github/workflows/build_and_push.yml`.
2. Le Dockerfile et le docker-compose.yml doivent être correctement configurés à la racine du dépôt.
3. Utilisez les secrets GitHub pour sécuriser les informations d'identification de Docker Hub (`DOCKER_HUB_USERNAME` et `DOCKER_HUB_PAT`).

### Pourquoi Utiliser Ce Workflow ?
- Automatisation complète du processus de construction et de publication, réduisant le risque d'erreurs humaines et accélérant le déploiement.
- Traçabilité des builds avec tags SHA, permettant un suivi facile des versions et une gestion efficace des déploiements.