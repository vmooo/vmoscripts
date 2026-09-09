
#!/usr/bin/env python3

import requests
import json
import sys
from datetime import datetime

def get_location_by_ip():
    try:
        response = requests.get('http://ip-api.com/json/', timeout=10)
        data = response.json()
        if data.get('status') == 'success':
            city = data.get('city')
            country = data.get('country')
            lat = data.get('lat')
            lon = data.get('lon')
            return city, country, lat, lon
        else:
            return None, None, None, None
    except Exception as e:
        print(f"Failed to determine location: {e}")
        return None, None, None, None

def get_weather(city):
    try:
        url = f'https://wttr.in/{city}?0T&m&lang=en'
        response = requests.get(url, timeout=15)
        if response.status_code == 200:
            return response.text
        else:
            return None
    except Exception as e:
        print(f"Error fetching weather: {e}")
        return None

def print_header(city, country):
    print("\n" + "=" * 50)
    print(f"   Weather in {city}, {country}")
    print(f"   {datetime.now().strftime('%A, %d %B %Y %H:%M')}")
    print("=" * 50 + "\n")

def main():
    print("Detecting your location...")
    city, country, lat, lon = get_location_by_ip()
    if not city:
        city = input("Enter city name: ").strip()
        if not city:
            print("No city provided. Exiting.")
            sys.exit(1)
        country = ""
    print(f"Your region: {city}" + (f", {country}" if country else ""))
    print("Fetching weather data...\n")
    weather_output = get_weather(city)
    if weather_output:
        print(weather_output)
    else:
        print("Could not retrieve weather data. Check your internet connection.")
        sys.exit(1)
        

if __name__ == "__main__":
    main()
