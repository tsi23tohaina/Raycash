allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    // 1. Configuration du dossier de build
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // 2. Dépendance indispensable pour Flutter (sauf pour l'app elle-même)
    if (project.name != "app") {
        project.evaluationDependsOn(":app")
    }

    // 3. Fonction de réparation (Namespace + Manifest + lStar)
    fun repairOldPlugin(proj: Project) {
        if (proj.hasProperty("android")) {
            val android = proj.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
            if (android != null) {
                
                // FIX lStar : Force le SDK 34 pour tous les sous-projets
                android.compileSdkVersion(36)

                // FIX Namespace : Pour tflite_v2 et autres
                if (android.namespace == null) {
                    val generatedNamespace = "com.example.raycash.${proj.name.replace(":", ".")}"
                    android.namespace = generatedNamespace
                    println("RAJCASH_LOG: Namespace fixé pour ${proj.name} -> $generatedNamespace")
                }

                // FIX Manifest : Supprime l'attribut package conflictuel
                proj.tasks.withType<com.android.build.gradle.tasks.ProcessLibraryManifest>().configureEach {
                    doFirst {
                        val manifestFile = mainManifest.get().asFile
                        if (manifestFile.exists()) {
                            val content = manifestFile.readText()
                            if (content.contains("package=")) {
                                val newContent = content.replace(Regex("""package="[^"]*""""), "")
                                manifestFile.writeText(newContent)
                                println("RAJCASH_LOG: Manifest nettoyé pour ${proj.name}")
                            }
                        }
                    }
                }
            }
        }
    }

    // Gestion du timing sécurisée
    if (project.state.executed) {
        repairOldPlugin(project)
    } else {
        project.afterEvaluate {
            repairOldPlugin(project)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}