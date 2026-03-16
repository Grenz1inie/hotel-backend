-- 数据库迁移脚本：支持国际电话号码
-- 执行日期：2025-10-12
-- 说明：将phone字段从VARCHAR(11)扩展到VARCHAR(20)，并更新校验规则以支持国际号码

-- 1. 修改users表的phone字段长度和约束
ALTER TABLE users 
    MODIFY COLUMN phone VARCHAR(20) NOT NULL COMMENT '联系电话（支持国内11位和国际号码，含+和-）';

-- 2. 删除旧的phone格式约束
ALTER TABLE users 
    DROP CONSTRAINT IF EXISTS chk_phone_format;

-- 3. 添加新的phone格式约束（支持国内和国际号码）
-- 国内：1[3-9]开头的11位数字
-- 国际：可选的+号，后跟1-9开头的1-15位数字
ALTER TABLE users 
    ADD CONSTRAINT chk_phone_format 
    CHECK (phone REGEXP '^(1[3-9][0-9]{9}|\\+?[1-9][0-9]{1,14})$');

-- 4. 验证现有数据（可选，用于检查是否有不符合新规则的数据）
-- SELECT id, username, phone FROM users WHERE phone NOT REGEXP '^(1[3-9][0-9]{9}|\\+?[1-9][0-9]{1,14})$';

-- 注意：
-- - bookings表的contact_phone已经是VARCHAR(30)，无需修改
-- - hotel表的phone已经是VARCHAR(20)，无需修改
-- - 此脚本适用于MySQL 8.0+
-- - 执行前请备份数据库
