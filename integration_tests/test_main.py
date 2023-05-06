import subprocess

from . import cli


def test() -> None:
    result = subprocess.run(cli.init(), stdout=subprocess.PIPE)

    assert result.returncode == 0
    assert result.stdout.decode() == ""

    result = subprocess.run(cli.seed(count=1000), stdout=subprocess.PIPE)

    assert result.returncode == 0
    assert result.stdout.decode().startswith("Inserted 1000 tokens in ")
