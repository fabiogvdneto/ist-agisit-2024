import sys
import requests

url=sys.argv[1]
guess_url=f'{url}/guess'
amount=int(sys.argv[2])

cookies = {}
previous_csrf=None

def get_csrf_token(text: str):
    return text.split('csrfmiddlewaretoken" value="')[1].split('"')[0]

def create_session():
    global previous_csrf, cookies

    # Create a session object
    session = requests.Session()

    response = session.get(url)
    response.raise_for_status()

    # Get the UUID from the cookies
    uuid = session.cookies.get('uid')

    # Get the csrfmiddlewaretoken from the hidden input field
    csrfmiddlewaretoken = get_csrf_token(response.text)

    print(f"UUID: {uuid}")
    print(f"csrfmiddlewaretoken: {csrfmiddlewaretoken}")

    cookies['uid'] = uuid
    cookies['csrftoken'] = csrfmiddlewaretoken
    previous_csrf = csrfmiddlewaretoken

    print(f"Cookies: {cookies}")
    print(f"Previous CSRF: {previous_csrf}")

    return session

def make_requests(session):
    global previous_csrf

    for i in range(amount):
        response = session.post(guess_url, cookies=cookies, data={'value': i, 'csrfmiddlewaretoken': previous_csrf })
        response.raise_for_status()

        previous_csrf = get_csrf_token(response.text)

        print(f"Attempt {i}: {response}")

if __name__ == "__main__":
    session = create_session()
    make_requests(session)