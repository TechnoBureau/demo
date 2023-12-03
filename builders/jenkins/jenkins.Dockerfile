ARG jenkins=bitnami/jenkins
ARG baseruntime=${jenkins}
ARG buildnumber=1

FROM ${baseruntime}

USER 0

# Install Docker in the Bitnami Jenkins image
RUN install_packages docker

# Copy the custom entrypoint script
COPY ./jenkins/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN mkdir -p /opt/softwareag/Licenses/3rdparty

COPY ./jenkins/bitnami-license-terms.pdf /opt/softwareag/Licenses/3rdparty/bitnami-license-terms.pdf

USER 1001

# Set the custom entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]