-- schema.sql (enhanced)
-- 安全清理
SET FOREIGN_KEY_CHECKS = 0;

-- 数据库
CREATE DATABASE IF NOT EXISTS hotel_db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE hotel_db;

-- 丢弃旧表（先子后父）
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS room_inventory;
DROP TABLE IF EXISTS room_images;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS rooms;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;

-- 用户表
CREATE TABLE users
(
    id         BIGINT PRIMARY KEY AUTO_INCREMENT,
    username   VARCHAR(100)               NOT NULL,
    password   VARCHAR(255)               NOT NULL,
    role       ENUM ('ADMIN','USER')      NOT NULL DEFAULT 'USER',
    vip_level  TINYINT                    NOT NULL DEFAULT 0,
    phone      VARCHAR(30),
    email      VARCHAR(255),
    status     ENUM ('ACTIVE','DISABLED') NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP                  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP                  NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_users_username (username)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

-- 房型表（保留 images 文本用于兼容；新增 room_images 管理多图）
CREATE TABLE rooms
(
    id              BIGINT PRIMARY KEY AUTO_INCREMENT,
    name            VARCHAR(255)   NOT NULL,
    type            VARCHAR(100)   NOT NULL,
    total_count     INT            NOT NULL DEFAULT 0,
    available_count INT            NOT NULL DEFAULT 0,
    price_per_night DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    images          TEXT,
    description     TEXT,
    amenities       JSON           NULL,
    area_sqm        DECIMAL(6, 2)  NULL,
    bed_type        VARCHAR(50),
    max_guests      INT            NOT NULL DEFAULT 2,
    is_active       TINYINT(1)     NOT NULL DEFAULT 1,
    created_at      TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_rooms_type (type),
    INDEX idx_rooms_active (is_active)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

-- 房型图片（多图）
CREATE TABLE room_images
(
    id         BIGINT PRIMARY KEY AUTO_INCREMENT,
    room_id    BIGINT        NOT NULL,
    url        VARCHAR(1000) NOT NULL,
    is_primary TINYINT(1)    NOT NULL DEFAULT 0,
    sort_order INT           NOT NULL DEFAULT 0,
    created_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_room_images_room FOREIGN KEY (room_id) REFERENCES rooms (id) ON DELETE CASCADE,
    INDEX idx_room_images_room (room_id),
    INDEX idx_room_images_primary (room_id, is_primary)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

-- 房型逐日库存与售价
CREATE TABLE room_inventory
(
    id              BIGINT PRIMARY KEY AUTO_INCREMENT,
    room_id         BIGINT                 NOT NULL,
    date            DATE                   NOT NULL,
    available_count INT                    NOT NULL,
    price           DECIMAL(10, 2)         NOT NULL,
    status          ENUM ('OPEN','CLOSED') NOT NULL DEFAULT 'OPEN',
    created_at      TIMESTAMP              NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP              NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_room_date (room_id, date),
    CONSTRAINT fk_room_inventory_room FOREIGN KEY (room_id) REFERENCES rooms (id) ON DELETE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

-- 订单
CREATE TABLE bookings
(
    id            BIGINT PRIMARY KEY AUTO_INCREMENT,
    room_id       BIGINT                                                                         NOT NULL,
    user_id       BIGINT                                                                         NOT NULL,
    start_time    DATETIME                                                                       NOT NULL,
    end_time      DATETIME                                                                       NOT NULL,
    check_in      DATETIME AS (start_time) VIRTUAL,
    check_out     DATETIME AS (end_time) VIRTUAL,
    nights        INT AS (GREATEST(0, DATEDIFF(end_time, start_time))) VIRTUAL,
    status        ENUM ('PENDING','CONFIRMED','CHECKED_IN','CHECKED_OUT','CANCELLED','REFUNDED') NOT NULL DEFAULT 'PENDING',
    guests        INT                                                                            NOT NULL DEFAULT 1,
    amount        DECIMAL(10, 2)                                                                 NOT NULL DEFAULT 0.00,
    currency      CHAR(3)                                                                        NOT NULL DEFAULT 'CNY',
    contact_name  VARCHAR(100),
    contact_phone VARCHAR(30),
    remark        VARCHAR(500),
    created_at    TIMESTAMP                                                                      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP                                                                      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_bookings_room FOREIGN KEY (room_id) REFERENCES rooms (id),
    CONSTRAINT fk_bookings_user FOREIGN KEY (user_id) REFERENCES users (id),
    INDEX idx_bookings_user (user_id),
    INDEX idx_bookings_room (room_id),
    INDEX idx_bookings_status (status),
    INDEX idx_bookings_date (start_time, end_time)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

-- 支付
CREATE TABLE payments
(
    id             BIGINT PRIMARY KEY AUTO_INCREMENT,
    booking_id     BIGINT                                      NOT NULL,
    pay_method     ENUM ('WECHAT','ALIPAY','CARD','CASH')      NOT NULL,
    amount         DECIMAL(10, 2)                              NOT NULL,
    currency       CHAR(3)                                     NOT NULL DEFAULT 'CNY',
    status         ENUM ('INIT','SUCCESS','FAILED','REFUNDED') NOT NULL DEFAULT 'INIT',
    transaction_no VARCHAR(128),
    paid_at        DATETIME                                    NULL,
    created_at     TIMESTAMP                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP                                   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_booking_payment (booking_id),
    CONSTRAINT fk_payments_booking FOREIGN KEY (booking_id) REFERENCES bookings (id) ON DELETE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

-- 评价
CREATE TABLE reviews
(
    id         BIGINT PRIMARY KEY AUTO_INCREMENT,
    booking_id BIGINT    NOT NULL,
    room_id    BIGINT    NOT NULL,
    user_id    BIGINT    NOT NULL,
    rating     TINYINT   NOT NULL CHECK (rating BETWEEN 1 AND 5),
    content    TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reviews_booking FOREIGN KEY (booking_id) REFERENCES bookings (id) ON DELETE CASCADE,
    CONSTRAINT fk_reviews_room FOREIGN KEY (room_id) REFERENCES rooms (id) ON DELETE CASCADE,
    CONSTRAINT fk_reviews_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    INDEX idx_reviews_room (room_id),
    INDEX idx_reviews_user (user_id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

-- 预置用户
INSERT INTO users (username, password, role, vip_level, phone, email)
VALUES ('admin', 'adminpass', 'ADMIN', 0, '13900000000', 'admin@example.com'),
       ('alice', 'alicepwd', 'USER', 1, '13800000001', 'alice@example.com'),
       ('bob', 'bobpwd', 'USER', 0, '13800000002', 'bob@example.com'),
       ('charlie', 'charliepwd', 'USER', 2, '13800000003', 'charlie@example.com'),
       ('diana', 'dianapwd', 'USER', 1, '13800000004', 'diana@example.com');

-- 预置房型（图片使用 Unsplash 酒店房间图）
INSERT INTO rooms (name, type, total_count, available_count, price_per_night, images, description, amenities, area_sqm,
                   bed_type, max_guests, is_active)
VALUES ('豪华大床房', 'Deluxe', 8, 8, 528.00, NULL, '带落地窗，含早餐',
        JSON_ARRAY('WIFI', '电视', '窗景', '浴缸', '早餐'), 32.0, 'King', 2, 1),
       ('标准双床房', 'Standard', 16, 16, 388.00, NULL, '干净舒适，性价比高', JSON_ARRAY('WIFI', '电视', '淋浴'), 26.0,
        'Twin', 2, 1),
       ('行政套房', 'Suite', 4, 4, 1088.00, NULL, '宽敞，配备商务书桌', JSON_ARRAY('WIFI', '电视', '浴缸', '行政礼遇'),
        55.0, 'King', 3, 1),
       ('家庭房', 'Family', 6, 6, 688.00, NULL, '适合家庭出行，含儿童设施', JSON_ARRAY('WIFI', '电视', '婴儿床可选'),
        40.0, 'Queen+Single', 4, 1),
       ('海景大床房', 'SeaView', 5, 5, 798.00, NULL, '面朝大海，观景阳台', JSON_ARRAY('WIFI', '电视', '阳台', '咖啡机'),
        35.0, 'King', 2, 1),
       ('园景双床房', 'Garden', 7, 7, 468.00, NULL, '花园景观，安静惬意', JSON_ARRAY('WIFI', '电视', '淋浴'), 28.0,
        'Twin', 2, 1),
       ('商务大床房', 'Business', 10, 10, 498.00, NULL, '商务书桌，阅读灯', JSON_ARRAY('WIFI', '电视', '书桌', '咖啡机'),
        30.0, 'Queen', 2, 1),
       ('总统套房', 'Presidential', 1, 1, 3888.00, NULL, '独立客厅与会客区',
        JSON_ARRAY('WIFI', '电视', '浴缸', '餐桌', '厨房'), 160.0, 'King', 4, 1);

-- 为每个房型插入多张图片（Unsplash 稳定直链）
-- 豪华大床房
INSERT INTO room_images (room_id, url, is_primary, sort_order)
SELECT r.id, u.url, u.is_primary, u.sort_order
FROM rooms r
         JOIN (SELECT 1 AS                                                                                            seq,
                      'https://images.unsplash.com/photo-1505691938895-1758d7feb511?auto=format&fit=crop&w=1200&q=80' url,
                      1                                                                                               is_primary,
                      1                                                                                               sort_order
               UNION ALL
               SELECT 2,
                      'https://images.unsplash.com/photo-1505691723518-36a5ac3b2a59?auto=format&fit=crop&w=1200&q=80',
                      0,
                      2
               UNION ALL
               SELECT 3,
                      'https://images.unsplash.com/photo-1501117716987-c8e1ecb2108b?auto=format&fit=crop&w=1200&q=80',
                      0,
                      3) u ON r.name = '豪华大床房';

-- 标准双床房
INSERT INTO room_images (room_id, url, is_primary, sort_order)
SELECT r.id, u.url, u.is_primary, u.sort_order
FROM rooms r
         JOIN (SELECT 1,
                      'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=1200&q=80',
                      1,
                      1
               UNION ALL
               SELECT 2,
                      'https://images.unsplash.com/photo-1554995207-c18c203602cb?auto=format&fit=crop&w=1200&q=80',
                      0,
                      2
               UNION ALL
               SELECT 3,
                      'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&w=1200&q=80',
                      0,
                      3) u ON r.name = '标准双床房';

-- 行政套房
INSERT INTO room_images (room_id, url, is_primary, sort_order)
SELECT r.id, u.url, u.is_primary, u.sort_order
FROM rooms r
         JOIN (SELECT 1,
                      'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=1200&q=80',
                      1,
                      1
               UNION ALL
               SELECT 2,
                      'https://images.unsplash.com/photo-1512915779571-4c63d672c027?auto=format&fit=crop&w=1200&q=80',
                      0,
                      2
               UNION ALL
               SELECT 3,
                      'https://images.unsplash.com/photo-1502920917128-1aa500764ce7?auto=format&fit=crop&w=1200&q=80',
                      0,
                      3) u ON r.name = '行政套房';

-- 家庭房
INSERT INTO room_images (room_id, url, is_primary, sort_order)
SELECT r.id, u.url, u.is_primary, u.sort_order
FROM rooms r
         JOIN (SELECT 1,
                      'https://images.unsplash.com/photo-1551776235-dde6d4829804?auto=format&fit=crop&w=1200&q=80',
                      1,
                      1
               UNION ALL
               SELECT 2,
                      'https://images.unsplash.com/photo-1541976076758-347942db1979?auto=format&fit=crop&w=1200&q=80',
                      0,
                      2
               UNION ALL
               SELECT 3,
                      'https://images.unsplash.com/photo-1560067174-894b1ee7a391?auto=format&fit=crop&w=1200&q=80',
                      0,
                      3) u ON r.name = '家庭房';

-- 海景大床房
INSERT INTO room_images (room_id, url, is_primary, sort_order)
SELECT r.id, u.url, u.is_primary, u.sort_order
FROM rooms r
         JOIN (SELECT 1,
                      'https://images.unsplash.com/photo-1505692256278-3f4f5566f30a?auto=format&fit=crop&w=1200&q=80',
                      1,
                      1
               UNION ALL
               SELECT 2,
                      'https://images.unsplash.com/photo-1519710164239-da123dc03ef4?auto=format&fit=crop&w=1200&q=80',
                      0,
                      2
               UNION ALL
               SELECT 3,
                      'https://images.unsplash.com/photo-1505692794403-34d4982f88aa?auto=format&fit=crop&w=1200&q=80',
                      0,
                      3) u ON r.name = '海景大床房';

-- 园景双床房
INSERT INTO room_images (room_id, url, is_primary, sort_order)
SELECT r.id, u.url, u.is_primary, u.sort_order
FROM rooms r
         JOIN (SELECT 1,
                      'https://images.unsplash.com/photo-1554260570-327c1f2f42fd?auto=format&fit=crop&w=1200&q=80',
                      1,
                      1
               UNION ALL
               SELECT 2,
                      'https://images.unsplash.com/photo-1505691723518-36a5ac3b2a59?auto=format&fit=crop&w=1200&q=80',
                      0,
                      2
               UNION ALL
               SELECT 3,
                      'https://images.unsplash.com/photo-1501117716987-c8e1ecb2108b?auto=format&fit=crop&w=1200&q=80',
                      0,
                      3) u ON r.name = '园景双床房';

-- 商务大床房
INSERT INTO room_images (room_id, url, is_primary, sort_order)
SELECT r.id, u.url, u.is_primary, u.sort_order
FROM rooms r
         JOIN (SELECT 1,
                      'https://images.unsplash.com/photo-1505691723518-36a5ac3b2a59?auto=format&fit=crop&w=1200&q=80',
                      1,
                      1
               UNION ALL
               SELECT 2,
                      'https://images.unsplash.com/photo-1505692794403-34d4982f88aa?auto=format&fit=crop&w=1200&q=80',
                      0,
                      2
               UNION ALL
               SELECT 3,
                      'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=1200&q=80',
                      0,
                      3) u ON r.name = '商务大床房';

-- 总统套房
INSERT INTO room_images (room_id, url, is_primary, sort_order)
SELECT r.id, u.url, u.is_primary, u.sort_order
FROM rooms r
         JOIN (SELECT 1,
                      'https://images.unsplash.com/photo-1502920917128-1aa500764ce7?auto=format&fit=crop&w=1200&q=80',
                      1,
                      1
               UNION ALL
               SELECT 2,
                      'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=1200&q=80',
                      0,
                      2
               UNION ALL
               SELECT 3,
                      'https://images.unsplash.com/photo-1512915779571-4c63d672c027?auto=format&fit=crop&w=1200&q=80',
                      0,
                      3) u ON r.name = '总统套房';

-- 将多图聚合回 rooms.images（逗号分隔，兼容旧前端）
SET @old_len := @@SESSION.group_concat_max_len;
SET SESSION group_concat_max_len = 8192;
UPDATE rooms r
SET r.images = (SELECT GROUP_CONCAT(url ORDER BY sort_order SEPARATOR ',')
                FROM room_images ri
                WHERE ri.room_id = r.id);
SET SESSION group_concat_max_len = @old_len;

-- 为未来 30 天初始化库存（按房型基础价和总量）
INSERT INTO room_inventory (room_id, date, available_count, price, status)
SELECT r.id,
       DATE_ADD(CURDATE(), INTERVAL d.n DAY) AS date,
       r.total_count,
       r.price_per_night,
       'OPEN'
FROM rooms r
         JOIN (SELECT 0 n
               UNION ALL
               SELECT 1
               UNION ALL
               SELECT 2
               UNION ALL
               SELECT 3
               UNION ALL
               SELECT 4
               UNION ALL
               SELECT 5
               UNION ALL
               SELECT 6
               UNION ALL
               SELECT 7
               UNION ALL
               SELECT 8
               UNION ALL
               SELECT 9
               UNION ALL
               SELECT 10
               UNION ALL
               SELECT 11
               UNION ALL
               SELECT 12
               UNION ALL
               SELECT 13
               UNION ALL
               SELECT 14
               UNION ALL
               SELECT 15
               UNION ALL
               SELECT 16
               UNION ALL
               SELECT 17
               UNION ALL
               SELECT 18
               UNION ALL
               SELECT 19
               UNION ALL
               SELECT 20
               UNION ALL
               SELECT 21
               UNION ALL
               SELECT 22
               UNION ALL
               SELECT 23
               UNION ALL
               SELECT 24
               UNION ALL
               SELECT 25
               UNION ALL
               SELECT 26
               UNION ALL
               SELECT 27
               UNION ALL
               SELECT 28
               UNION ALL
               SELECT 29) d;

-- 示例订单（含不同状态）
-- Alice 预订 豪华大床房，已确认
INSERT INTO bookings (room_id, user_id, start_time, end_time, status, guests, amount, currency, contact_name,
                      contact_phone, remark)
VALUES ((SELECT id FROM rooms WHERE name = '豪华大床房' LIMIT 1),
        (SELECT id FROM users WHERE username = 'alice' LIMIT 1),
        DATE_ADD(DATE_ADD(CURDATE(), INTERVAL 3 DAY), INTERVAL 15 HOUR),
        DATE_ADD(DATE_ADD(CURDATE(), INTERVAL 5 DAY), INTERVAL 12 HOUR),
        'CONFIRMED', 2, 528.00 * 2, 'CNY', 'Alice', '13800000001', '高楼层需求');

-- Bob 预订 标准双床房，待支付
INSERT INTO bookings (room_id, user_id, start_time, end_time, status, guests, amount, currency, contact_name,
                      contact_phone, remark)
VALUES ((SELECT id FROM rooms WHERE name = '标准双床房' LIMIT 1),
        (SELECT id FROM users WHERE username = 'bob' LIMIT 1),
        DATE_ADD(DATE_ADD(CURDATE(), INTERVAL 7 DAY), INTERVAL 15 HOUR),
        DATE_ADD(DATE_ADD(CURDATE(), INTERVAL 9 DAY), INTERVAL 12 HOUR),
        'PENDING', 2, 388.00 * 2, 'CNY', 'Bob', '13800000002', '靠近电梯');

-- Charlie 预订 海景大床房，已入住
INSERT INTO bookings (room_id, user_id, start_time, end_time, status, guests, amount, currency, contact_name,
                      contact_phone, remark)
VALUES ((SELECT id FROM rooms WHERE name = '海景大床房' LIMIT 1),
        (SELECT id FROM users WHERE username = 'charlie' LIMIT 1),
        DATE_ADD(DATE_ADD(CURDATE(), INTERVAL -1 DAY), INTERVAL 15 HOUR),
        DATE_ADD(DATE_ADD(CURDATE(), INTERVAL 1 DAY), INTERVAL 12 HOUR),
        'CHECKED_IN', 2, 798.00 * 2, 'CNY', 'Charlie', '13800000003', '海景房高层');

-- Diana 预订 园景双床房，已取消
INSERT INTO bookings (room_id, user_id, start_time, end_time, status, guests, amount, currency, contact_name,
                      contact_phone, remark)
VALUES ((SELECT id FROM rooms WHERE name = '园景双床房' LIMIT 1),
        (SELECT id FROM users WHERE username = 'diana' LIMIT 1),
        DATE_ADD(DATE_ADD(CURDATE(), INTERVAL 10 DAY), INTERVAL 15 HOUR),
        DATE_ADD(DATE_ADD(CURDATE(), INTERVAL 12 DAY), INTERVAL 12 HOUR),
        'CANCELLED', 2, 0.00, 'CNY', 'Diana', '13800000004', '行程变更');

-- 支付记录（对已确认/已入住订单创建成功支付）
INSERT INTO payments (booking_id, pay_method, amount, currency, status, transaction_no, paid_at)
SELECT b.id, 'ALIPAY', b.amount, b.currency, 'SUCCESS', CONCAT('ALI', b.id, UNIX_TIMESTAMP()), NOW()
FROM bookings b
WHERE b.status IN ('CONFIRMED', 'CHECKED_IN');

-- 示例评价（入住后）
INSERT INTO reviews (booking_id, room_id, user_id, rating, content)
SELECT b.id, b.room_id, b.user_id, 5, '房间整洁，景色很好，会再来！'
FROM bookings b
WHERE b.status = 'CHECKED_IN'
LIMIT 1;

-- 可选：根据今日库存回填 rooms.available_count（演示）
UPDATE rooms r
    JOIN (SELECT room_id, MIN(available_count) AS min_avail
          FROM room_inventory
          WHERE date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
          GROUP BY room_id) x ON x.room_id = r.id
SET r.available_count = x.min_avail;
