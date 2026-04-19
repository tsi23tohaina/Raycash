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
    // Configuration du répertoire de build
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // Dépendance d'évaluation pour le module app
    project.evaluationDependsOn(":app")

    // --- SOLUTION ROBUSTE POUR LE NAMESPACE ---
    // Cette fonction sera appelée pour chaque projet
    fun configureNamespace(proj: Project) {
        if (proj.hasProperty("android")) {
            val android = proj.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
            if (android != null && android.namespace == null) {
                val generatedNamespace = "com.example.raycash.${proj.name.replace(":", ".")}"
                android.namespace = generatedNamespace
                println("INFO: Namespace fixé pour ${proj.name} -> $generatedNamespace")
            }
        }
    }

    // Si le projet est déjà chargé, on configure de suite, sinon on attend
    if (project.state.executed) {
        configureNamespace(project)
    } else {
        project.afterEvaluate {
            configureNamespace(project)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}