from flask import request, jsonify, g
from functools import wraps
from fn import passthru, branch, compose
import os
import time
import uuid
import jwt
from base64 import b64decode
from whereuat.models.user import User


def require_env(name):
    """Ensures an environment variable is present, and returns it"""
    var = os.environ.get(name)
    if not var:
        raise Exception('Missing environment variable {}'.format(name))
    return var


def endpoint(app, method, path, authenticate='jwt'):
    """Composite decorator for API endpoint behavior"""
    return compose(
        app.route(path, methods=[method]),
        branch(authenticate == 'jwt', require_jwt_auth,
               branch(authenticate == 'basic', require_basic_auth, passthru)),
        json_data
    )


def ok(data, **kwargs):
    """Returns a JSON 200 OK response"""
    return jsonify({
        'success': True,
        'data': data,
        **kwargs
    }), 200


def fail(message, status=400, **kwargs):
    """Returns a JSON failure response"""
    return jsonify({
        'success': False,
        'message': message,
        'status': status,
        **kwargs
    }), status


def current_user():
    return g.current_user


def require_jwt_auth(f):
    """Decorator for a route that requires a valid JWT to be present, and sets the current user"""
    @wraps(f)
    def wrapped(*args, **kwargs):
        auth = request.headers.get('Authorization')
        if not auth:
            return fail('No Authorization header present for protected resource', 401)
        authtype, authstr = auth.split(' ', 1)
        if authtype.lower() != 'token':
            return fail('Authorization type was not Token', 401)

        try:
            token = jwt.decode(authstr, issuer='whereuat')
        except jwt.InvalidTokenError as e:
            return fail('Could not decode JWT: ' + str(e), 401)

        user = User.from_id(token['sub'])
        if not user:
            return fail('Unknown user', 401)

        g.current_user = user

        return f(*args, **kwargs)
    return wrapped


def require_basic_auth(f):
    """Decorator for a route that requires a valid username/password to be present, and sets the current user"""
    @wraps(f)
    def wrapped(*args, **kwargs):
        auth = request.headers.get('Authorization')
        if not auth:
            return fail('No Authorization header present for protected resource', 401)
        authtype, authstr = auth.split(' ', 1)
        if authtype.lower() != 'basic':
            return fail('Authorization type was not Basic', 401)

        username, password = b64decode(authstr).decode('utf-8').split(':', 1)
        if not username or not password:
            return fail('Incomplete basic authorization', 401)

        user = User.from_login(username, password)
        if not user:
            return fail('Unknown user or invalid password', 401)

        g.current_user = user

        return f(*args, **kwargs)
    return wrapped


def json_data(f):
    @wraps(f)
    def wrapped(*args, **kwargs):
        data = request.get_json(force=True)
        args.append(data)
        return f(*args, **kwargs)
    return wrapped


def make_token(id, **kwargs):
    now = time.time()
    return jwt.encode({
        'iss': 'whereuat',
        'sub': id,
        'exp': now + 3600*24,
        'iat': now,
        'nbf': now,
        'jti': uuid.uuid4().hex,
        **kwargs
    })
