@echo off
setlocal EnableDelayedExpansion
echo *****************************************************************
echo      initialize_datas.bat
echo                by niuren.zhu
echo                       2017.03.22
echo  ˵����
echo     1. ����jar������ʼ�����ݣ����ݿ���Ϣȡֵapp.xml��
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
SET TOOLS_TRANSFORM=%TOOLS_FOLDER%btulz.transforms.bobas-0.1.0.jar
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
  SET FILE_APP=%IBCP_DEPLOY%!module!\WEB-INF\app.xml   
  if exist "%IBCP_DEPLOY%!module!\WEB-INF\lib\!jar!" (
    echo ----��ʼ����[.\WEB-INF\lib\!jar!]
	SET CLASSES=
	for %%f in (%IBCP_DEPLOY%!module!\WEB-INF\lib\*.jar) DO (
       SET CLASSES=!CLASSES!%%f;
    )
    for %%f in (%IBCP_DEPLOY%!module!\WEB-INF\lib\!jar!) DO (
       call :INIT_DATA %%f !FILE_APP! !CLASSES!
  ))
  if exist "%IBCP_LIB%!jar!" (
    echo ----��ʼ����[%IBCP_LIB%!jar!]
	SET CLASSES=
	for %%f in (%IBCP_LIB%*.jar) DO (
       SET CLASSES=!CLASSES!%%f;
    )
    for %%f in (%IBCP_LIB%!jar!) DO (
       call :INIT_DATA %%f !FILE_APP! !CLASSES!
  ))
)
echo --
)
echo �������

goto :EOF
REM ��������ʼ�����ݡ�����1��������jar�� ����2�������ļ� ����3�����ص����
:INIT_DATA
  SET JarFile=%1
  SET Config=%2
  SET Classes=%3
  SET COMMOND=java ^
    -jar "%TOOLS_TRANSFORM%" init^
    -data="%JarFile%"^
    -config=%Config%^
    -classes=%Classes%^
  echo ���У�%COMMOND%
  call %COMMOND%
goto :EOF