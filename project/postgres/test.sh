#!/bin/bash
TESTS="/db/test/*.sql"

echo "Running tests: $TESTS"
# install pgtap
PGPASSWORD=$POSTGRES_PASSWORD psql -h localhost -p 5432 -d $POSTGRES_DB -U $POSTGRES_USER -f /pgtap/sql/pgtap.sql >/dev/null 2>&1

rc=$?
# exit if pgtap failed to install
if [[ $rc != 0 ]] ; then
  echo "pgTap was not installed properly. Unable to run tests!"
  exit $rc
fi
# run the tests
PGPASSWORD=$POSTGRES_PASSWORD pg_prove -h localhost -p 5432 -d $POSTGRES_DB -U $POSTGRES_USER $TESTS
rc=$?
# uninstall pgtap
PGPASSWORD=$POSTGRES_PASSWORD psql -h localhost -p 5432 -d $POSTGRES_DB -U $POSTGRES_USER -f /pgtap/sql/uninstall_pgtap.sql >/dev/null 2>&1
# exit with return code of the tests
exit $rc
