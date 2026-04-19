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
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    project.evaluationDependsOn(":app")

    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
            if (android != null) {
                
                // FIX 1: Résout l'erreur 'android:attr/lStar not found'
                android.compileSdkVersion(34)

                // FIX 2: Résout l'erreur 'Namespace not specified'
                if (android.namespace == null) {
                    val generatedNamespace = "com.example.raycash.${project.name.replace(":", ".")}"
                    android.namespace = generatedNamespace
                }

                // FIX 3: Résout l'erreur 'package= found in source AndroidManifest.xml'
                project.tasks.withType<com.android.build.gradle.tasks.ProcessLibraryManifest>().configureEach {
                    doFirst {
                        val manifestFile = mainManifest.get().asFile
                        if (manifestFile.exists()) {
                            val content = manifestFile.readText()
                            if (content.contains("package=")) {
                                val newContent = content.replace(Regex("""package="[^"]*""""), "")
                                manifestFile.writeText(newContent)
                                println("RAJCASH_LOG: Manifest nettoyé pour ${project.name}")
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