ARG KONG_BASE_TAG=:2.8.0-ubuntu
ARG KONG_BASE_DIGEST=sha256:025cd6086dd1809a98b5997426b5150693acf874f1a1224468e08cec8d2c7d93
FROM kong${KONG_BASE_TAG}@${KONG_BASE_DIGEST}

USER root

ENV KONG_PLUGINS=bundled,oidc

WORKDIR /usr/local/src/kong-oidc

COPY kong-plugin-oidc-1.4.0-1.rockspec ./
COPY kong/ ./kong/

RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc unzip \
    && luarocks install https://luarocks.org/manifests/daurnimator/luaossl-20190731-0.src.rock OPENSSL_DIR=/usr/local/kong CRYPTO_DIR=/usr/local/kong \
    && luarocks install https://luarocks.org/manifests/cdbattags/lua-resty-jwt-0.2.3-0.src.rock \
    && luarocks install https://luarocks.org/manifests/hanszandbelt/lua-resty-openidc-1.7.6-3.src.rock \
    && luarocks make kong-plugin-oidc-1.4.0-1.rockspec \
    && apt-get purge -y --auto-remove gcc unzip \
    && rm -rf /var/lib/apt/lists/* /usr/local/src/kong-oidc

USER kong
