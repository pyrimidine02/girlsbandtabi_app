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
subprojects {
    project.evaluationDependsOn(":app")
}

// EN: Kotlin 2.x dropped support for languageVersion < 2.0. Force all subprojects
//     (including Flutter plugins like sentry_flutter) to compile with KOTLIN_2_0 so
//     the build doesn't fail with "Language version 1.6 is no longer supported".
// KO: Kotlin 2.x는 languageVersion < 2.0을 지원하지 않습니다. sentry_flutter 등
//     Flutter 플러그인을 포함한 모든 서브프로젝트가 KOTLIN_2_0으로 컴파일되도록 강제합니다.
subprojects {
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        compilerOptions {
            languageVersion.set(
                org.jetbrains.kotlin.gradle.dsl.KotlinVersion.KOTLIN_2_0,
            )
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
