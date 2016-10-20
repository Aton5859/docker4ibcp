# docker4ibcp
为ibcp创建的docker相关内容。

### 鼓励师 | encourager
[![encourager]](https://github.com/niurenzhu/docker4ibcp/blob/master/encourager.gif)  
[encourager]:https://github.com/niurenzhu/docker4ibcp/blob/master/encourager.gif "unknown"
* 姓名：NA
* 生日：NA
* 国籍：NA

### 使用说明 | instructions
* build_dockerfile4all.sh      使用dockerfile4all创建容器镜像，且拷贝ibcp.app.xml，ibcp.service_routing.xml到容器的ibcp配置目录。
* deploy_ibcp_all.sh           下载并部署ibcp全部模块。
* 使用时注意提前修改配置文件内容。
* 测试环境时，配置文件中涉及的主机，建议修改本机host文件指向。

### 启动 | running
* docker run --name ibcp-srv-db -p 3306:3306 -d -e MYSQL_ROOT_PASSWORD=1q2w3e mysql:5.7
* docker run --name=ibcp-srv-app-01 --link=ibcp-srv-db -p 8080:8080 -d ibcp-all:1476945979

* 修改访问主机host：192.168.3.60    ibcp-srv-app

### 鸣谢 | thanks
[牛加人等于朱](http://baike.baidu.com/view/1769.htm "NiurenZhu")<br>
[Color-Coding](http://colorcoding.org/ "咔啦工作室")<br>
