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

    // 2. Dépendance indispensable pour Flutter
    project.evaluationDependsOn(":app")

    // 3. Fonction de réparation (Namespace + Manifest)
    fun repairOldPlugin(proj: Project) {
        if (proj.hasProperty("android")) {
            val android = proj.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
            if (android != null) {
                
                // FIX 1: Forcer le Namespace si absent (ton code précédent)
                if (android.namespace == null) {
                    val generatedNamespace = "com.example.raycash.${proj.name.replace(":", ".")}"
                    android.namespace = generatedNamespace
                    println("RAJCASH_LOG: Namespace fixé pour ${proj.name} -> $generatedNamespace")
                }

                // FIX 2: Supprimer le package="sq.flutter.tflite" du Manifest (Le crash actuel)
                proj.tasks.withType<com.android.build.gradle.tasks.ProcessLibraryManifest>().configureEach {
                    doFirst {
                        val manifestFile = mainManifest.get().asFile
                        if (manifestFile.exists()) {
                            val content = manifestFile.readText()
                            if (content.contains("package=")) {
                                // Cette ligne efface l'attribut package pour éviter le conflit
                                val newContent = content.replace(Regex("""package="[^"]*""""), "")
                                manifestFile.writeText(newContent)
                                println("RAJCASH_LOG: Manifest nettoyé (package supprimé) pour ${proj.name}")
                            }
                        }
                    }
                }
            }
        }
    }

    // Gestion du timing pour GitHub Actions (Évite l'erreur 'already evaluated')
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