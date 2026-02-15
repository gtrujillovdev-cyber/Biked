import requests
import os

url = "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Courier_bike_icon.svg/1200px-Courier_bike_icon.svg.png"
headers = {
    'User-Agent': 'Mozilla/5.0'
}

print(f"Downloading placeholder...")
try:
    r = requests.get(url, headers=headers, timeout=10)
    if r.status_code == 200:
        if not os.path.exists("Images"):
            os.makedirs("Images")
        with open("Images/placeholder_bike.png", "wb") as f:
            f.write(r.content)
        print("Success! Saved placeholder_bike.png")
    else:
        print(f"Failed: {r.status_code}")
except Exception as e:
    print(f"Error: {e}")
