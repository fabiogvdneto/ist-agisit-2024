import sys
import requests
from datetime import datetime
from multiprocessing.pool import ThreadPool

url=sys.argv[1]
guess_url=f'{url}/guess'
clients=int(sys.argv[2])
amount=int(sys.argv[3])

def get_csrf_token(text: str):
    return text.split('csrfmiddlewaretoken" value="')[1].split('"')[0]

def create_session():

    # Create a session object
    session = requests.Session()

    response = session.get(url)
    response.raise_for_status()

    # Get the UUID from the cookies
    uuid = session.cookies.get('uid')

    # Get the csrfmiddlewaretoken from the hidden input field
    csrfmiddlewaretoken = get_csrf_token(response.text)

    cookies = {
        'uid': uuid,
        'csrftoken': csrfmiddlewaretoken
    }
 
    return session, cookies, csrfmiddlewaretoken

def make_requests(_):
    session, cookies, csrfmiddlewaretoken = create_session()

    time_sum = 0
    min_time = 999999
    max_time = 0
    for i in range(amount):
        response = session.post(guess_url, cookies=cookies, data={'value': i, 'csrfmiddlewaretoken': csrfmiddlewaretoken })
        response.raise_for_status()

        time_sum += response.elapsed.total_seconds()
        min_time = min(min_time, response.elapsed.total_seconds())
        max_time = max(max_time, response.elapsed.total_seconds())

        csrfmiddlewaretoken = get_csrf_token(response.text)
    
    avg = time_sum / amount
    avg *= 1000
    min_time *= 1000
    max_time *= 1000

    return avg, min_time, max_time

def create_clients():
    with ThreadPool(clients) as pool:

        now = datetime.now()
        # Each thread will return [avg, min, max]. Get a global average, min and max
        results = pool.map(make_requests, range(clients))

        elapsed = datetime.now() - now

        avg = 0
        min_time = 999999
        max_time = 0
        for result in results:
            avg += result[0]
            min_time = min(min_time, result[1])
            max_time = max(max_time, result[2])

        avg /= clients

        print(f'=== Results ===')
        print(f"Clients: {clients}")
        print(f"Requests: {clients * amount}")
        print(f"Time taken: {elapsed.total_seconds():.2f}s")
        print(f'RPS: {((clients * amount) / elapsed.total_seconds()):.2f}')
        print(f'----------------')
        print(f"Min time: {min_time:.2f}ms")
        print(f"Average time: {avg:.2f}ms")
        print(f"Max time: {max_time:.2f}ms")
        print(f'================')
        

if __name__ == "__main__":
    create_clients()