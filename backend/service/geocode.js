import NodeGeocoder from "node-geocoder";

const geocoder = NodeGeocoder({
  provider: "openstreetmap" // free, no API key
});

export async function getCoordinatesFromPlace(place) {
  const results = await geocoder.geocode(place);

  if (!results || results.length === 0) {
    throw new Error("Unable to find location");
  }

  return {
    latitude: results[0].latitude,
    longitude: results[0].longitude
  };
}
