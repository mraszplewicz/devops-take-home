FROM microsoft/azure-cli:2.0.46

#install terraform
ENV TERRAFORM_VERSION=0.11.8

RUN apk add --update git curl openssh && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip > terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin && \
    rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && rm -rf /var/cache/apk/*

#install docker cli
ARG DOCKER_CLI_VERSION="18.03.0-ce"
ENV DOCKER_DOWNLOAD_URL="https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_CLI_VERSION.tgz"

RUN mkdir -p /tmp/download \
    && curl -L $DOCKER_DOWNLOAD_URL | tar -xz -C /tmp/download \
    && mv /tmp/download/docker/docker /usr/local/bin/ \
    && rm -rf /tmp/download

COPY deploy/entrypoint.sh /usr/local/bin/
COPY deploy/terraform/ /app/
COPY . /src

WORKDIR /app

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]