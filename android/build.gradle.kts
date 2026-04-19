allprojects {
    repositories {
        google()
        mavenCentral()
    }

    // --- SOLUTION POUR LE NAMESPACE ET LE MANIFEST ---
    // On applique la configuration à TOUS les projets immédiatement
    if (project.hasProperty("android")) {
        val android = project.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        if (android != null) {
            
            // 1. Forcer le Namespace
            if (android.namespace == null) {
                android.namespace = "com.example.raycash.${project.name.replace(":", ".")}"
            }

            // 2. Nettoyage du Manifest (supprime l'attribut package)
            project.tasks.withType<com.android.build.gradle.tasks.ProcessLibraryManifest>().configureEach {
                doFirst {
                    val manifestFile = mainManifest.get().asFile
                    if (manifestFile.exists()) {
                        val content = manifestFile.readText()
                        if (content.contains("package=")) {
                            val newContent = content.replace(Regex("""package="[^"]*""""), "")
                            manifestFile.writeText(newContent)
                            println("NETTOYAGE: Manifest corrigé pour ${project.name}")
                        }
                    }
                }
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}