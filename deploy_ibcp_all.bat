@echo off
setlocal EnableDelayedExpansion
echo *****************************************************************
echo      deploy_ibcp_all.bat
echo                by niuren.zhu
echo                           2016.12.02
echo  说明：
echo     1. 部署war到部署目录。
echo     2. 参数1，IBCP的war包位置。
echo     3. 参数2，IBCP部署目录。
echo     4. 参数3，IBCP数据目录。
echo     5. 参数4，IBCP共享库目录。
echo *****************************************************************
REM 设置参数变量
SET WORK_FOLDER=%~dp0
REM 设置package_folder目录
SET PACKAGE_FOLDER=%~1
if "%PACKAGE_FOLDER%" equ "" SET PACKAGE_FOLDER=%WORK_FOLDER%ibcp_packages\latest\
REM 设置deploy_folder目录
SET DEPLOY_FOLDER=%~2
if "%DEPLOY_FOLDER%" equ "" SET DEPLOY_FOLDER=%WORK_FOLDER%webapps\
if not exist "%DEPLOY_FOLDER%" mkdir "%DEPLOY_FOLDER%"
REM 设置ibcp目录
SET IBCP_HOME=%~3
if "%IBCP_HOME%" equ "" SET IBCP_HOME=%WORK_FOLDER%ibcp\
if not exist "%IBCP_HOME%" mkdir "%IBCP_HOME%"
REM 设置lib目录
SET IBCP_LIB=%~4
if "%IBCP_LIB%" equ "" SET IBCP_LIB=%WORK_FOLDER%lib\
if not exist "%IBCP_HOME%" mkdir "%IBCP_HOME%"
REM ibcp配置目录
SET IBCP_CONF=%IBCP_HOME%conf\
if not exist "%IBCP_CONF%" mkdir "%IBCP_CONF%"
REM ibcp数据目录
SET IBCP_DATA=%IBCP_HOME%data\
if not exist "%IBCP_DATA%" mkdir "%IBCP_DATA%"
REM ibcp日志目录
SET IBCP_LOG=%IBCP_HOME%log\
if not exist "%IBCP_LOG%" mkdir "%IBCP_LOG%"

echo 开始解压[%PACKAGE_FOLDER%]的war包
REM 开始发布当前版本
if not exist "%PACKAGE_FOLDER%ibcp.deploy.order.txt" dir /b "%PACKAGE_FOLDER%ibcp.*.war" >"%PACKAGE_FOLDER%ibcp.deploy.order.txt"
for /f %%m in (%PACKAGE_FOLDER%ibcp.deploy.order.txt) DO (
echo --开始处理[%%m]
SET module=%%m
SET name=!module:~5,-18!
REM echo !name! REM 此处有个坑，文件名后几位不是.service-X.X.X.war格式就挂了。
if exist "%PACKAGE_FOLDER%%%m" (
  echo !name!>>"%DEPLOY_FOLDER%ibcp.release.txt"
  7z x "%PACKAGE_FOLDER%%%m" -r -y -o"%DEPLOY_FOLDER%!name!"
REM 删除配置文件，并统一到IBCP_CONF目录
  if exist "%DEPLOY_FOLDER%!name!\WEB-INF\app.xml" (
    del /q "%DEPLOY_FOLDER%!name!\WEB-INF\app.xml"
    mklink "%DEPLOY_FOLDER%!name!\WEB-INF\app.xml" "%IBCP_CONF%app.xml"
  )
REM 删除路由文件，并统一到IBCP_CONF目录
  if exist "%DEPLOY_FOLDER%!name!\WEB-INF\service_routing.xml" (
    del /q "%DEPLOY_FOLDER%!name!\WEB-INF\service_routing.xml"
    mklink "%DEPLOY_FOLDER%!name!\WEB-INF\service_routing.xml" "%IBCP_CONF%service_routing.xml"
  )
REM 统一日志目录到IBCP_LOG目录
  if not exist "%DEPLOY_FOLDER%!name!\WEB-INF\log" (
    mklink /d "%DEPLOY_FOLDER%!name!\WEB-INF\log" "%IBCP_LOG%"
  )
REM 统一lib目录到运行目录
  if exist "%DEPLOY_FOLDER%!name!\WEB-INF\lib" (
    copy /y "%DEPLOY_FOLDER%!name!\WEB-INF\lib\*.jar" "%IBCP_LIB%"
    del /q "%DEPLOY_FOLDER%!name!\WEB-INF\lib\*.jar"
  )
)
)