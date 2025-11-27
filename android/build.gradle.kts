// Configuración del directorio de build personalizado
// (se mantiene para compatibilidad con Flutter)
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Tarea de limpieza personalizada
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
