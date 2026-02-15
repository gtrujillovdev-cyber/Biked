import requests
from bs4 import BeautifulSoup

pages = [
    "https://commons.wikimedia.org/wiki/File:Trek_MADONE.jpg",
    "https://commons.wikimedia.org/wiki/File:Cannondale_SuperSix.jpg",
    "https://commons.wikimedia.org/wiki/File:Pinarello_Dogma_F_Super_Record_EPS.jpg",
    "https://commons.wikimedia.org/wiki/File:Giant_Propel_Advanced_SL_0_Disc_-_2019.jpg" # Trying a guess/search result
]

headers = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36'
}

print("Extracting Direct URLs...")
for page in pages:
    try:
        r = requests.get(page, headers=headers)
        if r.status_code == 200:
            soup = BeautifulSoup(r.content, 'html.parser')
            # Wikimedia uses .fullImageLink a or similar
            div = soup.find("div", class_="fullImageLink")
            if div:
                a = div.find("a")
                if a and a.get("href"):
                    print(f"FOUND: {a['href']}")
                else:
                    print(f"NO LINK IN DIV: {page}")
            else:
                print(f"NO DIV FOUND: {page}")
        else:
            print(f"FAILED ({r.status_code}): {page}")
    except Exception as e:
        print(f"ERROR: {e}")
