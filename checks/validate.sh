#!/usr/bin/env bash

# Exit on error. Append "|| true" if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail
# Turn on traces, useful while debugging but commented out by default
# set -o xtrace

workdir=$PWD

cd $workdir/example

terraform fmt --recursive ..

terraform init -reconfigure -upgrade -backend=true

terraform validate

terraform plan -out=$workdir/example/tfplan -input=false

terraform-compliance -f $workdir/checks/ -p $workdir/example/tfplan
