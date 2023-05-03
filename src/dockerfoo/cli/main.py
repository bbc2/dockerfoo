import click

from . import init, seed


@click.group()
def cli() -> None:
    pass


cli.add_command(init.cli, name="init")
cli.add_command(seed.cli, name="seed")
