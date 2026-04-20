# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Cloudinary
-keep class com.cloudinary.** { *; }

# Dio / OkHttp
-dontwarn okhttp3.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# Modelo de datos
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }

# Video player
-keep class com.google.android.exoplayer2.** { *; }

# Flutter secure storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Image picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# Share plus
-keep class dev.fluttercommunity.plus.share.** { *; }

# Evitar warnings innecesarios
-dontwarn java.lang.invoke.*
-dontwarn **$$serializer
-dontwarn kotlin.**

# Flutter Play Store Split — clases internas que R8 no encuentra
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
-keep class com.google.android.play.core.** { *; }