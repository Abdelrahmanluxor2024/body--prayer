package com.sheikhhussein.prayertimes

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.os.PowerManager
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class PrayerAlarmReceiver : BroadcastReceiver() {

    companion object {
        const val CHANNEL_ID = "prayer_channel_alerts"
        const val CHANNEL_NAME = "تنبيهات مواقيت الصلاة والأذان"
        var mediaPlayer: MediaPlayer? = null
    }

    override fun onReceive(context: Context, intent: Intent) {
        val pm = context.getSystemService(Context.POWER_SERVICE) as? PowerManager
        val wakeLock = pm?.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP,
            "PrayerTimes:AlarmWakeLock"
        )
        wakeLock?.acquire(15000L)

        try {
            val type = intent.getStringExtra("type") ?: "reminder"
            val prayerName = intent.getStringExtra("prayerName") ?: "الصلاة"
            val title = intent.getStringExtra("title") ?: if (type == "athan") "🕌 حان الآن موعد الصلاة" else "🕌 اقتراب موعد الصلاة"
            val message = intent.getStringExtra("message") ?: if (type == "athan") "الله أكبر.. حان الآن موعد $prayerName" else "متبقي 15 دقيقة على موعد $prayerName"
            val id = intent.getIntExtra("id", (System.currentTimeMillis() % 100000).toInt())

            createNotificationChannel(context)

            val openAppIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                id,
                openAppIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val builder = NotificationCompat.Builder(context, CHANNEL_ID)
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

            with(NotificationManagerCompat.from(context)) {
                try {
                    notify(id, builder.build())
                } catch (_: SecurityException) {
                }
            }

            if (type == "athan") {
                var athanWakeLock: PowerManager.WakeLock? = null
                try {
                    val pm2 = context.getSystemService(Context.POWER_SERVICE) as? PowerManager
                    athanWakeLock = pm2?.newWakeLock(
                        PowerManager.PARTIAL_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP,
                        "PrayerTimes:AthanPlayWakeLock"
                    )
                    athanWakeLock?.acquire(35000L)

                    mediaPlayer?.release()
                    mediaPlayer = null

                    val afd = context.resources.openRawResourceFd(R.raw.aaa)
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
                            mediaPlayer = null
                            try {
                                if (athanWakeLock?.isHeld == true) {
                                    athanWakeLock.release()
                                }
                            } catch (_: Exception) {}
                        }
                        mp.start()
                        mediaPlayer = mp
                    } else {
                        val mp = MediaPlayer.create(context, R.raw.aaa)
                        mp?.start()
                        mediaPlayer = mp
                    }
                } catch (e: Exception) {
                    try {
                        val mp = MediaPlayer.create(context, R.raw.aaa)
                        mp?.start()
                        mediaPlayer = mp
                    } catch (_: Exception) {}
                }
            }
        } finally {
            if (wakeLock?.isHeld == true) {
                wakeLock.release()
            }
        }
    }

    private fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(CHANNEL_ID, CHANNEL_NAME, importance).apply {
                description = "إشعارات التنبيه قبل الصلاة بـ 15 دقيقة وصوت الأذان"
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 500, 200, 500)
                lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
            }
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
}
