package co.doneservices.callkeep

import android.app.Service
import android.content.Intent
import android.os.IBinder

class CallKeepBackgroundMessagingService : Service() {
//    protected fun getTaskConfig(intent: Intent): HeadlessJsTaskConfig {
//        val extras = intent.extras
//        return HeadlessJsTaskConfig(
//                "RNCallKeepBackgroundMessage",
//                Arguments.fromBundle(extras),
//                60000,
//                false
//        )
//    }

    override fun onBind(intent: Intent?): IBinder? {
        TODO("not implemented")
    }
}
