#!/bin/bash
echo '*************************************************************************************'
echo '         deploy_ibcp_all.sh                                                          '
echo '                      by niuren.zhu                                                  '
echo '                           2016.10.20                                                '
echo '  说明：                                                                             '
echo '    1. 下载并部署IBCP的WAR到部署目录。                                               '
echo '    2. 参数1，IBCP数据目录，默认.\ibcp。                                             '
echo '    3. 参数2，IBCP的包位置，默认.\ibcp_packages。                                    '
echo '    4. 参数3，IBCP部署目录，默认.\webapps。                                          '
echo '    5. 参数4，IBCP共享库目录，默认.\ibcp_lib。                                       '
echo '    6. 脚本通文件链接方式，集中配置文件和日志目录到IBCP_HOME下。                     '
echo '    7. 请调整catalina.properties的shared.loader="${catalina.home}/ibcp_lib/*.jar"。  '
echo '*************************************************************************************'
# 定义变量
# 工作目录
WORK_FOLDER=$PWD
# 设置ibcp目录
IBCP_HOME=$1
if [ "${IBCP_HOME}" == "" ];then IBCP_HOME=${WORK_FOLDER}/ibcp; fi;
if [ ! -e "${IBCP_HOME}" ];then mkdir -p "${IBCP_HOME}"; fi;
# ibcp配置目录
IBCP_CONF=${IBCP_HOME}/conf
if [ ! -e "${IBCP_CONF}" ];then mkdir -p "${IBCP_CONF}"; fi;
# ibcp数据目录
IBCP_DATA=${IBCP_HOME}/data
if [ ! -e "${IBCP_DATA}" ];then mkdir -p "${IBCP_DATA}"; fi;
# ibcp日志目录
IBCP_LOG=${IBCP_HOME}/log
if [ ! -e "${IBCP_LOG}" ];then mkdir -p "${IBCP_LOG}"; fi;
# 设置IBCP_PACKAGE目录
IBCP_PACKAGE=$2
if [ "${IBCP_PACKAGE}" == "" ];then IBCP_PACKAGE=${WORK_FOLDER}/ibcp_packages/$(date +%s); fi;
if [ ! -e "${IBCP_PACKAGE}" ];then mkdir -p "${IBCP_PACKAGE}"; fi;
# 设置IBCP_DEPLOY目录
IBCP_DEPLOY=$3
if [ "${IBCP_DEPLOY}" == "" ];then IBCP_DEPLOY=${WORK_FOLDER}/webapps; fi;
if [ ! -e "${IBCP_DEPLOY}" ];then mkdir -p "${IBCP_DEPLOY}"; fi;
# 设置IBCP_LIB目录
IBCP_LIB=$4
if [ "${IBCP_LIB}" == "" ];then IBCP_LIB=${WORK_FOLDER}/ibcp_lib; fi;
if [ ! -e "${IBCP_LIB}" ];then mkdir -p "${IBCP_LIB}"; fi;

# 程序包-发布服务地址
IBCP_PACKAGE_URL=http://ibas.club:8866/ibcp
# 程序包-发布服务用户名
IBCP_PACKAGE_USER=avatech/\amber
# 程序包-发布服务用户密码
IBCP_PACKAGE_PASSWORD=Aa123456
# 程序包-版本路径
IBCP_PACKAGE_VERSION=latest
# 程序包-下载目录
IBCP_PACKAGE_DOWNLOAD=${IBCP_PACKAGE}

# 显示参数信息
echo ----------------------------------------------------
echo 下载地址：${IBCP_PACKAGE_URL}/${IBCP_PACKAGE_VERSION}/
echo 下载目录：${IBCP_PACKAGE_DOWNLOAD}
echo 部署目录：${IBCP_DEPLOY}
echo 共享目录：${IBCP_LIB}
echo 数据目录：${IBCP_HOME}
echo ----------------------------------------------------

# 下载ibcp
echo 开始下载模块，从${IBCP_PACKAGE_URL}/${IBCP_PACKAGE_VERSION}/
wget -r -np -nd -nv -P ${IBCP_PACKAGE_DOWNLOAD} --http-user=${IBCP_PACKAGE_USER} --http-password=${IBCP_PACKAGE_PASSWORD} ${IBCP_PACKAGE_URL}/${IBCP_PACKAGE_VERSION}/
# 排序
if [ ! -e "${IBCP_PACKAGE_DOWNLOAD}/ibcp.deploy.order.txt" ]; then
    ls -l "${IBCP_PACKAGE_DOWNLOAD}/*.war" | awk '//{print $NF}' >>"${IBCP_PACKAGE_DOWNLOAD}/ibcp.deploy.order.txt";
fi;
echo 开始解压模块，到目录${IBCP_DEPLOY}
while read file
  do
    file=${file%%.war*}.war
    echo 释放"${IBCP_PACKAGE_DOWNLOAD}/${file}"
# 修正war包的解压目录
    folder=${file##*ibcp.}
    folder=${folder%%.service*}
# 记录释放的目录到ibcp.release.txt，此文件为部署顺序说明。
    if [ ! -e "${IBCP_DEPLOY}/ibcp.release.txt" ]; then :>"${IBCP_DEPLOY}/ibcp.release.txt"; fi;
    grep -q ${folder} "${IBCP_DEPLOY}/ibcp.release.txt" || echo "${folder}" >>"${IBCP_DEPLOY}/ibcp.release.txt"
# 解压war包到目录
    unzip -o "${IBCP_PACKAGE_DOWNLOAD}/${file}" -d "${IBCP_DEPLOY}/${folder}"
# 删除配置文件，并映射到统一位置
    if [ -e "${IBCP_DEPLOY}/${folder}/WEB-INF/app.xml" ]; then
      if [ ! -e "${IBCP_CONF}/app.xml" ]; then cp -f "${IBCP_DEPLOY}/${folder}/WEB-INF/app.xml" "${IBCP_CONF}/app.xml"; fi;
      rm -f "${IBCP_DEPLOY}/${folder}/WEB-INF/app.xml"
      ln -s "${IBCP_CONF}/app.xml" "${IBCP_DEPLOY}/${folder}/WEB-INF/app.xml"
    fi;
# 删除服务路由文件，并映射到统一位置
    if [ -e "${IBCP_DEPLOY}/${folder}/WEB-INF/service_routing.xml" ]; then
      if [ ! -e "${IBCP_CONF}/service_routing.xml" ]; then cp -f "${IBCP_DEPLOY}/${folder}/WEB-INF/service_routing.xml" "${IBCP_CONF}/service_routing.xml"; fi;
      rm -f "${IBCP_DEPLOY}/${folder}/WEB-INF/service_routing.xml"
      ln -s "${IBCP_CONF}/service_routing.xml" "${IBCP_DEPLOY}/${folder}/WEB-INF/service_routing.xml"
    fi
# 映射日志文件夹到统一位置
    if [ -e "${IBCP_DEPLOY}/${folder}/WEB-INF/log" ]; then rm -rf "${IBCP_DEPLOY}/${folder}/WEB-INF/log"; fi;
    ln -s -d "${IBCP_LOG}" "${IBCP_DEPLOY}/${folder}/WEB-INF/"
# 集中共享jar包
    if [ -e "${IBCP_LIB}" ]
    then
# 复制模块jar包到tomcat的lib目录
      cp -f "${IBCP_DEPLOY}/${folder}/WEB-INF/lib/"*.jar "${IBCP_LIB}";
# 清除tomcat的lib已经存在的jar包
      rm -f "${IBCP_DEPLOY}/${folder}/WEB-INF/lib/"*.jar;
    fi;
  done < "${IBCP_PACKAGE_DOWNLOAD}/ibcp.deploy.order.txt" | sed 's/\r//g';
echo 操作完成
