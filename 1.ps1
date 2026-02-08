# Define the project root
$root = Get-Location

# Paths to input files
$file11 = Join-Path $root "class11.txt"
$file12 = Join-Path $root "class12.txt"

# --- STAGE 1: ROBUST VALIDATION ---
if (-not (Test-Path $file11) -or -not (Test-Path $file12)) {
    Write-Error "CRITICAL ERROR: Missing input files. Ensure both 'class11.txt' and 'class12.txt' exist in $root."
    return # Exit script immediately
}

# --- STAGE 2: PREVIEW AND DATA PROCESSING ---
$list11 = Get-Content $file11 | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
$list12 = Get-Content $file12 | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

Write-Host "`n--- PROJECT SCAFFOLD PREVIEW ---" -ForegroundColor Cyan
Write-Host "Class 11 Chapters found: $($list11.Count)"
foreach ($ch in $list11) { Write-Host "  [11] -> $ch" }

Write-Host "`nClass 12 Chapters found: $($list12.Count)"
foreach ($ch in $list12) { Write-Host "  [12] -> $ch" }

Write-Host "`nTotal folders to create: $($list11.Count + $list12.Count)" -ForegroundColor Yellow

# --- STAGE 3: USER VERIFICATION ---
$confirmation = Read-Host "`nProceed with folder creation? (y/n)"
if ($confirmation -ne 'y') {
    Write-Host "Operation cancelled by user." -ForegroundColor Red
    return
}

# --- STAGE 4: EXECUTION ---
function Create-ChapterStructure($basePath, $chapterList) {
    if (-not (Test-Path $basePath)) { New-Item -ItemType Directory -Path $basePath -Force }
    
    foreach ($chapter in $chapterList) {
        $chapterPath = Join-Path $basePath $chapter
        $assetPath = Join-Path $chapterPath "assets"
        
        # Create directories
        New-Item -ItemType Directory -Path $assetPath -Force | Out-Null
        
        # Create the standard index.html
        $htmlPath = Join-Path $chapterPath "index.html"
        $htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>JEE Physics | $chapter</title>
    <script src="https://polyfill.io/v3/polyfill.min.js?features=es6"></script>
    <script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
</head>
<body>
    <h1>Chapter: $chapter</h1>
    <nav><a href="../../index.html">← Back to Main Syllabus</a></nav>
    <hr>
    <div class="content">
        <p>Derivations and Theory for $chapter will be added here.</p>
        <img src="assets/diagram.jpg" alt="Physics Diagram" style="max-width:100%;">
    </div>
</body>
</html>
"@
        Set-Content -Path $htmlPath -Value $htmlContent -Force
    }
}

Create-ChapterStructure (Join-Path $root "class-11") $list11
Create-ChapterStructure (Join-Path $root "class-12") $list12

Write-Host "`nSUCCESS: Physics project scaffolded successfully." -ForegroundColor Green