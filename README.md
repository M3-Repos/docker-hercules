# Hercules Docker Repo

Create a docker container of the newest hercules from source

## Build container

`docker build --tag "m3-repos/hercules:latest" .`

## Run container 

`docker run -it -u root -p 3270:3270 -p 8038:8038 -v $(pwd)/MAINFRAME:/home/hercules/MAINFRAME m3-repos/hercules:latest`

*MAINFRAME directory contains essential mainframe image, config and other files`
