import secrets
from typing import NoReturn

import click
from sqlalchemy import insert
from sqlalchemy.orm import Session
from tqdm import tqdm

from dockerfoo import db
from dockerfoo.sql.models import Token
from dockerfoo.util import timing


def insert_tokens(session: Session, count: int) -> None:
    if not count:
        return

    session.execute(
        insert(Token),
        [{"value": secrets.token_hex(32)} for _ in range(count)],
    )
    session.commit()


def main(session: Session, bar: "tqdm[NoReturn]", count: int) -> None:
    batch_size = 10000
    batch_count = count // batch_size
    remainder_count = count % batch_size

    for _ in range(batch_count):
        insert_tokens(session=session, count=batch_size)
        bar.update(batch_size)

    insert_tokens(session=session, count=remainder_count)
    bar.update(remainder_count)


@click.command()
@click.option("--count", type=int, required=True)
def cli(count: int) -> None:
    """
    Insert a specified number of random tokens into the database.
    """

    with timing.with_measurement() as result:
        with (
            db.get_session() as session,
            tqdm(total=count, unit="row") as bar,
        ):
            main(session=session, bar=bar, count=count)

    print(f"Inserted {count} tokens in {result.formatted}.")
