-- ========================================================
-- 1. 修改 users 表：修改 phone 列，重新添加 CHECK 约束
-- ========================================================

-- 添加列注释
COMMENT ON COLUMN users.phone IS 'Contact phone (supports domestic 11-digit and international numbers, including + and -)';

-- 删除原有的 phone 格式检查约束（动态查找约束名）
DECLARE
   cons_name VARCHAR2(30);
BEGIN
   -- 通过列名定位检查约束
   SELECT constraint_name INTO cons_name
   FROM user_cons_columns
   WHERE table_name = 'USERS'
     AND column_name = 'PHONE'
     AND constraint_name IN (
         SELECT constraint_name
         FROM user_constraints
         WHERE table_name = 'USERS'
           AND constraint_type = 'C'
     )
     AND ROWNUM = 1;

   EXECUTE IMMEDIATE 'ALTER TABLE users DROP CONSTRAINT ' || cons_name;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      NULL; -- 约束不存在，无需删除
END;
/

-- 添加新的 phone 格式检查约束
ALTER TABLE users ADD CONSTRAINT chk_users_phone
   CHECK (REGEXP_LIKE(phone, '^(1[3-9][0-9]{9}|\+?[1-9][0-9]{1,14})$'));

-- ========================================================
-- 2. 修改 bookings 表：调整 status 约束，添加退款相关列和索引
-- ========================================================

-- 删除原有的 status 检查约束（动态查找）
DECLARE
   cons_name VARCHAR2(30);
   cons_cond VARCHAR2(32767);  -- 用于存储 search_condition 的内容（假设不超过 32767 字节）
   CURSOR c IS
      SELECT constraint_name, search_condition
      FROM user_constraints
      WHERE table_name = 'USERS'
        AND constraint_type = 'C';
BEGIN
   FOR rec IN c LOOP
      cons_cond := rec.search_condition;  -- LONG 隐式转换为 VARCHAR2
      -- 检查条件中是否包含 'phone' 和 'REGEXP'
      IF cons_cond LIKE '%phone%REGEXP%' OR cons_cond LIKE '%REGEXP%phone%' THEN
         cons_name := rec.constraint_name;
         EXECUTE IMMEDIATE 'ALTER TABLE users DROP CONSTRAINT ' || cons_name;
         EXIT;  -- 只删除第一个匹配的约束，与原逻辑一致
      END IF;
   END LOOP;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      NULL;  -- 无匹配约束时不操作（实际上游标循环不会触发此异常，保留以兼容原逻辑）
   WHEN OTHERS THEN
      NULL;  -- 可选择性处理其他异常，保持原风格
END;
/

-- 添加新的 status 检查约束（包含所有 ENUM 值）
ALTER TABLE bookings ADD CONSTRAINT bookings_status_check
   CHECK (status IN ('PENDING','PENDING_CONFIRMATION','PENDING_PAYMENT','CONFIRMED',
                     'CHECKED_IN','CHECKED_OUT','CANCELLED','REFUND_REQUESTED','REFUNDED'));

-- 添加列注释
COMMENT ON COLUMN bookings.refund_reason IS 'Refund reason';
COMMENT ON COLUMN bookings.refund_requested_at IS 'Refund request time';
COMMENT ON COLUMN bookings.refund_approved_at IS 'Refund approval time';
COMMENT ON COLUMN bookings.refund_rejected_at IS 'Refund rejection time';
COMMENT ON COLUMN bookings.refund_approved_by IS 'Refund approver ID';

-- 创建索引（原 ADD INDEX）
CREATE INDEX idx_bookings_refund_status ON bookings(status, refund_requested_at);

-- ========================================================
-- 3. 查询列信息（替代 SHOW COLUMNS）
-- ========================================================

SELECT column_name, data_type, data_length, nullable
FROM user_tab_columns
WHERE table_name = 'BOOKINGS' AND column_name = 'STATUS';

SELECT column_name
FROM user_tab_columns
WHERE table_name = 'BOOKINGS' AND column_name LIKE 'REFUND%';

SELECT 'Migration completed successfully' AS result FROM DUAL;

-- ========================================================
-- 4. 切换 schema（可选，原 USE hotel_db）
-- ========================================================
-- ALTER SESSION SET CURRENT_SCHEMA = hotel_db;

-- ========================================================
-- 5. 更新酒店图片 URL
-- ========================================================
UPDATE hotel
SET hero_image_url = '/images/hotels/xinghe-hero.jpg',
    gallery_images = '/images/hotels/xinghe-gallery0.jpg,/images/hotels/xinghe-gallery1.jpg'
WHERE id = 1;

UPDATE hotel
SET hero_image_url = '/images/hotels/xinghe-hero.jpg',
    gallery_images = '/images/hotels/xinghe-gallery0.jpg,/images/hotels/xinghe-gallery1.jpg'
WHERE id = 2;

UPDATE hotel
SET hero_image_url = '/images/hotels/xinghe-hero.jpg',
    gallery_images = '/images/hotels/xinghe-gallery0.jpg,/images/hotels/xinghe-gallery1.jpg'
WHERE id = 3;

-- ========================================================
-- 6. 重新插入房间图片数据
-- ========================================================
DELETE FROM room_images;

INSERT INTO room_images (room_type_id, url, is_primary, sort_order)
SELECT rt.id,
       urls.url,
       urls.is_primary,
       urls.sort_order
FROM room_type rt
JOIN (
    SELECT 1 AS seq, 'Galaxy Executive King Room' AS name, '/images/rooms/xinghe-exec-1.jpg' AS url, 1 AS is_primary, 1 AS sort_order FROM DUAL UNION ALL
    SELECT 2, 'Galaxy Executive King Room', '/images/rooms/xinghe-exec-2.jpg', 0, 2 FROM DUAL UNION ALL
    SELECT 3, 'Galaxy Executive King Room', '/images/rooms/xinghe-exec-3.jpg', 0, 3 FROM DUAL UNION ALL
    SELECT 4, 'Galaxy Family Suite', '/images/rooms/xinghe-family-1.jpg', 1, 1 FROM DUAL UNION ALL
    SELECT 5, 'Galaxy Family Suite', '/images/rooms/xinghe-family-2.jpg', 0, 2 FROM DUAL UNION ALL
    SELECT 6, 'Galaxy Family Suite', '/images/rooms/xinghe-family-3.jpg', 0, 3 FROM DUAL UNION ALL
    SELECT 7, 'Galaxy City View Room', '/images/rooms/xinghe-city-1.jpg', 1, 1 FROM DUAL UNION ALL
    SELECT 8, 'Galaxy City View Room', '/images/rooms/xinghe-city-2.jpg', 0, 2 FROM DUAL UNION ALL
    SELECT 9, 'Haitan Ocean View Room', '/images/rooms/xinghe-exec-1.jpg', 1, 1 FROM DUAL UNION ALL
    SELECT 10, 'Haitan Ocean View Room', '/images/rooms/xinghe-exec-2.jpg', 0, 2 FROM DUAL UNION ALL
    SELECT 11, 'Haitan Family Fun Room', '/images/rooms/xinghe-family-1.jpg', 1, 1 FROM DUAL UNION ALL
    SELECT 12, 'Haitan Family Fun Room', '/images/rooms/xinghe-family-2.jpg', 0, 2 FROM DUAL UNION ALL
    SELECT 13, 'Haitan Sky Suite', '/images/rooms/xinghe-city-1.jpg', 1, 1 FROM DUAL UNION ALL
    SELECT 14, 'Haitan Sky Suite', '/images/rooms/xinghe-city-2.jpg', 0, 2 FROM DUAL UNION ALL
    SELECT 15, 'Yunqi Hot Spring King Room', '/images/rooms/xinghe-exec-1.jpg', 1, 1 FROM DUAL UNION ALL
    SELECT 16, 'Yunqi Hot Spring King Room', '/images/rooms/xinghe-exec-2.jpg', 0, 2 FROM DUAL UNION ALL
    SELECT 17, 'Yunqi Forest Chalet', '/images/rooms/xinghe-family-1.jpg', 1, 1 FROM DUAL UNION ALL
    SELECT 18, 'Yunqi Forest Chalet', '/images/rooms/xinghe-family-2.jpg', 0, 2 FROM DUAL UNION ALL
    SELECT 19, 'Yunqi Zen Suite', '/images/rooms/xinghe-city-1.jpg', 1, 1 FROM DUAL UNION ALL
    SELECT 20, 'Yunqi Zen Suite', '/images/rooms/xinghe-city-2.jpg', 0, 2 FROM DUAL
) urls ON urls.name = rt.name;

-- ========================================================
-- 7. 更新 room_type 的 images 字段，使用 LISTAGG 拼接图片 URL
-- ========================================================
UPDATE room_type rt
SET images = (
    SELECT LISTAGG(url, ',') WITHIN GROUP (ORDER BY sort_order)
    FROM room_images ri
    WHERE ri.room_type_id = rt.id
);

-- ========================================================
-- 8. 验证更新结果
-- ========================================================
SELECT id, name, hero_image_url, gallery_images FROM hotel;
SELECT id, name, images FROM room_type;

SELECT 'Image URLs updated successfully!' AS status FROM DUAL;

COMMIT;