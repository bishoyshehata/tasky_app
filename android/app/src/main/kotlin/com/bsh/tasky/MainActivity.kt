package com.bsh.tasky

import android.content.ContentValues
import android.provider.MediaStore
import java.io.File
import java.io.FileInputStream
import android.app.Activity
import android.content.Intent
import android.media.MediaPlayer
import android.media.Ringtone
import android.media.RingtoneManager
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.bsh.tasky/ringtone_picker"
    private var pendingResult: MethodChannel.Result? = null
    private val RINGTONE_PICKER_REQUEST_CODE = 999
    private var ringtonePlayer: Ringtone? = null
    private var mediaPlayer: MediaPlayer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickRingtone" -> {
                    pendingResult = result
                    val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
                        putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
                        putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, false)
                        putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, RingtoneManager.TYPE_ALL)
                        putExtra(RingtoneManager.EXTRA_RINGTONE_TITLE, "Select Alarm Sound")
                    }
                    startActivityForResult(intent, RINGTONE_PICKER_REQUEST_CODE)
                }
                "playRingtone" -> {
                    val uriStr = call.argument<String>("uri")
                    if (uriStr != null) {
                        try {
                            mediaPlayer?.stop()
                            mediaPlayer?.release()
                            mediaPlayer = null
                            
                            ringtonePlayer?.stop()
                            
                            mediaPlayer = MediaPlayer().apply {
                                if (uriStr.startsWith("content://")) {
                                    val uri = Uri.parse(uriStr)
                                    setDataSource(applicationContext, uri)
                                } else {
                                    setDataSource(uriStr)
                                }
                                isLooping = true
                                prepare()
                                start()
                            }
                            result.success(true)
                        } catch (e: Exception) {
                            // Fallback to RingtoneManager
                            try {
                                val uri = Uri.parse(uriStr)
                                ringtonePlayer = RingtoneManager.getRingtone(applicationContext, uri)
                                ringtonePlayer?.play()
                                result.success(true)
                            } catch (ex: Exception) {
                                result.error("PLAY_ERROR", ex.message, null)
                            }
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "URI is null", null)
                    }
                }
                "stopRingtone" -> {
                    mediaPlayer?.stop()
                    mediaPlayer?.release()
                    mediaPlayer = null
                    
                    ringtonePlayer?.stop()
                    result.success(true)
                }
                "saveAudioToSystem" -> {
                    val path = call.argument<String>("path")
                    val title = call.argument<String>("title")
                    if (path != null && title != null) {
                        val systemUri = saveAudioToSystemAlarms(path, title)
                        result.success(systemUri)
                    } else {
                        result.error("INVALID_ARGUMENT", "Path or title is null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun saveAudioToSystemAlarms(filePath: String, title: String): String? {
        val file = File(filePath)
        if (!file.exists()) return null

        val context = applicationContext
        val resolver = context.contentResolver

        // Check if already exists in MediaStore to avoid duplicates
        val projection = arrayOf(MediaStore.Audio.Media._ID)
        val selection = "${MediaStore.Audio.Media.TITLE} = ?"
        val selectionArgs = arrayOf(title)
        val queryCursor = resolver.query(
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
            projection,
            selection,
            selectionArgs,
            null
        )
        if (queryCursor != null && queryCursor.moveToFirst()) {
            val id = queryCursor.getLong(queryCursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID))
            queryCursor.close()
            return Uri.withAppendedPath(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, id.toString()).toString()
        }
        queryCursor?.close()

        // Insert into MediaStore
        val values = ContentValues().apply {
            put(MediaStore.Audio.Media.DISPLAY_NAME, file.name)
            put(MediaStore.Audio.Media.TITLE, title)
            put(MediaStore.Audio.Media.MIME_TYPE, "audio/mpeg")
            put(MediaStore.Audio.Media.IS_ALARM, true)
            put(MediaStore.Audio.Media.IS_RINGTONE, true)
            put(MediaStore.Audio.Media.IS_NOTIFICATION, true)
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
                put(MediaStore.Audio.Media.RELATIVE_PATH, "Alarms")
                put(MediaStore.Audio.Media.IS_PENDING, 1)
            }
        }

        val collection = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        val newUri = resolver.insert(collection, values) ?: return null

        try {
            resolver.openOutputStream(newUri)?.use { outputStream ->
                FileInputStream(file).use { inputStream ->
                    inputStream.copyTo(outputStream)
                }
            }

            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
                values.clear()
                values.put(MediaStore.Audio.Media.IS_PENDING, 0)
                resolver.update(newUri, values, null, null)
            }
            return newUri.toString()
        } catch (e: Exception) {
            resolver.delete(newUri, null, null)
            return null
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == RINGTONE_PICKER_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK && data != null) {
                val uri = data.getParcelableExtra<Uri>(RingtoneManager.EXTRA_RINGTONE_PICKED_URI)
                if (uri != null) {
                    val ringtone = RingtoneManager.getRingtone(this, uri)
                    val title = ringtone.getTitle(this) ?: "Selected Sound"
                    val resultData = mapOf("uri" to uri.toString(), "title" to title)
                    pendingResult?.success(resultData)
                } else {
                    pendingResult?.success(null)
                }
            } else {
                pendingResult?.success(null)
            }
            pendingResult = null
        }
    }
}
