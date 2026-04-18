from pydantic import BaseModel, Field
from typing import Literal, Dict, List, Optional

# -------- INPUT SCHEMAS --------

from pydantic import BaseModel, Field, field_validator
from typing import Literal, Optional, Dict, List


class BirthDate(BaseModel):
    year: int = Field(..., example=2004)
    month: int = Field(..., example=3)
    day: int = Field(..., example=6)


class BirthTime(BaseModel):
    hour: int | str = Field(..., example=7)
    minute: int | str = Field(..., example="05")
    ampm: str

    @field_validator("hour", mode="before")
    @classmethod
    def normalize_hour(cls, v):
        return int(v)

    @field_validator("minute", mode="before")
    @classmethod
    def normalize_minute(cls, v):
        return int(v)

    @field_validator("ampm", mode="before")
    @classmethod
    def normalize_ampm(cls, v):
        v = v.upper()
        if v not in ("AM", "PM"):
            raise ValueError("ampm must be AM or PM")
        return v


class ChartRequest(BaseModel):
    name: str = Field(..., example="Madhav Nimbola")
    gender: Literal["male", "female"]
    birth_date: BirthDate
    birth_time: BirthTime
    place_of_birth: str = Field(..., example="Ujjain, Madhya Pradesh, India")
    astrology_type: Literal["vedic", "western"] = "vedic"
    ayanamsa: Literal["lahiri", "raman", "tropical"] = "lahiri"


# -------- OUTPUT SCHEMAS --------

class PlanetInfo(BaseModel):
    degree: float
    rasi: str
    rasi_lord: str
    nakshatra: Optional[str]
    nakshatra_lord: Optional[str]
    house: int
    retrograde: bool

class ChartResponse(BaseModel):
    name: str
    gender: str
    birth_date: str
    birth_time: str
    place_of_birth: str
    ayanamsa: str

    rashi: str                 # 👈 MOON SIGN
    nakshatra: str

    ascendant: Dict[str, str]

    planets: Dict[str, PlanetInfo]

    houses: Dict[str, Dict[str, List[str]]]