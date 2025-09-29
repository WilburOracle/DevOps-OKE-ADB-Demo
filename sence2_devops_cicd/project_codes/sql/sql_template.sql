-- SQL模板，用于更新应用版本号

-- 更新app_info表中的版本号
UPDATE app_info
SET schema_sql_version = '<<APP_VERSION>>',
    updated_at = CURRENT_TIMESTAMP
WHERE id = 1;

-- 提交事务
COMMIT;
exit;