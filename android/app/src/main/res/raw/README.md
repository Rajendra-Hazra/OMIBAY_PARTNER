# Incoming Job Notification Sound

This directory contains the custom notification sound for incoming job alerts.

## Required File

Place your notification sound file here:

```
android/app/src/main/res/raw/incoming_job.mp3
```

## Sound File Requirements

- **Format**: MP3 (recommended) or OGG
- **Duration**: 10-30 seconds (will loop automatically)
- **Size**: Keep under 1MB for optimal performance
- **Quality**: 128kbps or higher for good audio quality
- **Style**: Use an attention-grabbing ringtone similar to Uber/Ola driver apps

## iOS Sound Setup

For iOS, place the sound file at:

```
ios/Runner/incoming_job.aiff
```

**Note**: iOS requires AIFF or CAF format for notification sounds.

## How It Works

1. When an incoming job notification is received via FCM, the system plays this sound
2. The notification channel is configured with high importance and custom sound
3. Sound continues until user accepts/declines the job or timeout occurs
4. Cancelling the notification stops the sound

## Testing

1. Ensure the sound file is placed correctly
2. Run the app on a physical device (emulators may not play notification sounds)
3. Send a test FCM notification with:
   ```json
   {
     "data": {
       "type": "incoming_job",
       "job_id": "test123",
       "service": "Home Cleaning",
       "customer": "Test Customer",
       "location": "Test Location",
       "price": "1499",
       "distance": "2.5 km"
     }
   }
   ```

## Troubleshooting

- If sound doesn't play, check that notification permissions are granted
- On Android 13+, ensure POST_NOTIFICATIONS permission is requested
- Clear app data if notification channel was created with wrong settings
- Check device is not in Do Not Disturb mode
