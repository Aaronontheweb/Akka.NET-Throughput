@echo off

pushd %~dp0

SETLOCAL
SET CACHED_NUGET=%LocalAppData%\NuGet\NuGet.exe

IF EXIST %CACHED_NUGET% goto copynuget
echo Downloading latest version of NuGet.exe...
IF NOT EXIST %LocalAppData%\NuGet md %LocalAppData%\NuGet
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest 'https://www.nuget.org/nuget.exe' -OutFile '%CACHED_NUGET%'"

:copynuget
IF EXIST tools\nuget\nuget.exe goto restore
md tools\nuget
copy %CACHED_NUGET% tools\nuget\nuget.exe > nul

:restore

tools\nuget\NuGet.exe update -self

tools\nuget\NuGet.exe install FAKE -OutputDirectory packages -Version 4.9.1 -ExcludeVersion

if not exist packages\SourceLink.Fake\tools\SourceLink.fsx ( 
  tools\nuget\nuget.exe install SourceLink.Fake -OutputDirectory packages -ExcludeVersion
)
rem cls

tools\nuget\NuGet.exe install NBench.Runner -OutputDirectory packages -ExcludeVersion

set encoding=utf-8
packages\FAKE\tools\FAKE.exe build.fsx %*

popd


