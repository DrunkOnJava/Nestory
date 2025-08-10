#!/bin/bash
# Move complex models to backup

cd /Users/griffin/Projects/Nestory/Foundation/Models

# Move complex models to backup
for file in Location.swift MaintenanceTask.swift PhotoAsset.swift Receipt.swift SchemaVersion.swift ShareGroup.swift Warranty.swift Item.swift.backup; do
    if [ -f "$file" ]; then
        mv "$file" ../Models.backup/
    fi
done

echo "Models moved to backup"
