if [[ $# < 2 ]]; then
    echo "usage: bash backup.sh (frontend | backend | both) backupname"
    exit 1
fi
if [[ $1 == frontend || $1 == both ]]; then
    echo "Restoring frontend from backups/$2/frontend"
    mkdir -p backups/$2/frontend/
    cp backups/$2/frontend/* frontend/public/data/
fi
if [[ $1 == backend || $1 == both ]]; then
    echo "Restoring backend from backups/$2/backend"
    mkdir -p backups/$2/backend/
    cp backups/$2/backend/* backend/data/
fi
