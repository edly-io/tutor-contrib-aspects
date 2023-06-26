#!/usr/bin/env bash

python3 -m venv virtualenv
. virtualenv/bin/activate

echo "Installing dbt packages..."
pip install pip install {{ DBT_PACKAGES }}

echo "Installing aspects-dbt"
git clone -b {{ DBT_BRANCH }} {{ DBT_REPOSITORY }}

cd aspects-dbt/aspects || exit

echo "Installing dbt dependencies"
dbt deps --profiles-dir /app/aspects/scripts/aspects/

echo "Running dbt"
dbt run --profiles-dir /app/aspects/scripts/aspects/