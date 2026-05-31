[CmdletBinding()]
param(
    [int]$GraceSeconds = 5,
    [switch]$ForceOnly,
    [switch]$DryRun
)

$ErrorActionPreference = 'Continue'

$targetGroups = @(
    [pscustomobject]@{
        App = 'WeChat'
        Names = @(
            'WeChat',
            'Weixin',
            'WeChatAppEx',
            'WeChatBrowser',
            'WeChatPlayer',
            'WeChatUtility',
            'WeChatOCR',
            'WeChatStore'
        )
    },
    [pscustomobject]@{
        App = 'QQ'
        Names = @(
            'QQ',
            'QQProtect',
            'QQExternal',
            'QQScLauncher',
            'QQAppHelper',
            'QQMiniDL'
        )
    },
    [pscustomobject]@{
        App = 'TickTick'
        Names = @(
            'TickTick',
            'TickTick*',
            'Dida',
            'Dida*'
        )
    },
    [pscustomobject]@{
        App = 'uTools'
        Names = @(
            'uTools',
            'uTools*'
        )
    },
    [pscustomobject]@{
        App = 'Telegram Desktop'
        Names = @(
            'Telegram',
            'TelegramDesktop'
        )
    }
)

function Test-ProcessName {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string[]]$Patterns
    )

    foreach ($pattern in $Patterns) {
        if ($pattern.Contains('*') -or $pattern.Contains('?')) {
            if ($Name -like $pattern) {
                return $true
            }
        }
        elseif ($Name -ieq $pattern) {
            return $true
        }
    }

    return $false
}

function Get-TargetProcesses {
    $allProcesses = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne $PID }
    $seen = @{}
    $result = @()

    foreach ($group in $targetGroups) {
        foreach ($process in $allProcesses) {
            if ($seen.ContainsKey($process.Id)) {
                continue
            }

            if (Test-ProcessName -Name $process.ProcessName -Patterns $group.Names) {
                $seen[$process.Id] = $true
                $result += [pscustomobject]@{
                    App = $group.App
                    ProcessName = $process.ProcessName
                    Id = $process.Id
                }
            }
        }
    }

    return $result | Sort-Object App, ProcessName, Id
}

Write-Host 'Closing background apps: WeChat, QQ, TickTick, uTools, Telegram Desktop'

$targets = @(Get-TargetProcesses)
if ($targets.Count -eq 0) {
    Write-Host 'No matching processes were found.'
    exit 0
}

Write-Host ''
Write-Host 'Matched processes:'
$targets | Format-Table App, ProcessName, Id -AutoSize

if ($DryRun) {
    Write-Host 'Dry run only. No process was closed.'
    exit 0
}

if (-not $ForceOnly) {
    $closeRequests = 0

    foreach ($target in $targets) {
        $process = Get-Process -Id $target.Id -ErrorAction SilentlyContinue
        if ($null -eq $process -or $process.MainWindowHandle -eq 0) {
            continue
        }

        try {
            if ($process.CloseMainWindow()) {
                $closeRequests += 1
            }
        }
        catch {
            Write-Warning ("Could not request normal close for {0} ({1}): {2}" -f $target.ProcessName, $target.Id, $_.Exception.Message)
        }
    }

    if ($closeRequests -gt 0) {
        Write-Host ("Sent normal close request to {0} process(es). Waiting {1} second(s)..." -f $closeRequests, $GraceSeconds)
        Start-Sleep -Seconds $GraceSeconds
    }
}

$remaining = @()
foreach ($target in $targets) {
    $process = Get-Process -Id $target.Id -ErrorAction SilentlyContinue
    if ($null -ne $process) {
        $remaining += $target
    }
}

if ($remaining.Count -eq 0) {
    Write-Host 'All matched processes closed normally.'
    exit 0
}

Write-Host ("Force-stopping {0} remaining process(es)..." -f $remaining.Count)
$failed = @()
foreach ($target in $remaining) {
    try {
        Stop-Process -Id $target.Id -Force -ErrorAction Stop
        Write-Host ("Stopped {0} ({1})." -f $target.ProcessName, $target.Id)
    }
    catch {
        $failed += $target
        Write-Warning ("Failed to stop {0} ({1}): {2}" -f $target.ProcessName, $target.Id, $_.Exception.Message)
    }
}

Start-Sleep -Milliseconds 500

$stillRunning = @()
foreach ($target in $targets) {
    $process = Get-Process -Id $target.Id -ErrorAction SilentlyContinue
    if ($null -ne $process) {
        $stillRunning += $target
    }
}

if ($stillRunning.Count -gt 0) {
    Write-Warning 'Some matching processes are still running. Run this script as Administrator if needed.'
    $stillRunning | Format-Table App, ProcessName, Id -AutoSize
    exit 1
}

if ($failed.Count -gt 0) {
    exit 1
}

Write-Host 'Done.'
exit 0
