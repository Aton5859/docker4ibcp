#!/bin/bash
echo '****************************************************************************'
echo '    build_dockerfile4alls.sh                                                '
echo '                      by niuren.zhu                                         '
echo '                           2016.12.12                                       '
echo '  说明：                                                                    '
echo '    1. 批量构建镜像，调用所处子文件夹的build_dockerfile4all.sh。            '
echo '    2. 参数1，构建的镜像的标签，默认为时间戳。                              '
echo '****************************************************************************'
# 定义变量
TAG=$1
if [ "${TAG}" == "" ]; then TAG=$(date +%s); fi;
WORK_FOLDER=$PWD

# 遍历工作目录的build_dockerfile4all.sh文件
for folder in `ls -l ${WORK_FOLDER} | awk '/^d/{print $NF}'` # `ls -F | grep /$` 
do
  folder=${WORK_FOLDER}/${folder}
  if [ -e "${folder}/build_dockerfile4all.sh" ]; then
    cd ${folder}
    "${folder}/build_dockerfile4all.sh" ${TAG};
  fi;
done

