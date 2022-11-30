#! /usr/bin/bash

# Get the IDs of existing db clusters (we know there's only 1 for now)
db_cluster_id=$(doctl databases list --no-header --format ID)

# Get the password for the doadmin user
doadmin_password=$(doctl databases user get ${db_cluster_id} doadmin --format Password --no-header)

echo "postgresql://doadmin:${doadmin_password}@private-pg-cluster-do-user-9096478-0.b.db.ondigitalocean.com:25060/clj?sslmode=require"
