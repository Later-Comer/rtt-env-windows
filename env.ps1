function  add_windows_terminate() {
    # env的配置
    $env = [PSCustomObject]@{
        commandline = "`"$env:windir\System32\cmd.exe`" /K `"$PSScriptRoot\init.bat`"";
        guid        = "{c06ccb37-4fca-4609-b969-30aa1b3d8549}";
        hidden      = $false;
        # icon              = "";
        name        = "RT-Thread ENV Windows";
        # source            = "RT-Thread.Env-Windows";
        # startingDirectory = "";
    }

    # C:\Users\xxx\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
    $wt_setting_file = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

    if (Test-Path "$wt_setting_file") { 
        # 读取wt的配置文件
        $wt_setting = (Get-Content "$wt_setting_file" -Raw)  | ConvertFrom-Json

        # 移除guid一样的配置，然后将env添加到末尾
        $wt_setting.profiles.list = $wt_setting.profiles.list.where({ $env.guid -ne $_.guid }) + $env 
        
        # 将env设置为默认终端
        $wt_setting.defaultProfile = $env.guid
        
        #  将wt配置写入到文件
        $wt_setting | ConvertTo-Json -Depth 10  | Set-Content -Path $wt_setting_file
    }
}

function add_context_menu() {

}

#=======================================================================
# determine timezone
#=======================================================================

$tz = Get-TimeZone

if ($tz.BaseUtcOffset.TotalHours -eq 8 `
        -or "$1" -eq "--gitee" `
        -or "$1" -eq "--china") {
    $python_amd64_url = "https://registry.npmmirror.com/-/binary/python/3.12.3/python-3.12.3-amd64.exe"
    $git_for_windows_url = "https://registry.npmmirror.com/-/binary/git-for-windows/v2.44.0.windows.1/MinGit-2.44.0-64-bit.zip"

    $rtt_pkg_url = "https://gitee.com/RT-Thread-Mirror/packages.git"
    $rtt_sdk_url = "https://github.com/RT-Thread-Mirror/sdk.git"
    $rtt_env_url = "https://gitee.com/RT-Thread-Mirror/env.git"
    $rtt_env_url = "https://gitee.com/latercomer/rtt-env.git"

} else {
    $python_amd64_url = "https://www.python.org/ftp/python/3.12.3/python-3.12.3-amd64.exe"
    $git_for_windows_url = "https://registry.npmmirror.com/-/binary/git-for-windows/v2.44.0.windows.1/MinGit-2.44.0-64-bit.zip"

    $rtt_pkg_url = "https://github.com/rt-thread/packages.git"
    $rtt_sdk_url = "https://github.com/rt-thread/sdk.git"
    # $rtt_env_url = "https://github.com/rt-thread/env.git"
    $rtt_env_url = "https://gitee.com/latercomer/rtt-env.git"
}

#=======================================================================
# create or activate venv
#=======================================================================

$python = "$PSScriptRoot\program\python\python-3.11.9-amd64\python.exe"
$venv = "$PSScriptRoot\.venv"
if (-not (Test-Path -Path $venv)) {
    & $python -m pip uninstall pip -y
    & $python -m ensurepip
    Write-Host "Create Python venv for RT-Thread..."
    & $python -m venv $venv
    Write-Host "Activate Python venv in $venv"
    & "$venv\Scripts\Activate.ps1"
    Write-Host "Install RT-Thread Env from $venv"
    pip install "git+$rtt_env_url"
} else {
    Write-Host "Activate Python venv in $venv"
    & "$venv\Scripts\Activate.ps1" 
}

#=======================================================================
# prepare env variable
#======================================================================= 

# python
# $env:PYTHONHOME = "$PSScriptRoot\program\python\python-3.11.9-amd64"
# $env:PATH = "$env:PYTHONHOME;$env:PYTHONHOME\Scripts;$env:PATH"
# gcc
$env:GCC_ARM_HOME = "$PSScriptRoot\program\gcc\gcc-arm-none-eabi-10.3-2021.10"
$env:GCC_EXEC_PATH = "$env:GCC_ARM_HOME\bin"
$env:RTT_EXEC_PATH = "$env:GCC_EXEC_PATH"
$env:RTT_CC = "gcc"
$env:PATH = "$env:GCC_EXEC_PATH;$env:PATH"
# qemu
$env:QEMU_HOME = "$PSScriptRoot\program\qemu\qemu-w64-v8.2.0"
$env:PATH = "$env:QEMU_HOME;$env:PATH"
# git
$env:PATH = "$PSScriptRoot\program\git\git-2.41.0-32-bit\cmd;$env:PATH"
# fatdisk
$env:PATH = "$PSScriptRoot\program\fatdisk;$env:PATH"

# other env variable
$env:ENV_ROOT = "$PSScriptRoot"
$env:ENV_SETTGING_PATH = "$PSScriptRoot\configure"
$env:ENV_DOWNLOAD_PATH = "$PSScriptRoot\downlaod"
$env:ENV_MANIFESTS_PATH = "$PSScriptRoot\manifests"
$env:ENV_PROGRAM_PATH = "$PSScriptRoot\program"
# pkgs相关路径
$env:PKGS_INDEX_ROOT = "$PSScriptRoot\manifests"
$env:PKGS_ROOT = "$PSScriptRoot\manifests"
$env:PKGS_DIR = "$PSScriptRoot\manifests"
# sdk相关路径
$env:SDK_INDEX_ROOT = "$PSScriptRoot\manifests\sdk"

# 添加ps1扩展名
$env:pathext = ".ps1;$env:pathext"


