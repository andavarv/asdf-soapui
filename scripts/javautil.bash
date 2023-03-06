#!/usr/bin/env bash

exec asdf local java adoptopenjdk-jre-11.0.13+8 || echo 'already selected'
