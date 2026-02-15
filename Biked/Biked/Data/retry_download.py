import requests
import time
import os

files = {
    "canyon_aeroad.jpg": "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Canyon_Aeroad_CF_SLX_Disc_9.0_SL.jpg/800px-Canyon_Aeroad_CF_SLX_Disc_9.0_SL.jpg",
    "giant_logo.png": "https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/Giant_Bicycles_Logo.svg/640px-Giant_Bicycles_Logo.svg.png"
}

headers = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36'
}

if not os.path.exists("Images"):
    os.makedirs("Images")

print("Retrying downloads...")
for filename, url in files.items():
    print(f"Waiting 2 seconds...")
    time.sleep(2)
    print(f"Downloading {filename}...")
    try:
        r = requests.get(url, headers=headers, timeout=15)
        if r.status_code == 200:
             with open(os.path.join("Images", filename), "wb") as f:
                f.write(r.content)
             print("Success!")
        else:
            print(f"Failed: {r.status_code}")
    except Exception as e:
        print(f"Error: {e}")
