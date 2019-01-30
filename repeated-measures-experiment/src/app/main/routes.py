from datetime import datetime
from flask import render_template, flash, redirect, url_for, request, g, \
    jsonify, current_app
import random
import itertools
from config import Config
import firebase_admin
from firebase_admin import credentials
from firebase_admin import db
# from app import db
# from app.models import User, Post
from app.main import bp

# counterbalance trial order
trialSet = range(int(Config.MAX_TRIALS))                  # 0:(MAX_TRIALS - 1)
# trialPerm = list(itertools.permutations(trialSet))      # all possible orderings
# useTrialSet = trialPerm[int(Config.TRIAL_SET_INDEX)]    # selected trial order for this run (set in config.py)
useTrialSet = trialSet

@bp.before_app_request
def before_request():
    string = 'somethinghere'
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

    # Check for repeat Turkers (alternative: Unique Turker (http://uniqueturker.myleott.com/)
    # if ref.once().exists():
    #     # Redirect user to page that instructs them to return HIT
        # return render_template('%s.html' % ('/experiment/' + '/0_return'))
    # else
    # Set up database entry for in workers
    workerRef = {"workerId": workerId, "token": token, "condition": cond}
    ref.push().set(workerRef)
    ref.set(workerRef)

    # Send user to practice page
    next_url = "/2_practice" + "?workerId=" + workerId + "&cond=" + cond + "&trial=practice"

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
    trial = str(request.args.get('trial'))
    if not trial:
        return 'Please provide trial as a Url Parameter.'

    next_url = "/3_main_experiment_interface" + "?workerId=" + workerId + "&cond=" + cond + "&trial=1"

    return render_template('%s.html' % ('/experiment/' + '/2_practice'),
        workerId = workerId,
        cond = cond,
        trial = trial,
        trialIdx = "practice",
        next_url = next_url)

@bp.route('/3_main_experiment_interface')
def experiment():
    workerId = str(request.args.get('workerId'))
    if not workerId:
        return 'Please provide your workerId as a Url Parameter.'
    cond = str(request.args.get('cond'))
    if not cond:
        return 'Please provide visualization condition (cond) as a Url Parameter.'
    trial = int(request.args.get('trial'))
    if not trial:
        return 'Please provide trial as a Url Parameter.'
    
    # determine the dat condition for the next trial by trial index
    trialIdx = useTrialSet[trial - 1]

    # send to next page based on trial number
    if trial == int(Config.MAX_TRIALS):
        # Send to survey
        next_url = "/4_survey" + "?workerId=" + workerId + "&cond=" + cond
    else:
        # Send to next trial
        next_url = "/3_main_experiment_interface" + "?workerId=" + workerId + "&cond=" + cond + "&trial=" + str(trial + 1)

    return render_template('%s.html' % ('/experiment/' + '/3_main_experiment_interface'),
        workerId = workerId,
        cond = cond,
        trial = trial,
        trialIdx = trialIdx,
        next_url = next_url)

@bp.route('/4_survey')
def survey():
    workerId = str(request.args.get('workerId'))
    if not workerId:
        return 'Please provide your workerId as a Url Parameter.'
    cond = str(request.args.get('cond'))
    if not cond:
        return 'Please provide visualization condition (cond) as a Url Parameter.'
    
    next_url = "/5_final" + "?workerId=" + workerId + "&cond=" + cond

    return render_template('%s.html' % ('/experiment/' + '/4_survey'),
        workerId = workerId,
        cond = cond,
        next_url = next_url)

@bp.route('/5_final')
def final():
    workerId = str(request.args.get('workerId'))
    if not workerId:
        return 'Please provide your workerId as a Url Parameter.'
    cond = str(request.args.get('cond'))
    if not cond:
        return 'Please provide visualization condition (cond) as a Url Parameter.'

    return render_template('%s.html' % ('/experiment/' + '/5_final'),
        workerId = workerId) # use workerId to query db for token

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
