# callkeep

Showing incoming call notification/screen using iOS CallKit and Android Custom UI for Flutter

## Native setup

flutter_callkeep requires the following permissions.

### Android

No extra setup is needed


### iOS
in `Info.plist`

```
<key>UIBackgroundModes</key>
<array>
    <string>processing</string>
    <string>remote-notification</string>
    <string>voip</string>
</array>
```

Then you need to update `AppDelegate.swift` to follow the example for handling PushKit as push handling must be done through native iOS code due to [iOS 13 PushKit VoIP restrictions](https://developer.apple.com/documentation/pushkit/pkpushregistrydelegate/2875784-pushregistry).

```swift
import UIKit
import PushKit
import Flutter
import flutter_callkeep

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        //Setup VOIP
        let mainQueue = DispatchQueue.main
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // Handle updated push credentials
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        print(credentials.token)
        let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
        print(deviceToken)
        //Save deviceToken to your server
        SwiftCallKeepPlugin.sharedInstance?.setDevicePushTokenVoIP(deviceToken)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("didInvalidatePushTokenFor")
        SwiftCallKeepPlugin.sharedInstance?.setDevicePushTokenVoIP("")
    }
    
    // Handle incoming pushes
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        print("didReceiveIncomingPushWith")
        guard type == .voIP else { return }
        
        let id = payload.dictionaryPayload["id"] as? String ?? ""
        let callerName = payload.dictionaryPayload["callerName"] as? String ?? ""
        let userId = payload.dictionaryPayload["callerId"] as? String ?? ""
        let handle = payload.dictionaryPayload["handle"] as? String ?? ""
        let isVideo = payload.dictionaryPayload["isVideo"] as? Bool ?? false
        
        let data = flutter_callkeep.Data(id: id, callerName: callerName, handle: handle, hasVideo: isVideo)
        //set more data
        data.extra = ["userId": callerId, "platform": "ios"]
        data.appName = "Done"
        //data.iconName = ...
        //data.....
        SwiftCallKeepPlugin.sharedInstance?.displayIncomingCall(data, fromPushKit: true)
    }   
}
```

## Usage

### Setup: 

You need to have base `CallKeep` config setup to reduce code duplication and make it easier to display incoming calls: 

```dart
 final callKeepBaseConfig = CallKeepBaseConfig(
      appName: 'Done',
      androidConfig: CallKeepAndroidConfig(
        logo: 'logo',
        notificationIcon: 'notification_icon',
        ringtoneFileName: 'ringtone.mp3',
        accentColor: '#34C7C2',
      ),
      iosConfig: CallKeepIosConfig(
        iconName: 'Icon',
        maximumCallGroups: 1,
      ),
    );
```

### Display incoming call:

```dart
// Config and uuid are the only required parameters
final config = CallKeepIncomingConfig.fromBaseConfig(
    config: callKeepBaseConfig,
    uuid: uuid,
    contentTitle: 'Incoming call from Done',
    hasVideo: hasVideo,
    handle: handle,
    callerName: incomingCallUsername,
    extra: callData,
);
await CallKeep.instance.displayIncomingCall(config);
```

### Show missed call notification (Android only):

```dart
// config and uuid are the only required parameters
final config = CallKeepIncomingConfig.fromBaseConfig(
    config: callKeepBaseConfig,
    uuid: uuid,
    contentTitle: 'Incoming call from Done',
    hasVideo: hasVideo,
    handle: handle,
    callerName: incomingCallUsername,
    extra: callData,
);
await CallKeep.instance.showMissCallNotification(config);
```

### Start an outgoing call:

```dart
// config and uuid are the only required parameters
final config = CallKeepOutgoingConfig.fromBaseConfig(
    config: DoneCallsConfig.instance.callKeepBaseConfig,
    uuid: uuid,
    handle: handle,
    hasVideo: hasVideo ?? false,
);
CallKeep.instance.startCall(config);
```

### Handling events:

```dart
CallKeep.instance.onEvent.listen((event) async {
    // TODO: Implement other events
    if (event == null) return;
    switch (event.type) {
        case CallKeepEventType.callAccept:
        final data = event.data as CallKeepCallData;
        print('call answered: ${data.toMap()}');
        NavigationService.instance
            .pushNamedIfNotCurrent(AppRoute.callingPage, args: data.toMap());
        if (callback != null) callback.call(event);
        break;
        case CallKeepEventType.callDecline:
        final data = event.data as CallKeepCallData;
        print('call declined: ${data.toMap()}');
        await requestHttp("ACTION_CALL_DECLINE_FROM_DART");
        if (callback != null) callback.call(data);
        break;
        default:
        break;
    }
});
```

### Customization (Android):

You can customize background color and add localizations to text through adding the values to your '{{yourApp}}/android/app/src/main/res/values' and '{{yourApp}}/android/app/src/main/res/values-{{languageCode}}' for localizations.

The main values are:
in `colors.xml`
```xml
    <!-- A hex color value to be displayed on the top part of the custom incoming call UI --> 
    <color name="incoming_call_bg_color">#80ffffff</color>
```

in `strings.xml`
```xml
    <!-- Accept button call text, useful for localization --> 
    <string name="accept_text">Accept</string>
    <!-- Decline button call text, useful for localization --> 
    <string name="decline_text">Decline</string>
    <!-- Missed call text, useful for localization --> 
    <string name="text_missed_call">Missed call</string>
    <!-- Callback button text, useful for localization --> 
    <string name="text_call_back">Call back</string>
    <!-- Incoming call custom UI header, useful for localization -->
    <!-- This can be set from Flutter as well when displaying incoming call --> 
    <string name="call_header">Call from CallKeep</string>
```