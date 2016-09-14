#!/bin/bash
# This is a shell script to read the desired login passwords from the environment
set -e

psql -v ON_ERROR_STOP=1 "$POSTGRES_DB" "$POSTGRES_USER" <<-EOSQL
  CREATE EXTENSION postgis;

  -- userreg is used to create new endusers
  DROP ROLE IF EXISTS whereuat_userreg;
  CREATE ROLE whereuat_userreg
    LOGIN PASSWORD '$WHEREUAT_USERREG_PASS';

  -- app is used by everything but user registration
  -- it can't do anything in and of itself, except login
  -- it's granted access to end user roles during registration, so that it can do SET ROLE and assume that identity
  DROP ROLE IF EXISTS whereuat_app;
  CREATE ROLE whereuat_app
    WITH LOGIN PASSWORD '$WHEREUAT_APP_PASS';

  -- endusers represent actual end users
  DROP ROLE IF EXISTS whereuat_enduser;
  CREATE ROLE whereuat_enduser;
EOSQL
