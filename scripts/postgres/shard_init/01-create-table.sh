#!/bin/bash
set -e
set -u

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
CREATE TYPE comment_status AS ENUM ('new', 'under_moderation', 'moderation_failed', 'moderation_passed');

CREATE TABLE $SHARDED_TABLE (
      id bigserial,
      user_id int not null,
      item_id int not null,
      comment varchar(512) not null,
      status_id comment_status
);

CREATE INDEX idx_comment_item_id ON $SHARDED_TABLE(item_id);
EOSQL
