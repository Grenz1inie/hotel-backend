-- ============================================
-- 图片URL更新脚本
-- 用途：将数据库中的图片URL从网络链接更新为本地路径
-- 执行方法：在MySQL客户端或工具中执行此脚本
-- ============================================

USE hotel_db;

-- 1. 更新酒店表的图片URL
-- 星河国际酒店
UPDATE hotel 
SET hero_image_url = '/images/hotels/xinghe-hero.jpg',
    gallery_images = '/images/hotels/xinghe-gallery0.jpg,/images/hotels/xinghe-gallery1.jpg'
WHERE id = 1;

-- 海天假日酒店（临时使用星河图片）
UPDATE hotel 
SET hero_image_url = '/images/hotels/xinghe-hero.jpg',
    gallery_images = '/images/hotels/xinghe-gallery0.jpg,/images/hotels/xinghe-gallery1.jpg'
WHERE id = 2;

-- 云栖温泉度假村（临时使用星河图片）
UPDATE hotel 
SET hero_image_url = '/images/hotels/xinghe-hero.jpg',
    gallery_images = '/images/hotels/xinghe-gallery0.jpg,/images/hotels/xinghe-gallery1.jpg'
WHERE id = 3;

-- 2. 更新房型图片URL
-- 先删除旧的图片数据
DELETE FROM room_images;

-- 重新插入带本地路径的图片数据
INSERT INTO room_images (room_type_id, url, is_primary, sort_order)
SELECT rt.id,
       urls.url,
       urls.is_primary,
       urls.sort_order
FROM room_type rt
JOIN (
    -- 星河国际酒店房型
    SELECT 1 AS seq, '星河行政大床房' AS name, '/images/rooms/xinghe-exec-1.jpg' AS url, 1 AS is_primary, 1 AS sort_order
    UNION ALL SELECT 2, '星河行政大床房', '/images/rooms/xinghe-exec-2.jpg', 0, 2
    UNION ALL SELECT 3, '星河行政大床房', '/images/rooms/xinghe-exec-3.jpg', 0, 3
    UNION ALL SELECT 4, '星河家庭套房', '/images/rooms/xinghe-family-1.jpg', 1, 1
    UNION ALL SELECT 5, '星河家庭套房', '/images/rooms/xinghe-family-2.jpg', 0, 2
    UNION ALL SELECT 6, '星河家庭套房', '/images/rooms/xinghe-family-3.jpg', 0, 3
    UNION ALL SELECT 7, '星河城市景观房', '/images/rooms/xinghe-city-1.jpg', 1, 1
    UNION ALL SELECT 8, '星河城市景观房', '/images/rooms/xinghe-city-2.jpg', 0, 2
    -- 海天假日酒店房型（临时使用星河图片）
    UNION ALL SELECT 9, '海天无边海景房', '/images/rooms/xinghe-exec-1.jpg', 1, 1
    UNION ALL SELECT 10, '海天无边海景房', '/images/rooms/xinghe-exec-2.jpg', 0, 2
    UNION ALL SELECT 11, '海天亲子乐园房', '/images/rooms/xinghe-family-1.jpg', 1, 1
    UNION ALL SELECT 12, '海天亲子乐园房', '/images/rooms/xinghe-family-2.jpg', 0, 2
    UNION ALL SELECT 13, '海天尊享套房', '/images/rooms/xinghe-city-1.jpg', 1, 1
    UNION ALL SELECT 14, '海天尊享套房', '/images/rooms/xinghe-city-2.jpg', 0, 2
    -- 云栖温泉度假村房型（临时使用星河图片）
    UNION ALL SELECT 15, '云栖温泉大床房', '/images/rooms/xinghe-exec-1.jpg', 1, 1
    UNION ALL SELECT 16, '云栖温泉大床房', '/images/rooms/xinghe-exec-2.jpg', 0, 2
    UNION ALL SELECT 17, '云栖森林木屋', '/images/rooms/xinghe-family-1.jpg', 1, 1
    UNION ALL SELECT 18, '云栖森林木屋', '/images/rooms/xinghe-family-2.jpg', 0, 2
    UNION ALL SELECT 19, '云栖禅意套房', '/images/rooms/xinghe-city-1.jpg', 1, 1
    UNION ALL SELECT 20, '云栖禅意套房', '/images/rooms/xinghe-city-2.jpg', 0, 2
) urls ON urls.name = rt.name;

-- 3. 将多图聚合回房型表 images 字段
SET @old_len := @@SESSION.group_concat_max_len;
SET SESSION group_concat_max_len = 8192;

UPDATE room_type rt
SET images = (
    SELECT GROUP_CONCAT(url ORDER BY sort_order SEPARATOR ',')
    FROM room_images ri
    WHERE ri.room_type_id = rt.id
);

SET SESSION group_concat_max_len = @old_len;

-- 验证更新结果
SELECT id, name, hero_image_url, gallery_images FROM hotel;
SELECT id, name, images FROM room_type;

-- 完成
SELECT '图片URL更新完成！' AS status;
