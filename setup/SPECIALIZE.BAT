@rem Description: specialize install script, Platform:ARM64
@echo off

echo 正在为您进行设置，请勿关闭命令行窗口，否则会导致虚拟机部分功能不可用

mkdir %PROGRAMDATA%\VMAgent
mkdir %PROGRAMDATA%\VMAgent\log
mkdir %PROGRAMDATA%\VMAgent\config
mkdir %PROGRAMDATA%\VMAgent\update
@REM for ico files
mkdir %PROGRAMDATA%\VMAgent\resource

@REM Disable CEIP
schtasks /Change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Disable >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM *******************
@REM ***** VMAgent *****
@REM *******************
@REM cacls Path
echo y|cacls %PROGRAMDATA%\VMAgent /c /t /p "SYSTEM":F "Administrators":F Users:R >>%PROGRAMDATA%\VMAgent\log\setup.log
@REM Prepare Paths
mkdir %PROGRAMDATA%\VMGT
mkdir %PROGRAMDATA%\VMGT\log
mkdir %PROGRAMDATA%\WinEvtMonitor
mkdir %PROGRAMDATA%\WinEvtMonitor\log
@REM cacls Path
echo y|cacls %PROGRAMDATA%\VMGT /c /t /p "SYSTEM":F "Administrators":F Users:R >>%PROGRAMDATA%\VMAgent\log\setup.log
@REM cacls Path
echo y|cacls %PROGRAMDATA%\WinEvtMonitor /c /t /p "SYSTEM":F "Administrators":F Users:R >>%PROGRAMDATA%\VMAgent\log\setup.log
@REM Copy Drivers and VMAgent
FOR %%I IN (A D E F G H I J K L N M O P Q R S T U V W X Y Z) DO (
    IF EXIST %%I:\driver\driver.zip (
        COPY %%I:\driver\driver.zip %PROGRAMDATA%\VMAgent\
        COPY %%I:\agent_service.exe %PROGRAMDATA%\VMAgent\
        COPY %%I:\update\update_confirm.exe %PROGRAMDATA%\VMAgent\update
        COPY %%I:\update\update_bar.exe %PROGRAMDATA%\VMAgent\update
        COPY %%I:\config\PerfSoftwareList.json %PROGRAMDATA%\VMAgent\config\
        COPY %%I:\config\installationList.json %PROGRAMDATA%\VMAgent\config\
        COPY %%I:\config\AutoPauseList.json %PROGRAMDATA%\VMAgent\config\
        COPY %%I:\win_evt_monitor\win_evt_monitor.exe %PROGRAMDATA%\WinEvtMonitor\
    )
) >>%PROGRAMDATA%\VMAgent\log\setup.log
@REM Install Signed Drivers
tar -xf %PROGRAMDATA%\VMAgent\driver.zip -C %PROGRAMDATA%\VMAgent
cd %PROGRAMDATA%\VMAgent\driver1
pnputil.exe /add-driver *.inf /subdirs /install >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM ***********************
@REM ***** performance *****
@REM ***********************
@REM Prepare Paths
mkdir %PROGRAMDATA%\performance
echo y|cacls %PROGRAMDATA%\performance /c /t /p "SYSTEM":F "Administrators":F Users:R >>%PROGRAMDATA%\VMAgent\log\setup.log
FOR %%I IN (A D E F G H I J K L N M O P Q R S T U V W X Y Z) DO (
    IF EXIST %%I:\performance\process_monitor.dll (
        COPY %%I:\performance\process_monitor.dll %PROGRAMDATA%\performance\
        COPY %%I:\performance\wndtext_fetch_helper.exe %PROGRAMDATA%\performance\
        COPY %%I:\performance\application_window_helper.exe %PROGRAMDATA%\performance\
        COPY %%I:\performance\pre_process_wndcontrol.exe %PROGRAMDATA%\performance\
        COPY %%I:\performance\ps_process_control.exe %PROGRAMDATA%\performance\
        COPY %%I:\performance\ps_hide_window.dll %PROGRAMDATA%\performance\
        COPY %%I:\performance\VisualEffectsEdit.exe %PROGRAMDATA%\performance\
        COPY %%I:\performance\PreloadHelper.exe %PROGRAMDATA%\performance\
        COPY %%I:\performance\perf.cfg %PROGRAMDATA%\performance\
        @REM Install VC redist
        %%I:\performance\VC_redist.arm64.exe /quiet /norestart
    )
) >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM setMpPreference
powershell "Set-MpPreference -ScanAvgCPULoadFactor 5"
powershell "Set-MpPreference -ServiceHealthReportInterval 14400"
powershell "Set-MpPreference -DisableCpuThrottleOnIdleScans $false"
powershell "Set-MpPreference -DisableScanningMappedNetworkDrivesForFullScan $true"
powershell "Set-MpPreference -ScanOnlyIfIdleEnabled $true"
powershell "Set-MpPreference -EnableFullScanOnBatteryPower $false"
powershell "Set-MpPreference -ScanScheduleDay 8"
powershell "Set-MpPreference -RemediationScheduleDay 8"
powershell "Set-MpPreference -ExclusionProcess %PROGRAMDATA%\VMAgent\agent_service.exe,%PROGRAMDATA%\display\display.exe,%PROGRAMDATA%\performance\ps_hide_window.dll,%PROGRAMDATA%\performance\ps_process_control.exe,%PROGRAMDATA%\performance\wndtext_fetch_helper.exe,%PROGRAMDATA%\performance\application_window_helper.exe,%PROGRAMDATA%\performance\pre_process_wndcontrol.exe,%PROGRAMDATA%\VMAgent\driver1\viogpu\vmgtsharemgr.exe,%PROGRAMDATA%\VMAgent\driver1\viogpu\vmgtsrv.exe"


@REM *******************
@REM ***** display *****
@REM *******************
@REM Prepare Paths
mkdir %PROGRAMDATA%\display
@REM cacls Path
echo y|cacls %PROGRAMDATA%\display /c /t /p "SYSTEM":F "Administrators":F Users:R >>%PROGRAMDATA%\VMAgent\log\setup.log
@REM Copy display and svga adapter
FOR %%I IN (A D E F G H I J K L N M O P Q R S T U V W X Y Z) DO (
    IF EXIST %%I:\display\display.exe (
        COPY %%I:\display\display.exe %PROGRAMDATA%\display\
        COPY %%I:\display\svga_adapter.dll %PROGRAMDATA%\display\
        COPY %%I:\display\svga_adapter_x64.dll %PROGRAMDATA%\display\
    )
) >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM @REM ********************
@REM @REM **** app filter ****
@REM @REM ********************
@REM @REM Prepare Paths
@REM mkdir %PROGRAMDATA%\AppFilter
@REM echo y|cacls %PROGRAMDATA%\AppFilter /c /t /p "SYSTEM":F "Administrators":F Users:R >>%PROGRAMDATA%\VMAgent\log\setup.log
@REM @REM Copy app filter
@REM FOR %%I IN (A D E F G H I J K L N M O P Q R S T U V W X Y Z) DO (
@REM     IF EXIST %%I:\app_filter\FilterAgent.exe (
@REM         COPY %%I:\app_filter\config.json %PROGRAMDATA%\AppFilter\
@REM         COPY %%I:\app_filter\FilterAgent.exe %PROGRAMDATA%\AppFilter\
@REM     )
@REM ) >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM *******************
@REM **** resource *****
@REM *******************
@REM Copy shared folder ico
FOR %%I IN (A D E F G H I J K L N M O P Q R S T U V W X Y Z) DO (
    IF EXIST %%I:\resource\hm_folder.ico (
        COPY %%I:\resource\hm_folder.ico %PROGRAMDATA%\VMAgent\resource\
    )
) >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM set first flag
reg add HKLM\System\Setup /v FirstStart /t REG_DWORD /d 1 /f >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM timezone settings
reg add HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation /v RealTimeIsUniversal /t REG_DWORD /d 1 /f >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM network share permissions
reg add HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLinkedConnections /t REG_DWORD /d 1 /f >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM windows service tailor
reg add HKLM\SYSTEM\CurrentControlSet\Services\BITS /v Start /t REG_DWORD /d 3 /f >>%PROGRAMDATA%\VMAgent\log\setup.log
reg add HKLM\SYSTEM\CurrentControlSet\Services\DiagTrack /v Start /t REG_DWORD /d 4 /f >>%PROGRAMDATA%\VMAgent\log\setup.log
reg add HKLM\SYSTEM\CurrentControlSet\Services\DPS /v Start /t REG_DWORD /d 4 /f >>%PROGRAMDATA%\VMAgent\log\setup.log
reg add HKLM\SYSTEM\CurrentControlSet\Services\DusmSvc /v Start /t REG_DWORD /d 4 /f >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM io settings
reg add HKLM\SYSTEM\CurrentControlSet\Services\disk /v TimeoutValue /t REG_DWORD /d 60 /f >>%PROGRAMDATA%\VMAgent\log\setup.log
reg add HKLM\SYSTEM\CurrentControlSet\Services\viostor\Parameters /v IoTimeOutValue /t REG_DWORD /d 60 /f >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM no new network block
reg add HKLM\System\CurrentControlSet\Control\Network\NewNetworkWindowOff /f >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM install viogpu
%PROGRAMDATA%\VMAgent\driver1\viogpu\vmgtsrv.exe -i >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM open crashdump
reg add HKLM\SYSTEM\CurrentControlSet\Control\CrashControl /v CrashDumpEnabled /t REG_DWORD /d 1 /f >>%PROGRAMDATA%\VMAgent\log\setup.log
@REM agent_service dump
reg add "HKLM\Software\Microsoft\Windows\Windows Error Reporting\LocalDumps\agent_service.exe" /f >>%PROGRAMDATA%\VMAgent\log\setup.log
reg add "HKLM\Software\Microsoft\Windows\Windows Error Reporting\LocalDumps\agent_service.exe" /v DumpFolder /t REG_EXPAND_SZ /d "%PROGRAMDATA%\VMAgent\log" /f >>%PROGRAMDATA%\VMAgent\log\setup.log
reg add "HKLM\Software\Microsoft\Windows\Windows Error Reporting\LocalDumps\agent_service.exe" /v DumpType /t REG_DWORD /d 1 /f >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM allow insecure guest auth
reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation /v AllowInsecureGuestAuth /t REG_DWORD /d 1 /f >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM set first enable2D flag
reg add HKLM\System\Setup /v FirstEnabled2D /t REG_DWORD /d 1 /f >>%PROGRAMDATA%\VMAgent\log\setup.log
