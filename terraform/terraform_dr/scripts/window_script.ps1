Write-Host "turn off PowerShell execution policy restrictions"
Set-ExecutionPolicy -ExecutionPolicy Unrestricted


# install python
Write-Host "Install Python"

$python_url = "https://www.python.org/ftp/python/3.8.5/python-3.8.5-amd64.exe"

$python_installer = "C:\python-3.8.5-amd64.exe"

Invoke-WebRequest -Uri $python_url -OutFile $python_installer

Start-Process -FilePath $python_installer -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait

#install .net framework 4.0 <
Write-Host "Install .NET Framework 4.0"

$dotnet_url = "https://download.microsoft.com/download/9/5/A/95A9616B-7A37-4AF6-BC36-D6EA96C8DAAE/dotNetFx40_Full_x86_x64.exe"

$dotnet_installer = "C:\dotNetFx40_Full_x86_x64.exe"

Invoke-WebRequest -Uri $dotnet_url -OutFile $dotnet_installer

Start-Process -FilePath $dotnet_installer -ArgumentList "/q" -Wait

#firewall rule ansible

Write-Host "Create a new firewall rule for ansible"

netsh advfirewall firewall add rule name="ansible" dir=in action=allow protocol=TCP localport=5986
