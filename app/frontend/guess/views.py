import logging
import requests
import os
from django.shortcuts import render, redirect
from .forms import GuessForm
from prometheus_client import Summary, Counter, generate_latest
from django.http import HttpResponse
import time  # Import the time module to track execution time

# Constants
GENERATOR_HOST = os.getenv('GENERATOR_HOST')
COMPARATOR_HOST = os.getenv('COMPARATOR_HOST')
LEADERBOARD_HOST = os.getenv('LEADERBOARD_HOST')

# Logger setup
logger = logging.getLogger(__name__)

# Validate environment variables
if not GENERATOR_HOST or not COMPARATOR_HOST or not LEADERBOARD_HOST:
    logger.error("Environment variables GENERATOR_HOST or COMPARATOR_HOST or LEADERBOARD_HOST are not set.")
    raise EnvironmentError("GENERATOR_HOST or COMPARATOR_HOST or LEADERBOARD_HOST environment variable not set.")

# Prometheus metrics
REQUEST_COUNT = Counter('frontend_request_count', 'Total request count', ['view_name'])
REQUEST_TIME_MS = Summary('frontend_request_processing_time_milliseconds', 'Time spent processing request in milliseconds', ['view_name'])
ERROR_COUNT = Counter('frontend_error_count', 'Total error count', ['view_name'])

def record_time(view_name, start_time):
    """Record elapsed time in milliseconds."""
    elapsed_time_ms = (time.time() - start_time) * 1000  
    REQUEST_TIME_MS.labels(view_name).observe(elapsed_time_ms)

@REQUEST_TIME_MS.labels('begin').time()
def begin(request):
    start_time = time.time() 
    logger.info("Starting the initialization function.")

    try:
        logger.info("Requesting UID from generator host.")
        response = requests.get(GENERATOR_HOST, timeout=5)
        response.raise_for_status()  # Automatically raises an error for non-2xx status codes
        
        uid = response.json().get('uuid')
        if uid:
            logger.info(f"UID obtained: {uid}. Setting cookie and redirecting.")
            response_redirect = redirect('guess_number')
            response_redirect.set_cookie('uid', uid, max_age=3600, httponly=True, secure=False)
            REQUEST_COUNT.labels('begin').inc() 
            record_time('begin', start_time) 
            return response_redirect
        else:
            logger.error("UID not found in the response from the generator host.")
            ERROR_COUNT.labels('begin').inc() 
            record_time('begin', start_time)  
            return error_page(request)
    
    except requests.RequestException as e:
        logger.error(f"RequestException while obtaining UID: {e}")
        ERROR_COUNT.labels('begin').inc() 
        record_time('begin', start_time)
        return error_page(request)

@REQUEST_TIME_MS.labels('guess_number').time()
def guess_number(request):
    start_time = time.time() 
    logger.info("Starting the guessing function.")
    
    uid = request.COOKIES.get('uid')
    if not uid:
        logger.warning("No UID found in cookies, redirecting to 'begin'.")
        REQUEST_COUNT.labels('guess_number').inc() 
        record_time('guess_number', start_time)  
        return redirect('begin')

    logger.info(f"UID found in cookies: {uid}")
    form = GuessForm(request.POST or None)
    result = attempts = error = None

    try:
        leaderboard_data = requests.get(LEADERBOARD_HOST, timeout=5).json()
        leaderboard_data = sorted(leaderboard_data, key=lambda x: x['score'])[:3]
    except requests.RequestException as e:
        logger.error(f"Error fetching leaderboard data: {e}")
        ERROR_COUNT.labels('guess_number').inc()  
        leaderboard_data = []

    if request.method == 'POST' and form.is_valid():
        value = form.cleaned_data['value']
        logger.info(f"Value submitted for guessing: {value}. Making API request.")
        try:
            url = f"{COMPARATOR_HOST}/{uid}?attempt={value}"
            response = requests.get(url, timeout=5)
            response.raise_for_status()

            data = response.json()
            result = data.get('comparison')
            attempts = data.get('attemptCount')
            logger.info(f"API response: result={result}, attempts={attempts}")

        except requests.RequestException as e:
            error = f"API Error: {e}"
            logger.error(f"Error in API request: {e}")
            ERROR_COUNT.labels('guess_number').inc()  
        except ValueError as e:
            error = "Invalid response format from API."
            logger.error(f"Error parsing API response: {e}")
            ERROR_COUNT.labels('guess_number').inc() 
    
    REQUEST_COUNT.labels('guess_number').inc()
    record_time('guess_number', start_time)  

    context = {
        'leaderboard': leaderboard_data,
        'form': form,
        'attempts': attempts,
        'result': result,
        'error': error,
    }

    return render(request, 'guess_number.html', context)

def error_page(request):
    logger.error("Rendering error page.")
    ERROR_COUNT.labels('error_page').inc() 
    return render(request, 'error.html', status=500)

def metrics_view(request):
    """Expose metrics for Prometheus to scrape."""
    return HttpResponse(generate_latest(), content_type="text/plain")