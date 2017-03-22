@echo off
setlocal EnableDelayedExpansion
echo *****************************************************************
echo      initialize_datas.bat
echo                by niuren.zhu
echo                       2017.03.22
echo  说明：
echo     1. 分析jar包并初始化数据，数据库信息取值app.xml。
echo     2. 参数1，待分析的目录，默认.\webapps。
echo     3. 参数2，共享库目录，默认.\ibcp_lib。
echo     4. 提前下载btulz.transforms并放置.\ibcp_tools\目录。
echo     5. 提前配置app.xml的数据库信息。
echo *****************************************************************
REM 检查JAVA运行环境
SET h=%time:~0,2%
SET hh=%h: =0%
SET DATE_NAME=%date:~0,4%%date:~5,2%%date:~8,2%_%hh%%time:~3,2%%time:~6,2%
REM 设置参数变量
SET WORK_FOLDER=%~dp0
REM 设置TOOLS目录
SET TOOLS_FOLDER=%WORK_FOLDER%ibcp_tools\
SET TOOLS_TRANSFORM=%TOOLS_FOLDER%btulz.transforms.bobas-0.1.0.jar
if not exist "%TOOLS_TRANSFORM%" (
  echo not found btulz.transforms.core.
  goto :EOF
)
REM 设置DEPLOY目录
SET IBCP_DEPLOY=%1
if "%IBCP_DEPLOY%" equ "" SET IBCP_DEPLOY=%WORK_FOLDER%webapps\
if not exist "%IBCP_DEPLOY%" (
  echo not found webapps.
  goto :EOF
)
REM 设置LIB目录
SET IBCP_LIB=%2
if "%IBCP_LIB%" equ "" SET IBCP_LIB=%WORK_FOLDER%ibcp_lib\
if not exist "%IBCP_LIB%" mkdir "%IBCP_LIB%"

REM 显示参数信息
echo ----------------------------------------------------
echo 工具地址：%TOOLS_TRANSFORM%
echo 部署目录：%IBCP_DEPLOY%
echo 共享目录：%IBCP_LIB%
echo ----------------------------------------------------

echo 开始分析[%IBCP_DEPLOY%]目录
REM 开始发布当前版本
if not exist "%IBCP_DEPLOY%ibcp.release.txt" dir /D /B /A:D "%IBCP_DEPLOY%" >"%IBCP_DEPLOY%ibcp.release.txt"
for /f %%m in (%IBCP_DEPLOY%ibcp.release.txt) DO (
echo --开始处理[%%m]
SET module=%%m
SET jar=ibcp.!module!-*.jar
if exist "%IBCP_DEPLOY%!module!\WEB-INF\app.xml" (
  SET FILE_APP=%IBCP_DEPLOY%!module!\WEB-INF\app.xml   
  if exist "%IBCP_DEPLOY%!module!\WEB-INF\lib\!jar!" (
    echo ----开始处理[.\WEB-INF\lib\!jar!]
	SET CLASSES=
	for %%f in (%IBCP_DEPLOY%!module!\WEB-INF\lib\*.jar) DO (
       SET CLASSES=!CLASSES!%%f;
    )
    for %%f in (%IBCP_DEPLOY%!module!\WEB-INF\lib\!jar!) DO (
       call :INIT_DATA %%f !FILE_APP! !CLASSES!
  ))
  if exist "%IBCP_LIB%!jar!" (
    echo ----开始处理[%IBCP_LIB%!jar!]
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
echo 操作完成

goto :EOF
REM 函数，初始化数据。参数1，分析的jar包 参数2，配置文件 参数3，加载的类库
:INIT_DATA
  SET JarFile=%1
  SET Config=%2
  SET Classes=%3
  SET COMMOND=java ^
    -jar "%TOOLS_TRANSFORM%" init^
    -data="%JarFile%"^
    -config=%Config%^
    -classes=%Classes%^
  echo 运行：%COMMOND%
  call %COMMOND%
goto :EOF