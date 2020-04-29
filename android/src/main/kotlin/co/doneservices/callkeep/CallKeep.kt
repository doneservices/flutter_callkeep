package co.doneservices.callkeep

import android.Manifest
import android.app.Activity
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.*
import android.content.pm.PackageManager
import android.graphics.drawable.Icon
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.telecom.*
import android.telephony.TelephonyManager
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import io.wazo.callkeep.Constants
import io.wazo.callkeep.VoiceConnection
import io.wazo.callkeep.VoiceConnectionService
import kotlin.collections.HashMap

private const val E_ACTIVITY_DOES_NOT_EXIST = "E_ACTIVITY_DOES_NOT_EXIST"

private const val TAG = "CallKeep:CallKeepPlugin"
private const val REQUEST_READ_PHONE_STATE = 58251
private const val NOTIFICATION_ID = 38496

private val requiredPermissions = arrayOf(Manifest.permission.READ_PHONE_STATE, Manifest.permission.CALL_PHONE, Manifest.permission.RECORD_AUDIO)

private fun isConnectionServiceAvailable(): Boolean {
    // PhoneAccount is available since api level 23
    return Build.VERSION.SDK_INT >= 23
}

class CallKeep(private val channel: MethodChannel, private var applicationContext: Context) : MethodChannel.MethodCallHandler, PluginRegistry.RequestPermissionsResultListener {
    internal var currentActivity: Activity? = null

    private var isReceiverRegistered = false

    private var hasPhoneAccountResult: MethodChannel.Result? = null
    private var voiceBroadcastReceiver: VoiceBroadcastReceiver? = null

    private var handle: PhoneAccountHandle? = null
    private var telecomManager: TelecomManager? = null
    private var telephonyManager: TelephonyManager? = null

    init {
        channel.setMethodCallHandler(this)
    }

    internal fun stopListening() {
        channel.setMethodCallHandler(null)
    }

    private fun hasPhoneAccount(): Boolean {
        return isConnectionServiceAvailable() && telecomManager!!.getPhoneAccount(handle).isEnabled
    }
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setup" -> {
                setup(call.argument("imageName"))
                result.success(null)
            }
            "displayIncomingCall" -> {
                displayIncomingCall(call.argument("uuid")!!, call.argument("number"), call.argument("callerName"))
                result.success(null)
            }
            "answerIncomingCall" -> {
                answerIncomingCall(call.argument("uuid")!!)
                result.success(null)
            }
            "startCall" -> {
                startCall(call.argument("uuid")!!, call.argument("number"), call.argument("callerName"))
                result.success(null)
            }
            "endCall" -> {
                endCall(call.argument("uuid")!!)
                result.success(null)
            }
            "endAllCalls" -> {
                endAllCalls()
                result.success(null)
            }
            "checkPhoneAccountPermission" -> {
                checkPhoneAccountPermission(call.argument<List<String>>("optionalPermissions")!!.toTypedArray(), result)
            }
            "checkDefaultPhoneAccount" -> {
                checkDefaultPhoneAccount(result)
            }
            "setOnHold" -> {
                setOnHold(call.argument("uuid")!!, call.argument("hold")!!)
                result.success(null)
            }
            "reportEndCallWithUUID" -> {
                reportEndCallWithUUID(call.argument("uuid")!!, call.argument("reason")!!)
                result.success(null)
            }
            "rejectCall" -> {
                rejectCall(call.argument("uuid")!!)
                result.success(null)
            }
            "setMutedCall" -> {
                setMutedCall(call.argument("uuid")!!, call.argument("muted")!!)
                result.success(null)
            }
            "sendDTMF" -> {
                sendDTMF(call.argument("uuid")!!, call.argument("key")!!)
                result.success(null)
            }
            "updateDisplay" -> {
                updateDisplay(call.argument("uuid")!!, call.argument("displayName"), call.argument("uri"))
                result.success(null)
            }
            "hasPhoneAccount" -> {
                hasPhoneAccount(result)
            }
            "hasOutgoingCall" -> {
                hasOutgoingCall(result)
            }
            "hasPermissions" -> {
                hasPermissions(result)
            }
            "setAvailable" -> {
                setAvailable(call.argument("available")!!)
                result.success(null)
            }
            "setReachable" -> {
                setReachable()
                result.success(null)
            }
            "setCurrentCallActive" -> {
                setCurrentCallActive(call.argument("uuid")!!)
                result.success(null)
            }
            "openPhoneAccounts" -> {
                openPhoneAccounts(result)
            }
            "openPhoneAccountSettings" -> {
                openPhoneAccountSettings(result)
            }
            "backToForeground" -> {
                backToForeground(result)
            }
            "displayCustomIncomingCall" -> {
                displayCustomIncomingCall(call.argument("packageName")!!, call.argument("className")!!, call.argument("icon")!!, call.argument("extra")!!, call.argument("contentTitle")!!, call.argument("answerText")!!, call.argument("declineText")!!, call.argument("ringtoneUri"))
                result.success(null)
            }
            "dismissCustomIncomingCall" -> {
                dismissCustomIncomingCall()
                result.success(null)
            }
            "isCurrentDeviceSupported" -> {
                isCurrentDeviceSupported(result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }


    private fun setup(imageName: String?) {
        VoiceConnectionService.setAvailable(false)

        if (isConnectionServiceAvailable()) {
            registerPhoneAccount(applicationContext, imageName)
            voiceBroadcastReceiver = VoiceBroadcastReceiver()
            registerReceiver()
            VoiceConnectionService.setPhoneAccountHandle(handle)
            VoiceConnectionService.setAvailable(true)
        }
    }

    private fun displayIncomingCall(uuid: String, number: String?, callerName: String?) {
        if (!isConnectionServiceAvailable() || !hasPhoneAccount()) return

        Log.d(TAG, "displayIncomingCall number: $number, callerName: $callerName")
        val extras = Bundle()
        val uri = Uri.fromParts(PhoneAccount.SCHEME_TEL, number, null)
        extras.putParcelable(TelecomManager.EXTRA_INCOMING_CALL_ADDRESS, uri)
        extras.putString(Constants.EXTRA_CALLER_NAME, callerName)
        extras.putString(Constants.EXTRA_CALL_UUID, uuid)
        telecomManager!!.addNewIncomingCall(handle, extras)
    }

    private fun answerIncomingCall(uuid: String) {
        Log.d(TAG, "answerIncomingCall called")
        if (!isConnectionServiceAvailable() || !hasPhoneAccount()) return

        val conn = VoiceConnectionService.getConnection(uuid) ?: return
        conn.onAnswer()
        Log.d(TAG, "answerIncomingCall executed")
    }

    private fun startCall(uuid: String, number: String?, callerName: String?) {
        if (!isConnectionServiceAvailable() || !hasPhoneAccount() || !hasPermissions() || number == null) {
            return
        }
        Log.d(TAG, "startCall number: $number, callerName: $callerName")
        val extras = Bundle()
        val uri = Uri.fromParts(PhoneAccount.SCHEME_TEL, number, null)
        val callExtras = Bundle()
        callExtras.putString(Constants.EXTRA_CALLER_NAME, callerName)
        callExtras.putString(Constants.EXTRA_CALL_UUID, uuid)
        callExtras.putString(Constants.EXTRA_CALL_NUMBER, number)
        extras.putParcelable(TelecomManager.EXTRA_PHONE_ACCOUNT_HANDLE, handle)
        extras.putParcelable(TelecomManager.EXTRA_OUTGOING_CALL_EXTRAS, callExtras)
        telecomManager!!.placeCall(uri, extras)
    }

    private fun endCall(uuid: String) {
        Log.d(TAG, "endCall called")
        if (!isConnectionServiceAvailable() || !hasPhoneAccount()) return

        val conn = VoiceConnectionService.getConnection(uuid) ?: return
        conn.onDisconnect()
        Log.d(TAG, "endCall executed")
    }

    private fun endAllCalls() {
        Log.d(TAG, "endAllCalls called")
        if (!isConnectionServiceAvailable() || !hasPhoneAccount()) return

        val currentConnections = VoiceConnectionService.currentConnections
        for ((_, connectionToEnd) in currentConnections) {
            connectionToEnd.onDisconnect()
        }
        Log.d(TAG, "endAllCalls executed")
    }

    private fun checkPhoneAccountPermission(optionalPermissions: Array<String>, result: MethodChannel.Result) {
        val activity = currentActivity

        if (!isConnectionServiceAvailable()) {
            result.error(E_ACTIVITY_DOES_NOT_EXIST, "ConnectionService not available for this version of Android.", null)
            return
        }
        if (activity == null) {
            result.error(E_ACTIVITY_DOES_NOT_EXIST, "Activity doesn't exist", null)
            return
        }
        val allPermissions = requiredPermissions + optionalPermissions
        hasPhoneAccountResult = result
        if (!this.hasPermissions()) {
            ActivityCompat.requestPermissions(activity, allPermissions, REQUEST_READ_PHONE_STATE)
            return
        }
        result.success(!hasPhoneAccount())
    }

    private fun checkDefaultPhoneAccount(result: MethodChannel.Result) {
        if (!isConnectionServiceAvailable() || !hasPhoneAccount()) {
            result.success(true)
            return
        }
        if (!Build.MANUFACTURER.equals("Samsung", ignoreCase = true)) {
            result.success(true)
            return
        }
        val hasSim = telephonyManager!!.simState != TelephonyManager.SIM_STATE_ABSENT
        val hasDefaultAccount = telecomManager!!.getDefaultOutgoingPhoneAccount("tel") != null
        result.success(!hasSim || hasDefaultAccount)
    }

    private fun setOnHold(uuid: String, hold: Boolean) {
        if (!isConnectionServiceAvailable()) return

        val conn = VoiceConnectionService.getConnection(uuid) ?: return
        if (hold) {
            conn.onHold()
        } else {
            conn.onUnhold()
        }
    }

    private fun reportEndCallWithUUID(uuid: String, reason: Int) {
        if (!isConnectionServiceAvailable() || !hasPhoneAccount()) return

        val conn = VoiceConnectionService.getConnection(uuid) as VoiceConnection?
                ?: return
        conn.reportDisconnect(reason)
    }

    private fun rejectCall(uuid: String) {
        if (!isConnectionServiceAvailable() || !hasPhoneAccount()) return

        val conn = VoiceConnectionService.getConnection(uuid) ?: return
        conn.onReject()
    }

    private fun setMutedCall(uuid: String, muted: Boolean) {
        if (!isConnectionServiceAvailable()) return

        val conn = VoiceConnectionService.getConnection(uuid) ?: return
        // if the requester wants to mute, do that. otherwise unmute
        val newAudioState = if (muted) {
            CallAudioState(true, conn.callAudioState.route,
                    conn.callAudioState.supportedRouteMask)
        } else {
            CallAudioState(false, conn.callAudioState.route,
                    conn.callAudioState.supportedRouteMask)
        }
        conn.onCallAudioStateChanged(newAudioState)
    }

    private fun sendDTMF(uuid: String, key: String) {
        if (!isConnectionServiceAvailable()) return

        val conn = VoiceConnectionService.getConnection(uuid) ?: return
        val dtmf = key[0]
        conn.onPlayDtmfTone(dtmf)
    }

    private fun updateDisplay(uuid: String, displayName: String?, uri: String?) {
        if (!isConnectionServiceAvailable()) return

        val conn = VoiceConnectionService.getConnection(uuid) ?: return
        conn.setAddress(Uri.parse(uri), TelecomManager.PRESENTATION_ALLOWED)
        conn.setCallerDisplayName(displayName, TelecomManager.PRESENTATION_ALLOWED)
    }

    private fun hasPhoneAccount(result: MethodChannel.Result) {
        result.success(hasPhoneAccount())
    }

    private fun hasOutgoingCall(result: MethodChannel.Result) {
        result.success(VoiceConnectionService.hasOutgoingCall)
    }

    private fun hasPermissions(result: MethodChannel.Result) {
        result.success(this.hasPermissions())
    }

    private fun setAvailable(available: Boolean) {
        VoiceConnectionService.setAvailable(available)
    }

    private fun setReachable() {
        VoiceConnectionService.setReachable()
    }

    private fun setCurrentCallActive(uuid: String) {
        if (!isConnectionServiceAvailable()) return

        val conn = VoiceConnectionService.getConnection(uuid) ?: return
        conn.connectionCapabilities = conn.connectionCapabilities or Connection.CAPABILITY_HOLD
        conn.setActive()
    }

    private fun openPhoneAccounts(result: MethodChannel.Result) {
        if (!isConnectionServiceAvailable()) return

        if (Build.MANUFACTURER.equals("Samsung", ignoreCase = true)) {
            val intent = Intent()
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_MULTIPLE_TASK
            intent.component = ComponentName("com.android.server.telecom",
                    "com.android.server.telecom.settings.EnableAccountPreferenceActivity")
            applicationContext.startActivity(intent)
            return
        }

        openPhoneAccountSettings(result)
    }

    private fun openPhoneAccountSettings(result: MethodChannel.Result) {
        if (!isConnectionServiceAvailable()) return

        val intent = Intent(TelecomManager.ACTION_CHANGE_PHONE_ACCOUNTS)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_MULTIPLE_TASK
        applicationContext.startActivity(intent)
        result.success(null)
    }

    private fun backToForeground(result: MethodChannel.Result) {
        val activity = currentActivity

        val packageName = applicationContext.packageName
        val focusIntent = applicationContext.packageManager.getLaunchIntentForPackage(packageName)!!.cloneFilter()

        focusIntent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)

        if (activity != null) {
            activity.startActivity(focusIntent)
        } else {
            focusIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            applicationContext.startActivity(focusIntent)
        }

        result.success(null)
    }

    private fun displayCustomIncomingCall(packageName: String, className: String, icon: String, extra: HashMap<String, String>, contentTitle: String, answerText: String, declineText: String, ringtoneUri: String?) {
        val notificationManager = applicationContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        var launchIntent = Intent()
        launchIntent.setClassName(packageName, "$packageName.$className")
        launchIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NEW_TASK)
        launchIntent.putExtra("co.doneservices.callkeep.NOTIFICATION_ID", NOTIFICATION_ID)

        for ((key, value) in extra) {
            launchIntent.putExtra(key, value)
        }

        var answerIntent = Intent()
        answerIntent.putExtra("co.doneservices.callkeep.ACTION", "answer")
        answerIntent.setClassName(packageName, "$packageName.$className")
        for ((key, value) in extra) {
            answerIntent.putExtra(key, value)
        }

        var declineIntent = Intent()
        declineIntent.putExtra("co.doneservices.callkeep.ACTION", "decline")
        declineIntent.setClassName(packageName, "$packageName.$className")
        for ((key, value) in extra) {
            declineIntent.putExtra(key, value)
        }
        

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel("incoming_calls", "Incoming Calls", NotificationManager.IMPORTANCE_HIGH)
            notificationManager.createNotificationChannel(channel)
        }

        val pendingIntent = PendingIntent.getActivity(applicationContext, 0, launchIntent, PendingIntent.FLAG_CANCEL_CURRENT)
        val builder = NotificationCompat.Builder(applicationContext, "incoming_calls")

        builder.setSmallIcon(applicationContext.resources.getIdentifier(icon, "drawable", applicationContext.packageName))
        builder.setFullScreenIntent(pendingIntent, true)
        builder.setOngoing(true)
        builder.setCategory(NotificationCompat.CATEGORY_CALL)
        builder.setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
        builder.setPriority(NotificationCompat.PRIORITY_MAX)
        builder.setAutoCancel(true)

        if (ringtoneUri != null) {
            builder.setSound(Uri.parse(ringtoneUri))
        }

        builder.setContentTitle(contentTitle)
        builder.addAction(0, declineText, PendingIntent.getActivity(applicationContext, 1, declineIntent, PendingIntent.FLAG_CANCEL_CURRENT))
        builder.addAction(0, answerText, PendingIntent.getActivity(applicationContext, 2, answerIntent, PendingIntent.FLAG_CANCEL_CURRENT))

        notificationManager.notify(NOTIFICATION_ID, builder.build())
    }

    private fun dismissCustomIncomingCall() {
        val notificationManager = applicationContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancel(NOTIFICATION_ID)
    }

    private fun isCurrentDeviceSupported(result: MethodChannel.Result) {
        result.success(isConnectionServiceAvailable());
    }

    private fun registerPhoneAccount(appContext: Context, imageName: String?) {
        if (!isConnectionServiceAvailable()) return

        val cName = ComponentName(applicationContext, VoiceConnectionService::class.java)
        val appName = getApplicationName(appContext)
        handle = PhoneAccountHandle(cName, appName)
        val builder = PhoneAccount.Builder(handle, appName)
                .setCapabilities(PhoneAccount.CAPABILITY_CALL_PROVIDER)
        if (imageName != null) {
            val identifier = appContext.resources.getIdentifier(imageName, "drawable", appContext.packageName)
            val icon = Icon.createWithResource(appContext, identifier)
            builder.setIcon(icon)
        }
        val account = builder.build()
        telephonyManager = applicationContext.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        telecomManager = applicationContext.getSystemService(Context.TELECOM_SERVICE) as TelecomManager
        telecomManager!!.registerPhoneAccount(account)
    }

    private fun getApplicationName(appContext: Context): String {
        val applicationInfo = appContext.applicationInfo
        val stringId = applicationInfo.labelRes
        return if (stringId == 0) applicationInfo.nonLocalizedLabel.toString() else appContext.getString(stringId)
    }

    private fun hasPermissions(): Boolean {
        // FIXME: raise proper error if currentActivity == null
        val activity = currentActivity!!

        for (permission in requiredPermissions) {
            val permissionCheck = ContextCompat.checkSelfPermission(activity, permission)
            if (permissionCheck != PackageManager.PERMISSION_GRANTED) return false
        }

        return true
    }

    private fun registerReceiver() {
        if (isReceiverRegistered) return

        val intentFilter = IntentFilter()
        intentFilter.addAction(Constants.ACTION_END_CALL)
        intentFilter.addAction(Constants.ACTION_ANSWER_CALL)
        intentFilter.addAction(Constants.ACTION_MUTE_CALL)
        intentFilter.addAction(Constants.ACTION_UNMUTE_CALL)
        intentFilter.addAction(Constants.ACTION_DTMF_TONE)
        intentFilter.addAction(Constants.ACTION_UNHOLD_CALL)
        intentFilter.addAction(Constants.ACTION_HOLD_CALL)
        intentFilter.addAction(Constants.ACTION_ONGOING_CALL)
        intentFilter.addAction(Constants.ACTION_AUDIO_SESSION)
        intentFilter.addAction(Constants.ACTION_CHECK_REACHABILITY)
        LocalBroadcastManager.getInstance(applicationContext).registerReceiver(voiceBroadcastReceiver!!, intentFilter)

        isReceiverRegistered = true
    }


    /// VideoBroadcastReceiver gets events from VoiceConnectionService
    /// it then invokes methods on the Flutter app
    private inner class VoiceBroadcastReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            Log.i(TAG, "Received action: ${intent.action}")

            @Suppress("UNCHECKED_CAST")
            val attributeMap = intent.getSerializableExtra("attributeMap") as? HashMap<String, String>

            when (intent.action) {
                Constants.ACTION_END_CALL -> {
                    channel.invokeMethod("performEndCallAction", hashMapOf(
                            "callUUID" to attributeMap?.get(Constants.EXTRA_CALL_UUID)
                    ))
                }
                Constants.ACTION_ANSWER_CALL -> {
                    channel.invokeMethod("performAnswerCallAction", hashMapOf(
                            "callUUID" to attributeMap?.get(Constants.EXTRA_CALL_UUID)
                    ))
                }
                Constants.ACTION_HOLD_CALL -> {
                    channel.invokeMethod("didToggleHoldAction", hashMapOf(
                            "hold" to true,
                            "callUUID" to attributeMap?.get(Constants.EXTRA_CALL_UUID)
                    ))
                }
                Constants.ACTION_UNHOLD_CALL -> {
                    channel.invokeMethod("didToggleHoldAction", hashMapOf(
                            "hold" to false,
                            "callUUID" to attributeMap?.get(Constants.EXTRA_CALL_UUID)
                    ))
                }
                Constants.ACTION_MUTE_CALL -> {
                    channel.invokeMethod("didPerformSetMutedCallAction", hashMapOf(
                            "muted" to true,
                            "callUUID" to attributeMap?.get(Constants.EXTRA_CALL_UUID)
                    ))
                }
                Constants.ACTION_UNMUTE_CALL -> {
                    channel.invokeMethod("didPerformSetMutedCallAction", hashMapOf(
                            "muted" to false,
                            "callUUID" to attributeMap?.get(Constants.EXTRA_CALL_UUID)
                    ))
                }
                Constants.ACTION_DTMF_TONE -> {
                    channel.invokeMethod("didPerformDTMFAction", hashMapOf(
                            "digits" to attributeMap?.get("DTMF"),
                            "callUUID" to attributeMap?.get(Constants.EXTRA_CALL_UUID)
                    ))
                }
                Constants.ACTION_ONGOING_CALL -> {
                    channel.invokeMethod("didReceiveStartCallAction", hashMapOf(
                            "handle" to attributeMap?.get(Constants.EXTRA_CALL_NUMBER),
                            "callUUID" to attributeMap?.get(Constants.EXTRA_CALL_UUID),
                            "name" to attributeMap?.get(Constants.EXTRA_CALLER_NAME)
                    ))
                }
                Constants.ACTION_AUDIO_SESSION -> {
                    channel.invokeMethod("didActivateAudioSession", null)
                }
                Constants.ACTION_CHECK_REACHABILITY -> {
                    channel.invokeMethod("checkReachability", null)
                }
                Constants.ACTION_WAKE_APP -> {
                    val headlessIntent = Intent(context, CallKeepBackgroundMessagingService::class.java)
                    headlessIntent.putExtra("callUUID", attributeMap?.get(Constants.EXTRA_CALL_UUID))
                    headlessIntent.putExtra("name", attributeMap?.get(Constants.EXTRA_CALLER_NAME))
                    headlessIntent.putExtra("handle", attributeMap?.get(Constants.EXTRA_CALL_NUMBER))
                    Log.d(TAG, "wakeUpApplication: ${attributeMap?.get(Constants.EXTRA_CALL_UUID)}, number: ${attributeMap?.get(Constants.EXTRA_CALL_NUMBER)}, displayName: ${attributeMap?.get(Constants.EXTRA_CALLER_NAME)}")
                    context.startService(headlessIntent)
                }
            }
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, grantedPermissions: Array<out String>?, grantResults: IntArray?): Boolean {
        if (requestCode != REQUEST_READ_PHONE_STATE) {
            return false
        }

        for ((permissionsIndex, result) in grantResults!!.withIndex()) {
            if (requiredPermissions.contains(grantedPermissions!![permissionsIndex]) && result != PackageManager.PERMISSION_GRANTED) {
                hasPhoneAccountResult!!.success(false)
                hasPhoneAccountResult = null
                return true
            }
        }

        hasPhoneAccountResult!!.success(true)
        hasPhoneAccountResult = null

        return true
    }
}
