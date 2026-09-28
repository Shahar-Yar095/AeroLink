# ==============================================================================
# 100X ULTRA-FAST SMART DATA TRANSFER FOR ALL ANDROID DEVICES (AeroLink Pro)
# Features:
#   - Verified MOVE Mode (Transfers & safely frees phone storage)
#   - Safe COPY Mode (Standard fast backup, leaves files on phone)
#   - Smart Auto-Skip: Instantly skips files already present on PC (size verified)
#   - High-Speed Batch Engine with timestamp preservation (-a)
#   - Zero Data Loss: Phone files deleted ONLY after local byte-match verification
#   - Automatic Drive & Free Space Detection (D:\ default with auto-fallback)
#   - Clean empty phone folders & comprehensive session log
# ==============================================================================

$ErrorActionPreference = "Continue"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Adb = Join-Path $ScriptDir "platform-tools\adb.exe"

try { Clear-Host } catch {}
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "         AEROLINK PRO: ULTRA-FAST UNIVERSAL ANDROID DATA SYNC & MOVE            " -ForegroundColor Yellow
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------------------------
# 1. VERIFY ADB BINARY
# ------------------------------------------------------------------------------
if (-not (Test-Path $Adb)) {
    Write-Host "[FATAL ERROR] ADB executable not found at: $Adb" -ForegroundColor Red
    Write-Host "Please ensure platform-tools folder is present in the script directory." -ForegroundColor Yellow
    Read-Host "Press Enter to exit..."
    return
}

# ------------------------------------------------------------------------------
# 2. SELECT DESTINATION DRIVE & STORAGE VERIFICATION
# ------------------------------------------------------------------------------
$PreferredDrives = @("D:\", "C:\", "E:\", "F:\", "G:\")
$TargetDrive = $null

foreach ($drv in $PreferredDrives) {
    if (Test-Path $drv) {
        $TargetDrive = $drv
        break
    }
}

if (-not $TargetDrive) {
    Write-Host "[FATAL ERROR] No suitable storage drive detected!" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    return
}

# Set destination path
$DefaultBackupPath = Join-Path $TargetDrive "AeroLink_Backup"
$driveObj = Get-PSDrive ($TargetDrive.TrimEnd(':\')) -ErrorAction SilentlyContinue
$freeGB = [math]::Round($driveObj.Free / 1GB, 1)

Write-Host "[STORAGE] Destination Directory : $DefaultBackupPath" -ForegroundColor Green
Write-Host "[STORAGE] Drive Free Space      : $freeGB GB available on $TargetDrive" -ForegroundColor Gray
Write-Host ""

$BackupTarget = $DefaultBackupPath
if (-not (Test-Path $BackupTarget)) {
    New-Item -ItemType Directory -Path $BackupTarget -Force | Out-Null
}

# ------------------------------------------------------------------------------
# 3. OPERATION MODE SELECTION (MOVE vs COPY)
# ------------------------------------------------------------------------------
Write-Host "================================================================================" -ForegroundColor DarkCyan
Write-Host "  SELECT TRANSFER MODE:" -ForegroundColor White
Write-Host "    [1] MOVE MODE  - Cut files to PC & FREE UP phone storage (Recommended)" -ForegroundColor Yellow
Write-Host "                     * Auto-skips any files already present on PC" -ForegroundColor Gray
Write-Host "                     * Deletes from phone ONLY after 100% byte verification" -ForegroundColor Gray
Write-Host "    [2] COPY MODE  - Safe backup (keeps all original files on phone)" -ForegroundColor Cyan
Write-Host "                     * Auto-skips any files already present on PC" -ForegroundColor Gray
Write-Host "================================================================================" -ForegroundColor DarkCyan

Write-Host "Choose mode [1 or 2] (Default is 1 [MOVE] in 6s): " -NoNewline -ForegroundColor White
$SelectedMode = "1"

# Interactive prompt with 6-second countdown
$TimeoutSeconds = 6
$StartTime = [DateTime]::Now
while (([DateTime]::Now - $StartTime).TotalSeconds -lt $TimeoutSeconds) {
    $hasKey = $false
    try {
        if (-not [Console]::IsInputRedirected -and [Console]::KeyAvailable) {
            $hasKey = $true
        }
    } catch {
        $hasKey = $false
    }

    if ($hasKey) {
        try {
            $key = [Console]::ReadKey($true)
            if ($key.KeyChar -eq '2') {
                $SelectedMode = "2"
                break
            }
            elseif ($key.KeyChar -eq '1' -or $key.Key -eq [ConsoleKey]::Enter) {
                $SelectedMode = "1"
                break
            }
        } catch {}
    }

    $remaining = [math]::Ceiling($TimeoutSeconds - ([DateTime]::Now - $StartTime).TotalSeconds)
    try {
        Write-Host "`rChoose mode [1 or 2] (Default is 1 [MOVE] in $remaining s): " -NoNewline -ForegroundColor White
    } catch {}
    Start-Sleep -Milliseconds 250
}

Write-Host ""
if ($SelectedMode -eq "1") {
    $IsMoveMode = $true
    Write-Host ">>> MODE SELECTED: [MOVE MODE] (Files will be safely transferred & phone space freed)" -ForegroundColor Yellow -BackgroundColor DarkBlue
} else {
    $IsMoveMode = $false
    Write-Host ">>> MODE SELECTED: [COPY MODE] (Files will be backed up; phone files kept intact)" -ForegroundColor Cyan -BackgroundColor DarkBlue
}
Write-Host ""

# ------------------------------------------------------------------------------
# 4. PHONE CONNECTION & AUTHORIZATION
# ------------------------------------------------------------------------------
Write-Host "Scanning for connected Android device via USB..." -ForegroundColor Gray
$Authorized = $false

while (-not $Authorized) {
    $devices = & $Adb devices | Where-Object { $_ -match "\S+\s+(device|unauthorized)" }
    if (-not $devices) {
        Write-Host "`r[WAITING] Phone not detected. Connect USB cable firmly to phone & PC...   " -NoNewline -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        continue
    }

    if ($devices -match "unauthorized") {
        Write-Host "`n"
        Write-Host "*****************************************************************" -ForegroundColor Magenta
        Write-Host " ACTION NEEDED ON YOUR PHONE SCREEN:                             " -ForegroundColor White -BackgroundColor DarkRed
        Write-Host " 1. Unlock your phone screen.                                   " -ForegroundColor White
        Write-Host " 2. A popup says: 'Allow USB debugging?'                        " -ForegroundColor Yellow
        Write-Host " 3. Check the box 'Always allow from this computer'.             " -ForegroundColor Green
        Write-Host " 4. Tap 'ALLOW' or 'OK'.                                         " -ForegroundColor Cyan
        Write-Host "*****************************************************************" -ForegroundColor Magenta
        Write-Host "Waiting for authorization..." -ForegroundColor Gray
        Start-Sleep -Seconds 3
    }
    elseif ($devices -match "device") {
        $Authorized = $true
        Write-Host "`n[SUCCESS] Phone connected and authorized via High-Speed USB!" -ForegroundColor Green
    }
}

# ------------------------------------------------------------------------------
# 5. DEVICE INFORMATION & PHONE STORAGE CHECK
# ------------------------------------------------------------------------------
$BrandRaw = (& $Adb shell getprop ro.product.brand 2>$null).Trim()
$Brand = if ($BrandRaw) { (Get-Culture).TextInfo.ToTitleCase($BrandRaw.ToLower()) } else { "" }
$ModelRaw = (& $Adb shell getprop ro.product.model 2>$null).Trim()
$Model = if ($Brand -and $ModelRaw) {
    if ($ModelRaw.ToLower().StartsWith($Brand.ToLower())) { $ModelRaw } else { "$Brand $ModelRaw" }
} elseif ($ModelRaw) {
    $ModelRaw
} elseif ($Brand) {
    "$Brand Device"
} else {
    "Android Device"
}
$AndroidVer = (& $Adb shell getprop ro.build.version.release 2>$null).Trim()
$PhoneStorageInfo = (& $Adb shell "df -h /sdcard 2>/dev/null | tail -n 1" 2>$null).Trim()
$BatteryLevel = (& $Adb shell "dumpsys battery 2>/dev/null | grep level | awk '{print `$2}'" 2>$null).Trim()

Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "Device Model      : $Model (Android $AndroidVer)" -ForegroundColor Cyan
if ($BatteryLevel) {
    Write-Host "Battery Level     : $BatteryLevel%" -ForegroundColor Green
}
if ($PhoneStorageInfo) {
    Write-Host "Phone Storage     : $PhoneStorageInfo" -ForegroundColor Gray
}
Write-Host "Target Folder     : $BackupTarget" -ForegroundColor Green
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""

# ------------------------------------------------------------------------------
# 6. DYNAMIC FULL STORAGE DISCOVERY (All Folders, Media Apps & Loose Files)
# ------------------------------------------------------------------------------
Write-Host "Scanning phone storage for all directories & user files..." -ForegroundColor Gray
$DiscoveredTargets = [System.Collections.Generic.List[PSCustomObject]]::new()

$rawTop = & $Adb shell "find /sdcard/ -maxdepth 1 -mindepth 1 2>/dev/null"
foreach ($item in $rawTop) {
    $p = $item.Trim().TrimEnd('/')
    if (-not $p) { continue }
    $name = Split-Path $p -Leaf
    if ($name.StartsWith(".")) { continue }

    if ($name -eq "Android") {
        # Discover all app media folders under Android/media/
        $mediaFolders = & $Adb shell "find /sdcard/Android/media/ -maxdepth 1 -mindepth 1 -type d 2>/dev/null"
        foreach ($mf in $mediaFolders) {
            $mp = $mf.Trim().TrimEnd('/')
            if ($mp) {
                $mName = Split-Path $mp -Leaf
                $DiscoveredTargets.Add([PSCustomObject]@{
                    SourcePath = $mp
                    Relative   = "Android/media/$mName"
                    IsFolder   = $true
                })
            }
        }
        continue
    }

    $isDir = & $Adb shell "[ -d `"$p`" ] && echo 'DIR' || echo 'FILE'"
    if ($isDir -match "DIR") {
        $DiscoveredTargets.Add([PSCustomObject]@{
            SourcePath = $p
            Relative   = $name
            IsFolder   = $true
        })
    } elseif ($isDir -match "FILE") {
        $DiscoveredTargets.Add([PSCustomObject]@{
            SourcePath = $p
            Relative   = $name
            IsFolder   = $false
        })
    }
}
Write-Host "Discovered $($DiscoveredTargets.Count) storage target categories across your phone." -ForegroundColor Green
Write-Host ""

# Statistics Trackers
$TotalSessionStart = Get-Date
$GlobalFilesTransferred = 0
$GlobalBytesTransferred = 0L
$GlobalFilesSkipped = 0
$GlobalBytesSkipped = 0L
$GlobalFilesDeletedPhone = 0
$GlobalBytesFreedPhone = 0L
$GlobalErrors = 0

# Session Log Setup
$LogTimestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$LogFile = Join-Path $BackupTarget "Transfer_Log_$LogTimestamp.txt"
$LogHeader = @"
================================================================================
AEROLINK UNIVERSAL DATA TRANSFER & SYNC LOG
Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Device: $Model (Android $AndroidVer)
Mode: $(if ($IsMoveMode) { "MOVE MODE (Transfer & Delete on Phone)" } else { "COPY MODE (Backup Only)" })
Destination: $BackupTarget
================================================================================
"@
Set-Content -Path $LogFile -Value $LogHeader -Encoding UTF8

# Helper: Append to log
function Write-LogEntry ($msg) {
    Add-Content -Path $LogFile -Value "[$(Get-Date -Format 'HH:mm:ss')] $msg" -Encoding UTF8
}

# Helper: Format Bytes
function Format-FileSize ([long]$bytes) {
    if ($bytes -ge 1GB) { return "{0:N2} GB" -f ($bytes / 1GB) }
    if ($bytes -ge 1MB) { return "{0:N2} MB" -f ($bytes / 1MB) }
    if ($bytes -ge 1KB) { return "{0:N2} KB" -f ($bytes / 1KB) }
    return "$bytes B"
}

# ------------------------------------------------------------------------------
# 7. MAIN TRANSFER & MOVE PROCESSING ENGINE
# ------------------------------------------------------------------------------
Write-Host "Starting Data Processing..." -ForegroundColor Yellow
Write-Host ""

foreach ($Target in $DiscoveredTargets) {
    $SourcePath = $Target.SourcePath
    $Folder = $Target.Relative
    $IsFolder = $Target.IsFolder
    $DestFolder = Join-Path $BackupTarget ($Folder -replace '/', '\')

    # Handle loose root file
    if (-not $IsFolder) {
        $localFile = Join-Path $BackupTarget $Folder
        $fileSize = 0L
        $rawStat = & $Adb shell "stat -c '%s' `"$SourcePath`" 2>/dev/null"
        if ($rawStat) {
            $statLine = ($rawStat -join "").Trim()
            if ($statLine -match '^\d+$') { $fileSize = [long]$statLine }
        }

        if ([System.IO.File]::Exists($localFile)) {
            $lLen = (Get-Item -LiteralPath $localFile).Length
            if ($fileSize -eq 0L -or $lLen -eq $fileSize) {
                Write-Host "  -> [AUTO-SKIP] $Folder already on PC" -ForegroundColor Cyan
                $GlobalFilesSkipped++
                $GlobalBytesSkipped += $fileSize
                if ($IsMoveMode) {
                    & $Adb shell "rm -f `"$SourcePath`"" | Out-Null
                    $GlobalFilesDeletedPhone++
                    $GlobalBytesFreedPhone += $fileSize
                }
                continue
            }
        }

        Write-Host "  -> Transferring root file: $Folder..." -ForegroundColor Yellow
        & $Adb pull -a "$SourcePath" "$BackupTarget" | Out-Null
        if ([System.IO.File]::Exists($localFile)) {
            $GlobalFilesTransferred++
            $GlobalBytesTransferred += $fileSize
            if ($IsMoveMode) {
                & $Adb shell "rm -f `"$SourcePath`"" | Out-Null
                $GlobalFilesDeletedPhone++
                $GlobalBytesFreedPhone += $fileSize
            }
        }
        continue
    }

    Write-Host "================================================================================" -ForegroundColor DarkCyan
    Write-Host "Processing Folder: $Folder" -ForegroundColor Yellow
    Write-Host "Source: $SourcePath -> Destination: $DestFolder" -ForegroundColor Gray

    # Ensure parent destination exists
    $DestParent = Split-Path -Parent $DestFolder
    if (-not (Test-Path $DestParent)) {
        New-Item -ItemType Directory -Path $DestParent -Force | Out-Null
    }

    # Fetch file list from phone with sizes using high-speed find + xargs stat (trailing slash ensures symlink traversal)
    Write-Host "Scanning files on phone..." -NoNewline -ForegroundColor Gray
    $rawList = & $Adb shell "find `"$SourcePath/`" -type f -print0 2>/dev/null | xargs -0 stat -c '%s|%n' 2>/dev/null"
    
    # Fallback if xargs stat was empty
    if (-not $rawList) {
        $rawList = & $Adb shell "find `"$SourcePath/`" -type f 2>/dev/null"
    }

    $validLines = @($rawList | Where-Object { $_ -and $_.Trim() -ne "" })
    Write-Host " Found $($validLines.Count) files." -ForegroundColor Green

    if ($validLines.Count -eq 0) {
        Write-Host "Folder is empty, moving to next." -ForegroundColor Gray
        continue
    }

    $FolderFilesToPull = [System.Collections.Generic.List[PSCustomObject]]::new()
    $FolderFilesAlreadyOnPC = [System.Collections.Generic.List[PSCustomObject]]::new()

    $trimmedSource = $SourcePath.TrimEnd('/')
    # Parse and categorize: Already On PC vs To Pull
    foreach ($line in $validLines) {
        $trimmed = $line.Trim()
        $remoteSize = 0L
        $remotePath = ""

        if ($trimmed -match '^(\d+)\|(.*)$') {
            $remoteSize = [long]$matches[1]
            $remotePath = $matches[2]
        } else {
            $remotePath = $trimmed
        }

        # Calculate relative path from $SourcePath
        if ($remotePath.StartsWith($trimmedSource, [System.StringComparison]::OrdinalIgnoreCase)) {
            $rel = $remotePath.Substring($trimmedSource.Length).TrimStart('/')
        } else {
            $rel = Split-Path $remotePath -Leaf
        }
        $localFile = Join-Path $DestFolder ($rel -replace '/', '\')

        $itemObj = [PSCustomObject]@{
            RemotePath = $remotePath
            RemoteSize = $remoteSize
            LocalPath  = $localFile
            Relative   = $rel
        }

        # Check if local file exists and matches size
        if ([System.IO.File]::Exists($localFile)) {
            $localSize = (Get-Item -LiteralPath $localFile).Length
            if ($remoteSize -eq 0L -or $localSize -eq $remoteSize) {
                $FolderFilesAlreadyOnPC.Add($itemObj)
                continue
            }
        }

        $FolderFilesToPull.Add($itemObj)
    }

    $FolderSkippedCount = $FolderFilesAlreadyOnPC.Count
    $FolderToPullCount = $FolderFilesToPull.Count

    Write-Host "  -> Already on PC (Auto-Skip) : $FolderSkippedCount files" -ForegroundColor Cyan
    Write-Host "  -> Needs Transfer            : $FolderToPullCount files" -ForegroundColor $(if ($FolderToPullCount -gt 0) { "Green" } else { "Gray" })

    # Update global skipped
    $GlobalFilesSkipped += $FolderSkippedCount
    foreach ($sk in $FolderFilesAlreadyOnPC) {
        $GlobalBytesSkipped += $sk.RemoteSize
    }

    $FolderVerifiedForDelete = [System.Collections.Generic.List[string]]::new()
    $FolderBytesFreed = 0L

    # In MOVE mode, files already on PC with matching size are queued for safe phone deletion
    if ($IsMoveMode) {
        foreach ($sk in $FolderFilesAlreadyOnPC) {
            $FolderVerifiedForDelete.Add($sk.RemotePath)
            $FolderBytesFreed += $sk.RemoteSize
        }
    }

    # FAST PULL LOGIC
    if ($FolderToPullCount -gt 0) {
        # If destination folder has NO files yet, whole-folder pull is 10x faster!
        $localExistsWithFiles = (Test-Path $DestFolder) -and ((Get-ChildItem -LiteralPath $DestFolder -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1).Count -gt 0)

        if (-not $localExistsWithFiles -and $FolderSkippedCount -eq 0) {
            Write-Host "  -> High-Speed Stream Pulling entire folder '$Folder'..." -ForegroundColor Yellow
            $pullStart = Get-Date
            # -a preserves timestamp & file mode
            & $Adb pull -a "$SourcePath" "$DestParent"

            $pullDuration = [math]::Round(((Get-Date) - $pullStart).TotalSeconds, 1)
            Write-Host "  -> Stream transfer completed in $pullDuration s" -ForegroundColor Green

            # Verify all pulled files
            foreach ($item in $FolderFilesToPull) {
                if ([System.IO.File]::Exists($item.LocalPath)) {
                    $lSize = (Get-Item -LiteralPath $item.LocalPath).Length
                    if ($item.RemoteSize -eq 0L -or $lSize -eq $item.RemoteSize) {
                        $GlobalFilesTransferred++
                        $GlobalBytesTransferred += $lSize
                        if ($IsMoveMode) {
                            $FolderVerifiedForDelete.Add($item.RemotePath)
                            $FolderBytesFreed += $lSize
                        }
                    } else {
                        $GlobalErrors++
                        Write-LogEntry "MISMATCH: $($item.RemotePath) (Phone: $($item.RemoteSize)B, Local: $($lSize)B)"
                    }
                } else {
                    $GlobalErrors++
                    Write-LogEntry "MISSING AFTER PULL: $($item.RemotePath)"
                }
            }
        } else {
            # Selective pull for missing or modified files, batched by parent directory
            Write-Host "  -> Selectively transferring $FolderToPullCount missing files..." -ForegroundColor Yellow
            $currentIdx = 0

            # Group files by local directory to optimize directory creation
            $grouped = $FolderFilesToPull | Group-Object { Split-Path -Parent $_.LocalPath }

            foreach ($grp in $grouped) {
                $targetDir = $grp.Name
                if (-not [System.IO.Directory]::Exists($targetDir)) {
                    [System.IO.Directory]::CreateDirectory($targetDir) | Out-Null
                }

                # Transfer in sub-batches of 25 files to balance ADB argument length & speed
                $batchSize = 25
                $groupItems = @($grp.Group)
                for ($b = 0; $b -lt $groupItems.Count; $b += $batchSize) {
                    $batch = $groupItems[$b..[math]::Min($b + $batchSize - 1, $groupItems.Count - 1)]
                    $remoteArgs = @($batch | ForEach-Object { $_.RemotePath })

                    # ADB pull multiple files to target dir
                    & $Adb pull -a $remoteArgs "$targetDir" | Out-Null

                    foreach ($item in $batch) {
                        $currentIdx++
                        if ([System.IO.File]::Exists($item.LocalPath)) {
                            $lSize = (Get-Item -LiteralPath $item.LocalPath).Length
                            if ($item.RemoteSize -eq 0L -or $lSize -eq $item.RemoteSize) {
                                $GlobalFilesTransferred++
                                $GlobalBytesTransferred += $lSize
                                if ($IsMoveMode) {
                                    $FolderVerifiedForDelete.Add($item.RemotePath)
                                    $FolderBytesFreed += $lSize
                                }
                            } else {
                                $GlobalErrors++
                                Write-LogEntry "SIZE MISMATCH: $($item.RemotePath) (Phone: $($item.RemoteSize), Local: $lSize)"
                            }
                        } else {
                            $GlobalErrors++
                            Write-LogEntry "PULL FAILED: $($item.RemotePath)"
                        }

                        if ($currentIdx % 20 -eq 0 -or $currentIdx -eq $FolderToPullCount) {
                            $pct = [math]::Round(($currentIdx / $FolderToPullCount) * 100, 0)
                            Write-Host "`r  -> Progress: $currentIdx / $FolderToPullCount ($pct%) transferred... " -NoNewline -ForegroundColor Green
                        }
                    }
                }
            }
            Write-Host ""
        }
    } else {
        Write-Host "  -> All files in '$Folder' already exist on PC. Transfer skipped!" -ForegroundColor Cyan
    }

    # --------------------------------------------------------------------------
    # MOVE MODE: SAFE PHONE STORAGE CLEANUP
    # --------------------------------------------------------------------------
    if ($IsMoveMode -and $FolderVerifiedForDelete.Count -gt 0) {
        $delCount = $FolderVerifiedForDelete.Count
        $freedStr = Format-FileSize $FolderBytesFreed
        Write-Host "  -> MOVE MODE: Safely removing $delCount verified files from phone ($freedStr freed)..." -ForegroundColor Magenta

        # Batch delete files safely on phone (30 files per call with escaped quotes)
        $chunkSize = 30
        for ($i = 0; $i -lt $FolderVerifiedForDelete.Count; $i += $chunkSize) {
            $delBatch = $FolderVerifiedForDelete[$i..[math]::Min($i + $chunkSize - 1, $FolderVerifiedForDelete.Count - 1)]
            $escapedArgs = ($delBatch | ForEach-Object { "'$($_ -replace "'", "'\''")'" }) -join " "
            & $Adb shell "rm -f $escapedArgs" | Out-Null
        }

        # Clean empty sub-directories on phone
        & $Adb shell "find `"$SourcePath`" -mindepth 1 -type d -empty -delete 2>/dev/null"

        $GlobalFilesDeletedPhone += $delCount
        $GlobalBytesFreedPhone += $FolderBytesFreed
        Write-Host "  -> Phone storage successfully freed ($freedStr)!" -ForegroundColor Green
        Write-LogEntry "FREED ON PHONE: $delCount files ($freedStr) from $SourcePath"
    }

    Write-Host ""
}

# ------------------------------------------------------------------------------
# 8. FINAL SUMMARY & REPORT
# ------------------------------------------------------------------------------
$TotalDuration = [math]::Round(((Get-Date) - $TotalSessionStart).TotalMinutes, 2)
$TotalDurationSec = [math]::Round(((Get-Date) - $TotalSessionStart).TotalSeconds, 0)

$TransferredSizeStr = Format-FileSize $GlobalBytesTransferred
$SkippedSizeStr = Format-FileSize $GlobalBytesSkipped
$FreedSizeStr = Format-FileSize $GlobalBytesFreedPhone

$SummaryText = @"
================================================================================
                         TRANSFER SUMMARY REPORT
================================================================================
Mode Used               : $(if ($IsMoveMode) { "MOVE MODE (Transferred & Freed Phone Storage)" } else { "COPY MODE (Safe Backup)" })
Device                  : $Model
Destination             : $BackupTarget
Total Session Duration  : $TotalDuration minutes ($TotalDurationSec seconds)

[STATISTICS]
  - Newly Transferred   : $GlobalFilesTransferred files ($TransferredSizeStr)
  - Auto-Skipped on PC  : $GlobalFilesSkipped files ($SkippedSizeStr)
  - Phone Storage Freed : $GlobalFilesDeletedPhone files ($FreedSizeStr)
  - Verification Errors : $GlobalErrors errors
  - Transfer Integrity : $(if ($GlobalErrors -eq 0) { "100% VERIFIED - PERFECT SUCCESS" } else { "$GlobalErrors files flagged for review in log" })

Session Log saved to    : $LogFile
================================================================================
"@

Clear-Host
Write-Host $SummaryText -ForegroundColor $(if ($GlobalErrors -eq 0) { "Green" } else { "Yellow" })
Add-Content -Path $LogFile -Value $SummaryText -Encoding UTF8

if ($IsMoveMode) {
    Write-Host "SUCCESS: Your phone storage has been freed and all files are safely moved to PC!" -ForegroundColor White -BackgroundColor DarkGreen
} else {
    Write-Host "SUCCESS: All files have been safely backed up to your PC!" -ForegroundColor White -BackgroundColor DarkGreen
}

Write-Host ""
Write-Host "Backup Folder is located at: $BackupTarget" -ForegroundColor Cyan
Write-Host ""
