package com.example.tagflo_flutter

import android.content.Context
import com.seuic.scanner.DecodeInfo
import com.seuic.scanner.DecodeInfoCallBack
import com.seuic.scanner.Scanner
import com.seuic.scanner.ScannerFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity(), DecodeInfoCallBack {
    private val CHANNEL = "com.example.tagflo_flutter/scanner"
    private lateinit var channel: MethodChannel
    private var scanner: Scanner? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "initializeScanner" -> {
                    initializeScanner()
                    result.success(null)
                }
                "disposeScanner" -> {
                    disposeScanner()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun initializeScanner() {
        scanner = ScannerFactory.getScanner(context)
        scanner?.apply {
            open()
            enable()
            setDecodeInfoCallBack(this@MainActivity)
        }
    }

    private fun disposeScanner() {
        scanner?.apply {
            disable()
            close()
        }
        scanner = null
    }

    override fun onDecodeComplete(info: DecodeInfo?) {
        info?.let {
            runOnUiThread {
                channel.invokeMethod("onScanComplete", mapOf(
                    "barcode" to it.barcode,
                    "codetype" to it.codetype,
                    "length" to it.length
                ))
            }
        }
    }
}
