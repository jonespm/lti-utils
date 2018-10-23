#!/bin/bash

# This is a helper script to get this project installed and released via docker
# TODO: There's a lot of duplicate here in the release stages, should clean it up

case "$1" in
'install')
    echo "Installing via docker"
    # This command runs docker, it mounts local directories /.m2 to improve recompilation, .gnupg for release and the local directory as the app directory
    # This needs to use the "non-slim" maven docker build that includes gpg
    docker run --rm -it --name lti-utils-build \
    -e "MAVEN_OPTS= -XX:+TieredCompilation -XX:TieredStopAtLevel=1" \
    -v "${HOME}"/.m2:/root/.m2 \
    -v "${HOME}"/.gnupg:/root/.gnupg \
    -v "${PWD}:/usr/src/app" \
    -w /usr/src/app maven:3.5.4-jdk-8 \
    /bin/bash -c "mvn -T 1C -B install" 
;;
'agent')
    # This seems to be necessary to setup SSH for github release
    # https://github.com/nardeas/docker-ssh-agent
    echo "Setting up agent"
    AGENT="ssh_agent"
    OLD="$(docker ps --all --quiet --filter=name="$AGENT")"
    if [ -n "$OLD" ]; then
        docker stop $OLD && docker rm $OLD
    fi
    docker run -d --name=$AGENT nardeas/ssh-agent
    docker run --rm --volumes-from=$AGENT -v ~/.ssh:/.ssh -it nardeas/ssh-agent /bin/bash -c "ssh-add /root/.ssh/id_rsa && ssh-keyscan github.com >> ~/.ssh/known_hosts"
;;
'release-prepare')
    echo "Releasing via Docker"
    # This command runs docker, it mounts local directories /.m2 to improve recompilation, .gnupg for release and the local directory as the app directory
    # This needs to use the "non-slim" maven docker build that includes gpg
    docker run --rm -it --name lti-utils-build \
    --volumes-from=ssh-agent \
    -e SSH_AUTH_SOCK=/.ssh-agent/socket \
    -e "MAVEN_OPTS= -XX:+TieredCompilation -XX:TieredStopAtLevel=1" \
    -v "${HOME}"/.m2:/root/.m2 \
    -v "${HOME}"/.gitconfig:/root/.gitconfig \
    -v "${HOME}"/.gnupg:/root/.gnupg \
    -v "${PWD}:/usr/src/app" \
    -w /usr/src/app maven:3.5.4-jdk-8 \
    /bin/bash -c "mvn release:clean release:prepare" 
;;
'release-perform')
    echo "Releasing via Docker"
    # This command runs docker, it mounts local directories /.m2 to improve recompilation, .gnupg for release and the local directory as the app directory
    # This needs to use the "non-slim" maven docker build that includes gpg
    docker run --rm -it --name lti-utils-build \
    --volumes-from=ssh-agent \
    -e SSH_AUTH_SOCK=/.ssh-agent/socket \
    -e "MAVEN_OPTS= -XX:+TieredCompilation -XX:TieredStopAtLevel=1" \
    -v "${HOME}"/.m2:/root/.m2 \
    -v "${HOME}"/.gitconfig:/root/.gitconfig \
    -v "${HOME}"/.gnupg:/root/.gnupg \
    -v "${PWD}:/usr/src/app" \
    -w /usr/src/app maven:3.5.4-jdk-8 \
    /bin/bash -c "mvn release:clean mvn release:perform" 
;;
'dryrun-prepare')
    echo "Dry run release via Docker"
    # This command runs docker, it mounts local directories /.m2 to improve recompilation, .gnupg for release and the local directory as the app directory
    # This needs to use the "non-slim" maven docker build that includes gpg
    docker run --rm -it --name lti-utils-build \
    --volumes-from=ssh-agent \
    -e SSH_AUTH_SOCK=/.ssh-agent/socket \
    -e "MAVEN_OPTS= -XX:+TieredCompilation -XX:TieredStopAtLevel=1" \
    -v "${HOME}"/.m2:/root/.m2 \
    -v "${HOME}"/.gitconfig:/root/.gitconfig \
    -v "${HOME}"/.gnupg:/root/.gnupg \
    -v "${PWD}:/usr/src/app" \
    -w /usr/src/app maven:3.5.4-jdk-8 \
    /bin/bash -c "mvn release:clean release:prepare -DdryRun=true" 
;;

*)
echo "Usage: $0 [install|agent|release-prepare|dryrun-prepare|release-perform]"
;;
esac
