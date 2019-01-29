from datetime import datetime
from flask import render_template, flash, redirect, url_for, request, g, \
    jsonify, current_app
import random
import firebase_admin
from firebase_admin import credentials
from firebase_admin import db
# from app import db
# from app.models import User, Post
from app.main import bp


@bp.before_app_request
def before_request():
    str = 'somethinghere'
    # probalby do something with request or database here


@bp.route('/', methods=['GET', 'POST'])
@bp.route('/index', methods=['GET', 'POST'])
def index():
    return render_template('_index.html')

# Using a string template route allows us to call a url with the 'html' part
# i.e. http://localhost:5000/1_instructions will render templates/experiment/1_instructions.html
# Even though no .html was listed


@bp.route('/<string:page_name>')
def static_page(page_name):
    print('GET: ' + '%s.html' % ('/experiment/' + page_name))
    return render_template('%s.html' % ('/experiment/' + page_name))


@bp.route('/1_instructions')
def instructions():
    workerId = str(request.args.get('workerId'))
    if not workerId:
        return 'Please provide your workerId as a Url Parameter.'
    cond = str(request.args.get('cond'))
    if not cond:
        return 'Please provide visualization condition (cond) as a Url Parameter.'

    # Connect to the Firebase instance
    ref = db.reference('/workers/' + workerId)
    token = ''.join(random.choice('0123456789ABCDEF') for i in range(16))

    workerRef = {"workerId": workerId, "token": token, "condition": cond}

    # Check for repeat Turkers
    # if (db.reference(‘/workers/’ + workerId) exists)
        # do something
    # or use Unique Turker (http://uniqueturker.myleott.com/)

    # Then set at workers/workerId a randomly generated token
    ref.push().set(workerRef)

    # next_url = "/2_next_instructions" + "?workerId=" + workerId
    next_url = "/2_practice" + "?workerId=" + workerId + "&cond=" + cond

    return render_template('%s.html' % ('/experiment/' + '/1_instructions'),
        workerId = workerId,
        cond = cond,
        next_url = next_url)

@bp.route('/2_practice')
def practice():
    workerId = str(request.args.get('workerId'))
    if not workerId:
        return 'Please provide your workerId as a Url Parameter.'
    cond = str(request.args.get('cond'))
    if not cond:
        return 'Please provide visualization condition (cond) as a Url Parameter.'

    next_url = "/3_main_experiment_interface" + "?workerId=" + workerId + "&cond=" + cond

    return render_template('%s.html' % ('/experiment/' + '/2_practice'),
        workerId = workerId,
        cond = cond,
        next_url = next_url)


## Define more requests similar to above for other main html templates, or api endpoints


@bp.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers',
                         'Content-Type,Authorization')
    response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE')
    return response


def shutdown_request(self, request):
    request.shutdown()
