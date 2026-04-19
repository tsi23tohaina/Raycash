# TensorFlow Lite rules
-keep class org.tensorflow.lite.** { *; }
-keep class com.google.android.gms.tflite.** { *; }

# Ignorer les avertissements sur les classes manquantes (GPU, etc.)
-dontwarn org.tensorflow.lite.gpu.**
-dontwarn com.google.android.gms.tflite.**