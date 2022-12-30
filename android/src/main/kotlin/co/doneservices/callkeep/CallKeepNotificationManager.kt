package co.doneservices.callkeep

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.drawable.Drawable
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import android.view.View
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.graphics.drawable.IconCompat
import co.doneservices.callkeep.CallKeepBroadcastReceiver.Companion.EXTRA_CALLKEEP_ACCENT_COLOR
import co.doneservices.callkeep.CallKeepBroadcastReceiver.Companion.EXTRA_CALLKEEP_AVATAR
import co.doneservices.callkeep.CallKeepBroadcastReceiver.Companion.EXTRA_CALLKEEP_DURATION
import co.doneservices.callkeep.CallKeepBroadcastReceiver.Companion.EXTRA_CALLKEEP_HANDLE
import co.doneservices.callkeep.CallKeepBroadcastReceiver.Companion.EXTRA_CALLKEEP_ID
import co.doneservices.callkeep.CallKeepBroadcastReceiver.Companion.EXTRA_CALLKEEP_INCOMING_CALL_NOTIFICATION_CHANNEL_NAME
import co.doneservices.callkeep.CallKeepBroadcastReceiver.Companion.EXTRA_CALLKEEP_NOTIFICATION_ICON
import co.doneservices.callkeep.CallKeepBroadcastReceiver.Companion.EXTRA_CALLKEEP_MISSED_CALL_NOTIFICATION_CHANNEL_NAME
import co.doneservices.callkeep.CallKeepBroadcastReceiver.Companion.EXTRA_CALLKEEP_CALLER_NAME
import co.doneservices.callkeep.CallKeepBroadcastReceiver.Companion.EXTRA_CALLKEEP_CONTENT_TITLE
import co.doneservices.callkeep.CallKeepBroadcastReceiver.Companion.EXTRA_CALLKEEP_ACCEPT_TEXT
import co.doneservices.callkeep.CallKeepBroadcastReceiver.Companion.EXTRA_CALLKEEP_CALLBACK_TEXT
import co.doneservices.callkeep.CallKeepBroadcastReceiver.Companion.EXTRA_CALLKEEP_DECLINE_TEXT
import co.doneservices.callkeep.CallKeepBroadcastReceiver.Companion.EXTRA_CALLKEEP_TEXT_MISSED_CALL
import co.doneservices.callkeep.CallKeepBroadcastReceiver.Companion.EXTRA_CALLKEEP_HAS_VIDEO
import com.squareup.picasso.OkHttp3Downloader
import com.squareup.picasso.Picasso
import com.squareup.picasso.Target
import okhttp3.OkHttpClient


class CallKeepNotificationManager(private val context: Context) {

    companion object {

        const val EXTRA_TIME_START_CALL = "EXTRA_TIME_START_CALL"

        private const val NOTIFICATION_CHANNEL_ID_INCOMING = "callkeep_channel_id"
        private const val NOTIFICATION_CHANNEL_ID_MISSED = "callkeep_missed_channel_id"
    }

    private lateinit var notificationBuilder: NotificationCompat.Builder
    private var notificationViews: RemoteViews? = null
    private var notificationSmallViews: RemoteViews? = null
    private var notificationId: Int = 9696

    private var targetLoadAvatarDefault = object : Target {
        override fun onBitmapLoaded(bitmap: Bitmap?, from: Picasso.LoadedFrom?) {
            notificationBuilder.setLargeIcon(bitmap)
            getNotificationManager().notify(notificationId, notificationBuilder.build())
        }

        override fun onBitmapFailed(e: Exception?, errorDrawable: Drawable?) {
        }

        override fun onPrepareLoad(placeHolderDrawable: Drawable?) {
        }
    }

    private var targetLoadAvatarCustomize = object : Target {
        override fun onBitmapLoaded(bitmap: Bitmap?, from: Picasso.LoadedFrom?) {
            notificationViews?.setImageViewBitmap(R.id.ivAvatar, bitmap)
            notificationViews?.setViewVisibility(R.id.ivAvatar, View.VISIBLE)
            notificationSmallViews?.setImageViewBitmap(R.id.ivAvatar, bitmap)
            notificationSmallViews?.setViewVisibility(R.id.ivAvatar, View.VISIBLE)
            getNotificationManager().notify(notificationId, notificationBuilder.build())
        }

        override fun onBitmapFailed(e: Exception?, errorDrawable: Drawable?) {
        }

        override fun onPrepareLoad(placeHolderDrawable: Drawable?) {
        }
    }


    fun showIncomingNotification(data: Bundle) {
        data.putLong(EXTRA_TIME_START_CALL, System.currentTimeMillis())

        notificationId = data.getString(EXTRA_CALLKEEP_ID, "callkeep").hashCode()
        createNotificationChanel(
                data.getString(EXTRA_CALLKEEP_INCOMING_CALL_NOTIFICATION_CHANNEL_NAME, "Incoming Calls"),
                data.getString(EXTRA_CALLKEEP_MISSED_CALL_NOTIFICATION_CHANNEL_NAME, "Missed Calls"),
        )

        notificationBuilder = NotificationCompat.Builder(context, NOTIFICATION_CHANNEL_ID_INCOMING)
        notificationBuilder.setAutoCancel(false)
        notificationBuilder.setChannelId(NOTIFICATION_CHANNEL_ID_INCOMING)
        notificationBuilder.setDefaults(NotificationCompat.DEFAULT_VIBRATE)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            notificationBuilder.setCategory(NotificationCompat.CATEGORY_CALL)
            notificationBuilder.priority = NotificationCompat.PRIORITY_MAX
        }
        notificationBuilder.setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
        notificationBuilder.setOngoing(true)
        notificationBuilder.setWhen(0)
        notificationBuilder.setTimeoutAfter(data.getLong(EXTRA_CALLKEEP_DURATION, 0L))
        notificationBuilder.setOnlyAlertOnce(true)
        notificationBuilder.setSound(null)
        notificationBuilder.setFullScreenIntent(
                getActivityPendingIntent(notificationId, data), true
        )
        notificationBuilder.setContentIntent(getActivityPendingIntent(notificationId, data))
        notificationBuilder.setDeleteIntent(getTimeOutPendingIntent(notificationId, data))
        val hasVideo = data.getBoolean(EXTRA_CALLKEEP_HAS_VIDEO, false)
        val notificationIcon = data.getString(EXTRA_CALLKEEP_NOTIFICATION_ICON, "")
        if (notificationIcon.isEmpty() || Build.VERSION.SDK_INT < Build.VERSION_CODES.M ) {
            var smallIcon = context.applicationInfo.icon
            if (hasVideo) {
                smallIcon = R.drawable.ic_video
            } else {
                if (smallIcon >= 0) {
                    smallIcon = R.drawable.ic_accept
                }
            }
            notificationBuilder.setSmallIcon(smallIcon)
        } else {
            val identifier = context.resources.getIdentifier(notificationIcon, "drawable", context.packageName)
            val icon = IconCompat.createWithResource(context, identifier)
            notificationBuilder.setSmallIcon(icon)
        }

        val accentColor = data.getString(EXTRA_CALLKEEP_ACCENT_COLOR, "#4CAF50")
        try {
            notificationBuilder.color = Color.parseColor(accentColor)
        } catch (error: Exception) {
        }

        val avatarUrl = data.getString(EXTRA_CALLKEEP_AVATAR, "")
        if (avatarUrl != null && avatarUrl.isNotEmpty()) {
            val headers =
                    data.getSerializable(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_HEADERS) as HashMap<String, Any?>
            getPicassoInstance(context, headers).load(avatarUrl)
                    .into(targetLoadAvatarDefault)
        }
        val contentTitle = data.getString(EXTRA_CALLKEEP_CONTENT_TITLE, "")
        if (contentTitle?.isNotEmpty() == true) {
            notificationBuilder.setContentTitle(contentTitle)
        } else {
            notificationBuilder.setContentTitle(data.getString(EXTRA_CALLKEEP_CALLER_NAME, ""))
        }
        notificationBuilder.setContentText(data.getString(EXTRA_CALLKEEP_HANDLE, ""))
        val declineText = data.getString(EXTRA_CALLKEEP_DECLINE_TEXT, "")
        val declineAction: NotificationCompat.Action = NotificationCompat.Action.Builder(
                R.drawable.ic_decline,
                if (TextUtils.isEmpty(declineText)) context.getString(R.string.decline_text) else declineText,
                getDeclinePendingIntent(notificationId, data)
        ).build()
        notificationBuilder.addAction(declineAction)
        val acceptText = data.getString(EXTRA_CALLKEEP_ACCEPT_TEXT, "")
        val acceptAction: NotificationCompat.Action = NotificationCompat.Action.Builder(
                R.drawable.ic_accept,
                if (TextUtils.isEmpty(declineText)) context.getString(R.string.accept_text) else acceptText,
                getAcceptPendingIntent(notificationId, data)
        ).build()
        notificationBuilder.addAction(acceptAction)

        val notification = notificationBuilder.build()
        notification.flags = Notification.FLAG_INSISTENT
        getNotificationManager().notify(notificationId, notification)
    }

    fun showMissCallNotification(data: Bundle) {
        notificationId = data.getString(EXTRA_CALLKEEP_ID, "callkeep").hashCode() + 1
        createNotificationChanel(
                data.getString(EXTRA_CALLKEEP_INCOMING_CALL_NOTIFICATION_CHANNEL_NAME, "Incoming Calls"),
                data.getString(EXTRA_CALLKEEP_MISSED_CALL_NOTIFICATION_CHANNEL_NAME, "Missed Calls"),
        )
        val missedCallSound: Uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        val hasVideo = data.getBoolean(EXTRA_CALLKEEP_HAS_VIDEO, false)
        val notificationIcon = data.getString(EXTRA_CALLKEEP_NOTIFICATION_ICON, "")
        notificationBuilder = NotificationCompat.Builder(context, NOTIFICATION_CHANNEL_ID_MISSED)
        notificationBuilder.setChannelId(NOTIFICATION_CHANNEL_ID_MISSED)
        if (notificationIcon.isEmpty() || Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            var smallIcon = context.applicationInfo.icon
            if (hasVideo) {
                smallIcon = R.drawable.ic_video
            } else {
                if (smallIcon >= 0) {
                    smallIcon = R.drawable.ic_accept
                }
            }
            notificationBuilder.setSmallIcon(smallIcon)
        } else {
            val identifier = context.resources.getIdentifier(notificationIcon, "drawable", context.packageName)
            val icon = IconCompat.createWithResource(context, identifier)
            notificationBuilder.setSmallIcon(icon)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                notificationBuilder.setCategory(Notification.CATEGORY_MISSED_CALL)
            }
        }
        val missedCallText = data.getString(EXTRA_CALLKEEP_TEXT_MISSED_CALL, "")
        notificationBuilder.setSubText(if (TextUtils.isEmpty(missedCallText)) context.getString(R.string.text_missed_call) else missedCallText)

        val contentTitle = data.getString(EXTRA_CALLKEEP_CONTENT_TITLE, "")
        if (contentTitle?.isNotEmpty() == true) {
            notificationBuilder.setContentTitle(contentTitle)
        } else {
            notificationBuilder.setContentTitle(data.getString(EXTRA_CALLKEEP_CALLER_NAME, ""))
        }
        notificationBuilder.setContentText(data.getString(EXTRA_CALLKEEP_HANDLE, ""))
        val avatarUrl = data.getString(EXTRA_CALLKEEP_AVATAR, "")
        if (avatarUrl != null && avatarUrl.isNotEmpty()) {
            val headers =
                    data.getSerializable(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_HEADERS) as HashMap<String, Any?>

            getPicassoInstance(context, headers).load(avatarUrl)
                    .into(targetLoadAvatarDefault)
        }
        val showCallBackAction = data.getBoolean(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_SHOW_CALLBACK, true)
        if (showCallBackAction) {
            val callBackText = data.getString(EXTRA_CALLKEEP_CALLBACK_TEXT, "")
            val callbackAction: NotificationCompat.Action = NotificationCompat.Action.Builder(
                    R.drawable.ic_accept,
                    if (TextUtils.isEmpty(callBackText)) context.getString(R.string.text_call_back) else callBackText,
                    getCallbackPendingIntent(notificationId, data)
            ).build()
            notificationBuilder.addAction(callbackAction)
        }

        notificationBuilder.priority = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            NotificationManager.IMPORTANCE_HIGH
        } else {
            Notification.PRIORITY_HIGH
        }
        notificationBuilder.setSound(missedCallSound)
        notificationBuilder.setContentIntent(getAppPendingIntent(notificationId, data))
        val accentColor = data.getString(EXTRA_CALLKEEP_ACCENT_COLOR, "#4CAF50")
        try {
            notificationBuilder.color = Color.parseColor(accentColor)
        } catch (error: Exception) {
        }

        val notification = notificationBuilder.build()
        getNotificationManager().notify(notificationId, notification)
        Handler(Looper.getMainLooper()).postDelayed({
            try {
                getNotificationManager().notify(notificationId, notification)
            } catch (error: Exception) {
            }
        }, 1000)
    }


    fun clearIncomingNotification(data: Bundle) {
        context.sendBroadcast(IncomingCallActivity.getIntentEnded(context))
        notificationId = data.getString(EXTRA_CALLKEEP_ID, "callkeep").hashCode()
        getNotificationManager().cancel(notificationId)
    }

    fun clearMissCallNotification(data: Bundle) {
        notificationId = data.getString(EXTRA_CALLKEEP_ID, "callkeep").hashCode()
        getNotificationManager().cancel(notificationId)
        Handler(Looper.getMainLooper()).postDelayed({
            try {
                getNotificationManager().cancel(notificationId)
            } catch (error: Exception) {
            }
        }, 1000)
    }

    fun incomingChannelEnabled(): Boolean {
        val notificationManager = getNotificationManager()
        val channel = notificationManager.getNotificationChannel(NOTIFICATION_CHANNEL_ID_INCOMING)

        return notificationManager.areNotificationsEnabled() &&
                (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                        channel != null &&
                        channel.importance > NotificationManagerCompat.IMPORTANCE_NONE) ||
                Build.VERSION.SDK_INT < Build.VERSION_CODES.O
    }

    private fun createNotificationChanel(
            incomingCallChannelName: String,
            missedCallChannelName: String,
    ) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            var channelCall = getNotificationManager().getNotificationChannel(NOTIFICATION_CHANNEL_ID_INCOMING)
            if (channelCall != null) {
                channelCall.setSound(null, null)
            } else {
                channelCall = NotificationChannel(
                        NOTIFICATION_CHANNEL_ID_INCOMING,
                        incomingCallChannelName,
                        NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = ""
                    vibrationPattern =
                            longArrayOf(0, 1000, 500, 1000, 500)
                    lightColor = Color.RED
                    enableLights(true)
                    enableVibration(true)
                    setSound(null, null)
                }
            }
            channelCall.lockscreenVisibility = Notification.VISIBILITY_PUBLIC

            channelCall.importance = NotificationManager.IMPORTANCE_HIGH

            getNotificationManager().createNotificationChannel(channelCall)

            val channelMissedCall = NotificationChannel(
                    NOTIFICATION_CHANNEL_ID_MISSED,
                    missedCallChannelName,
                    NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = ""
                vibrationPattern = longArrayOf(0, 1000)
                lightColor = Color.RED
                enableLights(true)
                enableVibration(true)
            }
            channelMissedCall.importance = NotificationManager.IMPORTANCE_DEFAULT
            getNotificationManager().createNotificationChannel(channelMissedCall)
        }
    }

    private fun getAcceptPendingIntent(id: Int, data: Bundle): PendingIntent {
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)?.cloneFilter()
        intent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (intent != null) {
            val intentTransparent = TransparentActivity.getIntentAccept(context, data)
            return PendingIntent.getActivities(
                    context,
                    id,
                    arrayOf(intent, intentTransparent),
                    getFlagPendingIntent()
            )
        } else {
            val acceptIntent = CallKeepBroadcastReceiver.getIntentAccept(context, data)
            return PendingIntent.getBroadcast(
                    context,
                    id,
                    acceptIntent,
                    getFlagPendingIntent()
            )
        }
    }

    private fun getDeclinePendingIntent(id: Int, data: Bundle): PendingIntent {
        val declineIntent = CallKeepBroadcastReceiver.getIntentDecline(context, data)
        return PendingIntent.getBroadcast(
                context,
                id,
                declineIntent,
                getFlagPendingIntent()
        )
    }

    private fun getTimeOutPendingIntent(id: Int, data: Bundle): PendingIntent {
        val timeOutIntent = CallKeepBroadcastReceiver.getIntentTimeout(context, data)
        return PendingIntent.getBroadcast(
                context,
                id,
                timeOutIntent,
                getFlagPendingIntent()
        )
    }

    private fun getCallbackPendingIntent(id: Int, data: Bundle): PendingIntent {
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)?.cloneFilter()
        intent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (intent != null) {
            val intentTransparent = TransparentActivity.getIntentCallback(context, data)
            return PendingIntent.getActivities(
                    context,
                    id,
                    arrayOf(intent, intentTransparent),
                    getFlagPendingIntent()
            )
        } else {
            val acceptIntent = CallKeepBroadcastReceiver.getIntentCallback(context, data)
            return PendingIntent.getBroadcast(
                    context,
                    id,
                    acceptIntent,
                    getFlagPendingIntent()
            )
        }
    }

    private fun getActivityPendingIntent(id: Int, data: Bundle): PendingIntent {
        val intent = IncomingCallActivity.getIntent(context, data)
        return PendingIntent.getActivity(context, id, intent, getFlagPendingIntent())
    }

    private fun getAppPendingIntent(id: Int, data: Bundle): PendingIntent {
        val intent: Intent? = context.packageManager.getLaunchIntentForPackage(context.packageName)
        intent?.putExtra(CallKeepBroadcastReceiver.EXTRA_CALLKEEP_INCOMING_DATA, data)
        return PendingIntent.getActivity(context, id, intent, getFlagPendingIntent())
    }

    private fun getFlagPendingIntent(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
    }

    private fun getNotificationManager(): NotificationManagerCompat {
        return NotificationManagerCompat.from(context)
    }


    private fun getPicassoInstance(context: Context, headers: HashMap<String, Any?>): Picasso {
        val client = OkHttpClient.Builder()
                .addNetworkInterceptor { chain ->
                    val newRequestBuilder: okhttp3.Request.Builder = chain.request().newBuilder()
                    for ((key, value) in headers) {
                        newRequestBuilder.addHeader(key, value.toString())
                    }
                    chain.proceed(newRequestBuilder.build())
                }
                .build()
        return Picasso.Builder(context)
                .downloader(OkHttp3Downloader(client))
                .build()
    }


}