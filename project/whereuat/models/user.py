from whereuat.models import Model
from whereuat.models.location import Location
from whereuat.db import db_exec
from passlib.hash import sha256_crypt
from uuid import uuid4


class User(Model):
    @staticmethod
    def from_id(id):
        return User._fetchone('SELECT * FROM users WHERE user_id = %s', (id))

    @staticmethod
    def from_login(user, password):
        user = User._fetchone('SELECT * FROM users WHERE username = %s', (user))
        if not user:
            return None
        if not sha256_crypt.verify(user.password, password):
            return None
        return user

    @staticmethod
    def create(username, password, **kwargs):
        id = uuid4().hex
        db_exec('SELECT create_enduser_role(%s)', id)
        return User._insert(
            'users',
            id=id,
            username=username,
            password=sha256_crypt.encrypt(password),
            **kwargs
        )

    def update_location(self, longitude, latitude):
        Location.update(self.user_id, longitude, latitude)


def role_for_id(id):
    return 'whereuat_enduser_' + id
