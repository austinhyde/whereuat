from whereuat.db import db_fetch, db_fetchall, db_insert, db_upsert


class Model:
    def __init__(self, data={}, **kwargs):
        for k, v in data.items():
            setattr(self, k, v)
        for k, v in kwargs.items():
            setattr(self, k, v)

    @classmethod
    def _fetchone(cls, sql, params=()):
        row = db_fetch(sql, params)
        if not row:
            return None
        return cls(row)

    @classmethod
    def _fetchall(cls, sql, params=()):
        rows = db_fetchall(sql, params)
        return map(cls, rows)

    @classmethod
    def _insert(cls, *args, **kwargs):
        row = db_insert(*args, **kwargs)
        if not row:
            return None
        return cls(row)

    @classmethod
    def _upsert(cls, *args, **kwargs):
        row = db_upsert(*args, **kwargs)
        if not row:
            return None
        return cls(row)
