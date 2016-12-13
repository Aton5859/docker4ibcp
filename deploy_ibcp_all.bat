@echo off
setlocal EnableDelayedExpansion
echo *************************************************************************************
echo      deploy_ibcp_all.bat
echo                by niuren.zhu
echo                           2016.12.02
echo  ˵����
echo     1. ���ز�����IBCP��WAR������Ŀ¼����Ҫ�Թ���ԱȨ��������
echo     2. ����1��IBCP����Ŀ¼��Ĭ��.\ibcp��
echo     3. ����2��IBCP�İ�λ�ã�Ĭ��.\ibcp_packages��
echo     4. ����3��IBCP����Ŀ¼��Ĭ��.\webapps��
echo     5. ����4��IBCP�����Ŀ¼��Ĭ��.\ibcp_lib��
echo     6. �ű�ͨ�ļ����ӷ�ʽ�����������ļ�����־Ŀ¼��IBCP_HOME�¡�
echo     7. ��ǰ���ز�����wget��PATH������
echo     8. �����catalina.properties��shared.loader="${catalina.home}/ibcp_lib/*.jar"��
echo **************************************************************************************
SET h=%time:~0,2%
SET hh=%h: =0%
SET DATE_NAME=%date:~0,4%%date:~5,2%%date:~8,2%_%hh%%time:~3,2%%time:~6,2%
REM ���ò�������
SET WORK_FOLDER=%~dp0
REM ����ibcpĿ¼
SET IBCP_HOME=%1
if "%IBCP_HOME%" equ "" SET IBCP_HOME=%WORK_FOLDER%ibcp\
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
REM ����IBCP_PACKAGEĿ¼
SET IBCP_PACKAGE=%2
if "%IBCP_PACKAGE%" equ "" SET IBCP_PACKAGE=%WORK_FOLDER%ibcp_packages\%DATE_NAME%\
REM ����IBCP_DEPLOYĿ¼
SET IBCP_DEPLOY=%3
if "%IBCP_DEPLOY%" equ "" SET IBCP_DEPLOY=%WORK_FOLDER%webapps\
if not exist "%IBCP_DEPLOY%" mkdir "%IBCP_DEPLOY%"
REM ����libĿ¼
SET IBCP_LIB=%4
if "%IBCP_LIB%" equ "" SET IBCP_LIB=%WORK_FOLDER%ibcp_lib\
if not exist "%IBCP_LIB%" mkdir "%IBCP_LIB%"
REM �����-���������ַ
SET IBCP_PACKAGE_URL=http://ibas.club:8866/ibcp
REM �����-���������û���
SET IBCP_PACKAGE_USER=avatech\amber
REM �����-���������û�����
SET IBCP_PACKAGE_PASSWORD=Aa123456
REM �����-�汾·��
SET IBCP_PACKAGE_VERSION=latest

REM ��ʾ������Ϣ
echo ----------------------------------------------------
echo ���ص�ַ��%IBCP_PACKAGE_URL%/%IBCP_PACKAGE_VERSION%/
echo ����Ŀ¼��%IBCP_PACKAGE%
echo ����Ŀ¼��%IBCP_DEPLOY%
echo ����Ŀ¼��%IBCP_LIB%
echo ����Ŀ¼��%IBCP_HOME%
echo ----------------------------------------------------

REM ����ibcp����
echo ��ʼ����ģ�飬��%IBCP_PACKAGE_URL%/%IBCP_PACKAGE_VERSION%/
if not exist "%IBCP_PACKAGE%" mkdir "%IBCP_PACKAGE%" 
wget -r -np -nd -nv --http-user=%IBCP_PACKAGE_USER% --http-password=%IBCP_PACKAGE_PASSWORD% -P %IBCP_PACKAGE% %IBCP_PACKAGE_URL%/%IBCP_PACKAGE_VERSION%/

echo ��ʼ��ѹ[%IBCP_PACKAGE%]��war��
REM ��ʼ������ǰ�汾
if not exist "%IBCP_PACKAGE%ibcp.deploy.order.txt" dir /b "%IBCP_PACKAGE%ibcp.*.war" >"%IBCP_PACKAGE%ibcp.deploy.order.txt"
for /f %%m in (%IBCP_PACKAGE%ibcp.deploy.order.txt) DO (
echo --��ʼ����[%%m]
SET module=%%m
SET name=!module:~5,-18!
REM echo !name! REM �˴��и��ӣ��ļ�����λ����.service-X.X.X.war��ʽ�͹��ˡ�
if exist "%IBCP_PACKAGE%%%m" (
  echo !name!>>"%IBCP_DEPLOY%ibcp.release.txt"
  7z x "%IBCP_PACKAGE%%%m" -r -y -o"%IBCP_DEPLOY%!name!"
REM ɾ�������ļ�����ͳһ��IBCP_CONFĿ¼
  if exist "%IBCP_DEPLOY%!name!\WEB-INF\app.xml" (
    if not exist "%IBCP_CONF%app.xml" copy /y "%IBCP_DEPLOY%!name!\WEB-INF\app.xml" "%IBCP_CONF%app.xml"
    del /q "%IBCP_DEPLOY%!name!\WEB-INF\app.xml"
    mklink "%IBCP_DEPLOY%!name!\WEB-INF\app.xml" "%IBCP_CONF%app.xml"
  )
REM ɾ��·���ļ�����ͳһ��IBCP_CONFĿ¼
  if exist "%IBCP_DEPLOY%!name!\WEB-INF\service_routing.xml" (
    if not exist "%IBCP_CONF%service_routing.xml" copy /y "%IBCP_DEPLOY%!name!\WEB-INF\service_routing.xml" "%IBCP_CONF%service_routing.xml"
    del /q "%IBCP_DEPLOY%!name!\WEB-INF\service_routing.xml"
    mklink "%IBCP_DEPLOY%!name!\WEB-INF\service_routing.xml" "%IBCP_CONF%service_routing.xml"
  )
REM ɾ��ǰ�����ã���ͳһ��IBCP_CONFĿ¼
  if exist "%IBCP_DEPLOY%!name!\config.json" (
    if not exist "%IBCP_CONF%config.json" copy /y "%IBCP_DEPLOY%!name!\config.json" "%IBCP_CONF%config.json"
    del /q "%IBCP_DEPLOY%!name!\config.json"
    mklink "%IBCP_DEPLOY%!name!\config.json" "%IBCP_CONF%config.json"
  )
REM ͳһ��־Ŀ¼��IBCP_LOGĿ¼
  if exist "%IBCP_DEPLOY%!name!\WEB-INF\log" rd /s /q "%IBCP_DEPLOY%!name!\WEB-INF\log"
  mklink /d "%IBCP_DEPLOY%!name!\WEB-INF\log" "%IBCP_LOG%"
REM ͳһ����Ŀ¼��IBCP_DATAĿ¼
  if exist "%IBCP_DEPLOY%!name!\WEB-INF\data" rd /s /q "%IBCP_DEPLOY%!name!\WEB-INF\data"
  mklink /d "%IBCP_DEPLOY%!name!\WEB-INF\data" "%IBCP_DATA%"
REM ͳһlibĿ¼������Ŀ¼
  if exist "%IBCP_DEPLOY%!name!\WEB-INF\lib\*.jar" (
    copy /y "%IBCP_DEPLOY%!name!\WEB-INF\lib\*.jar" "%IBCP_LIB%"
    del /q "%IBCP_DEPLOY%!name!\WEB-INF\lib\*.jar"
  )
)
)
echo �������