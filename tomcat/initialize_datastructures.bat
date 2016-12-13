@echo off
setlocal EnableDelayedExpansion
echo *****************************************************************
echo      initialize_datastructures.bat
echo                by niuren.zhu
echo                           2016.12.06
echo  ˵����
echo     1. ����jar�����������ݽṹ�����ݿ���Ϣȡֵapp.xml��
echo     2. ����1����������Ŀ¼��Ĭ��.\webapps��
echo     3. ����2�������Ŀ¼��Ĭ��.\ibcp_lib��
echo     4. ��ǰ����btulz.transforms������.\ibcp_tools\Ŀ¼��
echo     5. ��ǰ����app.xml�����ݿ���Ϣ��
echo *****************************************************************
REM ���JAVA���л���
SET h=%time:~0,2%
SET hh=%h: =0%
SET DATE_NAME=%date:~0,4%%date:~5,2%%date:~8,2%_%hh%%time:~3,2%%time:~6,2%
REM ���ò�������
SET WORK_FOLDER=%~dp0
REM ����TOOLSĿ¼
SET TOOLS_FOLDER=%WORK_FOLDER%ibcp_tools\
SET TOOLS_TRANSFORM=%TOOLS_FOLDER%btulz.transforms.core-0.1.0.jar
if not exist "%TOOLS_TRANSFORM%" (
  echo not found btulz.transforms.core.
  goto :EOF
)
REM ����DEPLOYĿ¼
SET IBCP_DEPLOY=%1
if "%IBCP_DEPLOY%" equ "" SET IBCP_DEPLOY=%WORK_FOLDER%webapps\
if not exist "%IBCP_DEPLOY%" (
  echo not found webapps.
  goto :EOF
)
REM ����LIBĿ¼
SET IBCP_LIB=%2
if "%IBCP_LIB%" equ "" SET IBCP_LIB=%WORK_FOLDER%ibcp_lib\
if not exist "%IBCP_LIB%" mkdir "%IBCP_LIB%"
REM ���ݿ���Ϣ
SET CompanyId=CC
SET MasterDbType=mysql
SET MasterDbServer=localhost
SET MasterDbPort=3306
SET MasterDbSchema=
SET MasterDbName=ibcp_demo
SET MasterDbUserID=root
SET MasterDbUserPassword=1q2w3e

REM ��ʾ������Ϣ
echo ----------------------------------------------------
echo ���ߵ�ַ��%TOOLS_TRANSFORM%
echo ����Ŀ¼��%IBCP_DEPLOY%
echo ����Ŀ¼��%IBCP_LIB%
echo ----------------------------------------------------

echo ��ʼ����[%IBCP_DEPLOY%]Ŀ¼
REM ��ʼ������ǰ�汾
if not exist "%IBCP_DEPLOY%ibcp.release.txt" dir /D /B /A:D "%IBCP_DEPLOY%" >"%IBCP_DEPLOY%ibcp.release.txt"
for /f %%m in (%IBCP_DEPLOY%ibcp.release.txt) DO (
echo --��ʼ����[%%m]
SET module=%%m
SET jar=ibcp.!module!-*.jar
if exist "%IBCP_DEPLOY%!module!\WEB-INF\app.xml" (
echo ----��ȡ�����ļ�[.\WEB-INF\app.xml]
   call :LOAD_CONF "%IBCP_DEPLOY%!module!\WEB-INF\app.xml"
)
if exist "%IBCP_DEPLOY%!module!\WEB-INF\lib\!jar!" (
echo ----��ʼ����[.\WEB-INF\lib\!jar!]
for %%f in (%IBCP_DEPLOY%!module!\WEB-INF\lib\!jar!) DO (
   call :CREATE_DS %%f
))
if exist "%IBCP_LIB%!jar!" (
echo ----��ʼ����[%IBCP_LIB%!jar!]
for %%f in (%IBCP_LIB%!jar!) DO (
   call :CREATE_DS %%f
))
echo --
)
echo �������

goto :EOF
REM �������������ݽṹ������1��������jar��
:CREATE_DS
  SET JarFile=%1
  SET COMMOND=java ^
    -jar "%TOOLS_TRANSFORM%" dsJar^
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
REM ����������Сд
  call :TO_LOWERCASE MasterDbType
REM ���ݿ�ܹ�����
  if "%MasterDbType%" equ "mssql" (
    SET MasterDbSchema=dbo
  ) else (
    SET MasterDbSchema=
  )
REM ���ݿ�˿�����
  if "%MasterDbType%" equ "mssql" SET MasterDbPort=1433
  if "%MasterDbType%" equ "mysql" SET MasterDbPort=3306
  if "%MasterDbType%" equ "pgsql" SET MasterDbPort=5432
  if "%MasterDbType%" equ "hana" SET MasterDbPort=30015
goto :EOF
REM ������ȥ���ո��Ʊ��������1������ı�����
:TRIM
if "!%1:~0,1!"==" " (set %1=!%1:~1!&&goto TRIM)
if "!%1:~0,1!"=="	" (set %1=!%1:~1!&&goto TRIM)
if "!%1:~-1!"==" " (set %1=!%1:~0,-1!&&goto TRIM)
if "!%1:~-1!"=="	" (set %1=!%1:~0,-1!&&goto TRIM)
goto :EOF
REM ��������д��ĸתСд������1������ı�����
:TO_UPPERCASE
  SET "UP=A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
  SET #=%1
  SET VALUE=!%#%!
  IF DEFINED # (
    FOR %%A IN (%UP%) DO SET VALUE=!VALUE:%%A=%%A!
  )
  SET %#%=%VALUE%
goto :EOF
REM ������Сд��ĸת��д������1������ı�����
:TO_LOWERCASE
  SET "DOWN=a b c d e f g h i j k l m n o p q r s t u v w x y z"
  SET #=%1
  SET VALUE=!%#%!
  IF DEFINED # (
    FOR %%A IN (%DOWN%) DO SET VALUE=!VALUE:%%A=%%A!
  )
  SET %#%=%VALUE%
goto :EOF