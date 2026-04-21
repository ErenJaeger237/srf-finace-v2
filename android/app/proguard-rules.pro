# Tink/Crypto annotations
-dontwarn com.google.errorprone.annotations.**
-dontwarn javax.annotation.**

# Keep rules generated for missing classes
-keep class com.google.errorprone.annotations.CanIgnoreReturnValue { *; }
-keep class com.google.errorprone.annotations.CheckReturnValue { *; }
-keep class com.google.errorprone.annotations.Immutable { *; }
-keep class com.google.errorprone.annotations.RestrictedApi { *; }
-keep class javax.annotation.Nullable { *; }
-keep class javax.annotation.concurrent.GuardedBy { *; }
