FROM debian:latest

RUN apt update

WORKDIR /srv

ADD install_requirements.sh /
RUN /install_requirements.sh
