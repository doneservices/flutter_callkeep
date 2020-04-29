# callkeep

iOS CallKit and Android ConnectionService bindings for Flutter

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

## Device Permission

flutter_callkeep requires the following permissions.

### Android

If you want to use the function `displayIncomingCall`, please add the following permissions and service to the `AndroidManifest.xml`.

```xml
..
<uses-permission android:name="android.permission.BIND_TELECOM_CONNECTION_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.CALL_PHONE" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
..
```
```xml
<application>
    ..
    <service android:name="io.wazo.callkeep.VoiceConnectionService"
        android:label="Wazo"
        android:permission="android.permission.BIND_TELECOM_CONNECTION_SERVICE">
        <intent-filter>
            <action android:name="android.telecom.ConnectionService" />
        </intent-filter>
    </service>
    ..
</application>
```

if you want to use the function `displayCustomIncomingCall`, please add the following permission to the `AndroidManifest.xml`.

```xml
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
```