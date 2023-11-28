ARG BASE_IMAGE
FROM ${BASE_IMAGE}
RUN apt-get update && apt-get install -y openssl 
RUN openssl genrsa -out ca.key 2048
RUN openssl req -new -x509 -key ca.key -out ca.crt -days 365 -subj "/CN=COOPER"
RUN mkdir -p /var/ssl/root
RUN mv ca.crt /var/ssl/root
