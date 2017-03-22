#!/bin/bash
echo '****************************************************************************'
echo '     initialize_datas.sh                                                    '
echo '            by niuren.zhu                                                   '
echo '               2017.03.22                                                   '
echo '  说明：                                                                     '
echo '    1. 分析jar包并初始化数据，数据库信息取值app.xml。                             '
echo '    2. 参数1，待分析的目录，默认.\webapps。                                     '
echo '    3. 参数2，共享库目录，默认.\ibcp_lib。                                      '
echo '    4. 提前下载btulz.transforms并放置.\ibcp_tools\目录。                       '
echo '    5. 提前配置app.xml的数据库信息。                                            '
echo '****************************************************************************'
# 设置参数变量
WORK_FOLDER=$PWD
# 设置ibcp_tools目录
TOOLS_FOLDER=${WORK_FOLDER}/ibcp_tools
TOOLS_TRANSFORM=${TOOLS_FOLDER}/btulz.transforms.bobas-0.1.0.jar
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

# 显示参数信息
echo ----------------------------------------------------
echo 工具地址：${TOOLS_TRANSFORM}
echo 部署目录：${IBCP_DEPLOY}
echo 共享目录：${IBCP_LIB}
echo ----------------------------------------------------

# 初始化数据
function initDatas()  
{
# 参数1，使用的jar包
  JarFile=$1;
# 参数2，配置文件
  Config=$2;
# 参数3，加载的类库
  Classes=$3;
# 生成命令
  COMMOND="java \
    -jar ${TOOLS_TRANSFORM} init \
    -data=${JarFile} \
    -config=${Config} \
    -classes=${Classes};"
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
# 判断配置文件是否存在
    FILE_APP=${IBCP_DEPLOY}/${folder}/WEB-INF/app.xml
    if [ -e "${FILE_APP}" ]; then
# 使用模块目录jar包
      if [ -e "${IBCP_DEPLOY}/${folder}/WEB-INF/lib" ]
      then
        CLASSES=
        for file in `ls "${IBCP_DEPLOY}/${folder}/WEB-INF/lib" | grep \..jar`
        do
          CLASSES=${CLASSES}${file};
        done
        for file in `ls "${IBCP_DEPLOY}/${folder}/WEB-INF/lib" | grep ibcp\.${folder}\-.`
        do
          echo ----${file}
          FILE_DATA=${IBCP_DEPLOY}/${folder}/WEB-INF/lib/${file}
          initDatas ${FILE_DATA} ${FILE_APP} ${CLASSES};
          echo ----
        done
      fi;
# 使用共享目录jar包
      if [ -e "${IBCP_LIB}" ]
      then
        CLASSES=
        for file in `ls "${IBCP_LIB}" | grep \..jar`
        do
          CLASSES=${CLASSES}${file};
        done
        for file in `ls "${IBCP_LIB}" | grep ibcp\.${folder}\-.`
        do
          echo ----${file}
          FILE_DATA=${IBCP_LIB}/${file};
          initDatas ${FILE_DATA} ${FILE_APP} ${CLASSES};
          echo ----
        done
      fi;
    fi;
    echo --
  done < "${IBCP_DEPLOY}/ibcp.release.txt" | sed 's/\r//g'
echo 操作完成
