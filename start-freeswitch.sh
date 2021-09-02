#!/bin/bash

set -euo pipefail

# Wait until PostgreSQL started
pg_isready -t 10

# Start server.
echo 'Starting Freeswitch...'
/usr/bin/freeswitch -u www-data -g www-data  -rp -nonat
