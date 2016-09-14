#!/bin/bash
psql=( psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" )

psql -v ON_ERROR_STOP=1 postgres postgres <<SQL
DROP DATABASE IF EXISTS $POSTGRES_DB;
CREATE DATABASE "$POSTGRES_DB";
SQL

for f in /db/schema/*; do
	case "$f" in
		*.sh)     echo "$0: running $f"; . "$f" ;;
		*.sql)    echo "$0: running $f"; "${psql[@]}" -f "$f"; echo ;;
		*.sql.gz) echo "$0: running $f"; gunzip -c "$f" | "${psql[@]}"; echo ;;
		*)        echo "$0: ignoring $f" ;;
	esac
	echo
done
