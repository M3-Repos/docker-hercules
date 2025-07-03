#!/bin/bash

docker run -d -u root -p 127.0.0.1:3270:3270 -p 8038:8038 -v $(pwd)/MAINFRAME:/home/hercules/MAINFRAME m3-repos/hercules:latest
