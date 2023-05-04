from dataclasses import dataclass

import pytest
from dockerfoo.util.urls import replace_password


@dataclass(frozen=True)
class ReplacePasswordCase:
    name: str
    arg_url: str
    arg_new_password: str
    expected: str

    def id(self) -> str:
        return self.name


@pytest.mark.parametrize(
    "case",
    [
        ReplacePasswordCase(
            name="no-auth",
            arg_url="sch://host:1",
            arg_new_password="pass-1",
            expected="sch://:pass-1@host:1",
        ),
        ReplacePasswordCase(
            name="only-username",
            arg_url="sch://usr@host:1",
            arg_new_password="pass-1",
            expected="sch://usr:pass-1@host:1",
        ),
        ReplacePasswordCase(
            name="only-password",
            arg_url="sch://:pass-0@host:1",
            arg_new_password="pass-1",
            expected="sch://:pass-1@host:1",
        ),
        ReplacePasswordCase(
            name="full-auth",
            arg_url="sch://usr:pass-0@host:1",
            arg_new_password="pass-1",
            expected="sch://usr:pass-1@host:1",
        ),
        ReplacePasswordCase(
            name="pass-special-chars",
            arg_url="sch://usr:pass-0@host:1",
            arg_new_password="pass/+",
            expected="sch://usr:pass%2F%2B@host:1",
        ),
    ],
    ids=ReplacePasswordCase.id,
)
def test_replace_password(case: ReplacePasswordCase) -> None:
    result = replace_password(url=case.arg_url, new_password=case.arg_new_password)

    assert result == case.expected
