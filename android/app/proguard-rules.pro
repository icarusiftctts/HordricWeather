###########################################
# 🎯 Flutter Core - Essential Rules
###########################################

# Flutter engine and embedding
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Generated plugin registry
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

###########################################
# 🎯 Your Specific Plugins
###########################################

# flutter_local_notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class ScheduledNotificationBootReceiver { *; }
-keep class ScheduledNotificationReceiver { *; }

# geolocator
-keep class com.baseflow.geolocator.** { *; }

# home_widget
-keep class es.antonborri.home_widget.** { *; }
-keep public class * extends android.appwidget.AppWidgetProvider

# permission_handler
-keep class com.baseflow.permissionhandler.** { *; }

# shared_preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# url_launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

# path_provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# package_info_plus
-keep class dev.fluttercommunity.plus.packageinfo.** { *; }

###########################################
# 🎯 Android Components
###########################################

# Keep application
-keep public class * extends android.app.Application

# Keep activities
-keep public class * extends android.app.Activity

# Keep services (for WorkManager)
-keep public class * extends android.app.Service
-keep class be.tramckrijte.workmanager.** { *; }

# Keep broadcast receivers
-keep public class * extends android.content.BroadcastReceiver
-keep class android.appwidget.AppWidgetProvider { *; }

# WorkManager components
-keep class be.tramckrijte.workmanager.BackgroundService { *; }
-keep class be.tramckrijte.workmanager.BackgroundWorker { *; }

###########################################
# 🎯 Kotlin & Reflection
###########################################

# Kotlin metadata
-keepattributes Signature, InnerClasses, EnclosingMethod, Exceptions
-keepattributes *Annotation*
-keepclasseswithmembers class * {
    @org.jetbrains.annotations.NotNull <fields>;
    @org.jetbrains.annotations.NotNull <methods>;
}

# Kotlin coroutines
-keep class kotlinx.coroutines.android.** { *; }
-keep class kotlin.coroutines.jvm.internal.** { *; }

###########################################
# 🎯 Resource & Build Files
###########################################

# Build config and resources
-keep class **.R { *; }
-keep class **.R$* { *; }
-keep class **.BuildConfig { *; }

###########################################
# 🎯 Optimization Rules
###########################################

# Remove logging in production
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# Optimize enum usage (reduces size)
-optimizations class/enum

# Remove debug attributes
-keepattributes SourceFile,LineNumberTable

###########################################
# 🎯 Warning Suppressions
###########################################

# Suppress common warnings
-dontwarn android.**
-dontwarn kotlin.**
-dontwarn org.jetbrains.annotations.**
-dontwarn javax.annotation.**
-dontwarn com.google.android.play.core.**

# Flutter plugin warnings
-dontwarn io.flutter.plugins.**
-dontwarn com.baseflow.**
-dontwarn com.dexterous.**