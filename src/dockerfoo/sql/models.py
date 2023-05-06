from typing import Any, List

from sqlalchemy import ForeignKey, Index, Text
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship


class Base(DeclarativeBase):
    pass


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True)

    tokens: Mapped[List["Token"]] = relationship(
        back_populates="user",
        cascade="all, delete-orphan",
    )


class Token(Base):
    __tablename__ = "tokens"

    id: Mapped[int] = mapped_column(primary_key=True)
    value: Mapped[str] = mapped_column(Text(), index=True)
    value_json: Mapped[dict[str, Any]] = mapped_column(JSONB)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)

    user: Mapped["User"] = relationship(back_populates="tokens")


Index("token_value_json_bytes_idx", Token.value_json["bytes"].astext)
