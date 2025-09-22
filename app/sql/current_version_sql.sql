-- 当前版本SQL脚本: 创建accounts表和app_info表

-- 创建accounts表
CREATE TABLE accounts (
    id NUMBER GENERATED ALWAYS AS IDENTITY START WITH 1 INCREMENT BY 1 PRIMARY KEY,
    username VARCHAR2(50) NOT NULL UNIQUE,
    email VARCHAR2(100) NOT NULL UNIQUE,
    department VARCHAR2(50) NOT NULL,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status VARCHAR2(10) DEFAULT 'active' NOT NULL,
    CONSTRAINT chk_status CHECK (status IN ('active', 'inactive'))
);

-- 创建app_info表
CREATE TABLE app_info (
    id NUMBER GENERATED ALWAYS AS IDENTITY START WITH 1 INCREMENT BY 1 PRIMARY KEY,
    schema_sql_version VARCHAR2(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- 添加表注释
COMMENT ON TABLE accounts IS '用户账户表';
COMMENT ON TABLE app_info IS '应用信息表';

-- 添加列注释
COMMENT ON COLUMN accounts.id IS '用户ID';
COMMENT ON COLUMN accounts.username IS '用户名';
COMMENT ON COLUMN accounts.email IS '邮箱';
COMMENT ON COLUMN accounts.department IS '部门';
COMMENT ON COLUMN accounts.create_time IS '创建时间';
COMMENT ON COLUMN accounts.status IS '状态(active/inactive)';

COMMENT ON COLUMN app_info.schema_sql_version IS '数据库模式版本号';
COMMENT ON COLUMN app_info.created_at IS '创建时间';
COMMENT ON COLUMN app_info.updated_at IS '更新时间';

-- 创建索引以提高查询性能
CREATE INDEX idx_accounts_username ON accounts(username);
CREATE INDEX idx_accounts_email ON accounts(email);
CREATE INDEX idx_accounts_status ON accounts(status);

-- 插入初始版本信息
INSERT INTO app_info (schema_sql_version) VALUES ('1.0.0');

-- 插入示例用户数据
INSERT INTO accounts (username, email, department, status) 
VALUES ('admin', 'admin@example.com', '管理员', 'active');

INSERT INTO accounts (username, email, department, status) 
VALUES ('user1', 'user1@example.com', '开发部', 'active');

INSERT INTO accounts (username, email, department, status) 
VALUES ('user2', 'user2@example.com', '测试部', 'active');

INSERT INTO accounts (username, email, department, status) 
VALUES ('user3', 'user3@example.com', '运维部', 'active');

INSERT INTO accounts (username, email, department, status) 
VALUES ('user4', 'user4@example.com', '产品部', 'active');

-- 提交事务
COMMIT;