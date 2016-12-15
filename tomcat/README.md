# docker4ibcp tomcat
为ibcp创建的docker4tomcat相关内容。

### 鼓励师 | encourager
[![encourager]](https://github.com/niurenzhu/docker4ibcp/blob/master/encourager.gif)  
[encourager]:https://github.com/niurenzhu/docker4ibcp/blob/master/encourager.gif "unknown"
* 姓名：NA
* 生日：NA
* 国籍：NA

### 使用说明 | instructions
* build_dockerfile4all.sh                   使用dockerfile4all创建容器镜像，且拷贝ibcp.*文件到容器的ibcp配置目录。
* deploy_ibcp_all.sh/bat                    下载并部署ibcp全部模块。
* initialize_datastructures.sh/bat          初始化数据结构。
* 使用时注意提前修改ibcp配置文件。
```
ibcp.app.xml                                ibcp服务配置
ibcp.service_routing.xml                    ibcp模块配置
ibcp.config.json                            ibcp前端配置
```
* 使用时注意提前修改tomcat配置文件。
```
ibcp.catalina.properties                    tomcat容器配置
ibcp.server.xml                             tomcat服务配置
ibcp.context.xml                            tomcat内容配置，务必打开允许软连接<Resources allowLinking="true" />。
```
* 测试环境时，配置文件中涉及的主机，建议修改本机host文件指向。
* 脚本中使用了额外文件作为任务执行顺序，详见各自内容。
* Windows环境下需要解压[wget](https://github.com/niurenzhu/docker4ibcp/blob/master/wget-win32.zip)并配置到PATH。

### 启动 | running
```
docker run --name ibcp-srv-db -p 3306:3306 -d -e MYSQL_ROOT_PASSWORD=1q2w3e mysql:5.7                             启动MYSQL容器
docker run --name=ibcp-srv-app-01 --link=ibcp-srv-db:ibcp-srv-db -p 8080:8080 -d ibcp-tomcat-all:1476945979       启动TOMCAT容器，并连接MYSQL容器。
docker exec -it ibcp-srv-app-01 ./ibcp_tools/initialize_datastructures.sh                                         执行创建数据结构
```

### 鸣谢 | thanks
[牛加人等于朱](http://baike.baidu.com/view/1769.htm "NiurenZhu")<br>
[Color-Coding](http://colorcoding.org/ "咔啦工作室")<br>
