#!/bin/bash

cd ~

diff -r -x '.git' DB-OPS-QAC1/mongodba DB-OPS/mongodba
diff -r -x '.git' DB-OPS-QAC1/postgresdba DB-OPS/postgresdba
diff -r -x '.git' DB-OPS-QAC1/commondba DB-OPS/commondba
