ARG KONG_BASE_TAG
FROM kong${KONG_BASE_TAG}
USER root

ENV LUA_PATH=/usr/local/share/lua/5.1/?.lua;/usr/local/kong-oidc/?.lua
# For lua-cjson
ENV LUA_CPATH=/usr/local/lib/lua/5.1/?.so

# Install unzip for luarocks, gcc for lua-cjson
RUN apt update && apt install -y unzip gcc curl
RUN luarocks install https://luarocks.org/manifests/mpeterv/luacov-0.13.0-1.src.rock
RUN luarocks install https://luarocks.org/manifests/bluebird75/luaunit-3.5-1.rockspec
RUN luarocks install https://luarocks.org/manifests/openresty/lua-cjson-2.1.0.10-1.rockspec
RUN luarocks install https://luarocks.org/manifests/daurnimator/luaossl-20190731-0.src.rock OPENSSL_DIR=/usr/local/kong CRYPTO_DIR=/usr/local/kong

# Change openidc version when version in rockspec changes
RUN luarocks install https://luarocks.org/manifests/hanszandbelt/lua-resty-openidc-1.7.6-3.src.rock

WORKDIR /usr/local/kong-oidc

COPY . .
