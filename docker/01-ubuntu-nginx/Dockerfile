FROM ubuntu:20.04

USER root

# update and install additional packages
RUN apt-get update && \
    apt-get install -y nginx 

COPY ./start-services.sh /start-services.sh
RUN chmod +x /start-services.sh

ENTRYPOINT ["/start-services.sh"]

# Default ENTRYPOINT: /bin/sh -c
# Keep the container alive
# ENTRYPOINT ["tail", "-f", "/dev/null"]


#### BUILD and RUN ####
# docker build -t ubuntu:services-example . && docker run -d -p 8080:80 ubuntu:services-example