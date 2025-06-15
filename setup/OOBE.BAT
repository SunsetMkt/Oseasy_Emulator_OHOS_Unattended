@rem Description: oobe install script, Platform:ARM64
@echo off

echo 正在为您进行设置，请勿关闭命令行窗口，否则会导致虚拟机部分功能不可用

@REM password never expire
net accounts /maxpwage:unlimited >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM autologon
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoLogonCount /t REG_DWORD /d 0 /f >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM no show start menu
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v StartShownOnUpgrade /t REG_DWORD /d 1 /f >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM disable onedrive
reg add HKCU\Software\Microsoft\OneDrive /v UserInitiatedUninstall /t REG_DWORD /d 1 /f >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM monitor settings
reg add "HKCU\Control Panel\Desktop" /v MonitorRemovalRecalcBehavior /t REG_DWORD /d 1 /f >>%PROGRAMDATA%\VMAgent\log\setup.log
reg add "HKCU\Control Panel\Desktop" /v RestorePreviousStateRecalcBehavior /t REG_DWORD /d 1 /f >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM touch keyboard default size
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\scaling" /v Monitorsize /t REG_SZ /d "11" /f >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM vmagent settings
sc create vmagent binpath= %PROGRAMDATA%\VMAgent\agent_service.exe type= own type= interact start= auto displayname= vmagent >>%PROGRAMDATA%\VMAgent\log\setup.log
sc failure vmagent reset= 0 actions= restart/0/restart/0/restart/0

@REM ---BEGIN--- enabling high performance power settings
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\45bcc044-d885-43e2-8605-ee0ec6e96b59 /v "Attributes" /t REG_DWORD /d 2 /f >> %PROGRAMDATA%\VMAgent\log\setup.log
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\7f2f5cfa-f10c-4823-b5e1-e93ae85f46b5 /v "Attributes" /t REG_DWORD /d 2 /f >> %PROGRAMDATA%\VMAgent\log\setup.log
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\b0deaf6b-59c0-4523-8a45-ca7f40244114 /v "Attributes" /t REG_DWORD /d 2 /f >> %PROGRAMDATA%\VMAgent\log\setup.log

powercfg setdcvalueindex scheme_min sub_processor PERFBOOSTPOL 0x00000064 >> %PROGRAMDATA%\VMAgent\log\setup.log
powercfg setdcvalueindex scheme_min sub_processor HETEROPOLICY 0x00000000 >> %PROGRAMDATA%\VMAgent\log\setup.log
powercfg setdcvalueindex scheme_min sub_processor MODULEUNPARKPOLICY 0x00000001 >> %PROGRAMDATA%\VMAgent\log\setup.log
powercfg setacvalueindex scheme_min sub_processor PERFBOOSTPOL 0x00000064 >> %PROGRAMDATA%\VMAgent\log\setup.log
powercfg setacvalueindex scheme_min sub_processor HETEROPOLICY 0x00000000 >> %PROGRAMDATA%\VMAgent\log\setup.log
powercfg setacvalueindex scheme_min sub_processor MODULEUNPARKPOLICY 0x00000001 >> %PROGRAMDATA%\VMAgent\log\setup.log

powercfg S scheme_min >> %PROGRAMDATA%\VMAgent\log\setup.log
@REM ---END--- enabling high performance power settings

@REM windows never sleep
powercfg -change -monitor-timeout-ac 0 >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM windows fastboot on
powercfg /h type reduced >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM set power button action to turn-off
powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS PBUTTONACTION 3 >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM enable power button action
powercfg /setactive SCHEME_CURRENT >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM install driver2
cd %PROGRAMDATA%\VMAgent\driver2
pnputil.exe /add-driver *.inf /subdirs /install >>%PROGRAMDATA%\VMAgent\log\setup.log

call C:\ProgramData\VMAgent\driver2\scream\Install-arm64.bat >>%PROGRAMDATA%\VMAgent\log\setup.log
call C:\ProgramData\VMAgent\driver2\hwfs\install.cmd install >>%PROGRAMDATA%\VMAgent\log\setup.log
call C:\ProgramData\VMAgent\driver2\app_filter\install.cmd install >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM set scaling ratio 150%
reg add "HKCU\Control Panel\Desktop" /v LogPixels /t REG_DWORD /d 144 /f >>%PROGRAMDATA%\VMAgent\log\setup.log
reg add "HKCU\Control Panel\Desktop" /v Win8DpiScaling /t REG_DWORD /d 1 /f >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM auto start DPS service
sc config DPS start= auto >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM auto start DusmSvc service
sc config DusmSvc start= auto >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM turn off auto update
sc config wuauserv start= disabled >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM change to minidump
wmic RECOVEROS set DebugInfoType = 1 >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM restore classic file explorer with ribbon
reg add "HKCU\Software\Classes\CLSID\{2aa9162e-c906-4dd9-ad0b-3d24a8eef5a0}" /t REG_SZ /d "CLSID_ItemsViewAdapter" /f >>%PROGRAMDATA%\VMAgent\log\setup.log
reg add "HKCU\Software\Classes\CLSID\{2aa9162e-c906-4dd9-ad0b-3d24a8eef5a0}\InProcServer32" /t REG_SZ /d "C:\\Windows\\System32\\Windows.UI.FileExplorer.dll_" /f >>%PROGRAMDATA%\VMAgent\log\setup.log
reg add "HKCU\Software\Classes\CLSID\{2aa9162e-c906-4dd9-ad0b-3d24a8eef5a0}\InProcServer32" /v ThreadingModel /t REG_SZ /d "Apartment" /f >>%PROGRAMDATA%\VMAgent\log\setup.log
reg add "HKCU\Software\Classes\CLSID\{6480100b-5a83-4d1e-9f69-8ae5a88e9a33}" /t REG_SZ /d "File Explorer Xaml Island View Adapter" /f >>%PROGRAMDATA%\VMAgent\log\setup.log
reg add "HKCU\Software\Classes\CLSID\{6480100b-5a83-4d1e-9f69-8ae5a88e9a33}\InProcServer32" /t REG_SZ /d "C:\\Windows\\System32\\Windows.UI.FileExplorer.dll_" /f >>%PROGRAMDATA%\VMAgent\log\setup.log
reg add "HKCU\Software\Classes\CLSID\{6480100b-5a83-4d1e-9f69-8ae5a88e9a33}\InProcServer32" /v ThreadingModel /t REG_SZ /d "Apartment" /f >>%PROGRAMDATA%\VMAgent\log\setup.log
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f >>%PROGRAMDATA%\VMAgent\log\setup.log
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InProcServer32" /t REG_SZ /d "" /f >>%PROGRAMDATA%\VMAgent\log\setup.log
reg add "HKCU\Software\Microsoft\Internet Explorer\Toolbar\ShellBrowser" /f >>%PROGRAMDATA%\VMAgent\log\setup.log
reg add "HKCU\Software\Microsoft\Internet Explorer\Toolbar\ShellBrowser" /v ITBar7Layout /t REG_BINARY /d "13000000000000000000000020000000100001000000000001000000010700005e01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" /f >>%PROGRAMDATA%\VMAgent\log\setup.log
reg add "HKCU\Software\Policies\Microsoft\Windows\Explorer" /f >>%PROGRAMDATA%\VMAgent\log\setup.log
reg add "HKCU\Software\Policies\Microsoft\Windows\Explorer" /v ExplorerRibbonStartsMinimized /t REG_DWORD /d 3 /f >>%PROGRAMDATA%\VMAgent\log\setup.log
reg add "HKCU\Software\Microsoft\Internet Explorer\Toolbar" /v IsModified /t REG_DWORD /d 1 /f >>%PROGRAMDATA%\VMAgent\log\setup.log
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows" /v GDIProcessHandleQuota /t REG_DWORD /d 24000 /f >>%PROGRAMDATA%\VMAgent\log\setup.log
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows" /v USERProcessHandleQuota /t REG_DWORD /d 24000 /f >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM turn off transparency
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f >>%PROGRAMDATA%\VMAgent\log\setup.log
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /t REG_SZ /f >>%PROGRAMDATA%\VMAgent\log\setup.log
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v NoDispAppearancePage /t REG_DWORD /d 1 /f >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM edit visual effects
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 3 /f >> %PROGRAMDATA%\VMAgent\log\setup.log
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ListviewShadow /t REG_DWORD /d 0 /f >> %PROGRAMDATA%\VMAgent\log\setup.log
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAnimations /t REG_DWORD /d 0 /f >> %PROGRAMDATA%\VMAgent\log\setup.log
reg add "HKCU\Control Panel\Desktop" /v DragFullWindows /t REG_SZ /d "0" /f >> %PROGRAMDATA%\VMAgent\log\setup.log
reg add "HKCU\Control Panel\Desktop" /v UserPreferencesMask /t REG_BINARY /d 9012078010000000 /f >> %PROGRAMDATA%\VMAgent\log\setup.log

@REM edit TouchKeyboardTapInvoke
reg add "HKCU\Software\Microsoft\TabletTip\1.7" /v TouchKeyboardTapInvoke /t REG_DWORD /d 2 /f >> %PROGRAMDATA%\VMAgent\log\setup.log

@REM ---BEGIN--- changing UAC level to 2.
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 5 /f >> %PROGRAMDATA%\VMAgent\log\setup.log
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 1 /f >> %PROGRAMDATA%\VMAgent\log\setup.log
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v PromptOnSecureDesktop /t REG_DWORD /d 0 /f >> %PROGRAMDATA%\VMAgent\log\setup.log
@REM ---END--- change UAC level to 2.

@REM closing news and interests by default.
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v TaskbarDa /t REG_DWORD /d 0 /f >> %PROGRAMDATA%\VMAgent\log\setup.log

@REM edit network parameters
reg add "HKLM\SYSTEM\CurrentControlSet\Services\HTTP\Parameters" /v "EnableHttpKeepAlive" /t REG_DWORD /d 1 /f >> %PROGRAMDATA%\VMAgent\log\setup.log
reg add "HKLM\SYSTEM\CurrentControlSet\Services\HTTP\Parameters" /v "MaxConnections" /t REG_DWORD /d 296 /f >> %PROGRAMDATA%\VMAgent\log\setup.log
reg add "HKLM\SYSTEM\CurrentControlSet\Services\HTTP\Parameters" /v "EnableTcpTimedWaitDelay" /t REG_DWORD /d 1 /f >> %PROGRAMDATA%\VMAgent\log\setup.log
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpAckFrequency" /t REG_DWORD /d 1 /f >> %PROGRAMDATA%\VMAgent\log\setup.log
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "MaxUserPort" /t REG_DWORD /d 65534 /f >> %PROGRAMDATA%\VMAgent\log\setup.log

@REM edit microsoft store taskbar
reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "NoPinningStoreToTaskbar" /t REG_DWORD /d 1 /f >> %PROGRAMDATA%\VMAgent\log\setup.log

@REM edit edge , enable smooth scroll and parallel downloading
mkdir "%localappdata%\Microsoft\Edge\User Data"
echo {"browser":{"enabled_labs_experiments":["smooth-scrolling@1","windows-scrolling-personality@1","enable-parallel-downloading@1"]}}> "%localappdata%\Microsoft\Edge\User Data\Local State"

@REM edit chrome initilizing configuration to enabling smooth scroll and parallel downloading
mkdir "%localappdata%\Google\Chrome\User Data"
echo {"browser":{"enabled_labs_experiments":["smooth-scrolling@1","windows-scrolling-personality@1","enable-parallel-downloading@1"]}}> "%localappdata%\Google\Chrome\User Data\Local State"

@REM edit w32time
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\w32time\Config /v UtilizeSslTimeData /t REG_DWORD /d 0 /f

sc stop wuauserv
sc config wuauserv start= disabled
sc failure wuauserv reset=0 actions=0/0/0
sc stop UsoSvc
sc config UsoSvc start=disabled
sc failure UsoSvc reset=0 actions=0/0/0
sc config BITS start= disabled
sc stop BITS
sc stop WaaSMedicSvc
sc config WaaSMedicSvc start=disabled
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v "FailureActions" /t REG_BINARY /d "000000000000000000000000" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DisableOSUpgrade" /t REG_DWORD /d "1" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d "1" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d "1" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "ScheduledInstallDay" /t REG_DWORD /d "0" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "ScheduledInstallTime" /t REG_DWORD /d "3" /f

@REM Copy clear wallpaper
copy "C:\Windows\Web\Wallpaper\Windows\img19.jpg" "%appdata%\Microsoft\Windows\Themes" >> %PROGRAMDATA%\VMAgent\log\setup.log

@REM Delete obscure wallpaper cache
del "%appdata%\Microsoft\Windows\Themes\TranscodedWallpaper" >> %PROGRAMDATA%\VMAgent\log\setup.log

@REM edit wallpaper
ren "%appdata%\Microsoft\Windows\Themes\img19.jpg" "TranscodedWallpaper" >> %PROGRAMDATA%\VMAgent\log\setup.log

@REM upgrade agent, maintain has upgraded flags.
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\VMConfig\Explorer\Advanced" /v ListviewAlphaSelect /t REG_SZ /d "1" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\VMConfig\Explorer\Advanced" /v TaskbarDa /t REG_SZ /d "1" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\VMConfig\Explorer\scaling" /v Monitorsize /t REG_SZ /d "1" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\VMConfig\\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d "1" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\VMConfig\TabletTip\1.7" /v TouchKeyboardTapInvoke /t REG_SZ /d "1" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\VMConfig\HTTP\Parameters" /v EnableHttpKeepAlive /t REG_SZ /d "1" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\VMConfig\HTTP\Parameters" /v MaxConnections /t REG_SZ /d "1" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\VMConfig\HTTP\Parameters" /v EnableTcpTimedWaitDelay /t REG_SZ /d "1" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\VMConfig\Tcpip\Parameters" /v TcpAckFrequency /t REG_SZ /d "1" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\VMConfig\Tcpip\Parameters" /v MaxUserPort /t REG_SZ /d "1" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\VMConfig\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_SZ /d "1" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\VMConfig\Policies\System" /v EnableLUA /t REG_SZ /d "1" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\VMConfig\Policies\System" /v PromptOnSecureDesktop /t REG_SZ /d "1" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\VMConfig\Edge\UserData" /v LocalState /t REG_SZ /d "1" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\VMConfig\Chrome\UserData" /v LocalState /t REG_SZ /d "1" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\VMConfig\Windows\Themes" /v TranscodedWallpaper /t REG_SZ /d "1" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\VMConfig\display" /v display /t REG_SZ /d "1" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\VMConfig\WinEvtMonitor" /v WinEvtMonitor /t REG_SZ /d "1" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\VMConfig\AppFilter" /v AppFilter /t REG_SZ /d "1" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\VMConfig\Windows\Themes" /v TranscodedWallpaper1 /t REG_SZ /d "1" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\VMConfig\Windows\Themes" /v TranscodedWallpaper2 /t REG_SZ /d "1" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\VMConfig\Windows\Themes" /v TranscodedWallpaper3 /t REG_SZ /d "1" /f


@REM mkdir c:\public\desktop\鸿蒙共享文件夹
mkdir "C:\Users\Public\Desktop\鸿蒙共享文件夹" >> %PROGRAMDATA%\VMAgent\log\setup.log
echo y|cacls "C:\Users\Public\Desktop\鸿蒙共享文件夹" /c /t /p "SYSTEM":F "Administrators":F Users:R >>%PROGRAMDATA%\VMAgent\log\setup.log

@REM 文件夹图标设置成大图标
FOR %%I IN (A D E F G H I J K L N M O P Q R S T U V W X Y Z) DO (
    IF EXIST %%I:\share_folder.reg (
        reg import %%I:\share_folder.reg >>%PROGRAMDATA%\VMAgent\log\setup.log
    )
)

powershell -Command "& { $SharedFolder = 'C:\Users\Public\Desktop\鸿蒙共享文件夹'; $objShell = New-Object -ComObject Shell.Application; $objShell.Namespace($SharedFolder).Self.InvokeVerb('PinToHome') }" >> %PROGRAMDATA%\VMAgent\log\setup.log 2>&1

@REM 重新排列桌面图标
FOR %%I IN (A D E F G H I J K L N M O P Q R S T U V W X Y Z) DO (
    IF EXIST %%I:\ArrangeDesktopIcons.exe (
        %%I:\ArrangeDesktopIcons.exe
    )
)

@REM install OETool
mkdir "c:\Program Files\oetool"
echo y|cacls "c:\Program Files\oetool" /c /t /p "SYSTEM":F "Administrators":F Users:R >>%PROGRAMDATA%\VMAgent\log\setup.log
mkdir "c:\ProgramData\oetool"
echo y|cacls "c:\ProgramData\oetool" /c /t /p "SYSTEM":F "Administrators":F Users:R >>%PROGRAMDATA%\VMAgent\log\setup.log
FOR %%I IN (A D E F G H I J K L N M O P Q R S T U V W X Y Z) DO (
    IF EXIST %%I:\OEToolsetup.exe (
        %%I:\OEToolsetup.exe /S /FirstStart=1
    )
)
sc failure oetool reset= 0 actions= restart/0/restart/0/restart/0
net start vmagent >>%PROGRAMDATA%\VMAgent\log\setup.log
