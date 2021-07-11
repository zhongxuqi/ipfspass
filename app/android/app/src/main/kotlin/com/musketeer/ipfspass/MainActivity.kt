package com.musketeer.ipfspass

import androidx.annotation.NonNull
import com.musketeer.ipfspass.encrypt.Aes
import com.musketeer.ipfspass.encrypt.toHex
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "ipfspass.tech"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "encryptData") {
                val req = call.arguments as HashMap<String, String>
                result.success(Aes.encryptData(req["masterPassword"]!!, req["rawData"]!!))
            } else if (call.method == "decryptData") {
                val req = call.arguments as HashMap<String, String>
                result.success(Aes.decryptData(req["masterPassword"]!!, req["encryptedData"]!!))
            } else if (call.method == "sha256") {
                val req = call.arguments as HashMap<String, String>
                result.success(Aes.sha256(req["data"]!!).toByteArray().toHex())
            }
        }
    }
}
