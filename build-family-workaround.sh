#!/bin/bash

docker build . -f Dockerfile.parent -t parent --no-cache
docker build --build-arg BUILDKIT_SYNTAX=docker/dockerfile:1.10.0 . -f Dockerfile.child-grandchild -t child-grandchild-1.10.0 --no-cache
