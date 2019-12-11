package co.doneservices.callkeep

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class CallKeepPlugin : FlutterPlugin, ActivityAware {
    companion object {
        @JvmStatic
        fun registerWith(registrar: PluginRegistry.Registrar) {
            val channel = MethodChannel(registrar.messenger(), "co.doneservices/callkeep")
            val plugin = CallKeep(channel, registrar.context().applicationContext)

            plugin.currentActivity = registrar.activity()

            registrar.addRequestPermissionsResultListener(plugin)
        }
    }

    private var methodCallHandler: CallKeep? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val channel = MethodChannel(binding.flutterEngine.dartExecutor, "co.doneservices/callkeep")
        val plugin = CallKeep(channel, binding.applicationContext)

        methodCallHandler = plugin
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodCallHandler?.stopListening()
        methodCallHandler = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        val plugin = methodCallHandler ?: return

        plugin.currentActivity = binding.activity
        binding.addRequestPermissionsResultListener(plugin)
    }

    override fun onDetachedFromActivity() {
        methodCallHandler?.currentActivity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }
}
