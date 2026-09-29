$ErrorActionPreference = 'Stop'

Write-Host ''
Write-Host '============================================================'
Write-Host ' CREATE / VERIFY XCODE PROJECT SPECIFICATION'
Write-Host ' OptionAnalyzer iOS V46.5.24'
Write-Host '============================================================'
Write-Host ''

$Root = (Get-Location).Path
$ProjectName = 'OptionAnalyzer'
$ProjectFile = Join-Path $Root 'OptionAnalyzer.xcodeproj'
$ProjectSpec = Join-Path $Root 'project.yml'

# ------------------------------------------------------------
# 1. Verify CURRENT source architecture
# ------------------------------------------------------------

Write-Host 'Checking current source files...'
Write-Host ''

$RequiredFiles = @(
    'OptionAnalyzer\AnalyzerViewModel.swift'
    'OptionAnalyzer\APIModels.swift'
    'OptionAnalyzer\APIService.swift'
    'OptionAnalyzer\ContentView.swift'
    'OptionAnalyzer\ExecutionView.swift'
    'OptionAnalyzer\OptionAnalyzerApp.swift'
    'API\APIConfig.swift'
    'Views\DashboardView.swift'
    'Views\StageAnalysisView.swift'
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
Write-Host 'All current source files found.'
Write-Host ''

# ------------------------------------------------------------
# 2. Verify Swift file count
# ------------------------------------------------------------

$SwiftFiles = Get-ChildItem `
    (Join-Path $Root 'OptionAnalyzer'),
    (Join-Path $Root 'API'),
    (Join-Path $Root 'Views') `
    -Recurse -File -Filter '*.swift'

Write-Host "Swift source file count: $($SwiftFiles.Count)"

if ($SwiftFiles.Count -ne 9) {
    Write-Host "ERROR: Expected 9 Swift files, found $($SwiftFiles.Count)."
    exit 1
}

Write-Host 'OK: 9 Swift source files.'
Write-Host ''

# ------------------------------------------------------------
# 3. Verify current project.yml
# ------------------------------------------------------------

if (-not (Test-Path -LiteralPath $ProjectSpec -PathType Leaf)) {
    Write-Host 'ERROR: project.yml not found.'
    exit 1
}

Write-Host 'Current project.yml found.'
Write-Host ''

$Yaml = Get-Content -LiteralPath $ProjectSpec -Raw

$RequiredYamlEntries = @(
    'name: OptionAnalyzer'
    '- path: OptionAnalyzer'
    '- path: API'
    '- path: Views'
    'PRODUCT_BUNDLE_IDENTIFIER: com.optionanalyzer.mobile'
    'INFOPLIST_FILE: Info.plist'
    'GENERATE_INFOPLIST_FILE: NO'
)

foreach ($Entry in $RequiredYamlEntries) {
    if ($Yaml -notlike "*$Entry*") {
        Write-Host "ERROR: project.yml is missing: $Entry"
        exit 1
    }

    Write-Host "  OK  $Entry"
}

Write-Host ''
Write-Host 'project.yml architecture is valid.'
Write-Host ''

# ------------------------------------------------------------
# 4. Show current specification
# ------------------------------------------------------------

Write-Host '============================================================'
Write-Host ' CURRENT project.yml'
Write-Host '============================================================'
Write-Host ''

Get-Content -LiteralPath $ProjectSpec

Write-Host ''
Write-Host '============================================================'
Write-Host ''

# ------------------------------------------------------------
# 5. Check XcodeGen availability
# ------------------------------------------------------------

$XcodeGenCommand = Get-Command xcodegen -ErrorAction SilentlyContinue

if ($null -eq $XcodeGenCommand) {

    Write-Host 'XcodeGen is not installed on this Windows computer.'
    Write-Host ''
    Write-Host 'OK: No local Xcode project generation will be attempted.'
    Write-Host 'The macOS GitHub Actions runner can execute XcodeGen.'
    Write-Host ''

} else {

    Write-Host 'XcodeGen detected:'
    Write-Host "  $($XcodeGenCommand.Source)"
    Write-Host ''

    Write-Host 'Generating OptionAnalyzer.xcodeproj from CURRENT project.yml...'
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
# 6. Verify generated project if present
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

    $SchemeFile = Join-Path `
        $ProjectFile `
        'xcshareddata\xcschemes\OptionAnalyzer.xcscheme'

    if (Test-Path -LiteralPath $SchemeFile -PathType Leaf) {
        Write-Host 'OK: shared OptionAnalyzer scheme exists.'
    } else {
        Write-Host 'WARNING: shared OptionAnalyzer scheme not found.'
    }

} else {

    Write-Host 'OK: No local Xcode project generated on this Windows machine.'
    Write-Host 'The macOS build environment will generate it with XcodeGen.'
}

# ------------------------------------------------------------
# 7. Final source-contract checks
# ------------------------------------------------------------

Write-Host ''
Write-Host '============================================================'
Write-Host ' FINAL SOURCE CONTRACT CHECK'
Write-Host '============================================================'
Write-Host ''

$SourceFiles = Get-ChildItem `
    (Join-Path $Root 'OptionAnalyzer'),
    (Join-Path $Root 'API'),
    (Join-Path $Root 'Views') `
    -Recurse -File -Filter '*.swift'

$Obsolete = $SourceFiles |
    Select-String -Pattern '\b(StageContainer|StatusResponse|APIResponse|DashboardModel|AppState)\b'

if ($Obsolete) {
    Write-Host 'ERROR: Obsolete contract references found:'
    $Obsolete | ForEach-Object {
        Write-Host ("  " + $_.Path.Replace($Root + '\','') + " : " + $_.Line.Trim())
    }
    exit 1
}

Write-Host 'OK: No obsolete API/model contract references.'

$DashboardAPI = Select-String `
    -Path (Join-Path $Root 'Views\DashboardView.swift') `
    -Pattern '\bAPIService\b|api\.'

if ($DashboardAPI) {
    Write-Host 'ERROR: DashboardView still contains direct APIService/API references.'
    $DashboardAPI | ForEach-Object {
        Write-Host ("  " + $_.Line.Trim())
    }
    exit 1
}

Write-Host 'OK: DashboardView uses AnalyzerViewModel as UI state owner.'

$APIConstruction = $SourceFiles |
    Select-String -Pattern '\bAPIService\s*\('

if (($APIConstruction | Measure-Object).Count -ne 1) {
    Write-Host 'ERROR: Unexpected APIService construction count.'
    $APIConstruction | ForEach-Object {
        Write-Host ("  " + $_.Path.Replace($Root + '\','') + " : " + $_.Line.Trim())
    }
    exit 1
}

Write-Host 'OK: APIService has a single singleton construction.'

Write-Host ''
Write-Host '============================================================'
Write-Host ' DONE'
Write-Host '============================================================'
Write-Host ''
Write-Host 'No Swift source files were modified.'
Write-Host 'No project.yml regeneration was performed.'
Write-Host 'The existing current project.yml was preserved.'
Write-Host ''
Write-Host 'Next step: run this script, then validate the macOS/Xcode build.'
Write-Host ''
