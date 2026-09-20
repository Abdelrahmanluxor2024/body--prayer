package com.abdelrahman.prayertimes

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.abdelrahman.prayertimes/audio"
    private var mediaPlayer: MediaPlayer? = null
    private val NOTIFICATION_PERMISSION_CODE = 101

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        createNotificationChannel()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "playAthan" -> {
                    try {
                        mediaPlayer?.release()
                        mediaPlayer = null

                        val afd = resources.openRawResourceFd(R.raw.aaa)
                        if (afd != null) {
                            val mp = MediaPlayer()
                            val audioAttributes = AudioAttributes.Builder()
                                .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                                .setLegacyStreamType(AudioManager.STREAM_RING)
                                .build()
                            mp.setAudioAttributes(audioAttributes)
                            mp.setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
                            afd.close()
                            mp.prepare()
                            mp.setVolume(1.0f, 1.0f)
                            mp.setOnCompletionListener {
                                it.release()
                                if (mediaPlayer == it) {
                                    mediaPlayer = null
                                }
                            }
                            mp.start()
                            mediaPlayer = mp
                            result.success(true)
                        } else {
                            val mp = MediaPlayer.create(this, R.raw.aaa)
                            mp?.start()
                            mediaPlayer = mp
                            result.success(true)
                        }
                    } catch (e: Exception) {
                        try {
                            mediaPlayer?.release()
                            val mp = MediaPlayer.create(this, R.raw.aaa)
                            mp?.start()
                            mediaPlayer = mp
                            result.success(true)
                        } catch (ex: Exception) {
                            result.error("AUDIO_ERROR", ex.message, null)
                        }
                    }
                }
                "stopAthan" -> {
                    try {
                        if (mediaPlayer?.isPlaying == true) {
                            mediaPlayer?.stop()
                        }
                    } catch (_: Exception) {}
                    try {
                        mediaPlayer?.release()
                    } catch (_: Exception) {}
                    mediaPlayer = null

                    try {
                        if (PrayerAlarmReceiver.mediaPlayer?.isPlaying == true) {
                            PrayerAlarmReceiver.mediaPlayer?.stop()
                        }
                        PrayerAlarmReceiver.mediaPlayer?.release()
                        PrayerAlarmReceiver.mediaPlayer = null
                    } catch (_: Exception) {}
                    result.success(true)
                }
                "isPlaying" -> {
                    val playing = (mediaPlayer?.isPlaying == true) || (PrayerAlarmReceiver.mediaPlayer?.isPlaying == true)
                    result.success(playing)
                }
                "checkNotificationPermission" -> {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            val granted = ContextCompat.checkSelfPermission(
                                this,
                                android.Manifest.permission.POST_NOTIFICATIONS
                            ) == PackageManager.PERMISSION_GRANTED
                            result.success(granted)
                        } else {
                            result.success(NotificationManagerCompat.from(this).areNotificationsEnabled())
                        }
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "requestNotificationPermission" -> {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            ActivityCompat.requestPermissions(
                                this,
                                arrayOf(android.Manifest.permission.POST_NOTIFICATIONS),
                                NOTIFICATION_PERMISSION_CODE
                            )
                            result.success(true)
                        } else {
                            openNotificationSettings()
                            result.success(true)
                        }
                    } catch (e: Exception) {
                        result.error("PERMISSION_ERROR", e.message, null)
                    }
                }
                "openNotificationSettings" -> {
                    try {
                        openNotificationSettings()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SETTINGS_ERROR", e.message, null)
                    }
                }
                "checkOverlayPermission" -> {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            result.success(Settings.canDrawOverlays(this))
                        } else {
                            result.success(true)
                        }
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "checkBatteryPermission" -> {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val powerManager = getSystemService(Context.POWER_SERVICE) as? PowerManager
                            val isIgnoring = powerManager?.isIgnoringBatteryOptimizations(packageName) ?: false
                            result.success(isIgnoring)
                        } else {
                            result.success(true)
                        }
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "openOverlaySettings" -> {
                    try {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName")
                        )
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        try {
                            val fallbackIntent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
                            startActivity(fallbackIntent)
                            result.success(true)
                        } catch (ex: Exception) {
                            result.error("SETTINGS_ERROR", ex.message, null)
                        }
                    }
                }
                "openBatterySettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        try {
                            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                                data = Uri.parse("package:$packageName")
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (ex: Exception) {
                            result.error("SETTINGS_ERROR", ex.message, null)
                        }
                    }
                }
                "showNotification" -> {
                    try {
                        val title = call.argument<String>("title") ?: "تنبيه موعد الصلاة"
                        val message = call.argument<String>("message") ?: "حان وقت الصلاة"
                        val isAthan = call.argument<Boolean>("isAthan") ?: false
                        val id = (System.currentTimeMillis() % 100000).toInt()

                        val openAppIntent = Intent(this, MainActivity::class.java).apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                        }
                        val pendingIntent = PendingIntent.getActivity(
                            this,
                            id,
                            openAppIntent,
                            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                        )

                        val builder = NotificationCompat.Builder(this, PrayerAlarmReceiver.CHANNEL_ID)
                            .setSmallIcon(R.mipmap.ic_launcher)
                            .setContentTitle(title)
                            .setContentText(message)
                            .setStyle(NotificationCompat.BigTextStyle().bigText(message))
                            .setPriority(NotificationCompat.PRIORITY_MAX)
                            .setCategory(NotificationCompat.CATEGORY_ALARM)
                            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                            .setAutoCancel(true)
                            .setContentIntent(pendingIntent)
                            .setVibrate(longArrayOf(0, 500, 200, 500))

                        with(NotificationManagerCompat.from(this)) {
                            notify(id, builder.build())
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("NOTIFICATION_ERROR", e.message, null)
                    }
                }
                "schedulePrayerAlarms" -> {
                    try {
                        val alarmsList = call.argument<List<Map<String, Any>>>("alarms")
                        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager

                        if (alarmsList != null) {
                            for (item in alarmsList) {
                                val id = (item["id"] as? Number)?.toInt() ?: continue
                                val triggerAtMs = (item["timestamp"] as? Number)?.toLong() ?: continue
                                val type = (item["type"] as? String) ?: "reminder"
                                val prayerName = (item["prayerName"] as? String) ?: "الصلاة"
                                val title = (item["title"] as? String) ?: ""
                                val message = (item["message"] as? String) ?: ""

                                val intent = Intent(this, PrayerAlarmReceiver::class.java).apply {
                                    action = "com.abdelrahman.prayertimes.ALARM_TRIGGER"
                                    putExtra("id", id)
                                    putExtra("type", type)
                                    putExtra("prayerName", prayerName)
                                    putExtra("title", title)
                                    putExtra("message", message)
                                }

                                val pendingIntent = PendingIntent.getBroadcast(
                                    this,
                                    id,
                                    intent,
                                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                                )

                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                    alarmManager.setExactAndAllowWhileIdle(
                                        AlarmManager.RTC_WAKEUP,
                                        triggerAtMs,
                                        pendingIntent
                                    )
                                } else {
                                    alarmManager.setExact(
                                        AlarmManager.RTC_WAKEUP,
                                        triggerAtMs,
                                        pendingIntent
                                    )
                                }
                            }
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ALARM_ERROR", e.message, null)
                    }
                }
                "saveImageToGallery" -> {
                    try {
                        val bytes = call.argument<ByteArray>("bytes")
                        val fileName = call.argument<String>("fileName") ?: "prayer_times_${System.currentTimeMillis()}.png"
                        if (bytes == null) {
                            result.error("NULL_BYTES", "Image bytes are null", null)
                            return@setMethodCallHandler
                        }

                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            val contentValues = android.content.ContentValues().apply {
                                put(android.provider.MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                                put(android.provider.MediaStore.MediaColumns.MIME_TYPE, "image/png")
                                put(android.provider.MediaStore.MediaColumns.RELATIVE_PATH, android.os.Environment.DIRECTORY_PICTURES + "/PrayerTimes")
                            }
                            val resolver = contentResolver
                            val uri = resolver.insert(android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)
                            if (uri != null) {
                                resolver.openOutputStream(uri)?.use { os ->
                                    os.write(bytes)
                                }
                                result.success(true)
                            } else {
                                result.error("INSERT_FAILED", "Failed to create MediaStore entry", null)
                            }
                        } else {
                            val picturesDir = android.os.Environment.getExternalStoragePublicDirectory(android.os.Environment.DIRECTORY_PICTURES)
                            val appDir = java.io.File(picturesDir, "PrayerTimes")
                            if (!appDir.exists()) appDir.mkdirs()
                            val file = java.io.File(appDir, fileName)
                            java.io.FileOutputStream(file).use { fos ->
                                fos.write(bytes)
                            }
                            android.media.MediaScannerConnection.scanFile(this, arrayOf(file.absolutePath), arrayOf("image/png"), null)
                            result.success(true)
                        }
                    } catch (e: Exception) {
                        result.error("SAVE_ERROR", e.message, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun openNotificationSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
            }
            startActivity(intent)
        } else {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
            }
            startActivity(intent)
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                PrayerAlarmReceiver.CHANNEL_ID,
                PrayerAlarmReceiver.CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "إشعارات التنبيه قبل الصلاة بـ 15 دقيقة وصوت الأذان"
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 500, 200, 500)
                lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
            }
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    override fun onDestroy() {
        mediaPlayer?.release()
        mediaPlayer = null
        super.onDestroy()
    }
}
