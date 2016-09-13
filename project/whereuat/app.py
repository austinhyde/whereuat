from flask import Flask
from .helpers import endpoint, fail, make_token, ok, require_env, current_user
from .db import with_connection, db_close
from .models.user import User

app = Flask(__name__)
userreg_connection = with_connection('whereuat_userreg', require_env('WHEREUAT_USERREG_PASS'))
app_connection = with_connection('whereuat_app', require_env('WHEREUAT_APP_PASS'))


@endpoint(app, 'POST', '/users', authenticate=False)
@userreg_connection
def add_user(data):
    username = data.get('username')
    if not username:
        return fail('No username present')

    password = data.get('password')
    if not password:
        return fail('No password present')

    email = data.get('email')
    if not email:
        return fail('No email present')

    user = User.create(username, password, email=email)
    if not user:
        return fail('Could not create user!', 500)

    return ok({
        'token': make_token(id),
        'id': user.user_id,
        'username': user.username
    })


@endpoint(app, 'POST', '/me/location')
@app_connection
def add_location(data):
    latitude = data.get('lat')
    if not latitude:
        return fail('No latitude')

    longitude = data.get('lon')
    if not longitude:
        return fail('No longitude')

    current_user().update_location(longitude, latitude)
    return ok(True)


@endpoint(app, 'POST', '/me/friends')
@app_connection
def add_friend():
    pass


@app.teardown_appcontext
def close_db(err):
    db_close(err is None)


if __name__ == '__main__':
    app.run()
