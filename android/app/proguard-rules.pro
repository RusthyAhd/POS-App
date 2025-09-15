## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

## Firebase
-keepclassmembers class * {
  @com.google.firebase.database.PropertyName <methods>;
}

-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

## Gson
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.stream.** { *; }

## Google Play Core rules
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-dontwarn com.google.android.play.core.**

## Deferred components rules
-keep class **.SplitCompat { *; }
-keep class **.SplitInstall** { *; }

## Models
-keep class com.example.pos_app.** { *; }

# Bluetooth Serial
-keep class io.github.edufolly.** { *; }
-keep class android.bluetooth.** { *; }
-dontwarn android.bluetooth.**

# ESC POS Utils
-keep class com.dantsu.escposprinter.** { *; }
-dontwarn com.dantsu.escposprinter.**

# Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# URL Launcher
-keep class io.flutter.plugins.urllauncher.** { *; }
-dontwarn io.flutter.plugins.urllauncher.**

# General optimizations for faster builds
-optimizationpasses 3
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile