@echo off
rem dotnet ��Ŀ����
echo ============================begin build=======================================
set PUBLISH_DIR=C:\JenkinsPublishSpace
set "PROJECT_DIR=%1"
if "%PROJECT_DIR%"=="" (
echo This environment prams is needed to run this program
exit 1
)
cd %PUBLISH_DIR%\sourcCcode\%PROJECT_DIR%\src\WebApp.Web.Host
rem dotnet build
if exist %PUBLISH_DIR%\%PROJECT_DIR% (
	rd /S /Q %PUBLISH_DIR%\%PROJECT_DIR%
)
md %PUBLISH_DIR%\%PROJECT_DIR%
rem dotnet msbuild /t:Publish /p:OutputPath=D:\jekinsWorkspace\dotnet_publish\workflow /p:Configuration=Release
dotnet publish -o %PUBLISH_DIR%\%PROJECT_DIR% -c Release
echo ============================end build=======================================
rem Ĭ��ѹ����Ŀ¼���ݹ鴦�����ļ���ʹ�� -r
C:
cd %PUBLISH_DIR%
if not exist %PUBLISH_DIR%\temp\%PROJECT_DIR%\ (
	md %PUBLISH_DIR%\temp\%PROJECT_DIR%\
)
xcopy %PUBLISH_DIR%\%PROJECT_DIR% %PUBLISH_DIR%\temp\%PROJECT_DIR%\ /s/e/y/exclude:%PUBLISH_DIR%\dotnet_exclude.txt

cd %PUBLISH_DIR%\temp
WinRAR.exe a -k -r -s -m3 -o+ -ep1 %PROJECT_DIR%.rar %PROJECT_DIR%\
echo publish ok
cd %PUBLISH_DIR%
rem ��ѹ����ǰĿ¼��,������ѹ�����ڵ�·��
rem WinRAR.exe e  num_all_tg.zip
rem ��ѹ���ƶ�Ŀ¼��,������ѹ�����ڵ�·��
rem WinRAR.exe e  num_all_tg.zip .\test_d2

rem for line in `cat tomcat_info.txt`
rem do
rem kill -9 $line
rem done