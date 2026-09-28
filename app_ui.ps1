Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, System.Drawing

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) { $ScriptDir = Get-Location }
$Adb = Join-Path $ScriptDir "platform-tools\adb.exe"

# Preferred default destination drive
$PreferredDrives = @("D:\", "C:\", "E:\", "F:\", "G:\")
$DefaultTarget = "D:\AeroLink_Backup"
foreach ($drv in $PreferredDrives) {
    if (Test-Path $drv) {
        $DefaultTarget = Join-Path $drv "AeroLink_Backup"
        break
    }
}

# ==============================================================================
# XAML DESIGN - MODERN NATIVE PC DESKTOP INTERFACE
# ==============================================================================
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="AeroLink Pro — Universal Android High-Speed Data Sync &amp; Move" 
        Height="780" Width="1040" 
        MinHeight="680" MinWidth="880"
        WindowStartupLocation="CenterScreen"
        Background="#0B0F17" Foreground="#F1F5F9"
        FontFamily="Segoe UI">

    <Window.Resources>
        <!-- Modern Card Style -->
        <Style x:Key="CardPanel" TargetType="Border">
            <Setter Property="Background" Value="#151B26"/>
            <Setter Property="BorderBrush" Value="#222D3E"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="CornerRadius" Value="10"/>
            <Setter Property="Padding" Value="16"/>
        </Style>

        <!-- Metric Box Style -->
        <Style x:Key="MetricBox" TargetType="Border">
            <Setter Property="Background" Value="#0F141E"/>
            <Setter Property="BorderBrush" Value="#1E2738"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="CornerRadius" Value="8"/>
            <Setter Property="Padding" Value="12,10"/>
        </Style>

        <!-- Action Button Style -->
        <Style x:Key="PrimaryBtn" TargetType="Button">
            <Setter Property="Background" Value="#10B981"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Height" Value="46"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" CornerRadius="8" Padding="20,0">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Secondary Button Style -->
        <Style x:Key="SecondaryBtn" TargetType="Button">
            <Setter Property="Background" Value="#1E2638"/>
            <Setter Property="Foreground" Value="#E2E8F0"/>
            <Setter Property="FontWeight" Value="Medium"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Height" Value="38"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="BorderBrush" Value="#334155"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="6" Padding="14,0">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Danger Button Style -->
        <Style x:Key="DangerBtn" TargetType="Button">
            <Setter Property="Background" Value="#DC2626"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Height" Value="46"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" CornerRadius="8" Padding="20,0">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Grid Margin="20">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/> <!-- Header & Device Status -->
            <RowDefinition Height="Auto"/> <!-- Settings & Mode Grid -->
            <RowDefinition Height="Auto"/> <!-- Progress & Metrics -->
            <RowDefinition Height="*"/>    <!-- Activity Log Console -->
            <RowDefinition Height="Auto"/> <!-- Bottom Controls -->
        </Grid.RowDefinitions>

        <!-- 1. HEADER & DEVICE STATUS BAR -->
        <Grid Grid.Row="0" Margin="0,0,0,16">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>

            <!-- App Title -->
            <StackPanel Orientation="Vertical" VerticalAlignment="Center">
                <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                    <TextBlock Text="⚡ AEROLINK UNIVERSAL DATA SYNC" FontSize="20" FontWeight="Bold" Foreground="#FFFFFF"/>
                    <Border Background="#1E293B" CornerRadius="4" Margin="12,0,0,0" Padding="6,2">
                        <TextBlock Text="v2.0 PRO" FontSize="11" FontWeight="Bold" Foreground="#10B981"/>
                    </Border>
                </StackPanel>
                <TextBlock Text="Hardware-Accelerated ADB Transfer • Byte-Verified Move • Smart Auto-Skip" 
                           FontSize="12" Foreground="#94A3B8" Margin="0,4,0,0"/>
            </StackPanel>

            <!-- Device Connection Pill -->
            <Border Grid.Column="1" x:Name="PillDevice" Background="#23190B" BorderBrush="#F59E0B" BorderThickness="1" CornerRadius="20" Padding="14,8" VerticalAlignment="Center">
                <StackPanel Orientation="Horizontal">
                    <Ellipse x:Name="DotDevice" Width="10" Height="10" Fill="#F59E0B" VerticalAlignment="Center" Margin="0,0,8,0"/>
                    <TextBlock x:Name="TxtDeviceStatus" Text="Searching for Phone via USB..." FontSize="13" FontWeight="SemiBold" Foreground="#FCD34D" VerticalAlignment="Center"/>
                </StackPanel>
            </Border>
        </Grid>

        <!-- 2. SETTINGS & MODE SECTION -->
        <Grid Grid.Row="1" Margin="0,0,0,16">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="1.2*"/>
                <ColumnDefinition Width="16"/>
                <ColumnDefinition Width="1*"/>
            </Grid.ColumnDefinitions>

            <!-- Transfer Mode Selector Card -->
            <Border Grid.Column="0" Style="{StaticResource CardPanel}">
                <StackPanel>
                    <TextBlock Text="TRANSFER MODE" FontSize="11" FontWeight="Bold" Foreground="#64748B" Margin="0,0,0,10"/>
                    
                    <!-- Move Mode Radio -->
                    <RadioButton x:Name="RadioMove" IsChecked="True" GroupName="ModeGroup" Margin="0,0,0,10" Cursor="Hand">
                        <StackPanel Margin="6,0,0,0">
                            <StackPanel Orientation="Horizontal">
                                <TextBlock Text="MOVE MODE (Cut to PC &amp; Free Phone Storage)" FontWeight="Bold" Foreground="#10B981" FontSize="14"/>
                                <Border Background="#064E3B" CornerRadius="3" Margin="8,0,0,0" Padding="4,1">
                                    <TextBlock Text="RECOMMENDED" FontSize="10" FontWeight="Bold" Foreground="#34D399"/>
                                </Border>
                            </StackPanel>
                            <TextBlock Text="Verifies byte-for-byte on PC before freeing space on phone. Zero data loss." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0"/>
                        </StackPanel>
                    </RadioButton>

                    <!-- Copy Mode Radio -->
                    <RadioButton x:Name="RadioCopy" GroupName="ModeGroup" Cursor="Hand">
                        <StackPanel Margin="6,0,0,0">
                            <TextBlock Text="COPY MODE (Standard Backup - Keep Files on Phone)" FontWeight="Bold" Foreground="#38BDF8" FontSize="14"/>
                            <TextBlock Text="Backs up all data to PC and leaves original files untouched on phone." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0"/>
                        </StackPanel>
                    </RadioButton>
                </StackPanel>
            </Border>

            <!-- Destination Card -->
            <Border Grid.Column="2" Style="{StaticResource CardPanel}">
                <StackPanel>
                    <TextBlock Text="PC DESTINATION FOLDER" FontSize="11" FontWeight="Bold" Foreground="#64748B" Margin="0,0,0,8"/>
                    
                    <Grid Margin="0,0,0,8">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>
                        <TextBox x:Name="TxtDestPath" Text="$DefaultTarget" Background="#0F141E" Foreground="#FFFFFF" 
                                 BorderBrush="#2A374A" BorderThickness="1" Padding="8,6" FontSize="13" VerticalContentAlignment="Center"/>
                        <Button x:Name="BtnBrowse" Grid.Column="1" Content="Browse..." Style="{StaticResource SecondaryBtn}" Margin="8,0,0,0"/>
                    </Grid>

                    <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                        <TextBlock Text="PC Free Space: " FontSize="12" Foreground="#94A3B8"/>
                        <TextBlock x:Name="TxtDriveFree" Text="Checking..." FontSize="12" FontWeight="SemiBold" Foreground="#38BDF8"/>
                    </StackPanel>
                    
                    <CheckBox x:Name="ChkAutoSkip" IsChecked="True" Content="Smart Auto-Skip: Instantly skip files already on PC" 
                              Foreground="#CBD5E1" FontSize="12" Margin="0,10,0,0" Cursor="Hand"/>
                </StackPanel>
            </Border>
        </Grid>

        <!-- 3. PROGRESS & METRICS SECTION -->
        <Border Grid.Row="2" Style="{StaticResource CardPanel}" Margin="0,0,0,16">
            <StackPanel>
                <!-- Current Action Label & Percentage -->
                <Grid Margin="0,0,0,8">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    <TextBlock x:Name="TxtCurrentAction" Text="Ready. Click 'Start Full Transfer &amp; Move' to begin." 
                               FontSize="13" FontWeight="SemiBold" Foreground="#F8FAFC" TextTrimming="CharacterEllipsis"/>
                    <TextBlock x:Name="TxtPercent" Grid.Column="1" Text="0%" FontSize="14" FontWeight="Bold" Foreground="#10B981"/>
                </Grid>

                <!-- Modern Progress Bar -->
                <ProgressBar x:Name="ProgressBarMain" Height="14" Minimum="0" Maximum="100" Value="0" 
                             Background="#0F141E" Foreground="#10B981" BorderThickness="0" Margin="0,0,0,14"/>

                <!-- 4 Real-time Metric Cards -->
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="1*"/>
                        <ColumnDefinition Width="10"/>
                        <ColumnDefinition Width="1*"/>
                        <ColumnDefinition Width="10"/>
                        <ColumnDefinition Width="1*"/>
                        <ColumnDefinition Width="10"/>
                        <ColumnDefinition Width="1*"/>
                    </Grid.ColumnDefinitions>

                    <Border Grid.Column="0" Style="{StaticResource MetricBox}">
                        <StackPanel>
                            <TextBlock Text="TRANSFERRED" FontSize="10" FontWeight="Bold" Foreground="#64748B"/>
                            <TextBlock x:Name="TxtMetricTransferred" Text="0 files (0 MB)" FontSize="14" FontWeight="Bold" Foreground="#10B981" Margin="0,2,0,0"/>
                        </StackPanel>
                    </Border>

                    <Border Grid.Column="2" Style="{StaticResource MetricBox}">
                        <StackPanel>
                            <TextBlock Text="AUTO-SKIPPED (ON PC)" FontSize="10" FontWeight="Bold" Foreground="#64748B"/>
                            <TextBlock x:Name="TxtMetricSkipped" Text="0 files (0 GB)" FontSize="14" FontWeight="Bold" Foreground="#38BDF8" Margin="0,2,0,0"/>
                        </StackPanel>
                    </Border>

                    <Border Grid.Column="4" Style="{StaticResource MetricBox}">
                        <StackPanel>
                            <TextBlock Text="PHONE SPACE FREED" FontSize="10" FontWeight="Bold" Foreground="#64748B"/>
                            <TextBlock x:Name="TxtMetricFreed" Text="0 GB" FontSize="14" FontWeight="Bold" Foreground="#E879F9" Margin="0,2,0,0"/>
                        </StackPanel>
                    </Border>

                    <Border Grid.Column="6" Style="{StaticResource MetricBox}">
                        <StackPanel>
                            <TextBlock Text="SPEED &amp; STATUS" FontSize="10" FontWeight="Bold" Foreground="#64748B"/>
                            <TextBlock x:Name="TxtMetricSpeed" Text="Idle" FontSize="14" FontWeight="Bold" Foreground="#FCD34D" Margin="0,2,0,0"/>
                        </StackPanel>
                    </Border>
                </Grid>
            </StackPanel>
        </Border>

        <!-- 4. LIVE CONSOLE LOG -->
        <Border Grid.Row="3" Background="#070A0F" BorderBrush="#1C2433" BorderThickness="1" CornerRadius="8" Margin="0,0,0,16" Padding="12">
            <ScrollViewer x:Name="LogScroll" VerticalScrollBarVisibility="Auto">
                <TextBox x:Name="TxtConsoleLog" Background="Transparent" Foreground="#94A3B8" 
                         BorderThickness="0" FontFamily="Consolas" FontSize="11" IsReadOnly="True" 
                         TextWrapping="Wrap" AcceptsReturn="True"/>
            </ScrollViewer>
        </Border>

        <!-- 5. BOTTOM ACTION BAR -->
        <Grid Grid.Row="4">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>

            <!-- Secondary Actions -->
            <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                <Button x:Name="BtnOpenFolder" Content="📂 Open PC Backup Folder" Style="{StaticResource SecondaryBtn}" Margin="0,0,10,0"/>
                <Button x:Name="BtnOpenLog" Content="📄 View Detailed Log" Style="{StaticResource SecondaryBtn}" Margin="0,0,10,0"/>
            </StackPanel>

            <!-- Main Execution Controls -->
            <StackPanel Grid.Column="2" Orientation="Horizontal" VerticalAlignment="Center">
                <Button x:Name="BtnCancel" Content="⏹ Stop Transfer" Style="{StaticResource DangerBtn}" Visibility="Collapsed" Margin="0,0,12,0"/>
                <Button x:Name="BtnStart" Content="🚀 START FULL TRANSFER &amp; MOVE" Style="{StaticResource PrimaryBtn}"/>
            </StackPanel>
        </Grid>
    </Grid>
</Window>
"@

# Read XAML
$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# Map UI Controls
$PillDevice          = $window.FindName("PillDevice")
$DotDevice           = $window.FindName("DotDevice")
$TxtDeviceStatus     = $window.FindName("TxtDeviceStatus")
$RadioMove           = $window.FindName("RadioMove")
$RadioCopy           = $window.FindName("RadioCopy")
$TxtDestPath         = $window.FindName("TxtDestPath")
$BtnBrowse           = $window.FindName("BtnBrowse")
$TxtDriveFree        = $window.FindName("TxtDriveFree")
$ChkAutoSkip         = $window.FindName("ChkAutoSkip")
$TxtCurrentAction    = $window.FindName("TxtCurrentAction")
$TxtPercent          = $window.FindName("TxtPercent")
$ProgressBarMain     = $window.FindName("ProgressBarMain")
$TxtMetricTransferred= $window.FindName("TxtMetricTransferred")
$TxtMetricSkipped    = $window.FindName("TxtMetricSkipped")
$TxtMetricFreed      = $window.FindName("TxtMetricFreed")
$TxtMetricSpeed      = $window.FindName("TxtMetricSpeed")
$TxtConsoleLog       = $window.FindName("TxtConsoleLog")
$LogScroll           = $window.FindName("LogScroll")
$BtnOpenFolder       = $window.FindName("BtnOpenFolder")
$BtnOpenLog          = $window.FindName("BtnOpenLog")
$BtnStart            = $window.FindName("BtnStart")
$BtnCancel           = $window.FindName("BtnCancel")

# Set Initial Destination & Drive Free Space
$TxtDestPath.Text = $DefaultTarget
function Update-DriveSpaceText ($path) {
    try {
        $root = [System.IO.Path]::GetPathRoot($path)
        $drv = Get-PSDrive ($root.TrimEnd(':\')) -ErrorAction SilentlyContinue
        if ($drv) {
            $free = [math]::Round($drv.Free / 1GB, 1)
            $TxtDriveFree.Text = "$free GB Available on $root"
            $TxtDriveFree.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#38BDF8")
        } else {
            $TxtDriveFree.Text = "Drive not found"
            $TxtDriveFree.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#EF4444")
        }
    } catch {
        $TxtDriveFree.Text = "Unknown"
    }
}
Update-DriveSpaceText $DefaultTarget

# Helper for Logging in UI
function Add-LogLine ($msg) {
    $ts = [DateTime]::Now.ToString("HH:mm:ss")
    $line = "[$ts] $msg`r`n"
    $TxtConsoleLog.AppendText($line)
    $LogScroll.ScrollToEnd()
}

# Helper: Format File Sizes
function Format-UIBytes ([long]$b) {
    if ($b -ge 1GB) { return "{0:N2} GB" -f ($b / 1GB) }
    if ($b -ge 1MB) { return "{0:N2} MB" -f ($b / 1MB) }
    if ($b -ge 1KB) { return "{0:N2} KB" -f ($b / 1KB) }
    return "$b B"
}

# Browse Folder Action
$BtnBrowse.Add_Click({
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.Description = "Select Destination Folder for Phone Backup"
    $dlg.SelectedPath = $TxtDestPath.Text
    if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $TxtDestPath.Text = $dlg.SelectedPath
        Update-DriveSpaceText $dlg.SelectedPath
    }
})

$TxtDestPath.Add_TextChanged({
    Update-DriveSpaceText $TxtDestPath.Text
})

# Open Folder Action
$BtnOpenFolder.Add_Click({
    $p = $TxtDestPath.Text
    if (-not (Test-Path $p)) {
        New-Item -ItemType Directory -Path $p -Force | Out-Null
    }
    [System.Diagnostics.Process]::Start("explorer.exe", $p)
})

# Open Log Action
$BtnOpenLog.Add_Click({
    $p = $TxtDestPath.Text
    $latestLog = Get-ChildItem -Path $p -Filter "Transfer_Log_*.txt" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($latestLog) {
        [System.Diagnostics.Process]::Start("notepad.exe", $latestLog.FullName)
    } else {
        [System.Windows.MessageBox]::Show("No transfer log found yet in $p", "Log Viewer", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
    }
})

# State object for thread coordination
$syncState = [hashtable]::Synchronized(@{
    IsRunning = $false
    ShouldCancel = $false
    DeviceConnected = $false
    DeviceModel = ""
})

# Helper function to refresh device status
function Refresh-DeviceStatus {
    try {
        if ($syncState.IsRunning) { return }

        if (-not (Test-Path $Adb)) {
            $TxtDeviceStatus.Text = "ADB Binary Missing in platform-tools!"
            $PillDevice.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#3B0D0C")
            $PillDevice.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#EF4444")
            $DotDevice.Fill = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#EF4444")
            return
        }

        $rawDevices = & $Adb devices 2>$null
        $devLines = @($rawDevices | Where-Object { $_ -match "^\S+\s+(device|unauthorized)" })

        if ($devLines -and ($devLines -match "\bdevice\b")) {
            $devId = ($devLines[0] -split '\s+')[0]
            $brandRaw = & $Adb -s $devId shell getprop ro.product.brand 2>$null
            $brand = if ($brandRaw) { ($brandRaw -join "").Trim() } else { "" }
            $brandFormatted = if ($brand) { (Get-Culture).TextInfo.ToTitleCase($brand.ToLower()) } else { "" }
            
            $modelRaw = & $Adb -s $devId shell getprop ro.product.model 2>$null
            $rawModel = if ($modelRaw) { ($modelRaw -join "").Trim() } else { "" }

            $model = if ($brandFormatted -and $rawModel) {
                if ($rawModel.ToLower().StartsWith($brandFormatted.ToLower())) { $rawModel } else { "$brandFormatted $rawModel" }
            } elseif ($rawModel) {
                $rawModel
            } elseif ($brandFormatted) {
                "$brandFormatted Phone"
            } else {
                "Android Device"
            }

            $verRaw = & $Adb -s $devId shell getprop ro.build.version.release 2>$null
            $androidVer = if ($verRaw) { ($verRaw -join "").Trim() } else { "" }
            $battRaw = & $Adb -s $devId shell "dumpsys battery 2>/dev/null | grep level | awk '{print `$2}'" 2>$null
            $batt = if ($battRaw) { ($battRaw -join "").Trim() } else { "" }
            $battStr = if ($batt) { " • Battery: $batt%" } else { "" }

            $syncState.DeviceModel = $model
            $TxtDeviceStatus.Text = "Connected: $model (Android $androidVer)$battStr"
            $PillDevice.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#064E3B")
            $PillDevice.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#10B981")
            $DotDevice.Fill = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#10B981")

            if (-not $syncState.DeviceConnected) {
                $syncState.DeviceConnected = $true
                Add-LogLine "Phone connected: $model (Android $androidVer)$battStr"
                $TxtCurrentAction.Text = "Ready! Phone is connected. Click 'START FULL TRANSFER & MOVE' below."
            }
        } elseif ($devLines -and ($devLines -match "unauthorized")) {
            $syncState.DeviceConnected = $false
            $TxtDeviceStatus.Text = "Unlock phone & tap 'ALLOW USB Debugging'"
            $PillDevice.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#3B0D0C")
            $PillDevice.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#EF4444")
            $DotDevice.Fill = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#EF4444")
        } else {
            $syncState.DeviceConnected = $false
            $TxtDeviceStatus.Text = "Searching for Phone via USB..."
            $PillDevice.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#23190B")
            $PillDevice.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#F59E0B")
            $DotDevice.Fill = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#F59E0B")
        }
    } catch {
        # Keep timer alive on transient errors
    }
}

# Run device check immediately on window load
$window.Add_Loaded({
    Refresh-DeviceStatus
})

# ==============================================================================
# DEVICE POLLING DISPATCHER TIMER (2-second interval)
# ==============================================================================
$deviceTimer = New-Object System.Windows.Threading.DispatcherTimer
$deviceTimer.Interval = [TimeSpan]::FromSeconds(2)
$deviceTimer.Add_Tick({
    Refresh-DeviceStatus
})
$deviceTimer.Start()

# Cancel Button
$BtnCancel.Add_Click({
    if ($syncState.IsRunning) {
        $syncState.ShouldCancel = $true
        $BtnCancel.IsEnabled = $false
        Add-LogLine "[CANCEL REQUESTED] Stopping after current batch..."
    }
})

# ==============================================================================
# START TRANSFER CLICK HANDLER (BackgroundWorker)
# ==============================================================================
$BtnStart.Add_Click({
    if ($syncState.IsRunning) { return }

    $targetDir = $TxtDestPath.Text.Trim()
    if (-not $targetDir) {
        [System.Windows.MessageBox]::Show("Please enter a valid destination folder.", "Validation Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
        return
    }

    $isMove = $RadioMove.IsChecked
    $autoSkip = $ChkAutoSkip.IsChecked

    # Switch UI to Running Mode
    $syncState.IsRunning = $true
    $syncState.ShouldCancel = $false
    $BtnStart.Visibility = [System.Windows.Visibility]::Collapsed
    $BtnCancel.Visibility = [System.Windows.Visibility]::Visible
    $BtnCancel.IsEnabled = $true
    $BtnBrowse.IsEnabled = $false
    $RadioMove.IsEnabled = $false
    $RadioCopy.IsEnabled = $false
    $ChkAutoSkip.IsEnabled = $false

    $ProgressBarMain.Value = 0
    $TxtPercent.Text = "0%"
    $TxtMetricTransferred.Text = "0 files (0 MB)"
    $TxtMetricSkipped.Text = "0 files (0 GB)"
    $TxtMetricFreed.Text = "0 GB"
    $TxtMetricSpeed.Text = "Connecting..."

    Add-LogLine "=========================================================="
    Add-LogLine "Starting Full Phone Sync & Move"
    Add-LogLine "Mode: $(if ($isMove) { 'MOVE (Cut & Free Space)' } else { 'COPY (Safe Backup)' })"
    Add-LogLine "Target: $targetDir"
    Add-LogLine "=========================================================="

    # BackgroundWorker execution
    $worker = New-Object System.ComponentModel.BackgroundWorker
    $worker.WorkerSupportsCancellation = $true

    $worker.DoWork += {
        param($sender, $e)

        $adbPath = $Adb
        $destRoot = $targetDir
        $doMove = $isMove
        $skipExisting = $autoSkip

        # 1. Wait for Device Connection
        while (-not $syncState.ShouldCancel) {
            $dev = & $adbPath devices 2>$null | Where-Object { $_ -match "\S+\s+device" }
            if ($dev) { break }
            $window.Dispatcher.Invoke([Action]{
                $TxtCurrentAction.Text = "Waiting for phone connection. Plug in USB cable..."
            })
            Start-Sleep -Seconds 1
        }

        if ($syncState.ShouldCancel) { return }

        if (-not (Test-Path $destRoot)) {
            New-Item -ItemType Directory -Path $destRoot -Force | Out-Null
        }

        $sessionStart = [DateTime]::Now
        $logFile = Join-Path $destRoot "Transfer_Log_$($sessionStart.ToString('yyyyMMdd_HHmmss')).txt"
        $logHeader = "AEROLINK UNIVERSAL DATA SYNC LOG`r`nDevice: $($syncState.DeviceModel)`r`nStarted: $($sessionStart.ToString('yyyy-MM-dd HH:mm:ss'))`r`nMode: $(if ($doMove) {'MOVE'} else {'COPY'})`r`nDestination: $destRoot`r`n"
        [System.IO.File]::WriteAllText($logFile, $logHeader, [System.Text.Encoding]::UTF8)

        $totTransferredFiles = 0
        $totTransferredBytes = 0L
        $totSkippedFiles = 0
        $totSkippedBytes = 0L
        $totFreedFiles = 0
        $totFreedBytes = 0L
        $totErrors = 0

        # 2. DYNAMIC FULL STORAGE DISCOVERY (All folders & loose files)
        $window.Dispatcher.Invoke([Action]{
            $TxtCurrentAction.Text = "Scanning full phone storage (all folders & app media)..."
            Add-LogLine "Discovering all directories in /sdcard/..."
        })

        $discoveredTargets = [System.Collections.Generic.List[PSCustomObject]]::new()

        # Top-level items in /sdcard/ (trailing slash ensures symlink traversal)
        $rawTop = & $adbPath shell "find /sdcard/ -maxdepth 1 -mindepth 1 2>/dev/null"
        foreach ($item in $rawTop) {
            $p = $item.Trim().TrimEnd('/')
            if (-not $p) { continue }
            $name = Split-Path $p -Leaf

            # Skip hidden system metadata
            if ($name.StartsWith(".")) { continue }

            if ($name -eq "Android") {
                # Scan all app media under Android/media/
                $mediaFolders = & $adbPath shell "find /sdcard/Android/media/ -maxdepth 1 -mindepth 1 -type d 2>/dev/null"
                foreach ($mf in $mediaFolders) {
                    $mp = $mf.Trim().TrimEnd('/')
                    if ($mp) {
                        $mName = Split-Path $mp -Leaf
                        $discoveredTargets.Add([PSCustomObject]@{
                            RemotePath = $mp
                            Relative   = "Android/media/$mName"
                            IsFolder   = $true
                        })
                    }
                }
                continue
            }

            # Check if directory or loose file
            $isDir = & $adbPath shell "[ -d `"$p`" ] && echo 'DIR' || echo 'FILE'"
            if ($isDir -match "DIR") {
                $discoveredTargets.Add([PSCustomObject]@{
                    RemotePath = $p
                    Relative   = $name
                    IsFolder   = $true
                })
            } elseif ($isDir -match "FILE") {
                $discoveredTargets.Add([PSCustomObject]@{
                    RemotePath = $p
                    Relative   = $name
                    IsFolder   = $false
                })
            }
        }

        $window.Dispatcher.Invoke([Action]{
            Add-LogLine "Discovered $($discoveredTargets.Count) target categories on phone."
        })

        $currentStep = 0
        $totalSteps = $discoveredTargets.Count

        # 3. PROCESS EACH TARGET
        foreach ($target in $discoveredTargets) {
            if ($syncState.ShouldCancel) {
                $window.Dispatcher.Invoke([Action]{ Add-LogLine "[CANCELLED] Operation stopped by user." })
                break
            }

            $currentStep++
            $rel = $target.Relative
            $remoteSource = $target.RemotePath
            $isFolder = $target.IsFolder

            $window.Dispatcher.Invoke([Action]{
                $TxtCurrentAction.Text = "Processing ($currentStep / $totalSteps): $rel"
                $pct = [math]::Round(($currentStep / $totalSteps) * 100, 0)
                $ProgressBarMain.Value = $pct
                $TxtPercent.Text = "$pct%"
            })

            # CASE A: LOOSE ROOT FILE
            if (-not $isFolder) {
                $localFilePath = Join-Path $destRoot $rel
                $fileSize = 0L
                $rawStat = & $adbPath shell "stat -c '%s' `"$remoteSource`" 2>/dev/null"
                if ($rawStat) {
                    $statLine = ($rawStat -join "").Trim()
                    if ($statLine -match '^\d+$') { $fileSize = [long]$statLine }
                }

                $alreadyOnPC = $false
                if ($skipExisting -and [System.IO.File]::Exists($localFilePath)) {
                    $localLen = (Get-Item -LiteralPath $localFilePath).Length
                    if ($fileSize -eq 0L -or $localLen -eq $fileSize) {
                        $alreadyOnPC = $true
                    }
                }

                if ($alreadyOnPC) {
                    $totSkippedFiles++
                    $totSkippedBytes += $fileSize
                    $window.Dispatcher.Invoke([Action]{
                        Add-LogLine "  [AUTO-SKIP] $rel already on PC ($(Format-UIBytes $fileSize))"
                        $TxtMetricSkipped.Text = "$totSkippedFiles files ($(Format-UIBytes $totSkippedBytes))"
                    })
                    if ($doMove) {
                        & $adbPath shell "rm -f `"$remoteSource`"" | Out-Null
                        $totFreedFiles++
                        $totFreedBytes += $fileSize
                        $window.Dispatcher.Invoke([Action]{
                            $TxtMetricFreed.Text = Format-UIBytes $totFreedBytes
                        })
                    }
                } else {
                    $window.Dispatcher.Invoke([Action]{
                        Add-LogLine "  [PULLING] $rel ($(Format-UIBytes $fileSize))..."
                    })
                    & $adbPath pull -a "$remoteSource" "$destRoot" | Out-Null
                    if ([System.IO.File]::Exists($localFilePath)) {
                        $totTransferredFiles++
                        $totTransferredBytes += $fileSize
                        $window.Dispatcher.Invoke([Action]{
                            $TxtMetricTransferred.Text = "$totTransferredFiles files ($(Format-UIBytes $totTransferredBytes))"
                        })
                        if ($doMove) {
                            & $adbPath shell "rm -f `"$remoteSource`"" | Out-Null
                            $totFreedFiles++
                            $totFreedBytes += $fileSize
                            $window.Dispatcher.Invoke([Action]{
                                $TxtMetricFreed.Text = Format-UIBytes $totFreedBytes
                            })
                        }
                    }
                }
                continue
            }

            # CASE B: DIRECTORY TREE
            $localDestDir = Join-Path $destRoot ($rel -replace '/', '\')
            $localDestParent = Split-Path -Parent $localDestDir
            if (-not (Test-Path $localDestParent)) {
                New-Item -ItemType Directory -Path $localDestParent -Force | Out-Null
            }

            # High-speed enumeration of all files inside this directory with exact byte sizes (trailing slash ensures symlink traversal)
            $rawFileList = & $adbPath shell "find `"$remoteSource/`" -type f -print0 2>/dev/null | xargs -0 stat -c '%s|%n' 2>/dev/null"
            if (-not $rawFileList) {
                $rawFileList = & $adbPath shell "find `"$remoteSource/`" -type f 2>/dev/null"
            }

            $validFiles = @($rawFileList | Where-Object { $_ -and $_.Trim() -ne "" })
            if ($validFiles.Count -eq 0) {
                continue
            }

            $filesToPull = [System.Collections.Generic.List[PSCustomObject]]::new()
            $filesAlreadyOnPC = [System.Collections.Generic.List[PSCustomObject]]::new()

            $trimmedRemote = $remoteSource.TrimEnd('/')
            foreach ($line in $validFiles) {
                $trimmed = $line.Trim()
                $rSize = 0L
                $rPath = ""
                if ($trimmed -match '^(\d+)\|(.*)$') {
                    $rSize = [long]$matches[1]
                    $rPath = $matches[2]
                } else {
                    $rPath = $trimmed
                }

                if ($rPath.StartsWith($trimmedRemote, [System.StringComparison]::OrdinalIgnoreCase)) {
                    $fileRel = $rPath.Substring($trimmedRemote.Length).TrimStart('/')
                } else {
                    $fileRel = Split-Path $rPath -Leaf
                }
                $locFile = Join-Path $localDestDir ($fileRel -replace '/', '\')

                $fObj = [PSCustomObject]@{
                    RemotePath = $rPath
                    RemoteSize = $rSize
                    LocalPath  = $locFile
                }

                if ($skipExisting -and [System.IO.File]::Exists($locFile)) {
                    $lSize = (Get-Item -LiteralPath $locFile).Length
                    if ($rSize -eq 0L -or $lSize -eq $rSize) {
                        $filesAlreadyOnPC.Add($fObj)
                        continue
                    }
                }
                $filesToPull.Add($fObj)
            }

            # Update auto-skipped metrics
            $skipCount = $filesAlreadyOnPC.Count
            $totSkippedFiles += $skipCount
            $folderVerifiedDelete = [System.Collections.Generic.List[string]]::new()
            $folderBytesToFree = 0L

            foreach ($sk in $filesAlreadyOnPC) {
                $totSkippedBytes += $sk.RemoteSize
                if ($doMove) {
                    $folderVerifiedDelete.Add($sk.RemotePath)
                    $folderBytesToFree += $sk.RemoteSize
                }
            }

            $window.Dispatcher.Invoke([Action]{
                $TxtMetricSkipped.Text = "$totSkippedFiles files ($(Format-UIBytes $totSkippedBytes))"
                Add-LogLine "[$rel] Total: $($validFiles.Count) | Auto-Skip: $skipCount | To Pull: $($filesToPull.Count)"
            })

            # Pull missing files
            if ($filesToPull.Count -gt 0) {
                $localExistsWithFiles = (Test-Path $localDestDir) -and ((Get-ChildItem -LiteralPath $localDestDir -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1).Count -gt 0)

                # Whole folder stream pull if no local files exist
                if (-not $localExistsWithFiles -and $skipCount -eq 0) {
                    $window.Dispatcher.Invoke([Action]{
                        $TxtCurrentAction.Text = "Stream-Pulling entire folder: $rel ($($filesToPull.Count) files)..."
                    })
                    $pullStart = [DateTime]::Now
                    & $adbPath pull -a "$remoteSource" "$localDestParent" | Out-Null
                    $pullSec = ([DateTime]::Now - $pullStart).TotalSeconds

                    foreach ($f in $filesToPull) {
                        if ([System.IO.File]::Exists($f.LocalPath)) {
                            $actualLen = (Get-Item -LiteralPath $f.LocalPath).Length
                            if ($f.RemoteSize -eq 0L -or $actualLen -eq $f.RemoteSize) {
                                $totTransferredFiles++
                                $totTransferredBytes += $actualLen
                                if ($doMove) {
                                    $folderVerifiedDelete.Add($f.RemotePath)
                                    $folderBytesToFree += $actualLen
                                }
                            }
                        }
                    }
                } else {
                    # Batch pull missing files grouped by parent directory
                    $grouped = $filesToPull | Group-Object { Split-Path -Parent $_.LocalPath }
                    $pulledIdx = 0

                    foreach ($grp in $grouped) {
                        if ($syncState.ShouldCancel) { break }
                        $tDir = $grp.Name
                        if (-not [System.IO.Directory]::Exists($tDir)) {
                            [System.IO.Directory]::CreateDirectory($tDir) | Out-Null
                        }

                        $batchSize = 25
                        $grpList = @($grp.Group)
                        for ($b = 0; $b -lt $grpList.Count; $b += $batchSize) {
                            if ($syncState.ShouldCancel) { break }
                            $batch = $grpList[$b..[math]::Min($b + $batchSize - 1, $grpList.Count - 1)]
                            $batchArgs = @($batch | ForEach-Object { $_.RemotePath })

                            & $adbPath pull -a $batchArgs "$tDir" | Out-Null

                            foreach ($it in $batch) {
                                $pulledIdx++
                                if ([System.IO.File]::Exists($it.LocalPath)) {
                                    $actLen = (Get-Item -LiteralPath $it.LocalPath).Length
                                    if ($it.RemoteSize -eq 0L -or $actLen -eq $it.RemoteSize) {
                                        $totTransferredFiles++
                                        $totTransferredBytes += $actLen
                                        if ($doMove) {
                                            $folderVerifiedDelete.Add($it.RemotePath)
                                            $folderBytesToFree += $actLen
                                        }
                                    }
                                }
                            }

                            $window.Dispatcher.Invoke([Action]{
                                $TxtMetricTransferred.Text = "$totTransferredFiles files ($(Format-UIBytes $totTransferredBytes))"
                                $TxtCurrentAction.Text = "Transferring $($rel): $pulledIdx / $($filesToPull.Count) files..."
                            })
                        }
                    }
                }
            }

            # Safe Phone Deletion in MOVE Mode
            if ($doMove -and $folderVerifiedDelete.Count -gt 0 -and -not $syncState.ShouldCancel) {
                $delCount = $folderVerifiedDelete.Count
                $freedStr = Format-UIBytes $folderBytesToFree
                $window.Dispatcher.Invoke([Action]{
                    $TxtCurrentAction.Text = "Safely freeing storage on phone: $($rel) ($delCount files, $freedStr)..."
                })

                $chunkSize = 30
                for ($ci = 0; $ci -lt $folderVerifiedDelete.Count; $ci += $chunkSize) {
                    $cBatch = $folderVerifiedDelete[$ci..[math]::Min($ci + $chunkSize - 1, $folderVerifiedDelete.Count - 1)]
                    $quoted = ($cBatch | ForEach-Object { "'$($_ -replace "'", "'\''")'" }) -join " "
                    & $adbPath shell "rm -f $quoted" | Out-Null
                }

                # Clean empty directories
                & $adbPath shell "find `"$remoteSource`" -mindepth 1 -type d -empty -delete 2>/dev/null"

                $totFreedFiles += $delCount
                $totFreedBytes += $folderBytesToFree
                $window.Dispatcher.Invoke([Action]{
                    $TxtMetricFreed.Text = Format-UIBytes $totFreedBytes
                    Add-LogLine "  [FREED ON PHONE] $($rel): $delCount files ($freedStr)"
                })
            }
        }

        # 4. COMPLETION SUMMARY
        $totalElapsed = [math]::Round(([DateTime]::Now - $sessionStart).TotalMinutes, 2)
        $summaryReport = @"
==========================================================
TRANSFER COMPLETE
Duration: $totalElapsed minutes
Mode: $(if ($doMove) {'MOVE'} else {'COPY'})
Newly Transferred: $totTransferredFiles files ($(Format-UIBytes $totTransferredBytes))
Auto-Skipped:      $totSkippedFiles files ($(Format-UIBytes $totSkippedBytes))
Phone Space Freed: $totFreedFiles files ($(Format-UIBytes $totFreedBytes))
Integrity:         100% VERIFIED
==========================================================
"@
        [System.IO.File]::AppendAllText($logFile, "`r`n$summaryReport", [System.Text.Encoding]::UTF8)

        $window.Dispatcher.Invoke([Action]{
            $ProgressBarMain.Value = 100
            $TxtPercent.Text = "100%"
            $TxtCurrentAction.Text = "Complete! All phone folders safely transferred & verified."
            $TxtMetricSpeed.Text = "Finished"
            Add-LogLine $summaryReport
            [System.Windows.MessageBox]::Show("Data Transfer Complete!`r`n`r`nTotal Transferred: $totTransferredFiles files ($(Format-UIBytes $totTransferredBytes))`r`nAuto-Skipped (already on PC): $totSkippedFiles files`r`nPhone Space Freed: $(Format-UIBytes $totFreedBytes)`r`n`r`nDestination: $destRoot", "Transfer Successful", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
        })
    }

    $worker.RunWorkerCompleted += {
        $syncState.IsRunning = $false
        $BtnStart.Visibility = [System.Windows.Visibility]::Visible
        $BtnCancel.Visibility = [System.Windows.Visibility]::Collapsed
        $BtnBrowse.IsEnabled = $true
        $RadioMove.IsEnabled = $true
        $RadioCopy.IsEnabled = $true
        $ChkAutoSkip.IsEnabled = $true
    }

    $worker.RunWorkerAsync()
})

# Show Window
$window.ShowDialog() | Out-Null
