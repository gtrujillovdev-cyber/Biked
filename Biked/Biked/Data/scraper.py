import json
import os

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

# --- Scraping / Data Generation Logic ---

def get_initial_database():
    """
    Returns the initial dataset. 
    In the future, you can add scraping functions here to fetch this data live.
    """
    bikes = []

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
        "https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/Canyon_Aeroad_CF_SLX_-_Stage_8_-_Tour_of_Britain_2016.jpg/640px-Canyon_Aeroad_CF_SLX_-_Stage_8_-_Tour_of_Britain_2016.jpg",
        canyon_geo
    ))

    # Orbea Orca Aero
    orbea_geo = [
        Geometry("47", 506, 368, 510, 74.5, 71.0),
        Geometry("49", 519, 374, 523, 74.0, 71.5),
        Geometry("51", 535, 380, 536, 73.7, 72.2),
        Geometry("53", 553, 386, 549, 73.5, 72.8),
        Geometry("55", 572, 393, 563, 73.5, 73.0),
        Geometry("57", 591, 400, 576, 73.5, 73.2),
        Geometry("60", 615, 408, 590, 73.5, 73.5)
    ]
    bikes.append(Bike(
        "orbea-orca-aero", 
        "Orbea", 
        "Orca Aero", 
        5999.0, 
        "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/Road_bike_Orbea_Orca_Aero_2020.jpg/640px-Road_bike_Orbea_Orca_Aero_2020.jpg",
        orbea_geo
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
    bikes.append(Bike(
        "specialized-tarmac-sl8", 
        "Specialized", 
        "Tarmac SL8", 
        12500.0, 
        "https://media.specialized.com/bikes/road/5758_TarmacSL8_ArticleTile_580x618_02.jpg",
        spec_geo
    ))

    return bikes

def save_to_json(bikes, filename="bikes.json"):
    data = [bike.to_dict() for bike in bikes]
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4, ensure_ascii=False)
    print(f"Database saved to {filename} with {len(bikes)} bikes.")

# --- Main Execution ---

if __name__ == "__main__":
    print("Generating Bike Database...")
    bikes = get_initial_database()
    
    # Example: In the future, you would call scraping functions here
    # e.g., bikes.extend(scrape_canyon_website())
    
    save_to_json(bikes)
