<#
.SYNOPSIS
    Run the graphical Emacs test suites, and the runtime key audit, in an
    isolated configuration root.

.DESCRIPTION
    Selector driven and suite agnostic: a new graphical suite is added to
    $Suites below, not by changing the runner.  Each suite gets its own
    graphical Emacs process, started with --init-directory pointed at a
    throwaway root built by tests/gui-setup.el.

    The two approximations this makes against a real user boot are documented
    in tests/gui-setup.el: a generated wrapper early-init.el that arms
    isolation before loading the real one as a payload, and a synthesized
    private.el / var/etc/custom.el.  Both are the approximations
    tests/verify-config.el already makes in batch.  Everything else is an
    ordinary startup: Emacs runs its own early-init, package-activate-all,
    init, after-init-hook and emacs-startup-hook sequence ONCE.  The rejected
    alternative -- `emacs -Q` plus an explicit load of early-init.el and
    init.el -- runs emacs-startup-hook TWICE, because command-line -l files are
    processed before Emacs runs that hook itself.

    IS IT SAFE TO RUN WHILE YOU ARE WORKING AT THIS MACHINE?  No.
    tests/frames-tests.el deliberately creates real operating-system frames
    (C-x 2, C-x 3, C-c C-SPC w h, C-c C-SPC w v, a magit-status frame and a
    help frame).  They appear on your desktop and can take focus while the run
    is in progress.  Nothing is written outside the throwaway root and
    var/uwumacs-audit/, and no process other than the one this script starts is
    ever signalled -- but expect windows to flicker in front of you for the
    duration.

    Timeouts have two layers, because neither is sufficient alone.  The
    in-session watchdog in tests/gui-run.el rescues a run blocked on a
    minibuffer prompt (observed).  It cannot rescue a modal Windows dialog,
    which freezes the event loop and every timer with it (inherited claim, not
    re-observed here), so this script also polls a deadline and terminates the
    process -- and only the process -- it started itself.

.EXAMPLE
    pwsh tools/run-gui-tests.ps1 -Suite all -Repeat 3
#>
[CmdletBinding()]
param(
    [ValidateSet('frames', 'hints', 'audit', 'all')]
    [string]$Suite = 'all',
    [int]$Repeat = 1,
    [int]$TimeoutSeconds = 240,
    [string]$Emacs = 'C:/Program Files/Emacs/emacs-31.1/bin/emacs.exe',
    [switch]$KeepRoot
)

$ErrorActionPreference = 'Stop'
$repository = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path -replace '\\', '/'
$packages = "$repository/var/elpa"
$reports = "$repository/var/uwumacs-audit/runs"

if (-not (Test-Path $Emacs)) { throw "No Emacs at $Emacs" }
if (-not (Test-Path $packages)) { throw "No package directory at $packages" }
New-Item -ItemType Directory -Force -Path $reports | Out-Null

$Suites = @{
    frames = @{ Tests = 'tests/frames-tests.el'; Selector = '^dots-frames-'; Expect = 5 }
    hints  = @{ Tests = 'tests/key-hints-gui-tests.el'; Selector = '^dots-hints-gui-'; Expect = 3 }
    audit  = @{ Tests = ''; Selector = ''; Expect = 0; Audit = 'observed-keys.json' }
}
$order = if ($Suite -eq 'all') { @('frames', 'hints', 'audit') } else { @($Suite) }

function Get-EmacsPids {
    @(Get-Process emacs*, runemacs* -ErrorAction SilentlyContinue | ForEach-Object { $_.Id })
}

function Remove-Root([string]$root) {
    # Git marks its object files read-only on Windows; -Force is what removes them.
    if (Test-Path $root) { Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue }
}

function Invoke-Suite([string]$name, [int]$attempt) {
    $definition = $Suites[$name]
    $label = "$name-$attempt"
    $server = "uwumacs-gui-$([guid]::NewGuid().ToString('N').Substring(0,12))"
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $resultFile = "$reports/$label-$stamp.log"
    $statusFile = "$reports/$label-$stamp.json"

    $env:EMACS_DOTS_TEST_PACKAGES = $packages
    $env:EMACS_DOTS_SOURCE = "$repository/"
    $env:EMACS_DOTS_GUI_SERVER = $server
    $build = & $Emacs -Q --batch -l "$repository/tests/gui-setup.el" 2>&1
    $root = ($build | Select-Object -Last 1).ToString().Trim()
    if (-not (Test-Path $root)) { throw "gui-setup.el did not produce a root: $build" }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $Emacs
    $psi.UseShellExecute = $false
    $psi.WorkingDirectory = $root
    [void]$psi.ArgumentList.Add("--init-directory=$root")
    [void]$psi.ArgumentList.Add('-l')
    [void]$psi.ArgumentList.Add("$root/tests/gui-run.el")
    foreach ($leak in 'ALTERNATE_EDITOR', 'EMACS_SERVER_FILE', 'EMACS_SOCKET_NAME') {
        [void]$psi.Environment.Remove($leak)
    }
    # A disposable profile: anything the session would write into the user's home
    # directory lands here instead, where it can be measured and deleted.
    $psi.Environment['HOME'] = $root + '/home'
    $psi.Environment['USERPROFILE'] = $root + '/home'
    $psi.Environment['APPDATA'] = $root + '/home'
    $psi.Environment['XDG_CONFIG_HOME'] = $root + '/home'
    $psi.Environment['XDG_CACHE_HOME'] = $root + '/home/cache'
    $psi.Environment['EMACS_DOTS_TEST_PACKAGES'] = $packages
    $psi.Environment['EMACS_DOTS_SOURCE_COMMIT'] = (git -C $repository rev-parse --short HEAD)
    $psi.Environment['EMACS_DOTS_GUI_RESULT'] = $resultFile
    $psi.Environment['EMACS_DOTS_GUI_STATUS'] = $statusFile
    $psi.Environment['EMACS_DOTS_GUI_SERVER'] = $server
    $psi.Environment['EMACS_DOTS_GUI_BUDGET'] = [string]([int]($TimeoutSeconds * 0.75))
    $psi.Environment['EMACS_DOTS_GUI_SELECTOR'] = $definition.Selector
    $psi.Environment['EMACS_DOTS_GUI_EXPECT'] = [string]$definition.Expect
    $psi.Environment['EMACS_DOTS_GUI_TESTS'] =
        if ($definition.Tests) { "$root/$($definition.Tests)" } else { '' }
    if ($definition.Audit) {
        $psi.Environment['EMACS_DOTS_GUI_AUDIT'] = "$repository/var/uwumacs-audit/$($definition.Audit)"
        $psi.Environment['EMACS_DOTS_GUI_LIBRARY'] = "$root/tools/observed-keys.el"
    }

    $before = Get-EmacsPids
    # var/uwumacs-audit is the only part of var/ this runner may add to.
    $varBefore = @(Get-ChildItem "$repository/var" -Recurse -File |
        Where-Object { $_.FullName -notlike "*\uwumacs-audit\*" }).Count
    $elpaBefore = (Get-ChildItem $packages -Directory).Count
    $process = [System.Diagnostics.Process]::Start($psi)
    $owned = $process.Id
    $deadline = [datetime]::UtcNow.AddSeconds($TimeoutSeconds)
    $verdict = $null
    try {
        while (-not (Test-Path $statusFile)) {
            if ($process.HasExited) {
                $verdict = if (Test-Path $statusFile) { $null } else { 'EXITED-WITHOUT-STATUS' }
                break
            }
            if ([datetime]::UtcNow -ge $deadline) { $verdict = 'PARENT-TIMEOUT'; break }
            Start-Sleep -Milliseconds 250
        }
        if (-not $process.HasExited) { $process.WaitForExit(15000) | Out-Null }
    }
    finally {
        if (-not $process.HasExited) {
            # Only ever the process this script started: never a name-based kill.
            [void]$process.CloseMainWindow()
            if (-not $process.WaitForExit(5000)) { $process.Kill($true) }
            $process.WaitForExit(5000) | Out-Null
        }
    }

    $status = if (Test-Path $statusFile) {
        (Get-Content -Raw -LiteralPath $statusFile | ConvertFrom-Json)
    } else { $null }
    if (-not $verdict) { $verdict = if ($status) { $status.status } else { 'NO-STATUS' } }

    $homeFiles = @(Get-ChildItem "$root/home" -Recurse -File -Force -ErrorAction SilentlyContinue)
    $rootElpa = @(Get-ChildItem "$root/var/elpa" -ErrorAction SilentlyContinue)
    $safety = @()
    if ($rootElpa.Count -ne 0) { $safety += "downloaded $($rootElpa.Count) entries into the test root" }
    if ((Get-ChildItem $packages -Directory).Count -ne $elpaBefore) { $safety += 'var/elpa entry count changed' }
    if (Test-Path "$packages/gnupg") { $safety += 'var/elpa/gnupg was created' }
    $varAfter = @(Get-ChildItem "$repository/var" -Recurse -File |
        Where-Object { $_.FullName -notlike "*\uwumacs-audit\*" }).Count
    if ($varAfter -ne $varBefore) { $safety += "var/ file count $varBefore -> $varAfter outside uwumacs-audit" }
    $stray = @(Get-EmacsPids | Where-Object { $_ -ne $owned -and $before -notcontains $_ })
    if ($stray.Count -gt 0) { $safety += "left emacs pids $($stray -join ',')" }

    Write-Host ''
    Write-Host "=== $label ($verdict) pid=$owned root=$root"
    if (Test-Path $resultFile) { Get-Content -LiteralPath $resultFile | ForEach-Object { Write-Host "    $_" } }
    Write-Host "    home-writes=$($homeFiles.Count) root-elpa=$($rootElpa.Count) safety=$(if ($safety) { $safety -join '; ' } else { 'clean' })"
    if ($homeFiles.Count -gt 0) {
        $homeFiles | Select-Object -First 10 | ForEach-Object {
            Write-Host "    home: $($_.FullName.Substring($root.Length + 6))"
        }
    }

    $ok = ($verdict -eq 'PASS') -and ($safety.Count -eq 0)
    if ($ok -and -not $KeepRoot) { Remove-Root $root }
    elseif (-not $ok) { Write-Host "    root kept for inspection: $root" }
    [pscustomobject]@{ Suite = $label; Status = $verdict; Safety = $safety; Ok = $ok; Result = $resultFile }
}

$results = @()
for ($attempt = 1; $attempt -le $Repeat; $attempt++) {
    foreach ($name in $order) { $results += Invoke-Suite $name $attempt }
}

Write-Host ''
Write-Host '=== summary'
$results | ForEach-Object { Write-Host ("    {0,-12} {1}" -f $_.Suite, $_.Status) }
Write-Host "    emacs processes now: $((Get-EmacsPids) -join ',')"
if ($results | Where-Object { -not $_.Ok }) { exit 1 } else { exit 0 }
