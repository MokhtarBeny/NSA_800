#!/bin/sh
# docker-entrypoint.sh

# Attendre que MySQL soit prêt
until mysql -h db -u app_user -papp_password -e "SELECT 1"; do
    echo 'En attente de MySQL...'
    sleep 1
done

echo 'MySQL est prêt!'

# Exécute les migrations Laravel
php artisan migrate

# Démarrer Apache en arrière-plan
exec apache2-foreground
