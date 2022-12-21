package co.doneservices.callkeep

import android.annotation.SuppressLint
import android.app.Activity
import android.app.KeyguardManager
import android.app.KeyguardManager.KeyguardLock
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.view.Window
import android.view.WindowManager
import android.view.animation.AnimationUtils
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import co.doneservices.callkeep.CallKeepBroadcastReceiver.Companion.ACTION_CALL_INCOMING
import co.doneservices.callkeep.CallKeepBroadcastReceiver.Companion.EXTRA_CALLKEEP_AVATAR
import co.doneservices.callkeep.CallKeepBroadcastReceiver.Companion.EXTRA_CALLKEEP_BACKGROUND_URL
import co.doneservices.callkeep.CallKeepBroadcastReceiver.Companion.EXTRA_CALLKEEP_BACKGROUND_COLOR
import co.doneservices.callkeep.CallKeepBroadcastReceiver.Companion.EXTRA_CALLKEEP_DURATION
import co.doneservices.callkeep.CallKeepBroadcastReceiver.Companion.EXTRA_CALLKEEP_INCOMING_DATA
import co.doneservices.callkeep.CallKeepBroadcastReceiver.Companion.EXTRA_CALLKEEP_CALLER_NAME
import co.doneservices.callkeep.CallKeepBroadcastReceiver.Companion.EXTRA_CALLKEEP_HANDLE
import co.doneservices.callkeep.CallKeepBroadcastReceiver.Companion.EXTRA_CALLKEEP_HEADERS
import co.doneservices.callkeep.CallKeepBroadcastReceiver.Companion.EXTRA_CALLKEEP_SHOW_LOGO
import co.doneservices.callkeep.CallKeepBroadcastReceiver.Companion.EXTRA_CALLKEEP_HAS_VIDEO
import co.doneservices.callkeep.widgets.RippleRelativeLayout
import com.squareup.picasso.Picasso
import de.hdodenhof.circleimageview.CircleImageView
import kotlin.math.abs
import okhttp3.OkHttpClient
import com.squareup.picasso.OkHttp3Downloader
import android.view.ViewGroup.MarginLayoutParams
import android.os.PowerManager
import android.os.PowerManager.WakeLock
import android.text.TextUtils
import co.doneservices.callkeep.CallKeepBroadcastReceiver.Companion.EXTRA_CALLKEEP_TEXT_ACCEPT
import co.doneservices.callkeep.CallKeepBroadcastReceiver.Companion.EXTRA_CALLKEEP_TEXT_DECLINE


class IncomingCallActivity : Activity() {

    companion object {

        const val ACTION_ENDED_CALL_INCOMING =
                "co.doneservices.callkeep.ACTION_ENDED_CALL_INCOMING"

        fun getIntent(data: Bundle) = Intent(ACTION_CALL_INCOMING).apply {
            action = ACTION_CALL_INCOMING
            putExtra(EXTRA_CALLKEEP_INCOMING_DATA, data)
            flags =
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
        }

        fun getIntentEnded() =
                Intent(ACTION_ENDED_CALL_INCOMING)

    }

    inner class EndedCallKeepBroadcastReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (!isFinishing) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    finishAndRemoveTask()
                } else {
                    finish()
                }
            }
        }
    }

    private var endedCallKeepBroadcastReceiver = EndedCallKeepBroadcastReceiver()

    private lateinit var ivBackground: ImageView
    private lateinit var llBackgroundAnimation: RippleRelativeLayout

    private lateinit var tvcallerName: TextView
    private lateinit var tvNumber: TextView
    private lateinit var ivLogo: ImageView
    private lateinit var ivAvatar: CircleImageView

    private lateinit var llAction: LinearLayout
    private lateinit var ivAcceptCall: ImageView
    private lateinit var tvAccept: TextView

    private lateinit var ivDeclineCall: ImageView
    private lateinit var tvDecline: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            setTurnScreenOn(true)
            setShowWhenLocked(true)
        } else {
            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            window.addFlags(WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON)
            window.addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED)
            window.addFlags(WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD)
        }
        transparentStatusAndNavigation()
        setContentView(R.layout.activity_callkit_incoming)
        initView()
        incomingData(intent)
        registerReceiver(
                endedCallKeepBroadcastReceiver,
                IntentFilter(ACTION_ENDED_CALL_INCOMING)
        )
    }

    private fun wakeLockRequest(duration: Long) {

        val pm = applicationContext.getSystemService(POWER_SERVICE) as PowerManager
        val wakeLock = pm.newWakeLock(
                PowerManager.SCREEN_BRIGHT_WAKE_LOCK or PowerManager.FULL_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP,
                "CallKeep:PowerManager"
        )
        wakeLock.acquire(duration)
    }

    private fun transparentStatusAndNavigation() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT && Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            setWindowFlag(
                    WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS
                            or WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION, true
            )
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            window.decorView.systemUiVisibility = (View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                    or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            setWindowFlag(
                    (WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS
                            or WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION), false
            )
            window.statusBarColor = Color.TRANSPARENT
            window.navigationBarColor = Color.TRANSPARENT
        }
    }

    private fun setWindowFlag(bits: Int, on: Boolean) {
        val win: Window = window
        val winParams: WindowManager.LayoutParams = win.attributes
        if (on) {
            winParams.flags = winParams.flags or bits
        } else {
            winParams.flags = winParams.flags and bits.inv()
        }
        win.attributes = winParams
    }


    private fun incomingData(intent: Intent) {
        val data = intent.extras?.getBundle(EXTRA_CALLKEEP_INCOMING_DATA)
        if (data == null) finish()

        tvcallerName.text = data?.getString(EXTRA_CALLKEEP_CALLER_NAME, "")
        tvNumber.text = data?.getString(EXTRA_CALLKEEP_HANDLE, "")

        val showLogo = data?.getBoolean(EXTRA_CALLKEEP_SHOW_LOGO, false)
        ivLogo.visibility = if (showLogo == true) View.VISIBLE else View.INVISIBLE

        val avatarUrl = data?.getString(EXTRA_CALLKEEP_AVATAR, "")
        if (avatarUrl != null && avatarUrl.isNotEmpty()) {
            ivAvatar.visibility = View.VISIBLE
            val headers = data.getSerializable(EXTRA_CALLKEEP_HEADERS) as HashMap<String, Any?>
            getPicassoInstance(this@IncomingCallActivity, headers)
                    .load(avatarUrl)
                    .placeholder(R.drawable.ic_default_avatar)
                    .error(R.drawable.ic_default_avatar)
                    .into(ivAvatar)
        }

        val hasVideo = data?.getInt(EXTRA_CALLKEEP_HAS_VIDEO, false) ?: false
        if (hasVideo) {
            ivAcceptCall.setImageResource(R.drawable.ic_video)
        }
        val duration = data?.getLong(EXTRA_CALLKEEP_DURATION, 0L) ?: 0L
        wakeLockRequest(duration)

        finishTimeout(data, duration)

        val acceptText = data?.getString(EXTRA_CALLKEEP_TEXT_ACCEPT, "")
        tvAccept.text = if (TextUtils.isEmpty(acceptText)) getString(R.string.text_accept) else acceptText
        val declineText = data?.getString(EXTRA_CALLKEEP_TEXT_DECLINE, "")
        tvDecline.text = if (TextUtils.isEmpty(declineText)) getString(R.string.text_decline) else declineText

        val backgroundColor = data?.getString(EXTRA_CALLKEEP_BACKGROUND_COLOR, "#0955fa")
        try {
            ivBackground.setBackgroundColor(Color.parseColor(backgroundColor))
        } catch (error: Exception) {
        }
        var backgroundUrl = data?.getString(EXTRA_CALLKEEP_BACKGROUND_URL, "")
        if (backgroundUrl != null && backgroundUrl.isNotEmpty()) {
            if (!backgroundUrl.startsWith("http://", true) && !backgroundUrl.startsWith("https://", true)){
                backgroundUrl = String.format("file:///android_asset/flutter_assets/%s", backgroundUrl)
            }
            val headers = data?.getSerializable(EXTRA_CALLKEEP_HEADERS) as HashMap<String, Any?>
            getPicassoInstance(this@IncomingCallActivity, headers)
                    .load(backgroundUrl)
                    .placeholder(R.drawable.transparent)
                    .error(R.drawable.transparent)
                    .into(ivBackground)
        }
    }

    private fun finishTimeout(data: Bundle?, duration: Long) {
        val currentSystemTime = System.currentTimeMillis()
        val timeStartCall =
                data?.getLong(CallKeepNotificationManager.EXTRA_TIME_START_CALL, currentSystemTime)
                        ?: currentSystemTime

        val timeOut = duration - abs(currentSystemTime - timeStartCall)
        Handler(Looper.getMainLooper()).postDelayed({
            if (!isFinishing) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    finishAndRemoveTask()
                } else {
                    finish()
                }
            }
        }, timeOut)
    }

    private fun initView() {
        ivBackground = findViewById(R.id.ivBackground)
        llBackgroundAnimation = findViewById(R.id.llBackgroundAnimation)
        llBackgroundAnimation.layoutParams.height =
                Utils.getScreenWidth() + Utils.getStatusBarHeight(this@IncomingCallActivity)
        llBackgroundAnimation.startRippleAnimation()

        tvcallerName = findViewById(R.id.tvcallerName)
        tvNumber = findViewById(R.id.tvNumber)
        ivLogo = findViewById(R.id.ivLogo)
        ivAvatar = findViewById(R.id.ivAvatar)

        llAction = findViewById(R.id.llAction)

        val params = llAction.layoutParams as MarginLayoutParams
        params.setMargins(0, 0, 0, Utils.getNavigationBarHeight(this@IncomingCallActivity))
        llAction.layoutParams = params

        ivAcceptCall = findViewById(R.id.ivAcceptCall)
        tvAccept = findViewById(R.id.tvAccept)
        ivDeclineCall = findViewById(R.id.ivDeclineCall)
        tvDecline = findViewById(R.id.tvDecline)
        animateAcceptCall()

        ivAcceptCall.setOnClickListener {
            onAcceptClick()
        }
        ivDeclineCall.setOnClickListener {
            onDeclineClick()
        }
    }

    private fun animateAcceptCall() {
        val shakeAnimation =
                AnimationUtils.loadAnimation(this@IncomingCallActivity, R.anim.shake_anim)
        ivAcceptCall.animation = shakeAnimation
    }


    private fun onAcceptClick() {
        val data = intent.extras?.getBundle(EXTRA_CALLKEEP_INCOMING_DATA)
        val intent = packageManager.getLaunchIntentForPackage(packageName)?.cloneFilter()
        if (isTaskRoot) {
            intent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
        } else {
            intent?.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        if (intent != null) {
            val intentTransparent = TransparentActivity.getIntentAccept(this@IncomingCallActivity, data)
            startActivities(arrayOf(intent, intentTransparent))
        } else {
            val acceptIntent = CallKeepBroadcastReceiver.getIntentAccept(this@IncomingCallActivity, data)
            sendBroadcast(acceptIntent)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
            keyguardManager.requestDismissKeyguard(this, null)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            finishAndRemoveTask()
        } else {
            finish()
        }
    }

    private fun onDeclineClick() {
        val data = intent.extras?.getBundle(EXTRA_CALLKEEP_INCOMING_DATA)
        val intent =
                CallKeepBroadcastReceiver.getIntentDecline(this@IncomingCallActivity, data)
        sendBroadcast(intent)
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

    override fun onDestroy() {
        unregisterReceiver(endedCallKeepBroadcastReceiver)
        super.onDestroy()
    }

    override fun onBackPressed() {}


}