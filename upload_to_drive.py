import os
import pickle
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from googleapiclient.errors import HttpError
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload


def get_credentials():
    """
    Gets valid user credentials from storage.

    If nothing has been stored, or if the stored credentials are invalid,
    the OAuth2 flow is completed to obtain the new credentials.

    Returns:
        Credentials, the obtained credential.
    """

    # The file token.pickle stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first time.
    if os.path.exists('token.pickle'):
        with open('token.pickle', 'rb') as token:
            creds = pickle.load(token)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                'credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open('token.pickle', 'wb') as token:
            pickle.dump(creds, token)

    return creds


def upload_to_drive(file_path, file_name):
    """
    Uploads a file to Google Drive using the Google Drive API.

    Args:
        file_path (str): Path to the file to upload.
        file_name (str): Name to give to the file in Google Drive.
    """

    # Set up the Drive API client
    service = build('drive', 'v3', credentials=get_credentials())

    try:
        # Create a MediaFileUpload object for the file
        file_metadata = {'name': file_name}
        media = MediaFileUpload(file_path,
                                mimetype='application/octet-stream')

        # Upload the file to the user's Google Drive
        file = service.files().create(body=file_metadata, media_body=media,
                                      fields='id').execute()
        print('File ID: %s' % file.get('id'))
    except HttpError as error:
        print('An error occurred: %s' % error)
        file = None

    return file


if __name__ == '__main__':
    file_path = '/path/to/all_databases-2023-03-26__01-00.tar.gz'
    file_name = 'all_databases-2023-03-26__01-00.tar.gz'
    upload_to_drive(file_path, file_name)


# You'll need to modify the file_path and file_name variables at the bottom of the script to match the file you want to upload.
#  You'll also need to download a credentials.json file from the Google API Console for your project,
#   and put it in the same directory as the script. Finally, you'll need to run pip install google-auth
#    google-auth-oauthlib google-auth-httplib2 google-api-python-client to install the required dependencies.