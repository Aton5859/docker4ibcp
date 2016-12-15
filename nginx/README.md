# docker4ibcp nginx
为ibcp创建的docker4nginx相关内容。

### 鼓励师 | encourager
[![encourager]](https://github.com/niurenzhu/docker4ibcp/blob/master/encourager.gif)  
[encourager]:https://github.com/niurenzhu/docker4ibcp/blob/master/encourager.gif "unknown"
* 姓名：NA
* 生日：NA
* 国籍：NA

### 使用说明 | instructions
* 使用时注意提前修改配置文件内容。
```
ibcp.nginx.conf                             nginx服务配置，默认转发非静态请求到ibcp-srv-tomcat。
```
* 测试环境时，配置文件中涉及的主机，建议修改本机host文件指向。
* Windows环境下需要解压[wget](https://github.com/niurenzhu/docker4ibcp/blob/master/wget-win32.zip)并配置到PATH。

### 启动 | running
```
docker run --name ibcp-srv-db -p 3306:3306 -d -e MYSQL_ROOT_PASSWORD=1q2w3e mysql:5.7                             启动MYSQL容器
docker run --name=ibcp-srv-app-01 --link=ibcp-srv-db:ibcp-srv-db -p 8080:8080 -d ibcp-tomcat-all:1476945979       启动TOMCAT容器，并连接MYSQL容器。
docker run --name=ibcp-srv-pxy-01 --link=ibcp-srv-app-01:ibcp-srv-tomcat -p 80:80 -d ibcp-nginx-all:1476945979    启动NGINX容器，并连接TOMCAT容器。
```


### 鸣谢 | thanks
[牛加人等于朱](http://baike.baidu.com/view/1769.htm "NiurenZhu")<br>
[Color-Coding](http://colorcoding.org/ "咔啦工作室")<br>
