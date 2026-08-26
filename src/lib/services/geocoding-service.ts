import { AddressDetails } from "@/lib/types";

const USER_AGENT = "CoolNet-AI-Climate-Dashboard/1.0";

/**
 * Perform reverse geocoding to retrieve structured address from coordinates
 */
export async function reverseGeocode(lat: number, lng: number): Promise<AddressDetails | null> {
  try {
    const url = `https://nominatim.openstreetmap.org/reverse?lat=${lat}&lon=${lng}&format=json&addressdetails=1`;
    const response = await fetch(url, {
      headers: {
        "User-Agent": USER_AGENT
      }
    });

    if (!response.ok) {
      throw new Error(`Reverse geocode returned status ${response.status}`);
    }
    const data = await response.json();
    if (!data || !data.address) return null;

    const address = data.address;
    return {
      road: address.road || address.pedestrian,
      neighbourhood: address.neighbourhood,
      suburb: address.suburb,
      city_district: address.city_district || address.subdistrict,
      city: address.city,
      town: address.town,
      village: address.village,
      county: address.county,
      state: address.state,
      postcode: address.postcode,
      country: address.country,
      country_code: address.country_code,
      displayName: data.display_name
    };
  } catch (error) {
    console.error("Geocoding: Reverse geocode failed", error);
    return null;
  }
}

/**
 * Searches Nominatim for matching names and addresses
 */
export async function searchLocation(query: string): Promise<{ lat: number; lng: number; address: AddressDetails }[]> {
  if (!query || query.trim().length < 3) return [];
  try {
    const url = `https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(query)}&format=json&limit=5&addressdetails=1`;
    const response = await fetch(url, {
      headers: {
        "User-Agent": USER_AGENT
      }
    });

    if (!response.ok) {
      throw new Error(`Location search returned status ${response.status}`);
    }
    const data = await response.json();
    if (!Array.isArray(data)) return [];

    return data.map((item: any) => {
      const address = item.address || {};
      return {
        lat: parseFloat(item.lat),
        lng: parseFloat(item.lon),
        address: {
          road: address.road || address.pedestrian,
          neighbourhood: address.neighbourhood,
          suburb: address.suburb,
          city_district: address.city_district || address.subdistrict,
          city: address.city,
          town: address.town,
          village: address.village,
          county: address.county,
          state: address.state,
          postcode: address.postcode,
          country: address.country,
          country_code: address.country_code,
          displayName: item.display_name
        }
      };
    });
  } catch (error) {
    console.error("Geocoding: Location search failed", error);
    return [];
  }
}
