ARG BASE_IMAGE
FROM ${BASE_IMAGE}

EXPOSE 2222 80

RUN apt-get update && \
    apt-get install -y --no-install-recommends openssh-server dialog && \
    echo "root:Docker!" | chpasswd

COPY components/sshd_config /etc/ssh/
COPY components/start.sh /azure-functions-host/
RUN chmod +x /azure-functions-host/start.sh && \
    chmod +x /opt/startup/install_ca_certificates.sh

ENTRYPOINT ["/azure-functions-host/start.sh"]