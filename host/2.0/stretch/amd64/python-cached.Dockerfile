ARG BASE_IMAGE=local/python/deen
ARG BASE_IMAGE_TAG=2.0

FROM ${BASE_IMAGE}:${BASE_IMAGE_TAG}

COPY ./python-context/cached_start/cached_requirements.txt /usr/local/cached_requirements.txt
COPY ./python-context/cached_start/install_cache.py /usr/local/install_cache.py

RUN chmod +x /usr/local/cached_requirements.txt && \
    chmod +x /usr/local/install_cache.py

RUN python /usr/local/install_cache.py

# This is a monkey patch, we discuss whether this is a good thing.
COPY ./python-context/cached_start/start.sh /azure-functions-host/workers/python/start.sh
RUN chmod +x /azure-functions-host/workers/python/start.sh