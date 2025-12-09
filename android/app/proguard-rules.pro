# Razorpay SDK
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# Suppress warnings for missing annotations used by Razorpay
-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers

# Keep annotation-related metadata (even if classes are missing)
-keepattributes *Annotation*
