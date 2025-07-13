#!/bin/bash

docker run -d \
	--cap-add=SYS_NICE,NET_ADMIN \
	-p 127.0.0.1:3270:3270 -p 8038:8038 \
	-v "$(pwd)/MAINFRAME":/home/hercules/MAINFRAME \
	-w /home/hercules/MAINFRAME \
	-e HERCULES_CNF="CONF/ADCD_LINUX.CONF" \
	-e HERCULES_RC="hercules.rc" \
	m3-repos/hercules:latest
