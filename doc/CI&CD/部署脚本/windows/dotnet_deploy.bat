@echo off
rem dotnet ��Ŀ����
echo ============================begin deploy=======================================
rem set CUR_TIME=%date:~0,4%-%date:~5,2%-%date:~8,2% %time:~0,2%:%time:~3,2%:%time:~6,2%
set CUR_TIME=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%
set SSH_DIR=C:\Users\Administrator\ssh_dir\dotnet_publish
set DEPLOY_DIR=C:\www
set "PROJECT_DIR=%1"
set IIS_SITE=Default Web Site
if "%PROJECT_DIR%"=="" (
echo This environment prams is needed to run this program
exit 1
)
C:
cd %SSH_DIR%
if exist %SSH_DIR%\%PROJECT_DIR%.rar (
rem ֹͣIISվ��
@C:\Windows\System32\inetsrv\appcmd.exe stop site "%IIS_SITE%"

rem �ȱ�����һ������
echo ============================begin back site dir=======================================
WinRAR.exe a -k -r -s -m3 -o+ -ep1 -y -inul -xApp_Data\Logs -xLogs.txt %DEPLOY_DIR%\bak\%PROJECT_DIR%_%CUR_TIME%.rar %DEPLOY_DIR%\%PROJECT_DIR%\
echo ============================end back site dir=======================================
rem �������ɾ��

rem ��ѹ���ƶ�Ŀ¼��
echo ============================begin unrar to site dir====================================
WinRAR.exe x -y -o+ %SSH_DIR%\%PROJECT_DIR%.rar %DEPLOY_DIR%\%PROJECT_DIR%\
echo ============================end unrar to site dir=======================================
rem ����IISվ��
@C:\Windows\System32\inetsrv\appcmd.exe start site "%IIS_SITE%"
echo deploy ok
del /Q %SSH_DIR%\%PROJECT_DIR%.rar
) else (
echo deploy excaption:not found the deploy package
exit 1
)
echo ============================end deploy=======================================