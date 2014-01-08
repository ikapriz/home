#!/bin/bash

cd ~

diff -r -x '.git' OPS-QAC1/ingestion OPS/ingestion
diff -r -x '.git' OPS-QAC1/postgresql OPS/postgresql
diff -r -x '.git' OPS-QAC1/authorization OPS/authorization
diff -r -x '.git' DB-OPS-QAC1/mongodba DB-OPS/mongodba
diff -r -x '.git' DB-OPS-QAC1/postgresdba DB-OPS/postgresdba
