import requests

urls = [
    "https://media.trekbikes.com/image/upload/f_auto,fl_progressive:semi,q_auto,w_1920/MadoneSLR9AXSGen7-23-41764-A-Portrait",
    "https://embed.widencdn.net/img/dorelrl/nx5y4s3p6n/2000px/C23_C11202U_SuperSix_EVO_Hi_MOD_1_BLU_PD.png",
    "https://pinarello.es/imgs/productos/ciclismo/carretera/dogma-f/dogma-f-disc-dura-ace-di2-2x12/DOGMA-F-DISC_BLACK-ON-BLACK_B301-1.jpg",
    "https://images2.giant-bicycles.com/b_white,c_pad,h_800,q_80,w_1200/2202271836/MY23PropelAdvancedSL0_ColorAWeathervane_SilverPine.jpg",
    "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Canyon_Aeroad_CF_SLX_Disc_9.0_SL.jpg/800px-Canyon_Aeroad_CF_SLX_Disc_9.0_SL.jpg",
    "https://media.specialized.com/bikes/road/5758_TarmacSL8_ArticleTile_580x618_02.jpg",
    "https://placehold.co/600x400/png?text=API+Working"
]

print("Checking Image URLs...")
headers = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36'
}

for url in urls:
    try:
        r = requests.head(url, headers=headers, timeout=5)
        print(f"[{r.status_code}] {url.split('/')[-1][:20]}...")
    except Exception as e:
        print(f"[ERROR] {url.split('/')[-1][:20]}... : {e}")
