# TensorFlow Lite
-keep class org.tensorflow.** { *; }
-dontwarn org.tensorflow.**

# Para evitar problemas com delegados de GPU
-keep class org.tensorflow.lite.gpu.** { *; }
-keep class org.tensorflow.lite.nnapi.** { *; }
-keep class org.tensorflow.lite.experimental.** { *; }

# Geral
-keep class org.tensorflow.lite.** { *; }
