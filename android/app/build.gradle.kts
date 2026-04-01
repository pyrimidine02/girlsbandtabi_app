import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.inputStream().use { load(it) }
    }
}

android {
    namespace = "cc.noraneko.girlsbandtabi_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    // .env 파일에서 환경변수 로드
    val envFile = rootProject.file("../.env")
    val envProperties = Properties().apply {
        if (envFile.exists()) {
            envFile.inputStream().use { load(it) }
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "cc.noraneko.girlsbandtabi_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // .env → gradle property → 빈 문자열 순으로 fallback
        manifestPlaceholders["MAPS_API_KEY"] =
            envProperties.getProperty("MAPS_API_KEY")
                ?: project.findProperty("MAPS_API_KEY") as String?
                ?: ""
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String? ?: ""
            keyPassword = keystoreProperties["keyPassword"] as String? ?: ""
            val storeFilePath = keystoreProperties["storeFile"] as String?
            storeFile = if (storeFilePath.isNullOrEmpty()) null else rootProject.file(storeFilePath)
            storePassword = keystoreProperties["storePassword"] as String? ?: ""
        }
    }

    buildTypes {
        release {
            signingConfig =
                if ((signingConfigs.findByName("release")?.storeFile != null)) {
                    signingConfigs.getByName("release")
                } else {
                    signingConfigs.getByName("debug")
                }
        }
    }
}

dependencies {
    // EN: Required by flutter_local_notifications on recent Android toolchains.
    // KO: 최근 Android 툴체인에서 flutter_local_notifications가 요구하는 설정입니다.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// EN: Apply Google Services and Firebase Crashlytics plugins only when firebase config file exists.
// KO: Firebase 설정 파일이 있을 때만 Google Services / Crashlytics 플러그인을 적용합니다.
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
    apply(plugin = "com.google.firebase.crashlytics")
}
