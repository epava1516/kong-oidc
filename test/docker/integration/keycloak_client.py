import time

import requests

class KeycloakClient:
    _token_ready_timeout_seconds = 30
    _token_ready_poll_interval_seconds = 1

    def __init__(self, url, realm, username, password):
        self._endpoint = url.rstrip("/")
        self._realm = realm
        self._session  = requests.session()
        self._username = username
        self._password = password

    def discover(self, config_type = "openid-configuration"):
        res = self._session.get("{}/realms/{}/.well-known/{}".format(self._endpoint, self._realm, config_type))
        res.raise_for_status()
        return res.json()

    def create_client(self, name, secret):
        url     = "{}/admin/realms/master/clients".format(self._endpoint)
        payload = {
            "clientId": name,
            "secret": secret,
            "redirectUris": ["*"],
        }

        headers = self.get_auth_header()
        res     = self._session.post(url, json=payload, headers=headers)
        
        if res.status_code not in [201, 409]:
            raise Exception("Cannot Keycloak create client")

    def get_auth_header(self):
        return {
            "Authorization": f'Bearer {self.get_token("admin-cli")}'
        }

    def get_token(self, client_id):
        url = "{}/realms/{}/protocol/openid-connect/token".format(self._endpoint, self._realm)
        
        payload = f'client_id={client_id}&grant_type=password' + \
                  f'&username={self._username}&password={self._password}'

        headers = {
            "Content-Type": "application/x-www-form-urlencoded"
        }
        
        deadline = time.monotonic() + self._token_ready_timeout_seconds
        last_error = None

        while time.monotonic() < deadline:
            try:
                res = self._session.post(url, data=payload, headers=headers)
                res.raise_for_status()
                return res.json()["access_token"]
            except (requests.RequestException, KeyError) as err:
                last_error = err
                time.sleep(self._token_ready_poll_interval_seconds)

        raise Exception("Cannot obtain Keycloak admin token") from last_error
