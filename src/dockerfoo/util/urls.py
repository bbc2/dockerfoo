from furl import furl  # type: ignore


def replace_password(url: str, new_password: str) -> str:
    parsed = furl(url)
    parsed.password = new_password
    return parsed.url  # type: ignore
