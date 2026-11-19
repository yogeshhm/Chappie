plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.falconate.cadence"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.falconate.cadence"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("cadenceSigning") {
            val keystoreFile = file("cadence.jks")
            if (keystoreFile.exists()) {
                storeFile = keystoreFile
                storePassword = "cadence123"
                keyAlias = "cadence"
                keyPassword = "cadence123"
            }
        }
    }

    buildTypes {
        release {
            val keyFile = file("cadence.jks")
            if (keyFile.exists()) {
                signingConfig = signingConfigs.getByName("cadenceSigning")
            } else {
                signingConfig = signingConfigs.getByName("debug")
            }
        }
        debug {
            val keyFile = file("cadence.jks")
            if (keyFile.exists()) {
                signingConfig = signingConfigs.getByName("cadenceSigning")
            } else {
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
