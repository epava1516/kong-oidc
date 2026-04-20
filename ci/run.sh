#!/bin/bash
set -e

for f in test/unit/test_*.lua; do
  lua -lluacov "${f}" -o TAP --failure
done
