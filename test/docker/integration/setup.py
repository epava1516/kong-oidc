#!/usr/bin/env python3

import os
from collections import namedtuple

from keycloak_client import KeycloakClient
from kong_client import KongClient

local_ip       = os.getenv("IP", default="")
discovery_host = os.getenv("DISCOVERY_HOST", default=local_ip)
host           = "localhost"
env_file_path  = ".env"

Config = namedtuple("Config", [
    "keycloak_endpoint",
    "keycloak_realm",
    "keycloak_admin",
    "keycloak_password",
    "client_id",
    "client_secret",
    "discovery",
    "kong_endpoint",
    "upstream_url"
])

def validate_discovery_host_set():
    if discovery_host == "":
        raise Exception("DISCOVERY_HOST or IP environment variable not set. See README.md for further instructions.")

"""
Attempt to pull in environment variables from .env file
Returns {"KONG_TAG": "", "KONG_DB_TAG": ":10.1" ...}
"""
def get_env_vars():
    with open(env_file_path) as f:
        lines = [l.rstrip().split("=", maxsplit=1) 
                 for l in f 
                 # Skip blank lines and comments
                 if l.strip() != "" and not l.startswith("#")]

    return {l[0]: l[1] for l in lines}

def get_config(env):
    keycloak_base_path = env.get("KEYCLOAK_BASE_PATH", "").rstrip("/")
    keycloak_url   = "http://{}:{}{}".format(host, env["KEYCLOAK_PORT"], keycloak_base_path)
    discovery_path = "{}/realms/master/.well-known/openid-configuration".format(keycloak_base_path)
    discovery_port = env["KEYCLOAK_PORT"]

    if discovery_host != local_ip and discovery_host not in ("localhost", "127.0.0.1"):
        discovery_port = env["KEYCLOAK_CONTAINER_PORT"]

    return Config(
        keycloak_endpoint = keycloak_url,
        keycloak_realm    = "master",
        keycloak_admin    = env["KEYCLOAK_USER"],
        keycloak_password = env["KEYCLOAK_PW"],
        client_id         = "kong",
        client_secret     = "secret",
        discovery         = "http://{}:{}{}".format(discovery_host, discovery_port, discovery_path),
        kong_endpoint     = "http://{}:{}".format(host, env["KONG_HTTP_ADMIN_PORT"]),
        upstream_url      = "http://httpbin:8080"
    )

if __name__ == '__main__':
    validate_discovery_host_set()

    print("Reading environment vars from {}".format(env_file_path))
    env    = get_env_vars()
    config = get_config(env)

    print("Creating Keycloak HTTP Client at {}".format(config.keycloak_endpoint))
    kc_client = KeycloakClient(config.keycloak_endpoint,
                               config.keycloak_realm,
                               config.keycloak_admin,
                               config.keycloak_password)

    print("Creating Keycloak client: {}".format(config.client_id))
    kc_client.create_client(config.client_id, config.client_secret)

    print("Creating Kong HTTP Admin Client at {}".format(config.kong_endpoint))
    kong_client = KongClient(config.kong_endpoint)

    print("Configuring Kong services, routes, and plugins for testing")
    kong_client.delete_service("httpbin")
    kong_client.create_service("httpbin", config.upstream_url)
    kong_client.create_route("httpbin", ["/httpbin"])
    kong_client.create_plugin("oidc", "httpbin", {
        "client_id":     config.client_id,
        "client_secret": config.client_secret,
        "discovery":     config.discovery,
        "logout_path":   "/httpbin/logout",
    })

    print("Environment setup complete")
