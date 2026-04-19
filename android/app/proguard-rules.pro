# Garder TensorFlow Lite
-keep class org.tensorflow.lite.** { *; }
-keep class com.google.android.gms.tflite.** { *; }
-dontwarn org.tensorflow.lite.**

# Garder les modèles d'IA (fichiers .tflite)
-keepnames class * extends java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
