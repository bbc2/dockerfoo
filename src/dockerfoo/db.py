import os
from contextlib import contextmanager
from typing import Iterator

from sqlalchemy import Engine, create_engine
from sqlalchemy.orm import Session

from dockerfoo.util import urls


def get_engine() -> Engine:
    arg_url = os.getenv("DOCKERFOO_DATABASE_URL")
    arg_password_file = os.getenv("DOCKERFOO_DATABASE_PASSWORD_FILE")

    if arg_url is None:
        raise Exception("Missing environment variable: DOCKERFOO_DATABASE_URL")

    if arg_password_file is None:
        raise Exception(
            "Missing password file variable: DOCKERFOO_DATABASE_PASSWORD_FILE"
        )

    password = open(arg_password_file).read().strip()
    url = urls.replace_password(url=arg_url, new_password=password)
    return create_engine(url)


@contextmanager
def get_session() -> Iterator[Session]:
    with Session(get_engine()) as session:
        yield session
