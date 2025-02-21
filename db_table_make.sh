#!/bin/bash

psql --version

CREATE_TARGET_TABLE="test_table" # insert your create target table
CREATE_TARGET_DB="test_db" # insert your create target db
DB_NAME="postgres"
DB_USER="postgres"

# password check
echo -e "\033[33m Please enter the password for user '$DB_USER': \033[0m"
read -s DB_PASSWORD  # read input '-s': not show terminal 

# password value keep
export PGPASSWORD=$DB_PASSWORD

# DB connect check
psql -U $DB_USER -d $DB_NAME -c "SELECT 1" &>/dev/null
if [[ $? -ne 0 ]]; then
    echo -e "\033[31m Failed to connect to the database '$DB_NAME'. Exiting...\033[0m"
    unset PGPASSWORD
    exit 1
fi

# Create target Database check
DB_EXISTS=$(psql -U $DB_USER -d $DB_NAME -tAc "SELECT 1 FROM pg_database WHERE datname = '$CREATE_TARGET_DB';")
if [[ -z "$DB_EXISTS" ]]; then
    echo -e "\033[31m Database '$CREATE_TARGET_DB' does not exist. Creating database...\033[0m"
    # If not create Database
    psql -U $DB_USER -d $DB_NAME <<EOF
CREATE DATABASE $CREATE_TARGET_DB;
\q
EOF
    echo -e "\033[32mDatabase '$CREATE_TARGET_DB' created.\033[0m"
else 
    echo -e "\033[32mDatabase '$CREATE_TARGET_DB' is using.\033[0m"
fi

# table check
TABLE_EXISTS=$(psql -U $DB_USER -d $CREATE_TARGET_DB -tAc "SELECT to_regclass('public.$CREATE_TARGET_TABLE');")

# if table using, exit
if [[ -n "$TABLE_EXISTS" ]]; then
    echo -e "\033[34m Table is now using '$CREATE_TARGET_TABLE'. Exiting...\033[0m"
    unset PGPASSWORD
    exit 0
fi

# table create
echo -e "\033[33m Creating table...\033[0m"
psql -U $DB_USER -d $CREATE_TARGET_DB <<EOF
CREATE TABLE public.$CREATE_TARGET_TABLE(
    index serial PRIMARY KEY,
    test_string VARCHAR(32),
    test_time TIMESTAMP
    );
SELECT * FROM public.$CREATE_TARGET_TABLE;
SELECT NOW();
\q
EOF

echo -e "\033[32m finish table create\033[0m"
unset PGPASSWORD # free password