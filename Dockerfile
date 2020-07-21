FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get --yes install rsync curl git zip openjdk-8-jdk python3 python3-pip
RUN pip3 install twine pytest
