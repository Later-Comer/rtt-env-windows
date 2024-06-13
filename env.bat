@echo off
:: Do not repeat run
if not "%ENV_ROOT%" == "" goto end


:: ====== RT-Thread ENV Change Code Page ================

chcp 65001 > nul
rem python %~dp0..\scripts\env.py -v
echo RT-Thread Env Tool (ConEmu) Version 1.5.2
echo  ^\ ^| /
echo - RT -     Thread Operating System
echo  / ^| ^\
echo 2006 - 2024 Copyright by RT-Thread team


Setlocal ENABLEDELAYEDEXPANSION
:: 启用命令扩展，参加setlocal /?命令
set str1=%~dp0
set str=%str1%
set env_root=%~dp0

:next
if not "%str%"=="" (
set /a num+=1
if "!str:~0,1!"==" " (
    echo.
    echo *******************************************************************
    echo Env 工具所在路径如下：
    echo %env_root:~0,-21%
    echo 警告：以上路径不能包含中文或空格，请将 Env 移动到符合要求的路径中。
    echo *******************************************************************
    endlocal
    goto break_str
)
set "str=%str:~1%"
goto next
)
endlocal

set "str=%~dp0"
>"%tmp%\t.t" echo;WSH.Echo(/[\u4E00-\u9FFF]/.test(WSH.Arguments(0)))
for /f %%a in ('cscript -nologo -e:jscript "%tmp%\t.t" "%str%"') do if %%a neq 0 (goto not_support_chinese) else goto break_str

:not_support_chinese
echo.
echo *******************************************************************
echo Env 工具所在路径如下：
echo %env_root:~0,-29%
echo 警告：以上路径不能包含中文或空格，请将 Env 移动到符合要求的路径中。
echo *******************************************************************

:break_str
set str=
chcp 437 > nul


:: =================== RT-Thread ENV Activate venv ============================

set RTT_ENV_URL=https://github.com/rt-thread/env
set VENV_ROOT="%~dp0\.venv"
echo.
if not exist %VENV_ROOT% (
    echo Create Python venv for RT-Thread
    python -m venv %VENV_ROOT%
    echo activate rt-thread venv in %VENV_ROOT% 
    call %VENV_ROOT%\Scripts\activate.bat
    echo install env from %RTT_ENV_URL%
    pip install git+%RTT_ENV_URL%
) else (
    echo activate rt-thread venv in %VENV_ROOT%
    call %VENV_ROOT%\Scripts\activate.bat
)


:: ============= RT-Thread ENV Add Path ==================

set ENV_ROOT=%~dp0
set PYTHONPATH=%ENV_ROOT%\program\python\python-3.11.9-amd64
set PYTHONHOME=%ENV_ROOT%\program\python\python-3.11.9-amd64
set RTT_EXEC_PATH=%ENV_ROOT%\program\gcc\gcc-arm-none-eabi-10.3-2021.10\bin
set RTT_CC=gcc
set PKGS_ROOT=%ENV_ROOT%\manifests\packages
:: Add to %PATH%
set path="%ENV_ROOT%\program\git\git-2.41.0-32-bit\cmd";%path%
set path="%ENV_ROOT%\program\bin";%path%
set path="%RTT_EXEC_PATH%";%path%
set path="%PYTHONHOME%";%path%
set path="%PYTHONHOME%\Scripts";%path%
set path="%ENV_ROOT%\program\qemu\qemu-w64-8.0.94";%path%

goto end


:: ============= Add Path Unique ==================

:: 不重复添加路径到 %PATH% 中
:AddPath
setlocal enabledelayedexpansion
set "new_path=%~1"

:: 将相对路径转换为绝对路径
for %%A in ("%new_path%") do set "new_path=%%~fA"

:: 检查 %PATH% 是否已经包含了要添加的路径
echo %PATH% | findstr /i /c:"%new_path%;" >nul
if errorlevel 1 (
    set "PATH=%new_path%;%PATH%"
) else (
    :: 如果已经包含则将路径移动到 %PATH% 的最前面
    set "PATH=!new_path!;!PATH:%new_path%;=!"
)

endlocal & set "PATH=%PATH%"
goto:eof

:end
rem if "%ConEmuBaseDir%" == "" (
rem     %ENV_ROOT%\tools\ConEmu\ConEmu\clink\clink.bat inject
rem )



cmd /k