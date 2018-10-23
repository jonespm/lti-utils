#!/bin/bash

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
'release')
    echo "Releasing via Docker"
    # This command runs docker, it mounts local directories /.m2 to improve recompilation, .gnupg for release and the local directory as the app directory
    # This needs to use the "non-slim" maven docker build that includes gpg
    docker run --rm -it --name lti-utils-build \
    -e "MAVEN_OPTS= -XX:+TieredCompilation -XX:TieredStopAtLevel=1" \
    -v "${HOME}"/.m2:/root/.m2 \
    -v "${HOME}"/.gitconfig:/root/.gitconfig \
    -v "${HOME}"/.ssh:/root/.ssh \
    -v "${HOME}"/.gnupg:/root/.gnupg \
    -v $(dirname $SSH_AUTH_SOCK):$(dirname $SSH_AUTH_SOCK) \
    -e SSH_AUTH_SOCK=$SSH_AUTH_SOCK \
    -v "${PWD}:/usr/src/app" \
    -w /usr/src/app maven:3.5.4-jdk-8 \
    /bin/bash -c "mvn release:clean release:prepare && mvn release:perform" 
;;
'rollback')
    echo "Rollback via docker"
    # This command runs docker, it mounts local directories /.m2 to improve recompilation, .gnupg for release and the local directory as the app directory
    # This needs to use the "non-slim" maven docker build that includes gpg
    docker run --rm -it --name lti-utils-build \
    -e "MAVEN_OPTS= -XX:+TieredCompilation -XX:TieredStopAtLevel=1" \
    -v "${HOME}"/.m2:/root/.m2 \
    -v "${HOME}"/.gitconfig:/root/.gitconfig \
    -v "${HOME}"/.ssh:/root/.ssh \
    -v "${HOME}"/.gnupg:/root/.gnupg \
    -v $(dirname $SSH_AUTH_SOCK):$(dirname $SSH_AUTH_SOCK) \
    -e SSH_AUTH_SOCK=$SSH_AUTH_SOCK \
    -v "${PWD}:/usr/src/app" \
    -w /usr/src/app maven:3.5.4-jdk-8 \
    /bin/bash -c "mvn release:rollback" 
;;
*)
echo "Usage: $0 [install|release]"
;;
esac
