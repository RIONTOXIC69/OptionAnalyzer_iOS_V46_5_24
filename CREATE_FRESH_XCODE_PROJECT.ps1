$ErrorActionPreference = 'Stop'

Write-Host ''
Write-Host '============================================================'
Write-Host ' CREATE FRESH XCODE PROJECT USING XCODEGEN'
Write-Host ' OptionAnalyzer iOS V46.5.24'
Write-Host '============================================================'
Write-Host ''

$Root = (Get-Location).Path

$ProjectName = 'OptionAnalyzer'
$ProjectFile = Join-Path $Root 'OptionAnalyzer.xcodeproj'
$ProjectSpec = Join-Path $Root 'project.yml'
$BackupDir = Join-Path $Root 'OptionAnalyzer.xcodeproj.BROKEN_BACKUP'

# ------------------------------------------------------------
# 1. Verify source files
# ------------------------------------------------------------

Write-Host 'Checking required source files...'
Write-Host ''

$RequiredFiles = @(
    'OptionAnalyzerApp.swift'
    'API\Models.swift'
    'API\OptionAnalyzerAPIClient.swift'
    'Views\ContentView.swift'
    'Views\MTFRow.swift'
    'Views\StageCard.swift'
    'Info.plist'
)

foreach ($File in $RequiredFiles) {

    $FullPath = Join-Path $Root $File

    if (-not (Test-Path -LiteralPath $FullPath -PathType Leaf)) {
        Write-Host ''
        Write-Host "ERROR: Required file not found: $File"
        exit 1
    }

    Write-Host "  OK  $File"
}

Write-Host ''
Write-Host 'All required source files found.'
Write-Host ''

# ------------------------------------------------------------
# 2. Backup existing Xcode project
# ------------------------------------------------------------

if (Test-Path -LiteralPath $ProjectFile -PathType Container) {

    Write-Host 'Existing OptionAnalyzer.xcodeproj detected.'

    if (Test-Path -LiteralPath $BackupDir -PathType Container) {
        Write-Host 'Removing previous backup...'
        Remove-Item -LiteralPath $BackupDir -Recurse -Force
    }

    Write-Host 'Moving existing project to backup...'
    Move-Item -LiteralPath $ProjectFile -Destination $BackupDir

    Write-Host 'Existing project backed up.'
    Write-Host ''
}

# ------------------------------------------------------------
# 3. Create XcodeGen specification
# ------------------------------------------------------------

Write-Host 'Creating project.yml...'
Write-Host ''

$YamlLines = @(
    'name: OptionAnalyzer'
    ''
    'options:'
    '  deploymentTarget:'
    '    iOS: 17.0'
    '  createIntermediateGroups: true'
    ''
    'configs:'
    '  Debug: debug'
    '  Release: release'
    ''
    'settings:'
    '  base:'
    '    SWIFT_VERSION: 5.0'
    '    IPHONEOS_DEPLOYMENT_TARGET: 17.0'
    '    SDKROOT: iphoneos'
    '    TARGETED_DEVICE_FAMILY: 1,2'
    ''
    'targets:'
    '  OptionAnalyzer:'
    '    type: application'
    '    platform: iOS'
    '    deploymentTarget: 17.0'
    ''
    '    sources:'
    '      - path: OptionAnalyzerApp.swift'
    '      - path: API'
    '      - path: Views'
    ''
    '    settings:'
    '      base:'
    '        PRODUCT_BUNDLE_IDENTIFIER: com.optionanalyzer.mobile'
    '        PRODUCT_NAME: "$(TARGET_NAME)"'
    '        MARKETING_VERSION: 46.5.24'
    '        CURRENT_PROJECT_VERSION: 1'
    '        INFOPLIST_FILE: Info.plist'
    '        GENERATE_INFOPLIST_FILE: NO'
    '        SWIFT_EMIT_LOC_STRINGS: YES'
    '        CODE_SIGNING_ALLOWED: NO'
    '        CODE_SIGNING_REQUIRED: NO'
    '        CODE_SIGN_IDENTITY: ""'
    ''
    'schemes:'
    '  OptionAnalyzer:'
    '    build:'
    '      targets:'
    '        OptionAnalyzer: all'
    '      parallelizeBuild: false'
    '      buildImplicitDependencies: true'
    '    run:'
    '      config: Debug'
    '    profile:'
    '      config: Release'
    '    analyze:'
    '      config: Debug'
    '    archive:'
    '      config: Release'
    '    management:'
    '      shared: true'
)

$YamlLines | Set-Content -LiteralPath $ProjectSpec -Encoding UTF8

if (-not (Test-Path -LiteralPath $ProjectSpec -PathType Leaf)) {
    Write-Host 'ERROR: project.yml was not created.'
    exit 1
}

Write-Host 'project.yml created successfully.'
Write-Host ''

# ------------------------------------------------------------
# 4. Show generated specification
# ------------------------------------------------------------

Write-Host '============================================================'
Write-Host ' GENERATED project.yml'
Write-Host '============================================================'
Write-Host ''

Get-Content -LiteralPath $ProjectSpec

Write-Host ''
Write-Host '============================================================'
Write-Host ''

# ------------------------------------------------------------
# 5. Check whether XcodeGen exists locally
# ------------------------------------------------------------

$XcodeGenCommand = Get-Command xcodegen -ErrorAction SilentlyContinue

if ($null -eq $XcodeGenCommand) {

    Write-Host 'XcodeGen is not installed on this Windows computer.'
    Write-Host ''
    Write-Host 'This is OK.'
    Write-Host 'XcodeGen will run on the macOS GitHub Actions runner.'
    Write-Host ''

} else {

    Write-Host 'XcodeGen detected:'
    Write-Host "  $($XcodeGenCommand.Source)"
    Write-Host ''

    Write-Host 'Generating OptionAnalyzer.xcodeproj...'
    Write-Host ''

    & xcodegen generate --spec $ProjectSpec

    if ($LASTEXITCODE -ne 0) {
        Write-Host ''
        Write-Host 'ERROR: XcodeGen generation failed.'
        exit $LASTEXITCODE
    }

    Write-Host ''
    Write-Host 'XcodeGen generation completed.'
    Write-Host ''
}

# ------------------------------------------------------------
# 6. Verify project specification
# ------------------------------------------------------------

Write-Host '============================================================'
Write-Host ' VERIFICATION'
Write-Host '============================================================'
Write-Host ''

if (Test-Path -LiteralPath $ProjectSpec -PathType Leaf) {
    Write-Host 'OK: project.yml exists.'
} else {
    Write-Host 'ERROR: project.yml does not exist.'
    exit 1
}

# ------------------------------------------------------------
# 7. If XcodeGen generated the project locally, verify it
# ------------------------------------------------------------

if (Test-Path -LiteralPath $ProjectFile -PathType Container) {

    Write-Host 'OK: OptionAnalyzer.xcodeproj exists.'

    $Pbxproj = Join-Path $ProjectFile 'project.pbxproj'

    if (Test-Path -LiteralPath $Pbxproj -PathType Leaf) {
        Write-Host 'OK: project.pbxproj exists.'
    } else {
        Write-Host 'ERROR: project.pbxproj is missing.'
        exit 1
    }

    $SchemeFile = Join-Path $ProjectFile 'xcshareddata\xcschemes\OptionAnalyzer.xcscheme'

    if (Test-Path -LiteralPath $SchemeFile -PathType Leaf) {
        Write-Host 'OK: shared OptionAnalyzer scheme exists.'
    } else {
        Write-Host 'WARNING: shared OptionAnalyzer scheme not found.'
    }

} else {

    Write-Host 'OK: No local Xcode project expected on Windows.'
    Write-Host 'The GitHub macOS runner will generate it with XcodeGen.'
}

# ------------------------------------------------------------
# 8. Final information
# ------------------------------------------------------------

Write-Host ''
Write-Host '============================================================'
Write-Host ' DONE'
Write-Host '============================================================'
Write-Host ''
Write-Host 'Created:'
Write-Host "  $ProjectSpec"
Write-Host ''
Write-Host 'Important:'
Write-Host '  Do NOT manually edit project.pbxproj.'
Write-Host '  GitHub Actions will generate the Xcode project using XcodeGen.'
Write-Host ''
Write-Host 'Next command:'
Write-Host '  git status --short'
Write-Host ''