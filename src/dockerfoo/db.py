import os
from contextlib import contextmanager
from typing import Iterator

from sqlalchemy import Engine, create_engine
from sqlalchemy.orm import Session

from dockerfoo.util import urls


def get_engine() -> Engine:
    arg_url = os.getenv("DOCKERFOO_DATABASE_URL")

    if arg_url is None:
        raise Exception("Missing environment variable: DOCKERFOO_DATABASE_URL")

    password = open("/run/secrets/database_password").read().strip()
    url = urls.replace_password(url=arg_url, new_password=password)
    return create_engine(url)


@contextmanager
def get_session() -> Iterator[Session]:
    with Session(get_engine()) as session:
        yield session
