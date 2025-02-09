import requests
import argparse

ALLOWED_STATUS_CODES = {200, 301, 302}

def check_health(url):
    try:
        response = requests.get(url)
        if response.status_code in ALLOWED_STATUS_CODES:
            print(f"✅ [SUCCESS] {url} is accessible (status {response.status_code}).")
            return True
        else:
            print(f"❌ [ERROR] {url} returned status {response.status_code}.")
            return False
    except Exception as e:
        print(f"❌ [ERROR] Failed to access {url}: {e}")
        return False

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Check the health of specified URLs.")
    parser.add_argument(
        "urls",
        metavar="URL",
        type=str,
        nargs="+",
        help="List of URLs to check."
    )
    args = parser.parse_args()

    results = [check_health(url) for url in args.urls]
    if not all(results):
        exit(1)