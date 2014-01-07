#!/bin/bash

cd ~

diff -r -x '.git' OPS-QAC1/ingestion OPS/ingestion
diff -r -x '.git' OPS-QAC1/postgresql OPS/postgresql
diff -r -x '.git' OPS-QAC1/authorization OPS/authorization
