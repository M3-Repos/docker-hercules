# Hercules Docker Repo

Create a docker container of the newest hercules from source

## Build container

`docker build --tag "mainframed767/hercules:latest" .`

## Run container 

`docker run -it -u root -p 3270:3270 -p 8038:8038 -v $(pwd)/MAINFRAME:/home/hercules/MAINFRAME mainframed767/hercules:latest`

*MAINFRAME directory contains essential mainframe image, config and other files`
