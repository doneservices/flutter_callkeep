package co.doneservices.callkeep

import android.os.Bundle

class Call {
}

@Suppress("UNCHECKED_CAST")
data class Data(val args: Map<String, Any?>) {

    var id: String = (args["id"] as? String) ?: ""
    var uuid: String = (args["id"] as? String) ?: ""
    var callerName: String = (args["callerName"] as? String) ?: ""
    var contentTitle: String = (args["contentTitle"] as? String) ?: ""
    var appName: String = (args["appName"] as? String) ?: ""
    var handle: String = (args["handle"] as? String) ?: ""
    var avatar: String = (args["avatar"] as? String) ?: ""
    var hasVideo: Boolean = (args["hasVideo"] as? Boolean) ?: false
    var duration: Long = (args["duration"] as? Long) ?: ((args["duration"] as? Int)?.toLong() ?: 30000L)
    var acceptText: String = (args["acceptText"] as? String) ?: ""
    var declineText: String = (args["declineText"] as? String) ?: ""
    var missedCallText: String = (args["missedCallText"] as? String) ?: ""
    var callBackText: String = (args["callBackText"] as? String) ?: ""
    var extra: HashMap<String, Any?> =
            (args["extra"] ?: HashMap<String, Any?>()) as HashMap<String, Any?>
    var headers: HashMap<String, Any?> =
            (args["headers"] ?: HashMap<String, Any?>()) as HashMap<String, Any?>
    var from: String = ""

    var logo: String
    var notificationIcon: String
    var showCallBackAction: Boolean = true
    var ringtoneFileName: String
    var accentColor: String
    var backgroundUrl: String
    var showMissedCallNotification: Boolean = true
    var incomingCallNotificationChannelName: String? = null
    var missedCallNotificationChannelName: String? = null
    var isAccepted: Boolean = false

    init {
        val android: HashMap<String, Any?>? = args["android"] as? HashMap<String, Any?>?
        if (android != null) {
            logo = (android["logo"] as? String) ?: ""
            notificationIcon = (android["notificationIcon"] as? String) ?: ""
            showCallBackAction = (android["showCallBackAction"] as? Boolean) ?: true
            ringtoneFileName = (android["ringtoneFileName"] as? String) ?: ""
            accentColor = (android["accentColor"] as? String) ?: "#0955fa"
            backgroundUrl = (android["backgroundUrl"] as? String) ?: ""
            showMissedCallNotification = (android["showMissedCallNotification"] as? Boolean) ?: true
            incomingCallNotificationChannelName = android["incomingCallNotificationChannelName"] as? String
            missedCallNotificationChannelName = android["missedCallNotificationChannelName"] as? String
        } else {
            logo = (args["logo"] as? String) ?: ""
            notificationIcon = (args["notificationIcon"] as? String) ?: ""
            showCallBackAction = (args["showCallBackAction"] as? Boolean) ?: true
            ringtoneFileName = (args["ringtoneFileName"] as? String) ?: ""
            accentColor = (args["accentColor"] as? String) ?: "#0955fa"
            backgroundUrl = (args["backgroundUrl"] as? String) ?: ""
            showMissedCallNotification = (args["showMissedCallNotification"] as? Boolean) ?: true
        }
    }

    override fun hashCode(): Int {
        return id.hashCode()
    }

    override fun equals(other: Any?): Boolean {
        if (other == null) return false
        val e: Data = other as Data
        return this.id == e.id
    }


    fun toBundle(): Bundle {
        val bundle = Bundle()
        bundle.putString(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_ID, id)
        bundle.putString(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_CALLER_NAME, callerName)
        bundle.putString(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_CONTENT_TITLE, contentTitle)
        bundle.putString(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_HANDLE, handle)
        bundle.putString(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_AVATAR, avatar)
        bundle.putBoolean(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_HAS_VIDEO, hasVideo)
        bundle.putLong(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_DURATION, duration)
        bundle.putString(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_ACCEPT_TEXT, acceptText)
        bundle.putString(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_DECLINE_TEXT, declineText)
        bundle.putString(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_TEXT_MISSED_CALL, missedCallText)
        bundle.putString(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_CALLBACK_TEXT, callBackText)
        bundle.putSerializable(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_EXTRA, extra)
        bundle.putSerializable(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_HEADERS, headers)

        bundle.putString(
                CallKeepBroadcastReceiver.EXTRA_CALLKEEP_LOGO,
                logo
        )
        bundle.putBoolean(
                CallKeepBroadcastReceiver.EXTRA_CALLKEEP_SHOW_CALLBACK,
                showCallBackAction
        )
        bundle.putString(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_RINGTONE_FILE_NAME, ringtoneFileName)
        bundle.putString(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_NOTIFICATION_ICON, notificationIcon)

        bundle.putString(
                CallKeepBroadcastReceiver.EXTRA_CALLKEEP_BACKGROUND_URL,
                backgroundUrl
        )
        bundle.putString(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_ACCENT_COLOR, accentColor)
        bundle.putString(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_ACTION_FROM, from)
        bundle.putBoolean(
                CallKeepBroadcastReceiver.EXTRA_CALLKEEP_SHOW_MISSED_CALL_NOTIFICATION,
                showMissedCallNotification
        )
        bundle.putString(
            CallKeepBroadcastReceiver.EXTRA_CALLKEEP_INCOMING_CALL_NOTIFICATION_CHANNEL_NAME,
            incomingCallNotificationChannelName
        )
        bundle.putString(
            CallKeepBroadcastReceiver.EXTRA_CALLKEEP_MISSED_CALL_NOTIFICATION_CHANNEL_NAME,
            missedCallNotificationChannelName
        )
        return bundle
    }

    companion object {

        fun fromBundle(bundle: Bundle): Data {
            val data = Data(emptyMap())
            data.id = bundle.getString(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_ID, "")
            data.callerName =
                    bundle.getString(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_CALLER_NAME, "")
            data.contentTitle =
                    bundle.getString(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_CONTENT_TITLE, "")
            data.appName =
                    bundle.getString(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_APP_NAME, "")
            data.handle =
                    bundle.getString(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_HANDLE, "")
            data.avatar =
                    bundle.getString(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_AVATAR, "")
            data.hasVideo = bundle.getBoolean(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_HAS_VIDEO, false)
            data.duration =
                    bundle.getLong(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_DURATION, 30000L)
            data.acceptText =
                    bundle.getString(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_ACCEPT_TEXT, "")
            data.declineText =
                    bundle.getString(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_DECLINE_TEXT, "")
            data.missedCallText =
                    bundle.getString(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_TEXT_MISSED_CALL, "")
            data.callBackText =
                    bundle.getString(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_CALLBACK_TEXT, "")
            data.extra =
                    bundle.getSerializable(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_EXTRA) as HashMap<String, Any?>
            data.headers =
                    bundle.getSerializable(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_HEADERS) as HashMap<String, Any?>

            data.logo = bundle.getString(
                    CallKeepBroadcastReceiver.EXTRA_CALLKEEP_LOGO,
                    ""
            )
            data.showCallBackAction = bundle.getBoolean(
                    CallKeepBroadcastReceiver.EXTRA_CALLKEEP_SHOW_CALLBACK,
                    true
            )
            data.ringtoneFileName = bundle.getString(
                    CallKeepBroadcastReceiver.EXTRA_CALLKEEP_RINGTONE_FILE_NAME,
                    ""
            )
            data.notificationIcon = bundle.getString(
                    CallKeepBroadcastReceiver.EXTRA_CALLKEEP_NOTIFICATION_ICON,
                    ""
            )
            data.accentColor = bundle.getString(
                    CallKeepBroadcastReceiver.EXTRA_CALLKEEP_ACCENT_COLOR,
                    "#0955fa"
            )
            data.backgroundUrl =
                    bundle.getString(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_BACKGROUND_URL, "")
            data.from =
                    bundle.getString(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_ACTION_FROM, "")
            data.showMissedCallNotification = bundle.getBoolean(
                    CallKeepBroadcastReceiver.EXTRA_CALLKEEP_SHOW_MISSED_CALL_NOTIFICATION,
                    true
            )
            data.incomingCallNotificationChannelName = bundle.getString(
                CallKeepBroadcastReceiver.EXTRA_CALLKEEP_INCOMING_CALL_NOTIFICATION_CHANNEL_NAME
            )
            data.missedCallNotificationChannelName = bundle.getString(
                CallKeepBroadcastReceiver.EXTRA_CALLKEEP_MISSED_CALL_NOTIFICATION_CHANNEL_NAME
            )
            return data
        }
    }

}