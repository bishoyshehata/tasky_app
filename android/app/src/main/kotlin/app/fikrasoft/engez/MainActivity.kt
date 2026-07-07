package app.fikrasoft.engez

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
import android.provider.DocumentsContract
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    // ── Ringtone channel ─────────────────────────────────────
    private val RINGTONE_CHANNEL = "app.fikrasoft.engez/ringtone_picker"
    private var pendingRingtoneResult: MethodChannel.Result? = null
    private val RINGTONE_PICKER_REQUEST_CODE = 999
    private var ringtonePlayer: Ringtone? = null
    private var mediaPlayer: MediaPlayer? = null

    // ── SAF Backup channel ───────────────────────────────────
    private val SAF_CHANNEL = "com.bsh.tasky/saf_backup"
    private var pendingSafResult: MethodChannel.Result? = null
    private val SAF_FOLDER_REQUEST_CODE = 1001

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ── Ringtone MethodChannel ───────────────────────────
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, RINGTONE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pickRingtone" -> {
                        pendingRingtoneResult = result
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
                    else -> result.notImplemented()
                }
            }

        // ── SAF Backup MethodChannel ─────────────────────────
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SAF_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    // Opens the system folder picker. Returns the chosen tree URI
                    // string, or null if the user cancelled.
                    "openFolderPicker" -> {
                        pendingSafResult = result
                        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                                val downloadsUri = Uri.parse(
                                    "content://com.android.externalstorage.documents/document/primary%3ADownloads"
                                )
                                putExtra(DocumentsContract.EXTRA_INITIAL_URI, downloadsUri)
                            }
                            addFlags(
                                Intent.FLAG_GRANT_READ_URI_PERMISSION or
                                Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                                Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
                                Intent.FLAG_GRANT_PREFIX_URI_PERMISSION
                            )
                        }
                        startActivityForResult(intent, SAF_FOLDER_REQUEST_CODE)
                    }

                    // Writes a JSON backup file into the persisted tree URI.
                    // Arguments: treeUriStr, fileName, content, maxCopies
                    // Returns: the created document URI string.
                    "writeBackupToTree" -> {
                        val treeUriStr = call.argument<String>("treeUriStr")
                        val fileName   = call.argument<String>("fileName") ?: "backup.json"
                        val content    = call.argument<String>("content")  ?: ""
                        val maxCopies  = call.argument<Int>("maxCopies")   ?: 3

                        if (treeUriStr == null) {
                            result.error("NO_URI", "treeUriStr is null", null)
                            return@setMethodCallHandler
                        }

                        try {
                            val treeUri = Uri.parse(treeUriStr)
                            val treeDoc = DocumentFile.fromTreeUri(applicationContext, treeUri)
                                ?: throw Exception("Cannot open tree URI")

                            // Rotate: remove oldest if at capacity
                            val existing = treeDoc.listFiles()
                                .filter { it.name?.endsWith(".json") == true }
                                .sortedBy { it.lastModified() }
                                .toMutableList()

                            while (existing.size >= maxCopies) {
                                existing.removeAt(0).delete()
                            }

                            // Write new file
                            val newFile = treeDoc.createFile("application/json", fileName)
                                ?: throw Exception("Could not create file in tree")

                            contentResolver.openOutputStream(newFile.uri)?.use { stream ->
                                stream.write(content.toByteArray(Charsets.UTF_8))
                            } ?: throw Exception("Could not open output stream")

                            result.success(newFile.uri.toString())
                        } catch (e: Exception) {
                            result.error("WRITE_ERROR", e.message, null)
                        }
                    }

                    // Lists backup file names for display in UI.
                    // Arguments: treeUriStr
                    // Returns: List<String> of file names (newest first)
                    "listBackupFiles" -> {
                        val treeUriStr = call.argument<String>("treeUriStr")
                        if (treeUriStr == null) {
                            result.success(emptyList<String>())
                            return@setMethodCallHandler
                        }
                        try {
                            val treeUri = Uri.parse(treeUriStr)
                            val treeDoc = DocumentFile.fromTreeUri(applicationContext, treeUri)
                            val names = treeDoc?.listFiles()
                                ?.filter { it.name?.endsWith(".json") == true }
                                ?.sortedByDescending { it.lastModified() }
                                ?.mapNotNull { it.name }
                                ?: emptyList()
                            result.success(names)
                        } catch (e: Exception) {
                            result.success(emptyList<String>())
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    // ── Audio helpers ────────────────────────────────────────

    private fun saveAudioToSystemAlarms(filePath: String, title: String): String? {
        val file = File(filePath)
        if (!file.exists()) return null

        val context = applicationContext
        val resolver = context.contentResolver

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
            return Uri.withAppendedPath(
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, id.toString()
            ).toString()
        }
        queryCursor?.close()

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

    // ── Activity results ─────────────────────────────────────

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        when (requestCode) {
            RINGTONE_PICKER_REQUEST_CODE -> {
                if (resultCode == Activity.RESULT_OK && data != null) {
                    val uri = data.getParcelableExtra<Uri>(RingtoneManager.EXTRA_RINGTONE_PICKED_URI)
                    if (uri != null) {
                        val ringtone = RingtoneManager.getRingtone(this, uri)
                        val title = ringtone.getTitle(this) ?: "Selected Sound"
                        pendingRingtoneResult?.success(
                            mapOf("uri" to uri.toString(), "title" to title)
                        )
                    } else {
                        pendingRingtoneResult?.success(null)
                    }
                } else {
                    pendingRingtoneResult?.success(null)
                }
                pendingRingtoneResult = null
            }

            SAF_FOLDER_REQUEST_CODE -> {
                if (resultCode == Activity.RESULT_OK && data != null) {
                    val treeUri = data.data
                    if (treeUri != null) {
                        // Persist read+write permission across reboots
                        contentResolver.takePersistableUriPermission(
                            treeUri,
                            Intent.FLAG_GRANT_READ_URI_PERMISSION or
                            Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                        )
                        pendingSafResult?.success(treeUri.toString())
                    } else {
                        pendingSafResult?.success(null)
                    }
                } else {
                    pendingSafResult?.success(null)
                }
                pendingSafResult = null
            }
        }
    }
}
