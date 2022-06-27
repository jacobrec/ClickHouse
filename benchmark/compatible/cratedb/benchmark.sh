#!/bin/bash

bash -c "$(curl -L https://try.crate.io/)" > crate.log 2>&1 &

sudo apt-get update
sudo apt-get install -y postgresql-client

psql -U crate -h localhost --no-password -t -c 'SELECT 1'

wget --continue 'https://datasets.clickhouse.com/hits_compatible/hits.tsv.gz'
gzip -d hits.tsv.gz

psql -U crate -h localhost --no-password -t -c 'CREATE DATABASE test'
psql -U crate -h localhost --no-password test -t < create.sql
psql -U crate -h localhost --no-password test -t -c '\timing' -c "\\copy hits FROM 'hits.tsv'"

#
#

./run.sh 2>&1 | tee log.txt

du -bcs crate-*

cat log.txt | grep -oP 'Time: \d+\.\d+ ms' | sed -r -e 's/Time: ([0-9]+\.[0-9]+) ms/\1/' |
    awk '{ if (i % 3 == 0) { printf "[" }; printf $1; if (i % 3 != 2) { printf "," } else { print "]," }; ++i; }'
