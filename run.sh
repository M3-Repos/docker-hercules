#!/bin/bash

docker run -d -u root -p 3270:3270 -p 8038:8038 -v $(pwd)/MAINFRAME:/home/hercules/MAINFRAME mainframe-container:latest
