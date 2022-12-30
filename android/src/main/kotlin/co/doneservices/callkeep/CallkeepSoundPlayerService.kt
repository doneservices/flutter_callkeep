package co.doneservices.callkeep

import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.*
import android.text.TextUtils

class CallKeepSoundPlayerService : Service() {

    private var vibrator: Vibrator? = null
    private var audioManager: AudioManager? = null

    private var mediaPlayer: MediaPlayer? = null
    private var data: Bundle? = null

    override fun onBind(p0: Intent?): IBinder? {
        return null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        this.prepare()
        this.playSound(intent)
        this.playVibrator()
        return START_STICKY;
    }

    override fun onDestroy() {
        super.onDestroy()
        mediaPlayer?.stop()
        mediaPlayer?.release()
        vibrator?.cancel()
    }

    private fun prepare() {
        mediaPlayer?.stop()
        mediaPlayer?.release()
        vibrator?.cancel()
    }

    private fun playVibrator() {
        vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager = this.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            vibratorManager.defaultVibrator
        } else {
            getSystemService(VIBRATOR_SERVICE) as Vibrator
        }
        audioManager = this.getSystemService(AUDIO_SERVICE) as AudioManager
        when (audioManager?.ringerMode) {
            AudioManager.RINGER_MODE_SILENT -> {
            }
            else -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    vibrator?.vibrate(VibrationEffect.createWaveform(longArrayOf(0L, 1000L, 1000L), 0))
                } else {
                    vibrator?.vibrate(longArrayOf(0L, 1000L, 1000L), 0)
                }
            }
        }
    }

    private fun playSound(intent: Intent?) {
        this.data = intent?.extras
        val sound = this.data?.getString(
                CallKeepBroadcastReceiver.EXTRA_CALLKEEP_RINGTONE_FILE_NAME,
                ""
        )
        var uri = sound?.let { getRingtoneUri(it) }
        if (uri == null) {
            uri = RingtoneManager.getActualDefaultRingtoneUri(
                    this@CallKeepSoundPlayerService,
                    RingtoneManager.TYPE_RINGTONE
            )
        }
        try {
            startLoopingSound(uri!!)
        } catch (e: Exception) {
            try {
                uri = getRingtoneUri("ringtone_default")
                startLoopingSound(uri!!)
            } catch (e2: Exception) {
                e2.printStackTrace()
            }
        }
    }

    private fun startLoopingSound(uri: Uri) {
        mediaPlayer = MediaPlayer()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val attribution = AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                    .setLegacyStreamType(AudioManager.STREAM_RING)
                    .build()
            mediaPlayer?.setAudioAttributes(attribution)
        } else {
            mediaPlayer?.setAudioStreamType(AudioManager.STREAM_RING)
        }
        val assetFileDescriptor = applicationContext.getContentResolver().openAssetFileDescriptor(uri, "r")
        if (assetFileDescriptor != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            mediaPlayer?.setDataSource(assetFileDescriptor)
        } else {
            mediaPlayer?.setDataSource(applicationContext, uri)
        }
        mediaPlayer?.prepare()
        mediaPlayer?.isLooping = true
        mediaPlayer?.start()
    }

    private fun getRingtoneUri(fileName: String): Uri {
        val defaultRingtoneUri = RingtoneManager.getActualDefaultRingtoneUri(this@CallKeepSoundPlayerService, RingtoneManager.TYPE_RINGTONE)
        try {
            if (TextUtils.isEmpty(fileName)) {
                return defaultRingtoneUri
            }
            val resId = resources.getIdentifier(fileName, "raw", packageName)
            if (resId != 0) {
                return Uri.parse("android.resource://${packageName}/$resId")
            } else {
                return defaultRingtoneUri

            }
        } catch (e: Exception) {
            return defaultRingtoneUri
        }
    }
}