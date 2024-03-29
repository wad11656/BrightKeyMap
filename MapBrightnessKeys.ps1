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

Stop-Process -Name "BrightKeyMap" -Force -ErrorAction Ignore
schtasks.exe /End /tn "BrightKeyMap" |Out-Null
schtasks.exe /Delete /f /tn "BrightKeyMap" |Out-Null

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
Write-Host "=== Configure Brightness/Volume/Media keys ===`n- For function keys, type the letter `"F`" followed by the number (e.g., `"F11`").`n- Keys you assign will not overwrite already-existing brightness/volume/media keys.`n- Leave the field blank if you don't want to add a button for it.`n- Reference this list for assigning non-alphanumeric keys (e.g., `"PgUp`"):`nhttps://gist.github.com/csharpforevermore/11348986`n(Remove any curly braces when you enter them below.)`n"
Write-Host "`First, let's configure a substitute `"Fn`" key for any Function keys you configure.`n(Sorry, AutoHotKey often doesn't recognize keyboards' `"Fn`" key, so we assign a substitute.)`n`nYou'll hold this key down while pressing your Function keys to trigger their normal operation.`n(Hint: Common choices would be `"Ctrl`", `"Alt`", `"LWin`", or `"RWin`".)`n(`"LWin`" & `"Rwin`" = Left & Right Windows/Special/Command keys, respectively.)`n"
Write-Host "(REMINDER: You can skip any of these by just pressing Enter.)"
$FnAlt = Read-Host "Enter your desired `"Fn`" key substitute"
if ($FnAlt -ne ""){
    $Master = $FnAlt + " & F1::Send, {F1}"
    for (($i = 2); $i -lt 13; $i++)
    {
        $Master = $Master + "`n" + $FnAlt + " & F" + $i + "::Send, {F" + $i + "}"
    }
    $Master = $Master + "`n`n#If !GetKeyState(`"" + $FnAlt + "`", `"P`")"
}
$BrightDown = Read-Host "Enter your desired `"Brightness Down`" key"
if ($BrightDown -ne ""){
    $Master = $Master + "`n" + $BrightDown + "::BrightnessSetter.SetBrightness`(-5`)"
}
$BrightUp = Read-Host "Enter your desired `"Brightness Up`" key"
if ($BrightUp -ne ""){
    $Master = $Master + "`n" + $BrightUp + "::BrightnessSetter.SetBrightness`(+5`)"
}
$PlayPrev = Read-Host "Enter your desired `"Play Previous`" (<<) key"
if ($PlayPrev -ne ""){
    $Master = $Master + "`n" + "$PlayPrev" + "::Send {Media_Prev}"
}
$PlayPause = Read-Host "Enter your desired `"Play/Pause`" key"
if ($PlayPause -ne ""){
    $Master = $Master + "`n" + $PlayPause + "::Send {Media_Play_Pause}"
}
$PlayNext = Read-Host "Enter your desired `"Play Next`" (>>) key"
if ($PlayNext -ne ""){
    $Master = $Master + "`n" + $PlayNext + "::Send {Media_Next}"
}
$VolMute = Read-Host "Enter your desired `"Mute`" key"
if ($VolMute -ne ""){
    $Master = $Master + "`n" + $VolMute + "::Send {Volume_Mute}"
}
$VolDown = Read-Host "Enter your desired `"Volume Down`" key"
if ($VolDown -ne ""){
    $Master = $Master + "`n" + $VolDown + "::Send {Volume_Down}"
}
$VolUp = Read-Host "Enter your desired `"Volume Up`" key"
if ($VolUp -ne ""){
    $Master = $Master + "`n" + $VolUp + "::Send {Volume_Up}"
}
if ($FnAlt -ne ""){
    $Master = $Master + "`n#If"
}
Add-Content BrightKeyMap.ahk $Master

rm "BrightKeyMap.exe" -ErrorAction Ignore
Invoke-Expression "& `"AHK_Compiler\Ahk2Exe.exe`"  /in `"BrightKeyMap.ahk`" /icon `"brightness.ico`""
Write-Host "`nCompiling..."
Start-Sleep -Seconds 5

Start-ScheduledTask -TaskName "BrightKeyMap"

rm "BrightKeyMap.ahk" -ErrorAction Ignore
rm "AHK_Compiler" -Recurse -ErrorAction Ignore
rm "blank_MappedKeys.ahk" -ErrorAction Ignore
rm "brightness.ico" -ErrorAction Ignore