@rem Description: pe install script, Platform:ARM64
@echo off

echo 正在为您进行设置，请勿关闭命令行窗口，否则会导致虚拟机部分功能不可用

@REM close cmd QuickEdit
reg add HKEY_CURRENT_USER\Console /v QuickEdit /t REG_DWORD /d 00000000 /f >null

@REM add reg to pass check
reg add HKLM\System\Setup\LabConfig\ /f >null
reg add HKLM\System\Setup\LabConfig /v BypassTPMCheck /t REG_DWORD /d 1 /f >null
reg add HKLM\System\Setup\LabConfig /v BypassSecureBootCheck /t REG_DWORD /d 1 /f  >null

@REM add reg to incre timeout
reg add HKLM\System\CurrentControlSet\Services\disk /v TimeoutValue /t REG_DWORD /d 60 /f >null

@REM add drivers before windows install
FOR %%I IN (A D E F G H I J K L N M O P Q R S T U V W X Y Z) DO (
    IF EXIST %%I:\driver\driver0 (
        XCOPY /E %%I:\driver\driver0 %WINDIR%\Temp\driver0\
        cd %WINDIR%\Temp\driver0
    )
) >null