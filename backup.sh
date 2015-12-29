if [[ $# < 2 ]]; then
    echo "usage: bash backup.sh (frontend | backend | both) backupname"
    exit 1
fi
if [[ $1 == frontend || $1 == both ]]; then
    echo "Backing up frontend to backups/$2/frontend"
    mkdir -p backups/$2/frontend/
    cp frontend/public/data/* backups/$2/frontend/
    ls backups/$2/frontend
fi
if [[ $1 == backend || $1 == both ]]; then
    echo "Backing up backend to backups/$2/backend"
    mkdir -p backups/$2/backend/
    cp backend/data/* backups/$2/backend/
    if [[ $? == 0 ]]; then
        echo "Clearing backend data"
        rm backend/data/*
    else
        echo "Error copying, not clearing backend data"
    fi
    ls backups/$2/backend
fi
