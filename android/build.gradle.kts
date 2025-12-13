buildscript {
    extra["kotlin_version"] = "2.0.20"
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.0.20")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
    
    // Fix Kotlin version for all subprojects
    configurations.all {
        resolutionStrategy {
            force("org.jetbrains.kotlin:kotlin-stdlib:2.0.20")
            force("org.jetbrains.kotlin:kotlin-stdlib-common:2.0.20")
            force("org.jetbrains.kotlin:kotlin-stdlib-jdk7:2.0.20")
            force("org.jetbrains.kotlin:kotlin-stdlib-jdk8:2.0.20")
        }
    }
}
