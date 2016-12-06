@echo off
setlocal EnableDelayedExpansion
echo *****************************************************************
echo      initialize_datastructures.bat
echo                by niuren.zhu
echo                           2016.12.06
echo  ˵����
echo     1. ����jar�����������ݽṹ��
echo     2. ����1��IBCP��war��λ�á�
echo     3. ����2��IBCP����Ŀ¼��
echo     4. ����3��IBCP����Ŀ¼��
echo     5. ����4��IBCP�����Ŀ¼��
echo *****************************************************************
REM ���JAVA���л���
SET h=%time:~0,2%
SET hh=%h: =0%
SET DATE_NAME=%date:~0,4%%date:~5,2%%date:~8,2%_%hh%%time:~3,2%%time:~6,2%
REM ���ò�������
SET WORK_FOLDER=%~dp0
REM ����ibcp_toolsĿ¼
SET TOOLS_FOLDER=%WORK_FOLDER%ibcp_tools\
SET TOOLS_TRANSFORM=%TOOLS_FOLDER%btulz.transforms.core-0.1.0.jar
if not exist "%TOOLS_TRANSFORM%" (
  echo not found btulz.transforms.core.
  goto :EOF
)
REM ����deploy_folderĿ¼
SET DEPLOY_FOLDER=%~2
if "%DEPLOY_FOLDER%" equ "" SET DEPLOY_FOLDER=%WORK_FOLDER%webapps\
if not exist "%DEPLOY_FOLDER%" (
  echo not found webapps.
  goto :EOF
)
REM ���ݿ���Ϣ
SET CompanyId=CC
SET MasterDbType=mysql
SET MasterDbServer=localhost
SET MasterDbPort=3306
SET MasterDbSchema=
SET MasterDbName=ibcp_demo
SET MasterDbUserID=root
SET MasterDbUserPassword=1q2w3e

echo ��ʼ����[%DEPLOY_FOLDER%]Ŀ¼
REM ��ʼ������ǰ�汾
if not exist "%DEPLOY_FOLDER%ibcp.release.txt" dir /D /B /A:D "%DEPLOY_FOLDER%" >"%DEPLOY_FOLDER%ibcp.release.txt"
for /f %%m in (%DEPLOY_FOLDER%ibcp.release.txt) DO (
echo --��ʼ����[%%m]
SET module=%%m
SET jar=ibcp.!module!-*.jar
if exist "%DEPLOY_FOLDER%!module!\WEB-INF\app.xml" (
echo ----��ȡ�����ļ�[.\WEB-INF\app.xml]
   call :LOAD_CONF "%DEPLOY_FOLDER%!module!\WEB-INF\app.xml"
)
if exist "%DEPLOY_FOLDER%!module!\WEB-INF\lib\!jar!" (
echo ----��ʼ����[.\WEB-INF\lib\!jar!]
for %%f in (%DEPLOY_FOLDER%!module!\WEB-INF\lib\!jar!) DO (
   call :CREATE_DS %%f
))
if exist "%WORK_FOLDER%lib\!jar!" (
echo ----��ʼ����[.\lib\!jar!]
for %%f in (%WORK_FOLDER%lib\!jar!) DO (
   call :CREATE_DS %%f
))
echo --
)

goto :EOF
REM �������������ݽṹ������1��ʹ�õ�jar��
:CREATE_DS
  SET JarFile=%1
  SET COMMOND=java -Djava.ext.dirs=%TOOLS_FOLDER%lib -jar^
    "%TOOLS_TRANSFORM%" dsJar^
    -DsTemplate=ds_%MasterDbType%_ibas_classic.xml^
    -JarFile="%JarFile%"^
    -SqlFilter=sql_%MasterDbType%^
    -Company=%CompanyId%^
    -DbServer=%MasterDbServer%^
    -DbPort=%MasterDbPort%^
    -DbSchema=%MasterDbSchema%^
    -DbName=%MasterDbName%^
    -DbUser=%MasterDbUserID%^
    -DbPassword=%MasterDbUserPassword%
  echo ���У�%COMMOND%
  call %COMMOND%
goto :EOF
REM ��������ȡ�����ļ�������1��ʹ�õ������ļ�
:LOAD_CONF
  SET ConfFile=%1
  if not exist %ConfFile% goto :EOF
  for /f "tokens=* delims== " %%i in ('type "%ConfFile%"') do (
    set str=%%i
    call :TRIM str
    if "!str:~0,5!"=="<add " (
      for /f tokens^=2^,4^ delims^=^" %%j in ("!str!") do (
        SET %%j=%%k
      )
    )
  )
REM ���ݿ�ܹ�����
  if "%MasterDbType%" equ "MSSQL" (
    SET MasterDbSchema=dbo
  ) else (
    SET MasterDbSchema=
  )
REM ���ݿ�˿�����
  if "%MasterDbType%" equ "MSSQL" SET MasterDbPort=1433
  if "%MasterDbType%" equ "MYSQL" SET MasterDbPort=3306
  if "%MasterDbType%" equ "PGSQL" SET MasterDbPort=5432
  if "%MasterDbType%" equ "HANA" SET MasterDbPort=30015
goto :EOF
REM ������ȥ���ո��Ʊ��������1��������ַ�
:TRIM
if "!%1:~0,1!"==" " (set %1=!%1:~1!&&goto TRIM)
if "!%1:~0,1!"=="	" (set %1=!%1:~1!&&goto TRIM)
if "!%1:~-1!"==" " (set %1=!%1:~0,-1!&&goto TRIM)
if "!%1:~-1!"=="	" (set %1=!%1:~0,-1!&&goto TRIM)
goto :EOF