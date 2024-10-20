#!/bin/bash
podman build --no-cache -f ./Dockerfile -t alpine-apache-php:latest .