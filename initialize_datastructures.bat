@echo off
setlocal EnableDelayedExpansion
echo *****************************************************************
echo      initialize_datastructures.bat
echo                by niuren.zhu
echo                           2016.12.06
echo  说明：
echo     1. 分析jar包并创建数据结构。
echo     2. 参数1，IBCP的war包位置。
echo     3. 参数2，IBCP部署目录。
echo     4. 参数3，IBCP数据目录。
echo     5. 参数4，IBCP共享库目录。
echo *****************************************************************
REM 检查JAVA运行环境
SET h=%time:~0,2%
SET hh=%h: =0%
SET DATE_NAME=%date:~0,4%%date:~5,2%%date:~8,2%_%hh%%time:~3,2%%time:~6,2%
REM 设置参数变量
SET WORK_FOLDER=%~dp0
REM 设置ibcp_tools目录
SET TOOLS_FOLDER=%WORK_FOLDER%ibcp_tools\
SET TOOLS_TRANSFORM=%TOOLS_FOLDER%btulz.transforms.core-0.1.0.jar
if not exist "%TOOLS_TRANSFORM%" (
  echo not found btulz.transforms.core.
  goto :EOF
)
REM 设置deploy_folder目录
SET DEPLOY_FOLDER=%~2
if "%DEPLOY_FOLDER%" equ "" SET DEPLOY_FOLDER=%WORK_FOLDER%webapps\
if not exist "%DEPLOY_FOLDER%" (
  echo not found webapps.
  goto :EOF
)
REM 数据库信息
SET CompanyId=CC
SET MasterDbType=mysql
SET MasterDbServer=localhost
SET MasterDbPort=3306
SET MasterDbSchema=
SET MasterDbName=ibcp_demo
SET MasterDbUserID=root
SET MasterDbUserPassword=1q2w3e

echo 开始分析[%DEPLOY_FOLDER%]目录
REM 开始发布当前版本
if not exist "%DEPLOY_FOLDER%ibcp.release.txt" dir /D /B /A:D "%DEPLOY_FOLDER%" >"%DEPLOY_FOLDER%ibcp.release.txt"
for /f %%m in (%DEPLOY_FOLDER%ibcp.release.txt) DO (
echo --开始处理[%%m]
SET module=%%m
SET jar=ibcp.!module!-*.jar
if exist "%DEPLOY_FOLDER%!module!\WEB-INF\app.xml" (
echo ----读取配置文件[.\WEB-INF\app.xml]
   call :LOAD_CONF "%DEPLOY_FOLDER%!module!\WEB-INF\app.xml"
)
if exist "%DEPLOY_FOLDER%!module!\WEB-INF\lib\!jar!" (
echo ----开始处理[.\WEB-INF\lib\!jar!]
for %%f in (%DEPLOY_FOLDER%!module!\WEB-INF\lib\!jar!) DO (
   call :CREATE_DS %%f
))
if exist "%WORK_FOLDER%lib\!jar!" (
echo ----开始处理[.\lib\!jar!]
for %%f in (%WORK_FOLDER%lib\!jar!) DO (
   call :CREATE_DS %%f
))
echo --
)

goto :EOF
REM 函数，创建数据结构。参数1，分析的jar包
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
  echo 运行：%COMMOND%
  call %COMMOND%
goto :EOF
REM 函数，读取配置文件。参数1，使用的配置文件
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
REM 调整变量大小写
  call :TO_LOWERCASE MasterDbType
REM 数据库架构修正
  if "%MasterDbType%" equ "mssql" (
    SET MasterDbSchema=dbo
  ) else (
    SET MasterDbSchema=
  )
REM 数据库端口修正
  if "%MasterDbType%" equ "mssql" SET MasterDbPort=1433
  if "%MasterDbType%" equ "mysql" SET MasterDbPort=3306
  if "%MasterDbType%" equ "pgsql" SET MasterDbPort=5432
  if "%MasterDbType%" equ "hana" SET MasterDbPort=30015
goto :EOF
REM 函数，去除空格及制表符。参数1，处理的变量名
:TRIM
if "!%1:~0,1!"==" " (set %1=!%1:~1!&&goto TRIM)
if "!%1:~0,1!"=="	" (set %1=!%1:~1!&&goto TRIM)
if "!%1:~-1!"==" " (set %1=!%1:~0,-1!&&goto TRIM)
if "!%1:~-1!"=="	" (set %1=!%1:~0,-1!&&goto TRIM)
goto :EOF
REM 函数，大写字母转小写。参数1，处理的变量名
:TO_UPPERCASE
  SET "UP=A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
  SET #=%1
  SET VALUE=!%#%!
  IF DEFINED # (
    FOR %%A IN (%UP%) DO SET VALUE=!VALUE:%%A=%%A!
  )
  SET %#%=%VALUE%
goto :EOF
REM 函数，小写字母转大写。参数1，处理的变量名
:TO_LOWERCASE
  SET "DOWN=a b c d e f g h i j k l m n o p q r s t u v w x y z"
  SET #=%1
  SET VALUE=!%#%!
  IF DEFINED # (
    FOR %%A IN (%DOWN%) DO SET VALUE=!VALUE:%%A=%%A!
  )
  SET %#%=%VALUE%
goto :EOF