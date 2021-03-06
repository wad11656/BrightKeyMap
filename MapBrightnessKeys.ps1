[xml]$xmlinfo = {<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Author></Author>
    <Description></Description>
    <URI>\BrightKeyMap</URI>
  </RegistrationInfo>
  <Triggers>
    <LogonTrigger>
      <Enabled>true</Enabled>
    </LogonTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <LogonType>InteractiveToken</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
    <UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>
    <WakeToRun>false</WakeToRun>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command></Command>
      <Arguments></Arguments>
    </Exec>
  </Actions>
</Task>}

$xmlinfo.Task.RegistrationInfo.Description = "Use custom key-mappings for brightness/volume/media control"
$xmlinfo.Task.RegistrationInfo.Author = $env:username
$xmlinfo.Task.Actions.Exec.Command = "cmd.exe"
$xmlinfo.Task.Actions.Exec.Arguments = "/c start ""BrightKeyMap"" ""$env:programfiles\BrightKeyMap\BrightKeyMap.exe"""
$xmlinfo.Save("$env:systemdrive\task.xml")
schtasks.exe /create /f /tn "BrightKeyMap" /xml "$env:systemdrive\task.xml" |Out-Null
if (Test-Path "$env:systemdrive\task.xml"){Remove-Item "$env:systemdrive\task.xml"}

rm "BrightKeyMap.ahk" -ErrorAction Ignore
Copy-Item blank_MappedKeys.ahk "BrightKeyMap.ahk"
$Master = ""
Write-Host "=== Configure Brightness/Volume/Media keys ===`n- For function keys, type the letter `"F`" followed by the number (e.g., `"F11`").`n- These won't overwrite existing buttons mapped to brightness/volume/media functions.`n- Leave the field blank if you don't want to add a button for it.`n- Reference this list for assigning non-alphanumeric keys (e.g., `"{PgUp}`"): https://gist.github.com/csharpforevermore/11348986`n"
$BrightDown = Read-Host "Enter your desired `'Brightness Down`' key"
if ($BrightDown -ne ""){
    $Master = $BrightDown + "::BrightnessSetter.SetBrightness`(-5`)"
    }
$BrightUp = Read-Host "Enter your desired `'Brightness Up`' key"
if ($BrightUp -ne ""){
    $Master = $Master + "`n" + $BrightUp + "::BrightnessSetter.SetBrightness`(+5`)"
    }
$PlayPrev = Read-Host "Enter your desired `'Play Previous`' (<<) key"
if ($PlayPrev -ne ""){
    $Master = $Master + "`n" + "$PlayPrev" + "::Send {Media_Prev}"
    }
$PlayPause = Read-Host "Enter your desired `'Play/Pause`' key"
if ($PlayPause -ne ""){
    $Master = $Master + "`n" + $PlayPause + "::Send {Media_Play_Pause}"
    }
$PlayNext = Read-Host "Enter your desired `'Play Next`' (>>) key"
if ($PlayNext -ne ""){
    $Master = $Master + "`n" + $PlayNext + "::Send {Media_Next}"
    }
$VolMute = Read-Host "Enter your desired `'Mute`' key"
if ($VolMute -ne ""){
    $Master = $Master + "`n" + $VolMute + "::Send {Volume_Mute}"
    }
$VolDown = Read-Host "Enter your desired `'Volume Down`' key"
if ($VolDown -ne ""){
    $Master = $Master + "`n" + $VolDown + "::Send {Volume_Down}"
    }
$VolUp = Read-Host "Enter your desired `'Volume Up`' key"
if ($VolUp -ne ""){
    $Master = $Master + "`n" + $VolUp + "::Send {Volume_Up}"
    }
Add-Content BrightKeyMap.ahk $Master

rm "BrightKeyMap.exe" -ErrorAction Ignore
Invoke-Expression "& `"Compiler\Ahk2Exe.exe`"  /in `"BrightKeyMap.ahk`" /icon `"brightness.ico`""
Write-Host "`nCompiling..."
Start-Sleep -Seconds 5

Start-ScheduledTask -TaskName "BrightKeyMap"

rm "BrightKeyMap.ahk" -ErrorAction Ignore
rm "Compiler" -Recurse -ErrorAction Ignore
rm "blank_MappedKeys.ahk" -ErrorAction Ignore
rm "brightness.ico" -ErrorAction Ignore