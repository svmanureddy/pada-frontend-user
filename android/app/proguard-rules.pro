# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Dio HTTP Client
-keep class dio.** { *; }
-keep interface dio.** { *; }
-dontwarn dio.**

# JSON Serialization
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep all model classes
-keep class * implements java.io.Serializable { *; }
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep exception classes
-keep class * extends java.lang.Exception { *; }
-keep class * extends java.lang.RuntimeException { *; }

# Keep all classes in your app package
-keep class com.pada.deliverapp.** { *; }

# Hive (if used)
-keep class hive.** { *; }
-dontwarn hive.**

# Flutter Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-dontwarn com.it_nomads.fluttersecurestorage.**

# Google Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep R class
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Preserve line numbers for stack traces
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Keep generic signatures
-keepattributes Signature
-keepattributes Exceptions

# Keep annotations
-keepattributes *Annotation*

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Prevent obfuscation of classes used in reflection
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# OkHttp (used by Dio)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# Google Play Core (optional, for deferred components)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class * extends kotlin.coroutines.jvm.internal.SuspendFunction { *; }

# Keep all response models and data classes
-keep class * extends java.lang.Object {
    <fields>;
}

# Keep all classes that might be used via reflection
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeVisibleParameterAnnotations

