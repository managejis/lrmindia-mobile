# Patches the generated Android project for ABBA Sunday School. Safe to run again.
#   .\patch_android.ps1
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------- AndroidManifest.xml
$m = 'android\app\src\main\AndroidManifest.xml'
if (-not (Test-Path $m)) { Write-Host 'Run setup.ps1 first (android folder not found).'; exit 1 }
$x = Get-Content $m -Raw -Encoding UTF8

foreach ($perm in 'INTERNET','POST_NOTIFICATIONS','RECEIVE_BOOT_COMPLETED') {
  if ($x -notmatch "android.permission.$perm") {
    $x = $x -replace '(<manifest[^>]*>)', "`$1`n    <uses-permission android:name=`"android.permission.$perm`"/>"
  }
}
$x = $x -replace 'android:label="[^"]*"', 'android:label="ABBA Sunday School"'

# open https (PDF, YouTube), tel and mailto links
if ($x -notmatch '<queries>') {
  $q = "    <queries>`n" +
       "        <intent><action android:name=`"android.intent.action.VIEW`"/><data android:scheme=`"https`"/></intent>`n" +
       "        <intent><action android:name=`"android.intent.action.VIEW`"/><data android:scheme=`"tel`"/></intent>`n" +
       "        <intent><action android:name=`"android.intent.action.SENDTO`"/><data android:scheme=`"mailto`"/></intent>`n" +
       "    </queries>`n"
  $x = $x -replace '(<application)', ($q + '    $1')
}

# weekly reminder: receivers (keep the alarm after the phone restarts)
if ($x -notmatch 'ScheduledNotificationReceiver') {
  $r = "        <receiver android:exported=`"false`" android:name=`"com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver`" />`n" +
       "        <receiver android:exported=`"false`" android:name=`"com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver`">`n" +
       "            <intent-filter>`n" +
       "                <action android:name=`"android.intent.action.BOOT_COMPLETED`"/>`n" +
       "                <action android:name=`"android.intent.action.MY_PACKAGE_REPLACED`"/>`n" +
       "                <action android:name=`"android.intent.action.QUICKBOOT_POWERON`"/>`n" +
       "                <action android:name=`"com.htc.intent.action.QUICKBOOT_POWERON`"/>`n" +
       "            </intent-filter>`n" +
       "        </receiver>`n"
  $x = $x -replace '</application>', ($r + '    </application>')
}
Set-Content $m $x -Encoding UTF8
Write-Host 'AndroidManifest.xml patched'

# ---------------------------------------------------------------- Gradle: core library desugaring (needed by the reminder plugin)
$kts = 'android\app\build.gradle.kts'; $grv = 'android\app\build.gradle'
if (Test-Path $kts) {
  $g = Get-Content $kts -Raw -Encoding UTF8
  if ($g -notmatch 'isCoreLibraryDesugaringEnabled') {
    $g = $g -replace '(compileOptions\s*\{)', "`$1`n        isCoreLibraryDesugaringEnabled = true"
  }
  if ($g -notmatch 'coreLibraryDesugaring\(') {
    if ($g -match '(?m)^dependencies\s*\{') { $g = $g -replace '(?m)^(dependencies\s*\{)', "`$1`n    coreLibraryDesugaring(`"com.android.tools:desugar_jdk_libs:2.1.4`")" }
    else { $g += "`ndependencies {`n    coreLibraryDesugaring(`"com.android.tools:desugar_jdk_libs:2.1.4`")`n}`n" }
  }
  Set-Content $kts $g -Encoding UTF8
  Write-Host 'build.gradle.kts patched'
} elseif (Test-Path $grv) {
  $g = Get-Content $grv -Raw -Encoding UTF8
  if ($g -notmatch 'coreLibraryDesugaringEnabled') {
    $g = $g -replace '(compileOptions\s*\{)', "`$1`n        coreLibraryDesugaringEnabled true"
  }
  if ($g -notmatch "coreLibraryDesugaring '") {
    if ($g -match '(?m)^dependencies\s*\{') { $g = $g -replace '(?m)^(dependencies\s*\{)', "`$1`n    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'" }
    else { $g += "`ndependencies {`n    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'`n}`n" }
  }
  Set-Content $grv $g -Encoding UTF8
  Write-Host 'build.gradle patched'
} else { Write-Host 'Could not find android\app\build.gradle(.kts)' }
