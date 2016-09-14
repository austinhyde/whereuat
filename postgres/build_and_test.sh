#!/bin/bash
set -e
/build.sh
exec /test.sh
