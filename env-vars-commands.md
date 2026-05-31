# Windows PowerShell 环境变量命令

## 当前会话

创建或修改环境变量：

```powershell
$env:NAME = "value"
```

查看单个环境变量：

```powershell
$env:NAME
```

查看所有环境变量：

```powershell
Get-ChildItem Env:
```

删除当前会话环境变量：

```powershell
Remove-Item Env:NAME
```

## 持久化环境变量

设置用户级环境变量：

```powershell
[System.Environment]::SetEnvironmentVariable("NAME", "value", "User")
```

设置系统级环境变量：

```powershell
[System.Environment]::SetEnvironmentVariable("NAME", "value", "Machine")
```

查看用户级环境变量：

```powershell
[System.Environment]::GetEnvironmentVariable("NAME", "User")
```

查看所有用户级环境变量：

```powershell
[System.Environment]::GetEnvironmentVariables("User")
```

查看系统级环境变量：

```powershell
[System.Environment]::GetEnvironmentVariable("NAME", "Machine")
```

查看所有系统级环境变量：

```powershell
[System.Environment]::GetEnvironmentVariables("Machine")
```

删除用户级环境变量：

```powershell
[System.Environment]::SetEnvironmentVariable("NAME", $null, "User")
```

删除系统级环境变量：

```powershell
[System.Environment]::SetEnvironmentVariable("NAME", $null, "Machine")
```

## 示例

```powershell
$env:JAVA_HOME = "C:\Java\jdk-21"
$env:JAVA_HOME
```
