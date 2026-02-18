#!/usr/bin/env python3

"""
MySQL Credential Tester
Tests common MySQL passwords to find the correct one
"""

import mysql.connector
from mysql.connector import Error

# Common passwords to try
COMMON_PASSWORDS = [
    "",           # Empty password
    "root",       # Common default
    "password",   # Common default
    "admin",      # Common default
    "123456",     # Common default
    "mysql",      # Common default
]

def test_connection(host='localhost', user='root', password='', port=3306):
    """Test MySQL connection with given credentials"""
    try:
        conn = mysql.connector.connect(
            host=host,
            user=user,
            password=password,
            port=port
        )
        
        if conn.is_connected():
            cursor = conn.cursor()
            cursor.execute("SELECT VERSION()")
            version = cursor.fetchone()
            cursor.close()
            conn.close()
            return True, version[0]
    except Error as e:
        return False, str(e)
    
    return False, "Unknown error"

def main():
    print("=" * 70)
    print("MySQL Credential Tester")
    print("=" * 70)
    print()
    
    host = input("Enter MySQL host [localhost]: ").strip() or 'localhost'
    user = input("Enter MySQL user [root]: ").strip() or 'root'
    port_input = input("Enter MySQL port [3306]: ").strip() or '3306'
    
    try:
        port = int(port_input)
    except ValueError:
        print("Invalid port, using default 3306")
        port = 3306
    
    print()
    print(f"Testing connection to {user}@{host}:{port}")
    print("-" * 70)
    
    # Test common passwords
    found = False
    for password in COMMON_PASSWORDS:
        password_display = '(empty)' if password == "" else password
        print(f"Testing password: {password_display:<15}", end=" ... ")
        
        success, result = test_connection(host, user, password, port)
        
        if success:
            print(f"✓ SUCCESS!")
            print(f"  MySQL Version: {result}")
            print()
            print("=" * 70)
            print(f"✓ Found working password: '{password_display}'")
            print("=" * 70)
            print()
            print("Use this in PowerShell:")
            print(f'  $env:MYSQL_USER = "{user}"')
            print(f'  $env:MYSQL_PASSWORD = "{password}"')
            found = True
            break
        else:
            print(f"✗ Failed")
    
    if not found:
        print()
        print("=" * 70)
        print("None of the common passwords worked.")
        print("=" * 70)
        print()
        print("Options:")
        print("1. Try entering a custom password:")
        custom_password = input("   Enter password to test: ").strip()
        if custom_password:
            print(f"   Testing custom password...", end=" ")
            success, result = test_connection(host, user, custom_password, port)
            if success:
                print(f"✓ SUCCESS!")
                print(f"   MySQL Version: {result}")
                print()
                print("Use this in PowerShell:")
                print(f'  $env:MYSQL_USER = "{user}"')
                print(f'  $env:MYSQL_PASSWORD = "{custom_password}"')
            else:
                print(f"✗ Failed: {result}")
        
        print()
        print("2. Check MySQL Workbench for saved connections")
        print("3. Check Windows Credential Manager")
        print("4. Reset MySQL password if needed")

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nTest cancelled by user.")
    except Exception as e:
        print(f"\nError: {e}")

