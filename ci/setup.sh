#!/bin/bash
set -e

export LUA_VERSION=${LUA_VERSION:-5.1}
export KONG_VERSION=${KONG_VERSION:-0.13.1-0}
export LUA_RESTY_OPENIDC_VERSION=${LUA_RESTY_OPENIDC_VERSION:-1.7.6-3}

pip install hererocks
hererocks lua_install -r^ --lua=${LUA_VERSION}
export PATH=${PATH}:${PWD}/lua_install/bin

luarocks install kong ${KONG_VERSION}
luarocks install https://luarocks.org/manifests/openresty/lua-cjson-2.1.0.10-1.rockspec
luarocks install https://luarocks.org/manifests/bluebird75/luaunit-3.5-1.rockspec
luarocks install https://luarocks.org/manifests/mpeterv/luacov-0.13.0-1.src.rock
luarocks install https://luarocks.org/manifests/cdbattags/lua-resty-jwt-0.2.3-0.src.rock
luarocks install https://luarocks.org/manifests/hanszandbelt/lua-resty-openidc-${LUA_RESTY_OPENIDC_VERSION}.src.rock
