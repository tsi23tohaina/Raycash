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
    // 1. Configuration des répertoires de build
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // 2. Dépendance d'évaluation pour le module app
    project.evaluationDependsOn(":app")

    // 3. Logique de réparation pour les anciens plugins (tflite_v2)
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
            if (android != null) {
                
                // Fixer le Namespace si manquant
                if (android.namespace == null) {
                    val generatedNamespace = "com.example.raycash.${project.name.replace(":", ".")}"
                    android.namespace = generatedNamespace
                    println("INFO: Namespace fixé pour ${project.name} -> $generatedNamespace")
                }

                // Supprimer l'attribut 'package' du Manifest pour éviter le conflit
                project.tasks.withType<com.android.build.gradle.tasks.ProcessLibraryManifest>().configureEach {
                    doFirst {
                        val manifestFile = mainManifest.get().asFile
                        if (manifestFile.exists()) {
                            val content = manifestFile.readText()
                            if (content.contains("package=")) {
                                val newContent = content.replace(Regex("""package="[^"]*""""), "")
                                manifestFile.writeText(newContent)
                                println("NETTOYAGE: Attribut package supprimé dans le Manifest de ${project.name}")
                            }
                        }
                    }
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}