# Stage 1
FROM hugomods/hugo:latest AS build

WORKDIR /opt/HugoApp

# Copy Hugo config into the container Workdir.
COPY . .

# Run Hugo in the Workdir to generate HTML.
RUN hugo

# Official Image is  https://quay.io/oauth2-proxy/oauth2-proxy
FROM bitnami/oauth2-proxy:latest
# Copy in the local proxy-config.yaml file into the container.
# COPY proxy-config.cfg /proxy-config.yaml
COPY proxy-alpha-config.yaml /proxy-alpha-config.yaml

# Copy the public folder from the build container to the public folder in the oauth2-proxy container.
# This is the output of the Hugo build which are the static files.
# The last parameter should match to the proxy-config.yaml file upstream `upstream: file://staticSite`
COPY --from=build /opt/HugoApp/public /staticSite

EXPOSE 8080
# the forward slashes here are important.
CMD ["oauth2-proxy", "--alpha-config", "/proxy-alpha-config.yaml", "--email-domain=*"]

