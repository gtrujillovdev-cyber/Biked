import json
import os
import requests
from bs4 import BeautifulSoup
import time

# --- Models (Python equivalent of Swift models) ---

class Geometry:
    def __init__(self, size_label, stack, reach, top_tube=None, seat_tube_angle=None, head_tube_angle=None):
        self.sizeLabel = size_label
        self.stack = stack
        self.reach = reach
        self.topTubeLength = top_tube
        self.seatTubeAngle = seat_tube_angle
        self.headTubeAngle = head_tube_angle

    def to_dict(self):
        return {
            "sizeLabel": self.sizeLabel,
            "stack": self.stack,
            "reach": self.reach,
            "topTubeLength": self.topTubeLength,
            "seatTubeAngle": self.seatTubeAngle,
            "headTubeAngle": self.headTubeAngle
        }

class Bike:
    def __init__(self, bike_id, brand, model_name, price, image_url, geometries):
        self.id = bike_id
        self.brand = brand
        self.modelName = model_name
        self.price = price
        self.imageUrl = image_url
        self.geometries = geometries

    def to_dict(self):
        return {
            "id": self.id,
            "brand": self.brand,
            "modelName": self.modelName,
            "price": self.price,
            "imageUrl": self.imageUrl,
            "geometries": [geo.to_dict() for geo in self.geometries]
        }

# --- Helper for Downloading ---
# Path to the raw image in the repo. 
# Matches structure: BikeGeometryFinder/Biked/Biked/Data/Images/
GITHUB_REPO_URL = "https://raw.githubusercontent.com/gtrujillovdev-cyber/Biked/main/Biked/Biked/Data/Images/"

def download_image(url, filename):
    """
    Downloads the image to the local Images/ folder and returns the GitHub Raw URL.
    """
    # Ensure directory exists
    if not os.path.exists("Images"):
        os.makedirs("Images")
        
    local_path = os.path.join("Images", filename)
    
    # If file exists and has size > 0, skip download (cache)
    if os.path.exists(local_path) and os.path.getsize(local_path) > 0:
        print(f"   [Cache] {filename} already exists.")
        return GITHUB_REPO_URL + filename
        
    try:
        headers = {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36'
        }
        print(f"   [Downloading] {url} -> {filename}...")
        r = requests.get(url, headers=headers, timeout=30) # Increased timeout for large files
        if r.status_code == 200:
            with open(local_path, "wb") as f:
                f.write(r.content)
            print(f"   -> Success: {len(r.content)} bytes")
            return GITHUB_REPO_URL + filename
        else:
            print(f"   [Error] Download failed: {r.status_code}")
    except Exception as e:
        print(f"   [Error] {e}")
    
    # Fallback to original URL if download fails (better than nothing)
    return url

def scrape_bike_metadata(url, brand, model_fallback):
    # (Kept for future use, but not used in initial DB generation to verify images first)
    pass

def get_initial_database():
    bikes = []

    # --- 1. POPULAR ROAD BIKES (Local Images) ---
    
    # TREK MADONE
    trek_geo = [
        Geometry("47", 500, 360, 500, 74.5, 70.0),
        Geometry("50", 520, 374, 521, 74.5, 71.0),
        Geometry("52", 533, 380, 534, 74.0, 72.0),
        Geometry("54", 540, 386, 543, 73.5, 73.0),
        Geometry("56", 563, 391, 559, 73.3, 73.5),
        Geometry("58", 581, 396, 574, 73.0, 73.8),
        Geometry("60", 601, 399, 586, 72.8, 73.9),
        Geometry("62", 620, 403, 598, 72.5, 74.0)
    ]
    bikes.append(Bike(
        "trek-madone-slr", 
        "Trek", 
        "Madone SLR Gen 7", 
        12000.0, 
        download_image("https://upload.wikimedia.org/wikipedia/commons/f/f8/Trek_MADONE.jpg", "trek_madone.jpg"),
        trek_geo
    ))

    # CANNONDALE SUPERSIX EVO
    c_geo = [
         Geometry("44", 495, 365, 500, 74.5, 70.5),
         Geometry("48", 515, 372, 515, 74.5, 71.5),
         Geometry("51", 535, 378, 530, 74.0, 72.0),
         Geometry("54", 555, 384, 545, 73.5, 73.0),
         Geometry("56", 575, 390, 560, 73.5, 73.3),
         Geometry("58", 595, 396, 575, 73.0, 73.5),
    ]
    bikes.append(Bike(
        "cannondale-supersix",
        "Cannondale",
        "SuperSix EVO Hi-Mod",
        11500.0,
        download_image("https://upload.wikimedia.org/wikipedia/commons/2/27/Cannondale_SuperSix.jpg", "cannondale_supersix.jpg"),
        c_geo
    ))
    
    # PINARELLO DOGMA F
    pin_geo = [
        Geometry("430", 490, 355, 490, 75.0, 70.0),
        Geometry("465", 505, 365, 505, 74.5, 71.0),
        Geometry("500", 520, 375, 520, 74.0, 72.0),
        Geometry("515", 535, 380, 530, 73.5, 72.5),
        Geometry("530", 545, 385, 540, 73.0, 73.0),
        Geometry("540", 555, 388, 550, 73.0, 73.2),
        Geometry("550", 565, 392, 560, 72.5, 73.5),
    ]
    bikes.append(Bike(
        "pinarello-dogma-f",
        "Pinarello",
        "Dogma F",
        14500.0,
        download_image("https://upload.wikimedia.org/wikipedia/commons/3/37/Pinarello_Dogma_F_Super_Record_EPS.jpg", "pinarello_dogma.jpg"),
        pin_geo
    ))
    
    # GIANT PROPEL
    giant_geo = [
        Geometry("XS", 500, 365, 515, 74.5, 71.0),
        Geometry("S", 520, 375, 535, 74.0, 72.5),
        Geometry("M", 545, 383, 550, 73.5, 73.0),
        Geometry("ML", 565, 393, 565, 73.0, 73.0),
        Geometry("L", 585, 403, 580, 73.0, 73.0),
        Geometry("XL", 605, 413, 600, 72.5, 73.0)
    ]
    bikes.append(Bike(
        "giant-propel-sl",
        "Giant",
        "Propel Advanced SL 0",
        12000.0,
        download_image("https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/Giant_Bicycles_Logo.svg/640px-Giant_Bicycles_Logo.svg.png", "giant_logo.png"),
        giant_geo
    ))

    # --- 2. EXISTING VERIFIED BIKES ---
    
    # Canyon Aeroad CFR
    canyon_geo = [
        Geometry("2XS", 493, 365, 508, 73.5, 70.0),
        Geometry("XS", 512, 376, 526, 73.5, 71.0),
        Geometry("S", 533, 385, 543, 73.5, 72.0),
        Geometry("M", 555, 395, 560, 73.5, 73.0),
        Geometry("L", 576, 405, 577, 73.5, 73.25),
        Geometry("XL", 597, 415, 596, 73.5, 73.5),
        Geometry("2XL", 618, 425, 616, 73.5, 73.75)
    ]
    bikes.append(Bike(
        "canyon-aeroad-cfr", 
        "Canyon", 
        "Aeroad CFR", 
        8999.0, 
        download_image("https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Canyon_Aeroad_CF_SLX_Disc_9.0_SL.jpg/800px-Canyon_Aeroad_CF_SLX_Disc_9.0_SL.jpg", "canyon_aeroad.jpg"),
        canyon_geo
    ))
    
    # Specialized Tarmac SL8
    spec_geo = [
        Geometry("44", 491, 365, 496, 75.5, 70.5),
        Geometry("49", 504, 375, 508, 75.5, 71.75),
        Geometry("52", 517, 380, 531, 74.0, 72.5),
        Geometry("54", 534, 384, 541, 74.0, 73.0),
        Geometry("56", 555, 395, 562, 73.5, 73.5),
        Geometry("58", 581, 402, 577, 73.5, 73.5),
        Geometry("61", 602, 408, 595, 73.0, 74.0)
    ]
    # For Specialized, we try the official one, but might need a fallback.
    # The placehold.co is robust. Use that as fallback inside download_image if needed, but here we supply the URL.
    bikes.append(Bike(
        "specialized-tarmac-sl8", 
        "Specialized", 
        "Tarmac SL8", 
        12500.0, 
        download_image("https://media.specialized.com/bikes/road/5758_TarmacSL8_ArticleTile_580x618_02.jpg", "specialized_tarmac.jpg"),
        spec_geo
    ))
    
    # DEBUG BIKE
    debug_geo = [Geometry("M", 550, 390, 550, 73.5, 73.0)]
    bikes.append(Bike(
        "debug-bike-1", "API TEST", "Connection Verified", 99999.0,
        "https://placehold.co/600x400/png?text=API+Working",
        debug_geo
    ))

    return bikes

def save_to_json(bikes, filename="bikes.json"):
    data = [bike.to_dict() for bike in bikes]
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4, ensure_ascii=False)
    print(f"Database saved to {filename} with {len(bikes)} bikes.")

if __name__ == "__main__":
    print("Generating Bike Database and Downloading Images...")
    bikes = get_initial_database()
    save_to_json(bikes)
