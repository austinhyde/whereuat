from db import db_fetchall


def serialize(row):
    return {
        'id': row['id'],
        'username': row['username']
    }


def get_all():
    return db_fetchall('SELECT * FROM users')
