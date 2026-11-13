# One-time setup. Run in PowerShell from this folder:   .\setup.ps1
# Needs Flutter (https://docs.flutter.dev/get-started/install/windows) with the Android toolchain.
$ErrorActionPreference = 'Stop'
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) { Write-Host 'Flutter was not found. Install Flutter first (see README.md).'; exit 1 }

# 1. create the Android project around the existing lib/ code (existing files are kept)
flutter create --org org.lrmindia --project-name abba_sunday_school --platforms android .

# 2. the default test refers to the template app - remove it
if (Test-Path test\widget_test.dart) { Remove-Item test\widget_test.dart }

# 3. permissions, links and the weekly reminder
.\patch_android.ps1

flutter pub get
Write-Host ''
Write-Host 'Done. Next: put your Supabase URL and anon key in lib\config.dart, then:  flutter run'
