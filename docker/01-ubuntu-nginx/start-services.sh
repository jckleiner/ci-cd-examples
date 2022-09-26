#!/bin/bash

echo "starting services..." && \
service nginx start && \
# Keep the container alive
tail -f /dev/null