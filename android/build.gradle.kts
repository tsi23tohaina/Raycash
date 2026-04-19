allprojects {
    repositories {
        google()
        mavenCentral() // C'est ici que l'erreur se trouvait
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

    // --- SOLUTION POUR L'ERREUR "NAMESPACE NOT SPECIFIED" ---
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
            if (android != null && android.namespace == null) {
                val generatedNamespace = "com.example.raycash.${project.name.replace(":", ".")}"
                android.namespace = generatedNamespace
                println("INFO: Namespace fixé pour ${project.name} -> $generatedNamespace")
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}