import requests
import os

url = "https://placehold.co/600x400/png?text=Image+Unavailable"
headers = {
    'User-Agent': 'Mozilla/5.0'
}

print(f"Downloading placeholder...")
try:
    r = requests.get(url, headers=headers, timeout=10)
    if r.status_code == 200:
        if not os.path.exists("Images"):
            os.makedirs("Images")
        with open("Images/placeholder.png", "wb") as f:
            f.write(r.content)
        print("Success! Saved placeholder.png")
    else:
        print(f"Failed: {r.status_code}")
except Exception as e:
    print(f"Error: {e}")
