import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use(keystoreProperties::load)
}

android {
    namespace = "com.example.raycash"
    compileSdk = 34 // Fix crucial pour l'erreur lStar
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.raycash"
        minSdk = 25 
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    aaptOptions {
        noCompress("tflite")
        noCompress("lite")
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

// --- SOLUTION POUR L'ERREUR NAMESPACE + LSTAR ---
// On utilise une version plus stable que "afterEvaluate" pour GitHub Actions
rootProject.subprojects {
    val subproject = this
    subproject.plugins.whenPluginAdded {
        if (this is com.android.build.gradle.api.AndroidBasePlugin) {
            subproject.extensions.configure<com.android.build.gradle.BaseExtension> {
                // 1. Fix lStar : on force le SDK 34 sur tous les plugins
                compileSdkVersion(34)
                
                // 2. Fix Namespace : pour tflite_v2
                if (namespace == null) {
                    namespace = "com.example.raycash.${subproject.name}"
                }
            }
        }
    }
    
    // Pour tflite_v2 : Nettoyage du Manifest (obligatoire même avec le namespace)
    subproject.tasks.withType<com.android.build.gradle.tasks.ProcessLibraryManifest>().configureEach {
        doFirst {
            val manifestFile = mainManifest.get().asFile
            if (manifestFile.exists()) {
                val content = manifestFile.readText()
                if (content.contains("package=")) {
                    val newContent = content.replace(Regex("""package="[^"]*""""), "")
                    manifestFile.writeText(newContent)
                }
            }
        }
    }
}