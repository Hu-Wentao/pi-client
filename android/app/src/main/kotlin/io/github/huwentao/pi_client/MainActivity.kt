package io.github.huwentao.pi_client

import android.app.Activity
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val exportExecutor = Executors.newSingleThreadExecutor()
    private var pendingExportResult: MethodChannel.Result? = null
    private var pendingTemporaryPath: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SESSION_EXPORT_CHANNEL,
        ).setMethodCallHandler(::handleSessionExportCall)
    }

    private fun handleSessionExportCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "saveExport") {
            result.notImplemented()
            return
        }
        if (pendingExportResult != null) {
            result.error("export_busy", "Another session export picker is active.", null)
            return
        }
        val temporaryPath = call.argument<String>("temporaryPath")
        val fileName = call.argument<String>("fileName")
        val contentType = call.argument<String>("contentType")
        if (temporaryPath.isNullOrBlank() || fileName.isNullOrBlank() || contentType.isNullOrBlank()) {
            result.error("invalid_export", "The session export request is incomplete.", null)
            return
        }
        val source = File(temporaryPath)
        if (!source.isFile) {
            result.error("missing_export", "The temporary session export is unavailable.", null)
            return
        }

        pendingExportResult = result
        pendingTemporaryPath = source.absolutePath
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = contentType
            putExtra(Intent.EXTRA_TITLE, fileName)
        }
        try {
            startActivityForResult(intent, SESSION_EXPORT_REQUEST_CODE)
        } catch (error: Exception) {
            finishPendingExportWithError("picker_failed")
        }
    }

    @Deprecated("Deprecated in Android")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != SESSION_EXPORT_REQUEST_CODE) return
        val destination = data?.data
        if (resultCode != Activity.RESULT_OK || destination == null) {
            finishPendingExport(false)
            return
        }
        copyExportToDestination(destination)
    }

    private fun copyExportToDestination(destination: Uri) {
        val temporaryPath = pendingTemporaryPath
        if (temporaryPath == null) {
            finishPendingExportWithError("missing_export")
            return
        }
        exportExecutor.execute {
            try {
                File(temporaryPath).inputStream().use { input ->
                    val output = contentResolver.openOutputStream(destination, "w")
                        ?: throw IllegalStateException("The selected destination cannot be opened.")
                    output.use { input.copyTo(it, DEFAULT_BUFFER_SIZE) }
                }
                runOnUiThread { finishPendingExport(true) }
            } catch (error: Exception) {
                runOnUiThread { finishPendingExportWithError("write_failed") }
            }
        }
    }

    private fun finishPendingExport(saved: Boolean) {
        val result = pendingExportResult
        pendingExportResult = null
        pendingTemporaryPath = null
        result?.success(saved)
    }

    private fun finishPendingExportWithError(code: String) {
        val result = pendingExportResult
        pendingExportResult = null
        pendingTemporaryPath = null
        result?.error(code, "The session export could not be saved.", null)
    }

    override fun onDestroy() {
        pendingExportResult?.error(
            "activity_destroyed",
            "The session export picker was closed.",
            null,
        )
        pendingExportResult = null
        pendingTemporaryPath = null
        exportExecutor.shutdownNow()
        super.onDestroy()
    }

    companion object {
        private const val SESSION_EXPORT_CHANNEL =
            "io.github.huwentao.pi_client/session_export"
        private const val SESSION_EXPORT_REQUEST_CODE = 43821
    }
}
