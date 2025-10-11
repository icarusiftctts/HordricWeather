###########################################
# ✅ Flutter + R8 Safe ProGuard Rules
###########################################

# --- Core Flutter engine classes (never shrink these) ---
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# --- Keep annotations and inner classes used by Flutter/Dart reflection ---
-keepattributes Signature, InnerClasses, EnclosingMethod

###########################################
# ✅ Plugins & Common Dependencies
###########################################

# --- Flutter Local Notifications plugin ---
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# --- Home Widget plugin ---
-keep public class * extends android.appwidget.AppWidgetProvider
-keep public class * extends android.appwidget.AppWidgetManager
-keep public class * implements android.app.Application$ActivityLifecycleCallbacks

###########################################
# ✅ Play Core / Deferred Components (Fixes R8 missing classes)
###########################################
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-dontwarn com.google.android.play.core.**

###########################################
# ✅ General Safety Rules
###########################################

# Keep generated classes (BuildConfig, R)
-keep class **.BuildConfig { *; }
-keep class **.R$* { *; }
-keep class **.R { *; }

# Keep all public Application classes (prevents removal if using custom app class)
-keep public class * extends android.app.Application { *; }

# Ignore warnings about missing annotations or metadata
-dontwarn javax.annotation.**
-dontwarn kotlin.**
-dontwarn org.jetbrains.annotations.**

###########################################
# ✅ Optional (if you use Firebase or Google Play Services)
###########################################
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

###########################################
# ✅ Logging & Reflection Safety
###########################################
-keepattributes SourceFile, LineNumberTable
-dontnote **.R
-dontnote **.R$*
