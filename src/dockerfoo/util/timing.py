import time
from contextlib import contextmanager
from dataclasses import dataclass, field
from typing import Iterator


@dataclass()
class Result:
    ns: int | None = field(default=None)

    @property
    def formatted(self) -> str:
        assert self.ns is not None
        ms = self.ns / 1e6
        return f"{ms:.2f} ms"


@contextmanager
def with_measurement() -> Iterator[Result]:
    result = Result()
    try:
        start = time.perf_counter_ns()
        yield result
    finally:
        stop = time.perf_counter_ns()
        result.ns = stop - start
