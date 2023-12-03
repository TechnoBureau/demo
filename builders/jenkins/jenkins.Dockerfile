ARG jenkins=bitnami/jenkins
ARG baseruntime=${jenkins}
ARG buildnumber=1
ARG VERSION=2.426.1

FROM ${baseruntime}

USER 0

# Install Docker in the Bitnami Jenkins image
RUN install_packages apt-transport-https ca-certificates curl gnupg2 software-properties-common

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

RUN add-apt-repository \
    "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/debian \
    $(lsb_release -cs) \
    stable"
RUN apt-get update && install_packages docker-ce docker-ce-cli containerd.io

RUN mkdir -p /opt/softwareag/Licenses/3rdparty

COPY ./jenkins/bitnami-license-terms.pdf /opt/softwareag/Licenses/3rdparty/bitnami-license-terms.pdf

USER 1001
