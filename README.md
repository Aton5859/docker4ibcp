# docker4ibcp
为ibcp创建的docker相关内容。

### 鼓励师 | encourager
[![encourager]](https://github.com/niurenzhu/docker4ibcp/blob/master/encourager.gif)  
[encourager]:https://github.com/niurenzhu/docker4ibcp/blob/master/encourager.gif "unknown"
* 姓名：NA
* 生日：NA
* 国籍：NA

### 使用说明 | instructions
* tomcat   tomcat相关东东，详见文件夹内README.MD
* nginx    nginx相关东东，详见文件夹内README.MD
* build_dockerfile4alls.sh    批量构建镜像，调用每个子文件夹的build_dockerfile4all.sh。

### 启动 | running
* docker run --name ibcp-srv-db -p 3306:3306 -d -e MYSQL_ROOT_PASSWORD=1q2w3e mysql:5.7          启动MYSQL容器
* docker run --name=ibcp-srv-app-01 --link=ibcp-srv-db -p 8080:8080 -d ibcp-all:1476945979       启动ibcp容器
* docker exec -it ibcp-srv-app-01 ./ibcp_tools/initialize_datastructures.sh                      执行ibcp容器中数据结构

* 修改访问主机host：192.168.3.60    ibcp-srv-app

### 鸣谢 | thanks
[牛加人等于朱](http://baike.baidu.com/view/1769.htm "NiurenZhu")<br>
[Color-Coding](http://colorcoding.org/ "咔啦工作室")<br>
