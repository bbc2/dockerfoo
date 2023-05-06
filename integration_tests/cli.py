from typing import Sequence


def init() -> Sequence[str]:
    """
    Generate command-line strings based on function parameters.

    The parameters and their default values are as close to the real CLI as possible, so
    that the function call looks pretty much the same as a CLI invocation.
    """

    cli = ["dockerfoo", "init"]

    return cli


def seed(count: int | None) -> Sequence[str]:
    """
    Generate command-line strings based on function parameters.

    The parameters and their default values are as close to the real CLI as possible, so
    that the function call looks pretty much the same as a CLI invocation.
    """

    cli = ["dockerfoo", "seed"]

    if count is not None:
        cli += ["--count", str(count)]

    return cli
