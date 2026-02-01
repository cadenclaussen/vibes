# Profile Enhancements - Requirements

## Functional Requirements

### Edit Profile

**REQ-1: Edit Profile Access**
WHEN the user taps the edit button on their profile
THEN the system SHALL present an Edit Profile sheet

**REQ-2: Display Name Editing**
WHILE editing profile
THE system SHALL allow the user to modify their display name
WITH a maximum of 50 characters
AND the field SHALL NOT be empty

**REQ-3: Bio Editing**
WHILE editing profile
THE system SHALL allow the user to add or modify a bio
WITH a maximum of 160 characters
AND the field MAY be empty

**REQ-4: Profile Picture Selection**
WHEN the user taps their profile picture in the edit sheet
THEN the system SHALL present a photo picker
AND allow selection from the device photo library

**REQ-5: Profile Picture Upload**
WHEN the user selects a new profile picture
THEN the system SHALL upload the image to Firebase Storage
AND update the user's profilePictureURL in Firestore
AND display a loading indicator during upload

**REQ-6: Save Profile Changes**
WHEN the user taps Save in the edit sheet
THEN the system SHALL validate all fields
AND persist changes to Firestore
AND dismiss the sheet on success
AND show an error alert on failure

**REQ-7: Cancel Edit**
WHEN the user taps Cancel or swipes down the edit sheet
THEN the system SHALL discard any unsaved changes
AND dismiss the sheet

### Profile Display

**REQ-8: Bio Display**
IF the user has a bio set
THEN the profile SHALL display the bio below the username
WITH secondary text styling
AND center alignment

**REQ-9: Edit Button Visibility**
WHEN viewing your own profile
THEN the system SHALL display an Edit button
WHEN viewing another user's profile
THEN the system SHALL NOT display an Edit button

### Top Genres

**REQ-10: Genre Extraction**
WHEN the profile loads AND Spotify is connected
THEN the system SHALL extract top genres from the user's top artists
AND display up to 5 unique genres

**REQ-11: Genre Display**
THE system SHALL display genres as horizontal chips/tags
WITH pill-shaped styling
AND accent color background
AND positioned below the followers/following counts

**REQ-12: Genre Loading State**
WHILE genres are loading
THE system SHALL display placeholder chips with shimmer effect

**REQ-13: No Genres State**
IF the user has no genres (Spotify not connected or no data)
THEN the system SHALL NOT display the genres section

## Non-Functional Requirements

**REQ-14: Image Size Limit**
THE system SHALL resize profile pictures to a maximum of 400x400 pixels
BEFORE uploading to Firebase Storage
TO reduce storage costs and load times

**REQ-15: Upload Performance**
THE profile picture upload SHALL complete within 5 seconds
ON a standard network connection
