#!/usr/bin/env python3

import os
from urllib.parse import parse_qs, urlparse

import requests


host = "localhost"
env_file_path = ".env"


def get_env_vars():
    with open(env_file_path) as env_file:
        lines = [
            line.rstrip().split("=", maxsplit=1)
            for line in env_file
            if line.strip() != "" and not line.startswith("#")
        ]

    return {line[0]: line[1] for line in lines}


def assert_plugin_configured(admin_url):
    response = requests.get(f"{admin_url}/services/httpbin/plugins")
    response.raise_for_status()
    plugins = response.json()["data"]
    oidc_plugins = [plugin for plugin in plugins if plugin["name"] == "oidc"]

    if len(oidc_plugins) != 1:
        raise AssertionError("Expected exactly one oidc plugin on service httpbin")

    plugin = oidc_plugins[0]
    if plugin["config"]["client_id"] != "kong":
        raise AssertionError("Unexpected client_id in oidc plugin config")


def assert_proxy_redirect(proxy_url):
    response = requests.get(f"{proxy_url}/httpbin", allow_redirects=False)
    if response.status_code != 302:
        raise AssertionError(f"Expected 302 from protected route, got {response.status_code}")

    location = response.headers.get("Location", "")
    if "protocol/openid-connect/auth" not in location:
        raise AssertionError("Redirect location does not point to the OIDC authorization endpoint")

    query = parse_qs(urlparse(location).query)
    if query.get("client_id") != ["kong"]:
        raise AssertionError("Redirect location does not contain the configured client_id")
    if query.get("response_type") != ["code"]:
        raise AssertionError("Redirect location does not request the authorization code flow")
    if "redirect_uri" not in query:
        raise AssertionError("Redirect location does not include redirect_uri")


if __name__ == "__main__":
    env = get_env_vars()
    admin_url = f"http://{host}:{env['KONG_HTTP_ADMIN_PORT']}"
    proxy_url = f"http://{host}:{env['KONG_HTTP_PROXY_PORT']}"

    assert_plugin_configured(admin_url)
    assert_proxy_redirect(proxy_url)
    print("Integration smoke tests passed")
