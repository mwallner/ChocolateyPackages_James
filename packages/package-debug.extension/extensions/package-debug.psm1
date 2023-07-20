function Test-DebugRequest {
    # We need to use $env:ChocolateyPackageParameters because Get-PackageParameters is not available here
    [bool]($env:ChocoPackageDebug) -or $env:ChocolateyPackageParameters -match '/Debug[:=]?["'']?(?<Value>.+)?["'']?\b'
    if ($Matches.Value) { $env:ChocoPackageDebug = $Matches.Value }
}

function Get-PatternLineNumberOrDefault($File, $Pattern, $Default) {
    $m = Select-String -Path $File -Pattern $Pattern
    if ($m.Count) {
        $m = $m | Select-Object -First 1
        $m.LineNumber
    }
    else {
        $Default
    }
}

function Invoke-DebugLetsGoAlready {
    $id = $PID
    $runspace = $([System.Management.Automation.Runspaces.Runspace]::DefaultRunSpace.Id)

    $debugCommand = @"
Enter-PSHostProcess -Id $id
Debug-Runspace $runspace
"@

    Write-Host @"
Now waiting for debug connection...'
This is PID '$id', in runspace '$runspace'
attach with your favourte debugger, or simply

$debugCommand

in PowerSHell ISE
"@

    if ($env:ChocoPackageDebugISE) {
        $tmpFile = New-TemporaryFile
        $debugCommand | Out-File $tmpFile -Encoding default
        powershell_ise.exe $tmpFile  
    }

    Wait-Debugger
}

if (Test-DebugRequest) {
    $ScriptRunnerFile = Join-Path $env:ChocolateyInstall 'helpers\chocolateyScriptRunner.ps1'

    $Breakpoint = switch -Regex ($env:ChocoPackageDebug) {
        '^(Line[:=]?)?\d+$' { @{Line = $env:ChocoPackageDebug -replace '^(Line[:=]?)?' } }

        # NOTE: default line numbers are according to chocolaetyScriptRunner of Chocolatey version 2.1

        # This waits before evaluating Prehook scripts
        '^Prehook$' { @{Line = Get-PatternLineNumberOrDefault $ScriptRunnerFile @('if \(\$preRunHookScripts\)', '& "\$prehookscript"') 54 } } 

        # This waits before evaluating Package scripts
        '^Package$' { @{Line = Get-PatternLineNumberOrDefault $ScriptRunnerFile @('if \(\$packageScript\)', '& "\$packageScript"') 61 } }  

        # This waits before evaluating Posthook scripts
        '^Posthook$' { @{Line = Get-PatternLineNumberOrDefault $ScriptRunnerFile @('if \(\$postRunHookScripts\)', '& "\$postRunHookScripts"') 89 } }

        # This waits at the start of Package scripts
        default { @{Line = Get-PatternLineNumberOrDefault $ScriptRunnerFile '& "\$packageScript"' 63 } } 
        '^Debug$' { 
            @{Line = 1 }  # This is for debugging the extension.
            Invoke-DebugLetsGoAlready
        }
    }

    Set-PSBreakpoint -Script $ScriptRunnerFile @Breakpoint -Action {
        Invoke-DebugLetsGoAlready
    }
}