# 使用Python官方镜像作为基础镜像
# FROM python:3.10-slim
# 使用为本次 POC 准备的 OCIR中镜像可以避免被官方仓库限流
FROM iad.ocir.io/sehubjapacprod/wilbur/python:3.10-slim-x86

# 设置工作目录
WORKDIR /app

# 更新apt并安装必要的系统依赖
# 安装gcc和g++是因为oracledb库在安装过程中可能需要编译部分组件
# RUN apt-get update && \n    apt-get install -y --no-install-recommends gcc g++ && \n    rm -rf /var/lib/apt/lists/*

# 复制requirements.txt文件
COPY server/requirements.txt .

# 安装Python依赖
RUN pip install --no-cache-dir -r requirements.txt

# 复制应用程序代码
COPY server/ .

# 复制静态文件
COPY server/static/ /app/static/

# 暴露应用端口
EXPOSE 8080

# 启动应用
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080"]