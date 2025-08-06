package es.victorcarreras.quiz_app

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val channel = "quiz.file"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Handle intent when app is launched
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // Handle intent when app is already running
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        intent?.let {
            when (it.action) {
                Intent.ACTION_VIEW -> {
                    // File opened from file manager or browser
                    handleFileOpen(it.data)
                }
                Intent.ACTION_SEND -> {
                    // File shared from another app
                    if (it.type?.startsWith("application/") == true || 
                        it.type?.startsWith("text/") == true) {
                        val uri = it.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
                        handleFileOpen(uri)
                    }
                }
            }
        }
    }

    private fun handleFileOpen(fileUri: Uri?) {
        fileUri?.let { uri ->
            try {
                // Check if the file is a .quiz file by name or content
                val fileName = getFileName(uri)
                if (fileName?.endsWith(".quiz") == true || isQuizFileContent(uri)) {
                    val inputStream = contentResolver.openInputStream(uri)
                    val tempFile = File(cacheDir, "temp_${System.currentTimeMillis()}.quiz")
                    tempFile.outputStream().use { output -> 
                        inputStream?.copyTo(output) 
                    }

                    // Send temporary file path to Flutter
                    flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                        MethodChannel(messenger, channel)
                            .invokeMethod("openFile", tempFile.absolutePath)
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private fun getFileName(uri: Uri): String? {
        return when (uri.scheme) {
            "content" -> {
                val cursor = contentResolver.query(uri, null, null, null, null)
                cursor?.use {
                    if (it.moveToFirst()) {
                        val nameIndex = it.getColumnIndex(android.provider.OpenableColumns.DISPLAY_NAME)
                        if (nameIndex >= 0) it.getString(nameIndex) else null
                    } else null
                }
            }
            "file" -> File(uri.path ?: "").name
            else -> null
        }
    }

    private fun isQuizFileContent(uri: Uri): Boolean {
        return try {
            contentResolver.openInputStream(uri)?.use { inputStream ->
                val bytes = ByteArray(1024)
                val bytesRead = inputStream.read(bytes)
                val content = String(bytes, 0, bytesRead)
                // Check if content looks like a quiz JSON structure
                content.contains("\"questions\"") && content.contains("\"metadata\"")
            } ?: false
        } catch (e: Exception) {
            false
        }
    }
}
