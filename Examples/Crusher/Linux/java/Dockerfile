FROM ubuntu:jammy
RUN apt update && apt install -y libglib2.0-0
RUN apt-get install -y libstdc++6
RUN apt install -y software-properties-common
RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y dist-upgrade
ARG USER_NAME
ARG USER_ID
ARG GROUP_ID
RUN addgroup --gid $GROUP_ID $USER_NAME
RUN adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID $USER_NAME
RUN apt install nano
COPY . /path/to/target
