FROM jenkins/jenkins:lts-jdk17

USER root

# Docker CLI only (no daemon) — talks to the host's Docker daemon through
# the /var/run/docker.sock socket mounted in at runtime (docker-outside-of-docker).
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl gnupg lsb-release unzip \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*

# Terraform CLI, used by the pipeline to run `terraform apply`.
ARG TERRAFORM_VERSION=1.9.5
RUN curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_$(dpkg --print-architecture).zip" -o terraform.zip \
    && unzip terraform.zip -d /usr/local/bin \
    && rm terraform.zip

USER jenkins
