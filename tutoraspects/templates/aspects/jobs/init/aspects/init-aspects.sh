#!/usr/bin/env bash

## WARNING: If you modify this block, make sure to also update the
##          corresponding block in the alembic.sh file.

cd /app/aspects/migrations

alembic upgrade head

cd -

## WARNING: If you modify this block, make sure to also update the
##          corresponding block in the dbt.sh file.

echo "Installing dbt packages..."

pip install -r /app/aspects/dbt/requirements.txt

{% if DBT_SSH_KEY %}
mkdir -p /root/.ssh
echo "{{ DBT_SSH_KEY}}" | tr -d '\r' > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa
eval `ssh-agent -s`
ssh -o StrictHostKeyChecking=no git@github.com || true
ssh-add /root/.ssh/id_rsa
{% endif %}

rm -rf {{ DBT_REPOSITORY_PATH }}

echo "Installing aspects-dbt"
echo "git clone -b {{ DBT_BRANCH }} {{ DBT_REPOSITORY }}"
git clone -b {{ DBT_BRANCH }} {{ DBT_REPOSITORY }}

cd {{ DBT_REPOSITORY_PATH }} || exit

export ASPECTS_EVENT_SINK_DATABASE={{ASPECTS_EVENT_SINK_DATABASE}}
export ASPECTS_XAPI_DATABASE={{ASPECTS_XAPI_DATABASE}}

echo "Installing dbt dependencies"
dbt deps --profiles-dir /app/aspects/dbt/

echo "Running dbt $*"
dbt run --profiles-dir /app/aspects/dbt/

rm -rf {{ DBT_REPOSITORY_PATH }}
