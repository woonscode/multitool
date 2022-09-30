import pytest
import os
from pythonapp.app import app

name = os.environ.get("NAME")

@pytest.fixture
def client():
    client = app.test_client()

    yield client

def test_hello(client):
    response = client.get("/hello")
    output = response.data.decode()
    assert output == f"Hello, {name}!"

def test_bye(client):
    response = client.get("/exit")
    output = response.data.decode()
    assert output == f"Goodbye, {name}!"