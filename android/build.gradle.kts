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
}
// Some plugins (media_store_plus) are compiled against an old Android API; raise it so their
// androidx dependencies pass the AAR metadata check.
subprojects {
    afterEvaluate {
        extensions.findByName("android")?.let { ext ->
            if (ext is com.android.build.gradle.LibraryExtension && (ext.compileSdk ?: 0) < 36) {
                ext.compileSdk = 36
            }
        }
    }
}
// Plugins whose Java target (11) differs from their Kotlin target (1.8) fail validation; align them.
subprojects {
    if (name != "app") {
        afterEvaluate {
            extensions.findByName("android")?.let { ext ->
                if (ext is com.android.build.gradle.LibraryExtension) {
                    ext.compileOptions {
                        sourceCompatibility = JavaVersion.VERSION_11
                        targetCompatibility = JavaVersion.VERSION_11
                    }
                }
            }
            tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
                compilerOptions.jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
