import click

from dockerfoo import db
from dockerfoo.sql.models import Base


@click.command()
def cli() -> None:
    engine = db.get_engine()
    Base.metadata.create_all(engine)
