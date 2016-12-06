@echo off
setlocal EnableDelayedExpansion
echo *****************************************************************
echo      deploy_ibcp_all.bat
echo                by niuren.zhu
echo                           2016.12.02
echo  ˵����
echo     1. ����war������Ŀ¼��
echo     2. ����1��IBCP��war��λ�á�
echo     3. ����2��IBCP����Ŀ¼��
echo     4. ����3��IBCP����Ŀ¼��
echo     5. ����4��IBCP�����Ŀ¼��
echo *****************************************************************
SET h=%time:~0,2%
SET hh=%h: =0%
SET DATE_NAME=%date:~0,4%%date:~5,2%%date:~8,2%_%hh%%time:~3,2%%time:~6,2%
REM ���ò�������
SET WORK_FOLDER=%~dp0
REM ����package_folderĿ¼
SET PACKAGE_FOLDER=%~1
if "%PACKAGE_FOLDER%" equ "" SET PACKAGE_FOLDER=%WORK_FOLDER%ibcp_packages\%DATE_NAME%\
REM ����deploy_folderĿ¼
SET DEPLOY_FOLDER=%~2
if "%DEPLOY_FOLDER%" equ "" SET DEPLOY_FOLDER=%WORK_FOLDER%webapps\
if not exist "%DEPLOY_FOLDER%" mkdir "%DEPLOY_FOLDER%"
REM ����ibcpĿ¼
SET IBCP_HOME=%~3
if "%IBCP_HOME%" equ "" SET IBCP_HOME=%WORK_FOLDER%ibcp\
if not exist "%IBCP_HOME%" mkdir "%IBCP_HOME%"
REM ����libĿ¼
SET IBCP_LIB=%~4
if "%IBCP_LIB%" equ "" SET IBCP_LIB=%WORK_FOLDER%lib\
if not exist "%IBCP_HOME%" mkdir "%IBCP_HOME%"
REM ibcp����Ŀ¼
SET IBCP_CONF=%IBCP_HOME%conf\
if not exist "%IBCP_CONF%" mkdir "%IBCP_CONF%"
REM ibcp����Ŀ¼
SET IBCP_DATA=%IBCP_HOME%data\
if not exist "%IBCP_DATA%" mkdir "%IBCP_DATA%"
REM ibcp��־Ŀ¼
SET IBCP_LOG=%IBCP_HOME%log\
if not exist "%IBCP_LOG%" mkdir "%IBCP_LOG%"
REM �����-���������ַ
SET IBCP_PACKAGE_URL=http://ibas.club:8866/ibcp
REM �����-���������û���
SET IBCP_PACKAGE_USER=avatech\amber
REM �����-���������û�����
SET IBCP_PACKAGE_PASSWORD=Aa123456
REM �����-�汾·��
SET IBCP_PACKAGE_VERSION=latest

REM ����ibcp����
echo ��ʼ����ģ�飬��%IBCP_PACKAGE_URL%/%IBCP_PACKAGE_VERSION%/
if not exist "%PACKAGE_FOLDER%" mkdir "%PACKAGE_FOLDER%" 
wget -r -np -nd -nv --http-user=%IBCP_PACKAGE_USER% --http-password=%IBCP_PACKAGE_PASSWORD% -P %PACKAGE_FOLDER% %IBCP_PACKAGE_URL%/%IBCP_PACKAGE_VERSION%/

echo ��ʼ��ѹ[%PACKAGE_FOLDER%]��war��
REM ��ʼ������ǰ�汾
if not exist "%PACKAGE_FOLDER%ibcp.deploy.order.txt" dir /b "%PACKAGE_FOLDER%ibcp.*.war" >"%PACKAGE_FOLDER%ibcp.deploy.order.txt"
for /f %%m in (%PACKAGE_FOLDER%ibcp.deploy.order.txt) DO (
echo --��ʼ����[%%m]
SET module=%%m
SET name=!module:~5,-18!
REM echo !name! REM �˴��и��ӣ��ļ�����λ����.service-X.X.X.war��ʽ�͹��ˡ�
if exist "%PACKAGE_FOLDER%%%m" (
  echo !name!>>"%DEPLOY_FOLDER%ibcp.release.txt"
  7z x "%PACKAGE_FOLDER%%%m" -r -y -o"%DEPLOY_FOLDER%!name!"
REM ɾ�������ļ�����ͳһ��IBCP_CONFĿ¼
  if exist "%DEPLOY_FOLDER%!name!\WEB-INF\app.xml" (
    del /q "%DEPLOY_FOLDER%!name!\WEB-INF\app.xml"
  )
  mklink "%DEPLOY_FOLDER%!name!\WEB-INF\app.xml" "%IBCP_CONF%app.xml"
REM ɾ��·���ļ�����ͳһ��IBCP_CONFĿ¼
  if exist "%DEPLOY_FOLDER%!name!\WEB-INF\service_routing.xml" (
    del /q "%DEPLOY_FOLDER%!name!\WEB-INF\service_routing.xml"
  )
  mklink "%DEPLOY_FOLDER%!name!\WEB-INF\service_routing.xml" "%IBCP_CONF%service_routing.xml"
REM ͳһ��־Ŀ¼��IBCP_LOGĿ¼
  if not exist "%DEPLOY_FOLDER%!name!\WEB-INF\log" (
    mklink /d "%DEPLOY_FOLDER%!name!\WEB-INF\log" "%IBCP_LOG%"
  )
REM ͳһlibĿ¼������Ŀ¼
  if exist "%DEPLOY_FOLDER%!name!\WEB-INF\lib\*.jar" (
    copy /y "%DEPLOY_FOLDER%!name!\WEB-INF\lib\*.jar" "%IBCP_LIB%"
    del /q "%DEPLOY_FOLDER%!name!\WEB-INF\lib\*.jar"
  )
)
)