#!/bin/bash

docker build . -f Dockerfile.parent -t parent --no-cache
docker build . -f Dockerfile.child -t child --no-cache
docker build . -f Dockerfile.grandchild -t grandchild --no-cache
docker build . -f Dockerfile.child-grandchild -t child-grandchild --no-cache
