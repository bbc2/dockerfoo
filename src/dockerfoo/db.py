from contextlib import contextmanager
from typing import Iterator

from sqlalchemy import Engine, create_engine
from sqlalchemy.orm import Session


def get_engine() -> Engine:
    password = open("/run/secrets/database_password").read().strip()
    return create_engine(f"postgresql://dockerfoo:{password}@database/dockerfoo")


@contextmanager
def get_session() -> Iterator[Session]:
    with Session(get_engine()) as session:
        yield session
