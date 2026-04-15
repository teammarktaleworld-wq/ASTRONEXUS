from fastapi import FastAPI, HTTPException
import swisseph as swe
from datetime import datetime, timedelta, date
from geopy.geocoders import Nominatim
from timezonefinder import TimezoneFinder
import pytz

from schemas import ChartRequest
from fastapi.middleware.cors import CORSMiddleware


# --------------------------------------------------
# APP SETUP
# --------------------------------------------------
app = FastAPI(title="AstroNexus Chart Engine")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

swe.set_ephe_path(".")


# --------------------------------------------------
# TOOLS
# --------------------------------------------------
geolocator = Nominatim(user_agent="astro_nexus_app")
tf = TimezoneFinder()


# --------------------------------------------------
# CONSTANTS
# --------------------------------------------------
SIGNS = [
    "Aries", "Taurus", "Gemini", "Cancer",
    "Leo", "Virgo", "Libra", "Scorpio",
    "Sagittarius", "Capricorn", "Aquarius", "Pisces"
]

NAKSHATRAS = [
    "Ashwini","Bharani","Krittika","Rohini","Mrigashira",
    "Ardra","Punarvasu","Pushya","Ashlesha",
    "Magha","Purva Phalguni","Uttara Phalguni",
    "Hasta","Chitra","Swati","Vishakha",
    "Anuradha","Jyeshtha","Mula","Purva Ashadha",
    "Uttara Ashadha","Shravana","Dhanishta",
    "Shatabhisha","Purva Bhadrapada",
    "Uttara Bhadrapada","Revati"
]

PLANETS = {
    "Sun": swe.SUN,
    "Moon": swe.MOON,
    "Mercury": swe.MERCURY,
    "Venus": swe.VENUS,
    "Mars": swe.MARS,
    "Jupiter": swe.JUPITER,
    "Saturn": swe.SATURN,
    "Rahu": swe.MEAN_NODE,
    "Uranus": swe.URANUS,
    "Neptune": swe.NEPTUNE,
    "Pluto": swe.PLUTO,
}

# --------------------------------------------------
# VIMSHOTTARI DASHA CONSTANTS
# --------------------------------------------------
VIMSHOTTARI_ORDER = [
    "Ketu", "Venus", "Sun", "Moon", "Mars",
    "Rahu", "Jupiter", "Saturn", "Mercury"
]

DASHA_YEARS = {
    "Ketu": 7,
    "Venus": 20,
    "Sun": 6,
    "Moon": 10,
    "Mars": 7,
    "Rahu": 18,
    "Jupiter": 16,
    "Saturn": 19,
    "Mercury": 17
}


# --------------------------------------------------
# HELPERS
# --------------------------------------------------
def zodiac_sign(lon):
    return SIGNS[int(lon // 30)]


def nakshatra(lon):
    return NAKSHATRAS[int(lon // (360 / 27))]


def north_indian_house(lon):
    return int(lon // 30) + 1


def resolve_city(city):
    location = geolocator.geocode(city, timeout=10)
    if not location:
        raise HTTPException(status_code=400, detail="City not found")
    return location.latitude, location.longitude


def local_to_utc(year, month, day, hour, minute, ampm, lat, lon):
    if ampm == "PM" and hour != 12:
        hour += 12
    if ampm == "AM" and hour == 12:
        hour = 0

    local_dt = datetime(year, month, day, hour, minute)

    tz_name = tf.timezone_at(lat=lat, lng=lon)
    if not tz_name:
        raise HTTPException(status_code=400, detail="Timezone not found")

    local_tz = pytz.timezone(tz_name)
    localized_dt = local_tz.localize(local_dt, is_dst=None)

    return localized_dt.astimezone(pytz.UTC)


def calculate_current_vimshottari_dasha(moon_lon, birth_dt):
    NAK_LEN = 360 / 27

    nak_index = int(moon_lon // NAK_LEN)
    nak_fraction = (moon_lon % NAK_LEN) / NAK_LEN

    start_lord = VIMSHOTTARI_ORDER[nak_index % 9]
    start_years = DASHA_YEARS[start_lord]

    balance_years = start_years * (1 - nak_fraction)

    def years_to_days(y):
        return int(y * 365.256)

    dasha_start = birth_dt
    dasha_end = dasha_start + timedelta(days=years_to_days(balance_years))

    today = date.today()

    if dasha_start.date() <= today <= dasha_end.date():
        return {
            "planet": start_lord,
            "start_date": dasha_start.date().isoformat(),
            "end_date": dasha_end.date().isoformat(),
            "duration_years": start_years
        }

    idx = (VIMSHOTTARI_ORDER.index(start_lord) + 1) % 9
    dasha_start = dasha_end

    while True:
        planet = VIMSHOTTARI_ORDER[idx]
        years = DASHA_YEARS[planet]
        dasha_end = dasha_start + timedelta(days=years_to_days(years))

        if dasha_start.date() <= today <= dasha_end.date():
            return {
                "planet": planet,
                "start_date": dasha_start.date().isoformat(),
                "end_date": dasha_end.date().isoformat(),
                "duration_years": years
            }

        dasha_start = dasha_end
        idx = (idx + 1) % 9


# --------------------------------------------------
# MAIN API
# --------------------------------------------------
@app.post("/api/v1/chart")
def generate_chart(payload: ChartRequest):

    lat, lon = resolve_city(payload.place_of_birth)

    utc_dt = local_to_utc(
        payload.birth_date.year,
        payload.birth_date.month,
        payload.birth_date.day,
        payload.birth_time.hour,
        payload.birth_time.minute,
        payload.birth_time.ampm,
        lat,
        lon
    )

    jd = swe.julday(
        utc_dt.year,
        utc_dt.month,
        utc_dt.day,
        utc_dt.hour + utc_dt.minute / 60
    )

    if payload.astrology_type == "vedic":
        if payload.ayanamsa == "lahiri":
            swe.set_sid_mode(swe.SIDM_LAHIRI)
        elif payload.ayanamsa == "raman":
            swe.set_sid_mode(swe.SIDM_RAMAN)
        else:
            raise HTTPException(status_code=400, detail="Invalid ayanamsa")

        flags = swe.FLG_SWIEPH | swe.FLG_SIDEREAL
    else:
        flags = swe.FLG_SWIEPH

    houses_tmp, ascmc = swe.houses(jd, lat, lon)
    asc_tropical = ascmc[0]

    if payload.astrology_type == "vedic":
        ayan = swe.get_ayanamsa(jd)
        asc_lon = (asc_tropical - ayan) % 360
    else:
        asc_lon = asc_tropical

    asc_sign = zodiac_sign(asc_lon)

    house_data = {str(i): {"sign": sign, "planets": []} for i, sign in enumerate(SIGNS, start=1)}

    planets_data = {}
    moon_sign = None
    moon_nakshatra = None
    moon_lon = None

    planets_data["Ascendant"] = {
        "longitude": round(asc_lon, 2),
        "sign": asc_sign,
        "nakshatra": None,
        "house": 1,
        "north_indian_box": north_indian_house(asc_lon)
    }

    for name, pid in PLANETS.items():
        pos, _ = swe.calc_ut(jd, pid, flags)
        lon_p = pos[0] % 360
        house_no = north_indian_house(lon_p)

        if name == "Moon":
            moon_sign = zodiac_sign(lon_p)
            moon_nakshatra = nakshatra(lon_p)
            moon_lon = lon_p

        planets_data[name] = {
            "longitude": round(lon_p, 2),
            "sign": zodiac_sign(lon_p),
            "nakshatra": nakshatra(lon_p) if payload.astrology_type == "vedic" else None,
            "house": house_no
        }

        house_data[str(house_no)]["planets"].append(name)

    rahu_lon = planets_data["Rahu"]["longitude"]
    ketu_lon = (rahu_lon + 180) % 360
    ketu_house = north_indian_house(ketu_lon)

    planets_data["Ketu"] = {
        "longitude": round(ketu_lon, 2),
        "sign": zodiac_sign(ketu_lon),
        "nakshatra": nakshatra(ketu_lon) if payload.astrology_type == "vedic" else None,
        "house": ketu_house
    }

    house_data[str(ketu_house)]["planets"].append("Ketu")

    dasha_data = None
    if payload.astrology_type == "vedic" and moon_lon is not None:
        dasha_data = {
            "current_dasha": calculate_current_vimshottari_dasha(moon_lon, utc_dt)
        }

    return {
        "name": payload.name,
        "gender": payload.gender,
        "birth_details": {
            "date": f"{payload.birth_date.year}-{payload.birth_date.month}-{payload.birth_date.day}",
            "time": f"{payload.birth_time.hour}:{payload.birth_time.minute:02d} {payload.birth_time.ampm}",
            "place_of_birth": payload.place_of_birth,
            "latitude": round(lat, 6),
            "longitude": round(lon, 6),
            "timezone": tf.timezone_at(lat=lat, lng=lon),
            "utc_time": utc_dt.isoformat()
        },
        "rashi": moon_sign,
        "nakshatra": moon_nakshatra,
        "ascendant": {
            "sign": asc_sign,
            "longitude": round(asc_lon, 2),
            "house": 1
        },
        "houses": house_data,
        "planets": planets_data,
        "dashas": dasha_data
    }
