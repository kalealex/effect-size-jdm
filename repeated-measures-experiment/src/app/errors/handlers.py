from flask import render_template
# from app import db
# We can call app.errors as a module since we have an __init__.py in that directory
# We then import the bp variable defined in app/errors/__init__.py, which is our blueprint handler
from app.errors import bp

# Return the a notfound template for 404 errors
# Flask knows which folder is our static, so we just define what template to render


@bp.app_errorhandler(404)
def not_found_error(error):
    return render_template('errors/404.html'), 404


@bp.app_errorhandler(500)
def internal_error(error):
    return render_template('errors/500.html'), 500
