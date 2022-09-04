#!/bin/bash
podman build -v $HOME/.cache/pip:/root/.cache/pip --iidfile=.dockerid .