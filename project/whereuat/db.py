from flask import g
from functools import wraps
import re
import hashlib
import psycopg2


def db_connect(user, password, **kwargs):
    if not hasattr(g, 'conn'):
        g.conn = psycopg2.connect(
            database='whereuat',
            user=user,
            password=password,
            host='postgis',
            **kwargs
        )
    return g.conn


def with_connection(user, password, **connkwargs):
    def decorator(f):
        @wraps(f)
        def wrapper(*args, **kwargs):
            db_connect(user, password, **connkwargs)
            return f(*args, **kwargs)
        return wrapper
    return decorator


def get_cursor():
    if not hasattr(g, 'conn'):
        raise Exception('No database connection has been established')
    if not hasattr(g, 'cursor'):
        g.cursor = g.conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    return g.cursor


def db_exec(sql, params=()):
    get_cursor().execute(sql, params)


def db_close(commit=True):
    if hasattr(g, 'cursor'):
        if commit:
            g.cursor.commit()
        else:
            g.cursor.rollback()
        g.cursor.close()
    if hasattr(g, 'conn'):
        g.conn.close()


def db_fetch(sql, params=()):
    db_exec(sql, params)
    return get_cursor().fetchone()


def db_fetchall(sql, params=()):
    db_exec(sql, params)
    return get_cursor().fetchall()


def db_insert(table, values={}, **kwargs):
    """INSERT a row in a table, returning the new row"""
    values = {**values, **kwargs}
    return db_fetch(
        'INSERT INTO {} ({}) VALUES ({}) RETURNING *'.format(
            table,
            ','.join(values.keys()),
            ','.join(['%s']*len(values))
        ),
        values.values()
    )


def db_upsert(table, keycols, values={}, **kwargs):
    """INSERT or UPDATE a row in a table, returning the new row"""
    values = {**values, **kwargs}
    if isinstance(keycols, str):
        keycols = [keycols]
    return db_fetch(
        '''
        INSERT INTO {} ({}) VALUES ({})
        ON CONFLICT ({}) DO UPDATE
        SET {}
        RETURNING *
        '''.format(
            table,
            ','.join(values.keys()),
            ','.join(['%s']*len(values)),
            ','.join(keycols),
            ','.join([
                '{} = EXCLUDED.{}'.format(k, k)
                for k in values.keys()
                if k not in keycols
            ])
        ),
        values.values()
    )
