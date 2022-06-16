#!/bin/bash
set -e
set -u

psql -v ON_ERROR_STOP=1 --username "$APP_DB_USER" --dbname "$SHARDED_DATABASE" <<-EOSQL
CREATE TYPE comment_status AS ENUM ('new', 'under_moderation', 'moderation_failed', 'moderation_passed');

CREATE TABLE comment (
     id bigserial,
     user_id int not null,
     item_id int not null,
     comment varchar(512) not null,
     status_id comment_status
) PARTITION BY HASH (id);
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$SHARDED_DATABASE" <<-EOSQL
CREATE FOREIGN TABLE comment_1 PARTITION OF comment FOR VALUES WITH (MODULUS 2, remainder 0) SERVER shard1;
CREATE FOREIGN TABLE comment_2 PARTITION OF comment FOR VALUES WITH (MODULUS 2, remainder 1) SERVER shard2;
EOSQL
