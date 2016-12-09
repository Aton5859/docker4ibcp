#!/bin/bash
echo '****************************************************************************'
echo '     initialize_datastructures.sh                                           '
echo '            by niuren.zhu                                                   '
echo '               2016.10.26                                                   '
echo '  说明：                                                                    '
echo '    1. 分析jar包并创建数据结构，数据库信息取值app.xml。                     '
echo '    2. 参数1，待分析的目录，默认.\webapps。                                 '
echo '    3. 参数2，共享库目录，默认.\ibcp_lib。                                  '
echo '    4. 提前下载btulz.transforms并放置.\ibcp_tools\目录。                    '
echo '    5. 提前配置app.xml的数据库信息。                                        '
echo '****************************************************************************'
# 设置参数变量
WORK_FOLDER=$PWD
# 设置ibcp_tools目录
TOOLS_FOLDER=${WORK_FOLDER}/ibcp_tools
TOOLS_TRANSFORM=${TOOLS_FOLDER}/btulz.transforms.core-0.1.0.jar
if [ ! -e "${TOOLS_TRANSFORM}" ];then
  echo not found btulz.transforms, in [${TOOLS_FOLDER}].
  exit 1
fi;
# 设置DEPLOY目录
IBCP_DEPLOY=$1
if [ "${IBCP_DEPLOY}" == "" ];then IBCP_DEPLOY=${WORK_FOLDER}/webapps; fi;
if [ ! -e "${IBCP_DEPLOY}" ];then
  echo not found webapps.
  exit 1;
fi;
# 设置LIB目录
IBCP_LIB=$2
if [ "${IBCP_LIB}" == "" ];then IBCP_LIB=${WORK_FOLDER}/ibcp_lib; fi;

# 数据库信息
CompanyId=CC
MasterDbType=
MasterDbServer=
MasterDbPort=
MasterDbSchema=
MasterDbName=
MasterDbUserID=
MasterDbUserPassword=

# 显示参数信息
echo ----------------------------------------------------
echo 工具地址：${TOOLS_TRANSFORM}
echo 部署目录：${IBCP_DEPLOY}
echo 共享目录：${IBCP_LIB}
echo ----------------------------------------------------

# 获取属性值
function getAttr()  
{  
   ATTR_PAIR=${1#*$2=\"}  
   echo "${ATTR_PAIR%%\"*}"  
} 
# 从app.xml中获取配置项，参数1：配置文件
function getConfigValue()
{
   CONFIG_FILE=$1;
   local IFS=\>

   while read -d \< ENTITY CONTENT
     do     
       TAG_NAME=${ENTITY%% *}
       ATTRIBUTES=${ENTITY#* }
       if [[ $TAG_NAME == "add" ]]
         then
           key=`getAttr ${ATTRIBUTES} "key"`
           value=`getAttr ${ATTRIBUTES} "value"`
           # echo $key=$value
           eval "${key}='${value}'"
        fi
     done < ${CONFIG_FILE}
     
# 修正参数值
  MasterDbType=$(echo $MasterDbType | tr '[A-Z]' '[a-z]')
# 数据库架构修正
  if [ "${MasterDbType}" == "mssql" ];then
    if [ "${MasterDbSchema}" == "" ];then MasterDbSchema=dbo; fi;
  else
    MasterDbSchema=
  fi;
# 数据库端口修正
  if [ "${MasterDbType}" == "mssql" ];then
    if [ "${MasterDbPort}" == "" ];then MasterDbPort=1433; fi;
  fi;
  if [ "${MasterDbType}" == "mysql" ];then
    if [ "${MasterDbPort}" == "" ];then MasterDbPort=3306; fi;
  fi;
  if [ "${MasterDbType}" == "pgsql" ];then
    if [ "${MasterDbPort}" == "" ];then MasterDbPort=5432; fi;
  fi;
  if [ "${MasterDbType}" == "hana" ];then
    if [ "${MasterDbPort}" == "" ];then MasterDbPort=30015; fi;
  fi;
}
# 创建数据结构
function createDS()  
{
# 参数1，使用的jar包
  JarFile=$1;
  COMMOND="java \
    -jar ${TOOLS_TRANSFORM} dsJar \
    -DsTemplate=ds_${MasterDbType}_ibas_classic.xml \
    -JarFile=${JarFile} \
    -SqlFilter=sql_${MasterDbType} \
    -Company=${CompanyId} \
    -DbServer=${MasterDbServer} \
    -DbPort=${MasterDbPort} \
    -DbSchema=${MasterDbSchema} \
    -DbName=${MasterDbName} \
    -DbUser=${MasterDbUserID} \
    -DbPassword=${MasterDbUserPassword};"
  echo exec: ${COMMOND};
  eval $(echo ${COMMOND});
}

echo 开始分析${IBCP_DEPLOY}目录下数据
# 检查是否存在模块说明文件，此文件描述模块初始化顺序。
if [ ! -e "${IBCP_DEPLOY}/ibcp.release.txt" ]
then
  ls -l "${IBCP_DEPLOY}" | awk '/^d/{print $NF}' > "${IBCP_DEPLOY}/ibcp.release.txt"
fi
while read folder
do
  echo --${folder}
# 读取配置信息，用配置文件刷新变量
    FILE_APP=${IBCP_DEPLOY}/${folder}/WEB-INF/app.xml
    if [ -e "${FILE_APP}" ]; then
      getConfigValue ${FILE_APP};
    fi;
# 使用模块目录jar包
    if [ -e "${IBCP_DEPLOY}/${folder}/WEB-INF/lib" ]
    then
      for file in `ls "${IBCP_DEPLOY}/${folder}/WEB-INF/lib" | grep ibcp\.${folder}\-.`
      do
        echo ----${file}
        createDS ${IBCP_DEPLOY}/${folder}/WEB-INF/lib/${file};      
        echo ----
      done
    fi;
# 使用共享目录jar包
    if [ -e "${IBCP_LIB}" ]
    then
      for file in `ls "${IBCP_LIB}" | grep ibcp\.${folder}\-.`
      do
        echo ----${file}
        createDS ${IBCP_LIB}/${file};      
        echo ----
      done
    fi;
    echo --
  done < "${IBCP_DEPLOY}/ibcp.release.txt" | sed 's/\r//g'
echo 操作完成
