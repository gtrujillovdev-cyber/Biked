import json
import os
import time
import re
import requests
from bs4 import BeautifulSoup
from urllib.parse import urlparse, unquote

# Configuration
JSON_PATH = 'bikes.json'
# Path relative to build/data script location
IMAGE_DIR = os.path.join(os.path.dirname(__file__), '..', 'Resources', 'BikeImages')
FORCE_DOWNLOAD = True # Force re-download to fix missing/bad images

HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.9',
}

def setup_directories():
    if not os.path.exists(IMAGE_DIR):
        os.makedirs(IMAGE_DIR)

def get_og_image(url):
    try:
        if not url or "http" not in url: return None
        print(f"    Fallback: Checking official URL metadata...")
        # Use a standard browser header
        meta_headers = {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        }
        response = requests.get(url, headers=meta_headers, timeout=10)
        if response.status_code == 200:
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Fix: Use attrs={'property': ...} or attrs={'name': ...} to avoid name arg conflict
            og = soup.find("meta", attrs={"property": "og:image"})
            if og and og.get("content"): 
                return og["content"]
                
            tw = soup.find("meta", attrs={"name": "twitter:image"})
            if tw and tw.get("content"): 
                return tw["content"]
                
            # Try generic link rel=image_src
            link = soup.find("link", rel="image_src")
            if link and link.get("href"):
                return link["href"]
                
    except Exception as e:
        print(f"    Metadata error: {e}")
    return None

def search_image(query, transparent=False):
    try:
        ts_msg = " [Trans]" if transparent else ""
        print(f"    Searching Bing{ts_msg}: {query}")
        
        # Bing Images URL
        # qft=+filterui:photo-transparent for transparent images
        # qft=+filterui:imagesize-large for large images
        filters = "+filterui:imagesize-large"
        if transparent:
            filters += "+filterui:photo-transparent"
            
        base_url = "https://www.bing.com/images/search"
        params = {
            "q": query,
            "qft": filters,
            "form": "HDRSC2", 
            "first": "1"
        }
        
        bing_headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Referer': 'https://www.bing.com/'
        }
        
        response = requests.get(base_url, params=params, headers=bing_headers, timeout=10)
        
        if response.status_code != 200:
            print(f"    Bing Error: HTTP {response.status_code}")
            return None
            
        content = response.text
        
        # Bing embeds images in 'murl' (Media URL) inside the HTML source
        # Regex to find "murl":"https://..."
        # Pattern: murl&quot;:&quot;(https://.*?)&quot; or murl":"(https://.*?)"
        
        urls = re.findall(r'murl&quot;:&quot;(https://.*?\.(?:png|jpg|jpeg|webp))&quot;', content)
        if not urls:
             urls = re.findall(r'murl":"(https://.*?\.(?:png|jpg|jpeg|webp))"', content)
        
        for u in urls:
            u_lower = u.lower()
            if 'bing' in u_lower: continue
            
            # Return first finding
            return u
            
    except Exception as e:
        print(f"    Search error: {e}")
    return None

def download_image(img_url, bike_id):
    try:
        if not img_url or not img_url.startswith('http'): return None
        print(f"    Downloading: {img_url}")
        
        response = requests.get(img_url, headers=HEADERS, timeout=15)
        if response.status_code == 200:
            ext = 'jpg'
            ct = response.headers.get('content-type', '').lower()
            if 'png' in ct: ext = 'png'
            elif 'webp' in ct: ext = 'webp'
            
            filename = f"{bike_id}.{ext}"
            filepath = os.path.join(IMAGE_DIR, filename)
            
            with open(filepath, 'wb') as f:
                f.write(response.content)
            
            size = os.path.getsize(filepath)
            if size < 3000: # Increase min size to avoid 1x1 pixels or thumbnails
                print(f"    File too small ({size} bytes). Deleting.")
                os.remove(filepath)
                return None
                
            print(f"    Saved {filename} ({size//1024} KB)")
            return filename
        else:
            print(f"    Download failed: HTTP {response.status_code}")
    except Exception as e:
        print(f"    Download exception: {e}")
    return None

def main():
    setup_directories()
    try:
        with open(JSON_PATH, 'r') as f: bikes = json.load(f)
    except json.JSONDecodeError as e:
        print(f"CRITICAL: invalid JSON file. {e}")
        return

    count = 0
    for bike in bikes:
        # Check Local Existence
        current_image = bike['builds'][0]['images'][0]
        is_local_ref = not current_image.startswith("http")
        file_exists = False
        
        if is_local_ref:
            possible_path = os.path.join(IMAGE_DIR, current_image)
            if os.path.exists(possible_path) and os.path.getsize(possible_path) > 3000:
                file_exists = True
        
        if not FORCE_DOWNLOAD and file_exists:
            print(f"Skipping {bike['id']} (OK)")
            continue
            
        print(f"\nProcessing [{bike['id']}] {bike['brand']} {bike['model']}...")
        img_url = None
        
        # DIRECT URL OVERRIDES (Stubborn bikes)
        DIRECT_URLS = {
            "b2": "https://www.canyon.com/dw/image/v2/BCML_PRD/on/demandware.static/-/Sites-canyon-master/default/dw8e82755e/images/full/full_2024_/2024_/full_2024_Aeroad-CFR-Di2_3943_P04_P5.png?sw=1000&sh=1000&sm=fit&sfrm=png",
            "b4": "https://www.reveduvelo.com/2645-large_default/pinarello-dogma-f-dura-ace-di2-luxter-blue-2025-road-bike.jpg",
            "b5": "https://www.cannondale.com/-/media/images/product-images/supersix-evo/lab71-team/team/c23_c11082u_supersix_evo_lab71_team_team_3.ashx",
            "b8": "https://cdn.road.cc/sites/default/files/2024%20Orbea%20Orca%20Aero%20M10i%20LTD%20-%202.jpg",
            "b9": "https://bikeinsights.com/images/bikes/640f1a4a4f8b9e001dfa84b1.jpg",
            "b15": "https://www.vitoriabikes.es/wp-content/uploads/2023/10/Nyxtralight-Electric-Blue-1.jpg"
        }

        # 1. Try Direct URL first
        if bike['id'] in DIRECT_URLS:
            print(f"  [Direct URL Access] {bike['id']}")
            img_url = DIRECT_URLS[bike['id']]

        # 2. Hardcoded Manual Queries for remaining cases
        MANUAL_QUERIES = {
            "b2": "Canyon Aeroad CFR side profile 2024",
            "b4": "Pinarello Dogma F 2025 side view",
            "b5": "Cannondale SuperSix EVO LAB71 side view",
            "b8": "Orbea Orca Aero 2024 side profile",
            "b9": "Scott Foil RC 2024 side view",
            "b15": "Vitoria Nyxtralight road bike side view",
        }

        # Custom Override: S-Works
        if not img_url and bike['id'] == 'b1':
            print("  [Override] Searching for full bike with wheels...")
            img_url = search_image("Specialized S-Works Tarmac SL8 Dura Ace Di2 side view full bike png", transparent=True)
            
        # Manual Query Override
        if not img_url and bike['id'] in MANUAL_QUERIES:
             print(f"  [Manual Override] {bike['id']}")
             # Try transparent first
             img_url = search_image(MANUAL_QUERIES[bike['id']], transparent=True)
             # If fail, try normal
             if not img_url:
                 img_url = search_image(MANUAL_QUERIES[bike['id']], transparent=False)
            
        # STRATEGY 1: Transparent Search (Specific)
        if not img_url:
            q = f"{bike['brand']} {bike['model']} {bike['year']} side profile"
            img_url = search_image(q, transparent=True)
            
        # STRATEGY 2: Transparent Search (Generic)
        if not img_url:
            q = f"{bike['brand']} {bike['model']} road bike"
            img_url = search_image(q, transparent=True)
        
        # STRATEGY 3: Normal Search (Detailed) - If transparent fails
        if not img_url:
            print("    [Warn] No transparent image found. Trying normal search...")
            q = f"{bike['brand']} {bike['model']} side view"
            img_url = search_image(q, transparent=False)
            
        # STRATEGY 4: Official Site Metadata (Last resort)
        if not img_url:
            img_url = get_og_image(bike.get('official_url'))

        # DOWNLOAD
        if img_url:
            local = download_image(img_url, bike['id'])
            if local:
                # Update JSON in memory
                count += 1
                for b in bike['builds']:
                    if b['images']: b['images'][0] = local
                    else: b['images'] = [local]
            else:
                print("    [Error] Found info but failed to download/save valid image.")
        else:
            print("    [Fail] No image found after all attempts.")
            
        time.sleep(4) # Increased delay to avoid blocks
        
    with open(JSON_PATH, 'w') as f: json.dump(bikes, f, indent=4)
    print(f"\nCompleted. Updated {count} bikes.")

if __name__ == "__main__":
    main()
