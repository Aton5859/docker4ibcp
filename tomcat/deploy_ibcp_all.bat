@echo off
setlocal EnableDelayedExpansion
echo *************************************************************************************
echo      deploy_ibcp_all.bat
echo                by niuren.zhu
echo                           2016.12.02
echo  说明：
echo     1. 下载并部署IBCP的WAR到部署目录，需要以管理员权限启动。
echo     2. 参数1，IBCP数据目录，默认.\ibcp。
echo     3. 参数2，IBCP的包位置，默认.\ibcp_packages。
echo     4. 参数3，IBCP部署目录，默认.\webapps。
echo     5. 参数4，IBCP共享库目录，默认.\ibcp_lib。
echo     6. 脚本通文件链接方式，集中配置文件和日志目录到IBCP_HOME下。
echo     7. 提前下载并配置wget到PATH变量。
echo     8. 请调整catalina.properties的shared.loader="${catalina.home}/ibcp_lib/*.jar"。
echo **************************************************************************************
SET h=%time:~0,2%
SET hh=%h: =0%
SET DATE_NAME=%date:~0,4%%date:~5,2%%date:~8,2%_%hh%%time:~3,2%%time:~6,2%
REM 设置参数变量
SET WORK_FOLDER=%~dp0
REM 设置ibcp目录
SET IBCP_HOME=%1
if "%IBCP_HOME%" equ "" SET IBCP_HOME=%WORK_FOLDER%ibcp\
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
REM 设置IBCP_PACKAGE目录
SET IBCP_PACKAGE=%2
if "%IBCP_PACKAGE%" equ "" SET IBCP_PACKAGE=%WORK_FOLDER%ibcp_packages\%DATE_NAME%\
REM 设置IBCP_DEPLOY目录
SET IBCP_DEPLOY=%3
if "%IBCP_DEPLOY%" equ "" SET IBCP_DEPLOY=%WORK_FOLDER%webapps\
if not exist "%IBCP_DEPLOY%" mkdir "%IBCP_DEPLOY%"
REM 设置lib目录
SET IBCP_LIB=%4
if "%IBCP_LIB%" equ "" SET IBCP_LIB=%WORK_FOLDER%ibcp_lib\
if not exist "%IBCP_LIB%" mkdir "%IBCP_LIB%"
REM 程序包-发布服务地址
SET IBCP_PACKAGE_URL=http://ibas.club:8866/ibcp
REM 程序包-发布服务用户名
SET IBCP_PACKAGE_USER=avatech\amber
REM 程序包-发布服务用户密码
SET IBCP_PACKAGE_PASSWORD=Aa123456
REM 程序包-版本路径
SET IBCP_PACKAGE_VERSION=latest

REM 显示参数信息
echo ----------------------------------------------------
echo 下载地址：%IBCP_PACKAGE_URL%/%IBCP_PACKAGE_VERSION%/
echo 下载目录：%IBCP_PACKAGE%
echo 部署目录：%IBCP_DEPLOY%
echo 共享目录：%IBCP_LIB%
echo 数据目录：%IBCP_HOME%
echo ----------------------------------------------------

REM 下载ibcp程序
echo 开始下载模块，从%IBCP_PACKAGE_URL%/%IBCP_PACKAGE_VERSION%/
if not exist "%IBCP_PACKAGE%" mkdir "%IBCP_PACKAGE%" 
wget -r -np -nd -nv --http-user=%IBCP_PACKAGE_USER% --http-password=%IBCP_PACKAGE_PASSWORD% -P %IBCP_PACKAGE% %IBCP_PACKAGE_URL%/%IBCP_PACKAGE_VERSION%/

echo 开始解压[%IBCP_PACKAGE%]的war包
REM 开始发布当前版本
if not exist "%IBCP_PACKAGE%ibcp.deploy.order.txt" dir /b "%IBCP_PACKAGE%ibcp.*.war" >"%IBCP_PACKAGE%ibcp.deploy.order.txt"
for /f %%m in (%IBCP_PACKAGE%ibcp.deploy.order.txt) DO (
echo --开始处理[%%m]
SET module=%%m
SET name=!module:~5,-18!
REM echo !name! REM 此处有个坑，文件名后几位不是.service-X.X.X.war格式就挂了。
if exist "%IBCP_PACKAGE%%%m" (
  echo !name!>>"%IBCP_DEPLOY%ibcp.release.txt"
  7z x "%IBCP_PACKAGE%%%m" -r -y -o"%IBCP_DEPLOY%!name!"
REM 删除配置文件，并统一到IBCP_CONF目录
  if exist "%IBCP_DEPLOY%!name!\WEB-INF\app.xml" (
    if not exist "%IBCP_CONF%app.xml" copy /y "%IBCP_DEPLOY%!name!\WEB-INF\app.xml" "%IBCP_CONF%app.xml"
    del /q "%IBCP_DEPLOY%!name!\WEB-INF\app.xml"
    mklink "%IBCP_DEPLOY%!name!\WEB-INF\app.xml" "%IBCP_CONF%app.xml"
  )
REM 删除路由文件，并统一到IBCP_CONF目录
  if exist "%IBCP_DEPLOY%!name!\WEB-INF\service_routing.xml" (
    if not exist "%IBCP_CONF%service_routing.xml" copy /y "%IBCP_DEPLOY%!name!\WEB-INF\service_routing.xml" "%IBCP_CONF%service_routing.xml"
    del /q "%IBCP_DEPLOY%!name!\WEB-INF\service_routing.xml"
    mklink "%IBCP_DEPLOY%!name!\WEB-INF\service_routing.xml" "%IBCP_CONF%service_routing.xml"
  )
REM 删除前端配置，并统一到IBCP_CONF目录
  if exist "%IBCP_DEPLOY%!name!\config.json" (
    if not exist "%IBCP_CONF%config.json" copy /y "%IBCP_DEPLOY%!name!\config.json" "%IBCP_CONF%config.json"
    del /q "%IBCP_DEPLOY%!name!\config.json"
    mklink "%IBCP_DEPLOY%!name!\config.json" "%IBCP_CONF%config.json"
  )
REM 统一日志目录到IBCP_LOG目录
  if exist "%IBCP_DEPLOY%!name!\WEB-INF\log" rd /s /q "%IBCP_DEPLOY%!name!\WEB-INF\log"
  mklink /d "%IBCP_DEPLOY%!name!\WEB-INF\log" "%IBCP_LOG%"
REM 统一数据目录到IBCP_DATA目录
  if exist "%IBCP_DEPLOY%!name!\WEB-INF\data" rd /s /q "%IBCP_DEPLOY%!name!\WEB-INF\data"
  mklink /d "%IBCP_DEPLOY%!name!\WEB-INF\data" "%IBCP_DATA%"
REM 统一lib目录到运行目录
  if exist "%IBCP_DEPLOY%!name!\WEB-INF\lib\*.jar" (
    copy /y "%IBCP_DEPLOY%!name!\WEB-INF\lib\*.jar" "%IBCP_LIB%"
    del /q "%IBCP_DEPLOY%!name!\WEB-INF\lib\*.jar"
  )
)
)
echo 操作完成