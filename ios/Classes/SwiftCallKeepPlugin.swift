import Flutter
import UIKit
import CallKit
import AVFoundation

@available(iOS 10.0, *)
public class SwiftCallKeepPlugin: NSObject, FlutterPlugin, CXProviderDelegate {
    
    static let ACTION_DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP = "co.doneservices.callkeep.DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP"
    
    static let ACTION_CALL_INCOMING = "co.doneservices.callkeep.ACTION_CALL_INCOMING"
    static let ACTION_CALL_START = "co.doneservices.callkeep.ACTION_CALL_START"
    static let ACTION_CALL_ACCEPT = "co.doneservices.callkeep.ACTION_CALL_ACCEPT"
    static let ACTION_CALL_DECLINE = "co.doneservices.callkeep.ACTION_CALL_DECLINE"
    static let ACTION_CALL_ENDED = "co.doneservices.callkeep.ACTION_CALL_ENDED"
    static let ACTION_CALL_TIMEOUT = "co.doneservices.callkeep.ACTION_CALL_TIMEOUT"
    
    static let ACTION_CALL_TOGGLE_HOLD = "co.doneservices.callkeep.ACTION_CALL_TOGGLE_HOLD"
    static let ACTION_CALL_TOGGLE_MUTE = "co.doneservices.callkeep.ACTION_CALL_TOGGLE_MUTE"
    static let ACTION_CALL_TOGGLE_DMTF = "co.doneservices.callkeep.ACTION_CALL_TOGGLE_DMTF"
    static let ACTION_CALL_TOGGLE_GROUP = "co.doneservices.callkeep.ACTION_CALL_TOGGLE_GROUP"
    static let ACTION_CALL_TOGGLE_AUDIO_SESSION = "co.doneservices.callkeep.ACTION_CALL_TOGGLE_AUDIO_SESSION"
    
    @objc public static var sharedInstance: SwiftCallKeepPlugin? = nil
    
    private var channel: FlutterMethodChannel? = nil
    private var eventChannel: FlutterEventChannel? = nil
    private var callManager: CallManager? = nil
    
    private var eventCallbackHandler: EventCallbackHandler?
    private var sharedProvider: CXProvider? = nil
    
    private var outgoingCall : Call?
    private var answerCall : Call?
    
    private var data: Data?
    private var isFromPushKit: Bool = false
    private let devicePushTokenVoIP = "DevicePushTokenVoIP"
    
    private func sendEvent(_ event: String, _ body: [String : Any?]?) {
        let data = body ?? [:] as [String : Any?]
        eventCallbackHandler?.send(event, data)
    }
    
    @objc public func sendEventCustom(_ event: String, body: Any?) {
        eventCallbackHandler?.send(event, body ?? [:] as [String : Any?])
    }
    
    public static func sharePluginWithRegister(with registrar: FlutterPluginRegistrar) -> SwiftCallKeepPlugin {
        if(sharedInstance == nil){
            sharedInstance = SwiftCallKeepPlugin()
        }
        sharedInstance!.channel = FlutterMethodChannel(name: "flutter_callkeep", binaryMessenger: registrar.messenger())
        sharedInstance!.eventChannel = FlutterEventChannel(name: "flutter_callkeep_events", binaryMessenger: registrar.messenger())
        sharedInstance!.callManager = CallManager()
        sharedInstance!.eventCallbackHandler = EventCallbackHandler()
        sharedInstance!.eventChannel?.setStreamHandler(sharedInstance!.eventCallbackHandler as? FlutterStreamHandler & NSObjectProtocol)
        return sharedInstance!
    }
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = sharePluginWithRegister(with: registrar)
        registrar.addMethodCallDelegate(instance, channel: instance.channel!)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "displayIncomingCall":
            guard let args = call.arguments else {
                result(FlutterError.nilArgument)
                return
            }
            if let getArgs = args as? [String: Any] {
                self.data = Data(args: getArgs)
                displayIncomingCall(self.data!, fromPushKit: false)
            }
            result("OK")
            break
        case "showMissCallNotification":
            result("OK")
            break
        case "startCall":
            guard let args = call.arguments else {
                result(FlutterError.nilArgument)
                return
            }
            if let getArgs = args as? [String: Any] {
                self.data = Data(args: getArgs)
                self.startCall(self.data!, fromPushKit: false)
            }
            result("OK")
            break
        case "endCall":
            guard let args = call.arguments else {
                result(FlutterError.nilArgument)
                return
            }
            if let getArgs = args as? [String: Any] {
                self.data = Data(args: getArgs)
                self.endCall(self.data!)
            }
            result("OK")
            break
        case "activeCalls":
            result(self.callManager?.activeCalls())
            break;
        case "endAllCalls":
            self.callManager?.endAllCalls()
            result("OK")
            break
        case "getDevicePushTokenVoIP":
            result(self.getDevicePushTokenVoIP())
            break;
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    @objc public func setDevicePushTokenVoIP(_ deviceToken: String) {
        UserDefaults.standard.set(deviceToken, forKey: devicePushTokenVoIP)
        self.sendEvent(SwiftCallKeepPlugin.ACTION_DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP, ["deviceTokenVoIP":deviceToken])
    }
    
    @objc public func getDevicePushTokenVoIP() -> String {
        return UserDefaults.standard.string(forKey: devicePushTokenVoIP) ?? ""
    }
    
    @objc public func displayIncomingCall(_ data: Data, fromPushKit: Bool) {
        self.isFromPushKit = fromPushKit
        if(fromPushKit){
            self.data = data
        }
        
        var handle: CXHandle?
        handle = CXHandle(type: self.getHandleType(data.handleType), value: data.handle)
        
        let callUpdate = CXCallUpdate()
        callUpdate.remoteHandle = handle
        callUpdate.supportsDTMF = data.supportsDTMF
        callUpdate.supportsHolding = data.supportsHolding
        callUpdate.supportsGrouping = data.supportsGrouping
        callUpdate.supportsUngrouping = data.supportsUngrouping
        callUpdate.hasVideo = data.hasVideo
        callUpdate.localizedCallerName = data.callerName
        
        initCallkitProvider(data)
        
        let uuid = UUID(uuidString: data.uuid)
        
        configureAudioSession()
        self.sharedProvider?.reportNewIncomingCall(with: uuid!, update: callUpdate) { error in
            if(error == nil) {
                self.configureAudioSession()
                let call = Call(uuid: uuid!, data: data)
                call.handle = data.handle
                self.callManager?.addCall(call)
                self.sendEvent(SwiftCallKeepPlugin.ACTION_CALL_INCOMING, data.toJSON())
                self.endCallNotExist(data)
            }
        }
    }
    
    @objc public func startCall(_ data: Data, fromPushKit: Bool) {
        self.isFromPushKit = fromPushKit
        if(fromPushKit){
            self.data = data
        }
        initCallkitProvider(data)
        self.callManager?.startCall(data)
    }
    
    @objc public func endCall(_ data: Data) {
        if let uuid = UUID(uuidString: data.uuid) {
            var call: Call? = self.callManager?.callWithUUID(uuid: uuid)
            if(call == nil) {return}
            
            if(self.isFromPushKit){
                self.isFromPushKit = false
                self.sendEvent(SwiftCallKeepPlugin.ACTION_CALL_ENDED, data.toJSON())
            }
            self.callManager?.endCall(call: call!)
        }
    }
    
    @objc public func activeCalls() -> [[String: Any]]? {
        return self.callManager?.activeCalls()
    }
    
    @objc public func endAllCalls() {
        self.isFromPushKit = false
        self.callManager?.endAllCalls()
    }
    
    public func saveEndCall(_ uuid: String, _ reason: Int) {
        var endReason : CXCallEndedReason?
        switch reason {
        case 1:
            endReason = CXCallEndedReason.failed
            break
        case 2, 6:
            endReason = CXCallEndedReason.remoteEnded
            break
        case 3:
            endReason = CXCallEndedReason.unanswered
            break
        case 4:
            endReason = CXCallEndedReason.answeredElsewhere
            break
        case 5:
            endReason = CXCallEndedReason.declinedElsewhere
            break
        default:
            break
        }
        if(endReason != nil){
            self.sharedProvider?.reportCall(with: UUID(uuidString: uuid)!, endedAt: Date(), reason: endReason!)
        }
    }
    
    func endCallNotExist(_ data: Data) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(data.duration)) {
            let call = self.callManager?.callWithUUID(uuid: UUID(uuidString: data.uuid)!)
            if (call != nil && self.answerCall == nil && self.outgoingCall == nil) {
                self.callEndTimeout(data)
            }
        }
    }
    
    
    
    func callEndTimeout(_ data: Data) {
        self.saveEndCall(data.uuid, 3)
        sendEvent(SwiftCallKeepPlugin.ACTION_CALL_TIMEOUT, data.toJSON())
    }
    
    func getHandleType(_ handleType: String?) -> CXHandle.HandleType {
        var typeDefault = CXHandle.HandleType.generic
        switch handleType {
        case "number":
            typeDefault = CXHandle.HandleType.phoneNumber
            break
        case "email":
            typeDefault = CXHandle.HandleType.emailAddress
        default:
            typeDefault = CXHandle.HandleType.generic
        }
        return typeDefault
    }
    
    func initCallkitProvider(_ data: Data) {
        if(self.sharedProvider == nil){
            self.sharedProvider = CXProvider(configuration: createConfiguration(data))
            self.sharedProvider?.setDelegate(self, queue: nil)
        }
        self.callManager?.setSharedProvider(self.sharedProvider!)
    }
    
    func createConfiguration(_ data: Data) -> CXProviderConfiguration {
        let configuration = CXProviderConfiguration(localizedName: data.appName)
        configuration.supportsVideo = data.supportsVideo
        configuration.maximumCallGroups = data.maximumCallGroups
        configuration.maximumCallsPerCallGroup = data.maximumCallsPerCallGroup
        
        configuration.supportedHandleTypes = [
            CXHandle.HandleType.generic,
            CXHandle.HandleType.emailAddress,
            CXHandle.HandleType.phoneNumber
        ]
        if #available(iOS 11.0, *) {
            configuration.includesCallsInRecents = data.includesCallsInRecents
        }
        if !data.iconName.isEmpty {
            if let image = UIImage(named: data.iconName) {
                configuration.iconTemplateImageData = image.pngData()
            } else {
                print("Unable to load icon \(data.iconName).");
            }
        }
        if !data.ringtoneFileName.isEmpty || data.ringtoneFileName != "system_ringtone_default"  {
            configuration.ringtoneSound = data.ringtoneFileName
        }
        return configuration
    }
    
    
    
    func senddefaultAudioInterruptionNofificationToStartAudioResource(){
        var userInfo : [AnyHashable : Any] = [:]
        let intrepEndeRaw = AVAudioSession.InterruptionType.ended.rawValue
        userInfo[AVAudioSessionInterruptionTypeKey] = intrepEndeRaw
        userInfo[AVAudioSessionInterruptionOptionKey] = AVAudioSession.InterruptionOptions.shouldResume.rawValue
        NotificationCenter.default.post(name: AVAudioSession.interruptionNotification, object: self, userInfo: userInfo)
    }
    
    func configureAudioSession(){
        let session = AVAudioSession.sharedInstance()
        do{
            try session.setCategory(AVAudioSession.Category.playAndRecord, options: AVAudioSession.CategoryOptions.allowBluetooth)
            try session.setMode(self.getAudioSessionMode(data?.audioSessionMode))
            try session.setActive(data?.audioSessionActive ?? true)
            try session.setPreferredSampleRate(data?.audioSessionPreferredSampleRate ?? 44100.0)
            try session.setPreferredIOBufferDuration(data?.audioSessionPreferredIOBufferDuration ?? 0.005)
        }catch{
            print(error)
        }
    }
    
    func getAudioSessionMode(_ audioSessionMode: String?) -> AVAudioSession.Mode {
        var mode = AVAudioSession.Mode.default
        switch audioSessionMode {
        case "gameChat":
            mode = AVAudioSession.Mode.gameChat
            break
        case "measurement":
            mode = AVAudioSession.Mode.measurement
            break
        case "moviePlayback":
            mode = AVAudioSession.Mode.moviePlayback
            break
        case "spokenAudio":
            mode = AVAudioSession.Mode.spokenAudio
            break
        case "videoChat":
            mode = AVAudioSession.Mode.videoChat
            break
        case "videoRecording":
            mode = AVAudioSession.Mode.videoRecording
            break
        case "voiceChat":
            mode = AVAudioSession.Mode.voiceChat
            break
        case "voicePrompt":
            if #available(iOS 12.0, *) {
                mode = AVAudioSession.Mode.voicePrompt
            } else {
                // Fallback on earlier versions
            }
            break
        default:
            mode = AVAudioSession.Mode.default
        }
        return mode
    }
    
    
    
    
    
    
    
    public func providerDidReset(_ provider: CXProvider) {
        if(self.callManager == nil){ return }
        for call in self.callManager!.calls{
            call.endCall()
        }
        self.callManager?.removeAllCalls()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        let call = Call(uuid: action.callUUID, data: self.data!, isOutGoing: true)
        call.handle = action.handle.value
        configureAudioSession()
        call.hasStartedConnectDidChange = { [weak self] in
            self?.sharedProvider?.reportOutgoingCall(with: call.uuid, startedConnectingAt: call.connectData)
        }
        call.hasConnectDidChange = { [weak self] in
            self?.sharedProvider?.reportOutgoingCall(with: call.uuid, startedConnectingAt: call.connectedData)
        }
        self.outgoingCall = call;
        self.callManager?.addCall(call)
        self.sendEvent(SwiftCallKeepPlugin.ACTION_CALL_START, call.data.toJSON())
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard let call = self.callManager?.callWithUUID(uuid: action.callUUID) else{
            action.fail()
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1200)) {
            self.configureAudioSession()
        }
        call.data.isAccepted = true
        self.answerCall = call
        self.callManager?.updateCall(call)
        sendEvent(SwiftCallKeepPlugin.ACTION_CALL_ACCEPT, call.data.toJSON())
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        guard let call = self.callManager?.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        call.endCall()
        self.callManager?.removeCall(call)
        if (self.answerCall == nil && self.outgoingCall == nil) {
            sendEvent(SwiftCallKeepPlugin.ACTION_CALL_DECLINE, call.data.toJSON())
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                action.fulfill()
            }
        }else {
            sendEvent(SwiftCallKeepPlugin.ACTION_CALL_ENDED, call.data.toJSON())
            action.fulfill()
        }
    }
    
    
    public func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        guard let call = self.callManager?.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        call.isOnHold = action.isOnHold
        call.isMuted = action.isOnHold
        self.callManager?.setHold(call: call, onHold: action.isOnHold)
        self.sendEvent(SwiftCallKeepPlugin.ACTION_CALL_TOGGLE_HOLD, [ "id": action.callUUID.uuidString, "isOnHold": action.isOnHold ])
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        guard let call = self.callManager?.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        call.isMuted = action.isMuted
        self.sendEvent(SwiftCallKeepPlugin.ACTION_CALL_TOGGLE_MUTE, [ "id": action.callUUID.uuidString, "isMuted": action.isMuted ])
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXSetGroupCallAction) {
        guard (self.callManager?.callWithUUID(uuid: action.callUUID)) != nil else {
            action.fail()
            return
        }
        self.sendEvent(SwiftCallKeepPlugin.ACTION_CALL_TOGGLE_GROUP, [ "id": action.callUUID.uuidString, "callUUIDToGroupWith" : action.callUUIDToGroupWith?.uuidString])
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXPlayDTMFCallAction) {
        guard (self.callManager?.callWithUUID(uuid: action.callUUID)) != nil else {
            action.fail()
            return
        }
        self.sendEvent(SwiftCallKeepPlugin.ACTION_CALL_TOGGLE_DMTF, [ "id": action.callUUID.uuidString, "digits": action.digits, "type": action.type ])
        action.fulfill()
    }
    
    
    public func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        sendEvent(SwiftCallKeepPlugin.ACTION_CALL_TIMEOUT, self.data?.toJSON())
    }
    
    public func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        if(self.answerCall?.hasConnected ?? false){
            senddefaultAudioInterruptionNofificationToStartAudioResource()
            return
        }
        if(self.outgoingCall?.hasConnected ?? false){
            senddefaultAudioInterruptionNofificationToStartAudioResource()
            return
        }
        self.outgoingCall?.startCall(withAudioSession: audioSession) {success in
            if success {
                self.callManager?.addCall(self.outgoingCall!)
            }
        }
        self.answerCall?.ansCall(withAudioSession: audioSession) { _ in }
        senddefaultAudioInterruptionNofificationToStartAudioResource()
        configureAudioSession()
        self.sendEvent(SwiftCallKeepPlugin.ACTION_CALL_TOGGLE_AUDIO_SESSION, ["answerCall": self.answerCall?.data.toJSON(), "outgoingCall": self.outgoingCall?.data.toJSON(), "isActivate": true ])
    }
    
    public func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        if self.outgoingCall?.isOnHold ?? false || self.answerCall?.isOnHold ?? false{
            print("Call is on hold")
            return
        }
        
        self.sendEvent(SwiftCallKeepPlugin.ACTION_CALL_TOGGLE_AUDIO_SESSION, [ "isActivate": false ])
    }
    
    
}

class EventCallbackHandler: FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    
    public func send(_ event: String, _ body: Any) {
        let data: [String : Any] = [
            "event": event,
            "body": body
        ]
        eventSink?(data)
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}

extension FlutterError {
    static let nilArgument = FlutterError(
        code: "argument.nil",
        message: "Expected arguments when invoking channel method, but it is nil.", details: nil
    )
}