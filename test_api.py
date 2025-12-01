#!/usr/bin/env python3
"""
Test script for Waste Management System API endpoints
"""

import requests
import json
import time

BASE_URL = "http://127.0.0.1:5000"

def test_endpoint(method, endpoint, data=None):
    """Test an API endpoint"""
    url = f"{BASE_URL}{endpoint}"
    print(f"\n{'='*60}")
    print(f"Testing: {method} {endpoint}")
    print(f"{'='*60}")
    
    try:
        if method == "GET":
            response = requests.get(url, timeout=5)
        elif method == "POST":
            response = requests.post(url, json=data, timeout=5)
        elif method == "PUT":
            response = requests.put(url, json=data, timeout=5)
        elif method == "DELETE":
            response = requests.delete(url, timeout=5)
        
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            try:
                result = response.json()
                if isinstance(result, list) and len(result) > 0:
                    print(f"✓ Got {len(result)} records")
                    print(f"Sample: {json.dumps(result[0], indent=2)}")
                elif isinstance(result, list):
                    print("✓ Empty list (expected for new database operations)")
                else:
                    print(f"✓ Response: {json.dumps(result, indent=2)}")
            except:
                print(f"✓ Response received")
        else:
            print(f"Response: {response.text}")
        
        return response.status_code == 200
        
    except requests.exceptions.ConnectionError:
        print("✗ Connection Error - App may not be running")
        return False
    except requests.exceptions.Timeout:
        print("✗ Timeout Error")
        return False
    except Exception as e:
        print(f"✗ Error: {str(e)}")
        return False

def main():
    print("\n" + "="*60)
    print("WASTE MANAGEMENT SYSTEM - API ENDPOINT TESTS")
    print("="*60)
    
    # Wait for app to be ready
    print("\nWaiting for app to be ready...")
    time.sleep(2)
    
    tests_passed = 0
    tests_failed = 0
    
    # Test Dashboard
    endpoints_to_test = [
        ("GET", "/"),
        ("GET", "/api/citizens"),
        ("GET", "/api/areas"),
        ("GET", "/api/crew"),
        ("GET", "/api/waste"),
        ("GET", "/api/bins"),
        ("GET", "/api/bills"),
        ("GET", "/api/payments"),
        ("GET", "/api/schedules"),
        ("GET", "/api/centers"),
        ("GET", "/api/areas-list"),
        ("GET", "/api/citizens-list"),
        ("GET", "/api/crews-list"),
        ("GET", "/api/bills-list"),
    ]
    
    for method, endpoint in endpoints_to_test:
        if test_endpoint(method, endpoint):
            tests_passed += 1
        else:
            tests_failed += 1
    
    # Test POST endpoints with valid data
    test_data = {
        "area_name": "Test Zone",
        "location": "Test Location",
        "population": 1000
    }
    
    if test_endpoint("POST", "/api/areas", test_data):
        tests_passed += 1
    else:
        tests_failed += 1
    
    print("\n" + "="*60)
    print(f"TEST RESULTS")
    print("="*60)
    print(f"✓ Passed: {tests_passed}")
    print(f"✗ Failed: {tests_failed}")
    print(f"Total: {tests_passed + tests_failed}")
    print("="*60 + "\n")

if __name__ == "__main__":
    main()
