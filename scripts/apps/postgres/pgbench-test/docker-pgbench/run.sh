#!/bin/bash

function check_pgbench_tables() {
  psql --set 'ON_ERROR_STOP=' <<-EOSQL
    DO \$\$
      DECLARE
        pgbench_tables CONSTANT text[] := '{ "pgbench_branches", "pgbench_tellers", "pgbench_accounts", "pgbench_history" }';
        tbl text;
      BEGIN
        FOREACH tbl IN ARRAY pgbench_tables LOOP
          IF NOT EXISTS (
            SELECT 1
            FROM pg_catalog.pg_class c
            JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
            WHERE n.nspname = 'public'
            AND c.relname = tbl
            AND c.relkind = 'r'
          ) THEN 
            RAISE EXCEPTION 'pgbench table "%" does not exist!', tbl;
          END IF;
        END LOOP;
      END 
    \$\$;
EOSQL
  psql_status=$?
  
  case $psql_status in
    0) echo "All pgbench tables exist! We can begin the benchmark" ;;
    1) echo "psql encountered a fatal error!" ;;
    2) echo "psql encountered a connection error!" ;;
    3) echo "One or more tables was missing! Initializing the database.";;
  esac

  return $psql_status
}

function initialize_pgbench_tables() {
  echo '*********** Initializing pgbench tables ************'
  pgbench -i -F ${FILL_FACTOR:=100} -s ${SCALE_FACTOR:=100} --foreign-keys
}

export PGDATABASE=pgbench
export PGUSER=pgbench
export PGPASSWORD=${PGBENCH_PASSWORD}
export PGHOST=localhost
export PGPORT=5432

echo '*************** Waiting for postgres ***************'
echo '**                                                **'
echo "** PGDATABASE: ${PGDATABASE}                      **"
echo "** PGHOST:     ${PGHOST}                          **"
echo "** PGPORT:     ${PGPORT}                          **"
echo "** PGUSER:     ${PGUSER}                          **"
echo '**                                                **'
echo '****************************************************'

attempt=1
while (! pg_isready -t 1 ) && [[ $attempt -lt 100 ]]; do 
  sleep 1
done

if [[ $attempt -ge 100 ]]; then
  echo '!!!!                                          !!!!'
  echo '!!!!             BENCHMARK FAILED             !!!!'
  echo '!!!!                                          !!!!'
  echo '!!!!      postgres never became available     !!!!'
  echo '!!!!                                          !!!!'
  exit 1
fi

sleep 5

check_pgbench_tables

if [[ $? -eq 3 ]]; then
  echo "Initializing database..."
  initialize_pgbench_tables
elif [[ $? -ne 0 ]]; then
  echo "Exiting pgbench container..."
  exit $?
fi

echo '***************   Running pgbench    ***************'

run=0
while true; do
  run=$((run+1))
  echo Starting run $run
  pgbench -c $(($(nproc) * 4)) -j $(nproc) -M prepared -s ${SCALE_FACTOR} -T 300
  echo
  echo
done
