-- Oracle数据库初始化脚本
-- 创建ouser用户，密码为ouser，并授予操作表的权限

-- 创建用户
begin
  execute immediate 'CREATE USER ouser IDENTIFIED BY ouser';
  exception when others then
    if sqlcode = -1920 then
      execute immediate 'ALTER USER ouser IDENTIFIED BY ouser';
    else
      raise;
    end if;
end;
/

-- 授予基本权限
grant connect, resource to ouser;

-- 授予操作表的权限
grant create table to ouser;
grant create view to ouser;
grant create procedure to ouser;
grant create sequence to ouser;

alter user ouser quota unlimited on users;

-- 授予对现有表的操作权限（如果需要）
-- grant select, insert, update, delete on schema_name.table_name to ouser;