import pytest
import os
from pythonapp.app import app

name = os.environ.get("NAME")

@pytest.fixture
def client():
    client = app.test_client()

    yield client

def test_hello_goodbye(client):
    hello_response = client.get("/hello")
    goodbye_response = client.get("/exit")
    hello_output = hello_response.data.decode()
    goodbye_output = goodbye_response.data.decode()
    output = f"{hello_output} & {goodbye_output}"
    assert output == f"Hello, {name}! & Goodbye, {name}!"