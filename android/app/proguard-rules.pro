## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.firebase.** { *; }

## Gson rules (for JSON serialization)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

## Keep all model classes (adjust package name as needed)
-keep class com.example.tower_bts.** { *; }

## Google Maps
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }

## Google Fonts
-keep class com.google.android.gms.fonts.** { *; }

## Image Picker
-keep class io.flutter.plugins.imagepicker.** { *; }

## Geolocator
-keep class com.baseflow.geolocator.** { *; }

## URL Launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

## Shared Preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

## Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

## Keep setters and getters
-keepclassmembers public class * extends android.view.View {
   void set*(***);
   *** get*();
}

## Keep Parcelables
-keepclassmembers class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

## Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

## Prevent obfuscation of Flutter engine classes
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.android.** { *; }

## Keep BuildConfig
-keep class **.BuildConfig { *; }
