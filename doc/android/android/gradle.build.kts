object AppConfig {
    const val compileSdk = 33
    const val minSdk = 21
    const val targetSdk = 33
    const val versionCode = 1
    const val versionName = "1.0.0"
    const val buildToolsVersion = "33.0.1"

    const val androidTestInstrumentation = "androidx.test.runner.AndroidJUnitRunner"
    const val proguardConsumerRules =  "consumer-rules.pro"
    const val dimension = "environment"
}

// https://medium.com/android-dev-hacks/kotlin-dsl-gradle-scripts-in-android-made-easy-b8e2991e2ba

plugins {
    id("com.android.application")
    kotlin("android")
    id("kotlin-kapt")
    id("com.google.dagger.hilt.android")
}

android {
    namespace = "co.frog.pokedex"
    compileSdk = AppConfig.compileSdk
    buildToolsVersion = AppConfig.buildToolsVersion

    defaultConfig {
        applicationId = "co.frog.pokedex"
        minSdk = AppConfig.minSdk
        targetSdk = AppConfig.targetSdk
        versionCode = AppConfig.versionCode
        versionName = AppConfig.versionName

        testInstrumentationRunner = AppConfig.androidTestInstrumentation
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    flavorDimensions(AppConfig.dimension)
    productFlavors {
        create("staging") {
            applicationIdSuffix = ".staging"
            dimension = AppConfig.dimension
        }

        create("production") {
            dimension = AppConfig.dimension
        }

        // https://developer.android.com/studio/build/optimize-your-build#kts
        create("dev") {
            // The following configuration limits the "dev" flavor to using
            // English stringresources and xxhdpi screen-density resources.
            resourceConfigurations.addAll(listOf("en", "xxhdpi"))
        }
    }

    viewBinding {
        android.buildFeatures.viewBinding = true
    }

    packagingOptions.resources.excludes.add("META-INF/notice.txt")

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    dataBinding {
        enable = true
    }
}

dependencies {
    //app libs
    implementation("androidx.appcompat:appcompat:1.5.1")
    implementation("com.google.android.material:material:1.7.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    implementation("androidx.fragment:fragment-ktx:1.5.5")
    implementation("com.github.bumptech.glide:glide:4.14.2")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.5.1")
    implementation("androidx.recyclerview:recyclerview:1.2.1")

    // retrofit
    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    implementation("com.squareup.okhttp3:logging-interceptor:3.9.0")
    // JSON
    implementation("com.squareup.retrofit2:converter-jackson:2.9.0")
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin:2.13.3")
    // for hilt dependency injection
    implementation("com.google.dagger:hilt-android:2.44.2")
    kapt("com.google.dagger:hilt-compiler:2.44.2")
    // For instrumentation tests
    androidTestImplementation("com.google.dagger:hilt-android-testing:2.44.2")
    kaptAndroidTest("com.google.dagger:hilt-compiler:2.44.2")
    // For local unit tests
    testImplementation("com.google.dagger:hilt-android-testing:2.44.2")
    kaptTest("com.google.dagger:hilt-compiler:2.44.2")

    //test libs
    // Kotlin extensions for androidx.test.core
    // implementation("androidx.core:core-ktx:1.9.0")
    // Kotlin extensions for androidx.test.ext.junit
    //implementation("androidx.test.ext:junit-ktx:1.1.4")

    // mockito
    testImplementation("org.mockito.kotlin:mockito-kotlin:4.0.0")

    // for JUnit 5 extensions
    // https://www.baeldung.com/mockito-junit-5-extension
    //testImplementation "org.mockito:mockito-junit-jupiter:4.6.1"
    //testImplementation("org.junit.jupiter:junit-jupiter-api:5.8.2")
    //testImplementation("org.junit.jupiter:junit-jupiter-params:5.8.2")

    // temporary dir
    // https://www.baeldung.com/junit-5-temporary-directory

    // we use JUnit 5
    testImplementation("org.junit.jupiter:junit-jupiter:5.8.2")
    testRuntimeOnly("org.junit.jupiter:junit-jupiter-engine:5.8.2")
    //testRuntimeOnly("org.junit.vintage:junit-vintage-engine:5.8.2")

    // mockk has every ... getProperty
    //testImplementation "io.mockk:mockk-android:1.13.1"
    //testImplementation "io.mockk:mockk-agent:1.13.1"
}

tasks.withType<Test>().configureEach {
    useJUnitPlatform()
    testLogging {
        exceptionFormat = org.gradle.api.tasks.testing.logging.TestExceptionFormat.FULL
        events = setOf(
            org.gradle.api.tasks.testing.logging.TestLogEvent.STARTED,
            org.gradle.api.tasks.testing.logging.TestLogEvent.SKIPPED,
            org.gradle.api.tasks.testing.logging.TestLogEvent.PASSED,
            org.gradle.api.tasks.testing.logging.TestLogEvent.FAILED,
        )
        showStandardStreams = true
    }
}

// for dagger
kapt {
    correctErrorTypes = true
}

allprojects {
    tasks.withType<JavaCompile> {
        options.compilerArgs.plusAssign("-Xlint:unchecked")
        options.compilerArgs.plusAssign("-Xlint:deprecation")
    }
}

tasks.withType<org.jetbrains.kotlin.gradle.internal.KaptWithoutKotlincTask>()
    .configureEach {
        kaptProcessJvmArgs.add("-Xmx1g")
    }

/*
memo to optimize the build:
To speed up the gradle build: (with risk of bad build, then you can delete the cache ~/.gradle)
configuration caching should not be activated, neither should experimental optimizations

a macbook has 16GB RAM, we set 8 for the jvm flag, and 1 for the kapt flag

https://developer.android.com/studio/build/optimize-your-build#kts
https://docs.gradle.org/current/userguide/performance.html
use a global gradle.properties global and clean duplicate rules in the poject file:
~/gradle.properties
org.gradle.daemon=true
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.jvmargs=-Xmx8g -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8 -XX:+UseParallelGC -XX:MaxMetaspaceSize=1g
android.enableJetifier=false

and in gradle.build
    productFlavors {
        create("dev") {
            ...
            // The following configuration limits the "dev" flavor to using
            // English stringresources and xxhdpi screen-density resources.
            resourceConfigurations("en", "xxhdpi")
        }
        ...
    }

and for kapt (used by hilt, but careful do not activate experimental optimizations)
https://kotlinlang.org/docs/kapt.html#improving-the-speed-of-builds-that-use-kapt

tasks.withType(org.jetbrains.kotlin.gradle.internal.KaptWithoutKotlincTask.class)
    .configureEach {
        kaptProcessJvmArgs.add('-Xmx1g')
    }
*/
