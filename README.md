# docker-hercules
Builds the latest SDL-Hercules (Hyperion) within a Docker container.

## How to build
```
docker build -t m3-repos/hercules https://github.com/m3-repos/docker-hercules.git
```

## How to run
By default, hercules runs within this container as a non-root user. In order to run in unprivileged mode, the `NET_ADMIN`[^net_admin] and `SYS_NICE`[^sys_nice] Linux capabilities must be granted by providing the option `--cap-add=NET_ADMIN,SYS_NICE`.[^capabilities]

- Use the options `-it` (`-i`, `-t`) to launch an interactive session. 
- Alternatively, specify `-d` to launch the container in daemon mode. 
- Use the option `-p` to publish ports defined in `HERCULES_CNF`.

Example (Interactive Panel):
```
docker run -it -p3270:3270 -p8081:8081 --cap-add=NET_ADMIN,SYS_NICE ghcr.io/m3-repos/hercules
```

To IPL the system, use the `-v=` option to create a bind mount of the host directory containing necessary configuration and storage files under a subdirectory of `/home/hercules/` within the container. Use the `-w=` option to set the container's `WORKDIR` to the mount destination.

Example (Volume Bind Mount):
```
export src_dir="$(pwd)/MAINFRAME"
export dest_dir="/home/hercules/MAINFRAME"

docker run -d \
        --cap-add=NET_ADMIN,SYS_NICE \
        -p 127.0.0.1:3270:3270 -p8081:8081 \
        -v="$src_dir":"$dest_dir" \
        -w="$dest_dir" m3-repos/hercules
```

Hercules will look for machine and runtime configuration files named `hercules.cnf` and `hercules.rc` in the working directory. Explicitly set relative paths to configuration files at runtime by using the `-e=` option to set environment variables: 

```
docker run -d \
        --cap-add=NET_ADMIN,SYS_NICE \
        -p 127.0.0.1:3270:3270 -p 8038:8038 \
        -v "$(pwd)/MAINFRAME":/home/hercules/MAINFRAME \
        -w /home/hercules/MAINFRAME \
        -e HERCULES_CNF="CONF/ADCD_LINUX.CONF" \
        -e HERCULES_RC="hercules.rc" \
        m3-repos/hercules:latest
```

Alternatively, all necessary configuration and storage files can be copied into a new container image build.

Dockerfile:
```
FROM ghcr.io/m3-repos/hercules:latest

WORKDIR /home/hercules/MAINFRAME
COPY --chown=hercules:hercules . /home/hercules/MAINFRAME/

#ENV HERCULES_CNF="hercules.cnf" HERCULES_RC="hercules.rc"
#EXPOSE 3270/tcp 8081/tcp

CMD ["hercules"]
```

[^net_admin]: Allows performing various network-related operations.
[^sys_nice]: Allows raising process nice value (nice(2), setpriority(2)) and changing the nice value for arbitrary processes.
[^capabilities]: See [Hercifc and Hercules as setuid root programs](https://github.com/SDL-Hercules-390/hyperion/blob/master/readme/README.SETUID.md).
