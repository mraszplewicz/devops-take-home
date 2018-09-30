FROM microsoft/azure-cli:2.0.46

#install terraform
ENV TERRAFORM_VERSION=0.11.8

RUN apk add --update git curl openssh && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip > terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin && \
    rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

COPY deploy/entrypoint.sh /usr/local/bin/
COPY deploy/terraform /app/

WORKDIR /app

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]