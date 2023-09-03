#!/usr/bin/env python3

import os
import sys
from datetime import datetime, timedelta
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from googleapiclient.http import MediaFileUpload
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request

# Set the ID of the folder where the backup file will be uploaded
FOLDER_ID = 'your_folder_id_here'

# Set the expiration time for the file (2 months from now)
expiration_time = (datetime.utcnow() + timedelta(days=60)).isoformat() + 'Z'

def authenticate_with_google():
    creds = None
    if os.path.exists('token.json'):
        creds = Credentials.from_authorized_user_file('token.json')

    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file('client_secret.json', ['https://www.googleapis.com/auth/drive.file'])
            creds = flow.run_local_server(port=0)
            with open('token.json', 'w') as token:
                token.write(creds.to_json())
    return creds

def upload_file_to_drive(credentials_path, file_path):
    # Load credentials from the specified file
    creds = authenticate_with_google()

    # Create Drive API client
    service = build('drive', 'v3', credentials=creds)

    # Create file metadata
    file_metadata = {'name': os.path.basename(file_path),
                     'parents': [FOLDER_ID],
                     'expirationTime': expiration_time}

    # Create media object for file upload
    file_media = MediaFileUpload(file_path, resumable=True)

    try:
        # Upload the file to Google Drive
        file = service.files().create(body=file_metadata,
                                       media_body=file_media,
                                       fields='id').execute()

        print(f'File ID: {file.get("id")}')
    except HttpError as error:
        print(f'An error occurred: {error}')
        file = None

    return file

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print(f'Usage: {sys.argv[0]} <path_to_credentials_file> <file_path>')
        sys.exit(1)

    credentials_path = sys.argv[1]
    file_path = sys.argv[2]

    upload_file_to_drive(credentials_path, file_path)

# You'll need to modify the file_path and file_name variables at the bottom of the script to match the file you want to upload.
#  You'll also need to download a credentials.json file from the Google API Console for your project,
#   and put it in the same directory as the script. Finally, you'll need to run pip install google-auth
#    google-auth-oauthlib google-auth-httplib2 google-api-python-client to install the required dependencies.

# Note that the expiration time is specified in ISO 8601 format with a UTC timezone offset ('Z'),
#  and is calculated as 2 months from the current time using the timedelta function from the datetime module.
#   You can adjust the expiration time by changing the days argument of the timedelta function.
