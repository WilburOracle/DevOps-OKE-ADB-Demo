from fastapi import FastAPI, HTTPException
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
import os
import oracledb
from pydantic import BaseModel
from typing import List, Optional, Dict, Any

# 应用版本号
APP_VERSION = "1.0.0"

app = FastAPI(title="用户管理系统", version=APP_VERSION)

# 挂载静态文件目录
app.mount("/static", StaticFiles(directory="static"), name="static")

# 数据库配置
DB_USER = os.environ.get('DB_USER', 'admin')
DB_PASSWORD = os.environ.get('DB_PASSWORD', 'Oracle1234567')
DB_DSN = os.environ.get('DB_DSN', '(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1521)(host=kf4c11fo.adb.us-ashburn-1.oraclecloud.com))(connect_data=(service_name=n7djxxqbnkflnvn_adbdemo_high.adb.oraclecloud.com))(security=(ssl_server_dn_match=no)))')

# 数据库连接池
pool = None

def init_db_pool():
    global pool
    try:
        # 使用Thin Mode连接Oracle数据库
        pool = oracledb.create_pool(
            user=DB_USER,
            password=DB_PASSWORD,
            dsn=DB_DSN,
            min=2,
            max=10,
            increment=1,
            edition=None,
            events=False,
            homogeneous=True,
            retry_count=0,
            retry_delay=3,
            timeout=0,
            session_callback=None,
            tag=None,
            matchanytag=False,
            cclass=None,
            purity=oracledb.PURITY_DEFAULT,
            wait_timeout=None,
            max_lifetime_session=0
        )
        print("数据库连接池初始化成功")
        return True
    except Exception as e:
        print(f"数据库连接池初始化失败: {e}")
        return False

# 应用启动时初始化数据库连接池
@app.on_event("startup")
async def startup_event():
    init_db_pool()

# 健康检查接口
@app.get("/health", tags=["系统"], summary="健康检查")
async def health_check():
    return {"status": "healthy", "version": APP_VERSION}

# 根接口 - 返回版本信息
@app.get("/api/", tags=["系统"], summary="获取版本信息")
async def get_version_info():
    schema_sql_version = "未连接数据库"
    
    try:
        if pool is None:
            if not init_db_pool():
                raise HTTPException(status_code=500, detail="数据库连接池初始化失败")
        
        # 查询数据库版本信息
        with pool.acquire() as connection:
            with connection.cursor() as cursor:
                try:
                    cursor.execute("SELECT schema_sql_version FROM app_info WHERE rownum = 1")
                    result = cursor.fetchone()
                    if result:
                        schema_sql_version = result[0]
                except oracledb.Error as e:
                    print(f"查询数据库版本失败: {e}")
                    schema_sql_version = "表未初始化"
    except Exception as e:
        print(f"获取版本信息失败: {e}")
    
    return {
        "app_version": APP_VERSION,
        "schema_sql_version": schema_sql_version
    }

# 用户模型
class User(BaseModel):
    id: int
    username: str
    email: str
    department: str
    create_time: str
    status: str

# 获取用户列表接口
@app.get("/api/accounts", tags=["用户"], summary="获取用户列表")
async def get_accounts() -> Dict[str, Any]:
    try:
        if pool is None:
            if not init_db_pool():
                raise HTTPException(status_code=500, detail="数据库连接池初始化失败")
        
        with pool.acquire() as connection:
            with connection.cursor() as cursor:
                try:
                    # 查询用户表数据
                    cursor.execute("SELECT id, username, email, department, TO_CHAR(create_time, 'YYYY-MM-DD HH24:MI:SS'), status FROM accounts")
                    columns = [col[0] for col in cursor.description]
                    users = []
                    
                    for row in cursor.fetchall():
                        user_dict = dict(zip(columns, row))
                        users.append({
                            "id": user_dict["ID"],
                            "username": user_dict["USERNAME"],
                            "email": user_dict["EMAIL"],
                            "department": user_dict["DEPARTMENT"],
                            "create_time": user_dict["TO_CHAR(CREATE_TIME,'YYYY-MM-DDHH24:MI:SS')"],
                            "status": user_dict["STATUS"]
                        })
                    
                    # 如果没有数据，返回模拟数据
                    if not users:
                        users = [
                            {"id": 1, "username": "admin", "email": "admin@example.com", "department": "管理员", "create_time": "2023-01-01 10:00:00", "status": "active"},
                            {"id": 2, "username": "user1", "email": "user1@example.com", "department": "开发部", "create_time": "2023-01-02 11:30:00", "status": "active"},
                            {"id": 3, "username": "user2", "email": "user2@example.com", "department": "测试部", "create_time": "2023-01-03 14:15:00", "status": "active"}
                        ]
                        
                    return {"success": True, "data": users}
                except oracledb.Error as e:
                    print(f"查询用户数据失败: {e}")
                    # 表不存在或其他数据库错误时返回模拟数据
                    users = [
                        {"id": 1, "username": "admin", "email": "admin@example.com", "department": "管理员", "create_time": "2023-01-01 10:00:00", "status": "active"},
                        {"id": 2, "username": "user1", "email": "user1@example.com", "department": "开发部", "create_time": "2023-01-02 11:30:00", "status": "active"},
                        {"id": 3, "username": "user2", "email": "user2@example.com", "department": "测试部", "create_time": "2023-01-03 14:15:00", "status": "active"}
                    ]
                    return {"success": True, "data": users}
    except Exception as e:
        print(f"获取用户列表失败: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# 首页路由 - 返回index.html
@app.get("/", tags=["首页"], include_in_schema=False)
async def read_root():
    return FileResponse("static/index.html")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)