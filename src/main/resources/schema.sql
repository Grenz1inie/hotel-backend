-- schema.sql (multi-hotel enhanced)
-- 统一重建所有表以匹配新的多酒店、房型/房间拆分设计

SET FOREIGN_KEY_CHECKS = 0;

DROP VIEW IF EXISTS rooms;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS room_maintenance;
DROP TABLE IF EXISTS room_inventory;
DROP TABLE IF EXISTS room_price_strategy;
DROP TABLE IF EXISTS room_images;
DROP TABLE IF EXISTS room;
DROP TABLE IF EXISTS room_type;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS hotel;

SET FOREIGN_KEY_CHECKS = 1;

-- 酒店基础信息表
CREATE TABLE hotel
(
    id            BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '酒店ID',
    name          VARCHAR(100)                NOT NULL COMMENT '酒店名称',
    address       VARCHAR(255)                NOT NULL COMMENT '酒店地址',
    city          VARCHAR(50)                 NOT NULL COMMENT '所在城市',
    phone         VARCHAR(20)                 NOT NULL COMMENT '联系电话',
    star_level    TINYINT      DEFAULT 0      NOT NULL COMMENT '星级（0=未评级）',
    status        TINYINT      DEFAULT 1      NOT NULL COMMENT '状态（1=营业中，0=停业）',
    created_time  DATETIME     DEFAULT CURRENT_TIMESTAMP                    NOT NULL,
    updated_time  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT uq_hotel_name UNIQUE (name),
    KEY idx_city (city)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci
  COMMENT ='酒店信息表';

-- 用户表（保持与现有业务兼容）
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
  COLLATE = utf8mb4_general_ci
  COMMENT ='用户表';

-- 房型表，承载聚合维度并兼容旧 rooms 表字段
CREATE TABLE room_type
(
    id               BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '房型ID',
    hotel_id         BIGINT                             NOT NULL COMMENT '所属酒店ID',
    name             VARCHAR(80)                        NOT NULL COMMENT '房型名称（前台展示名称）',
    type             VARCHAR(60)                        NOT NULL COMMENT '房型分类（如 Deluxe / Standard）',
    description      TEXT COMMENT '房型描述',
    price_per_night  DECIMAL(10, 2)                     NOT NULL COMMENT '基础价格（元/晚）',
    total_count      INT                                NOT NULL DEFAULT 0 COMMENT '房型总房间数',
    available_count  INT                                NOT NULL DEFAULT 0 COMMENT '当前可售数量',
    images           TEXT COMMENT '房型图片（逗号分隔 URL）',
    amenities        JSON COMMENT '设施列表 JSON',
    area_sqm         DECIMAL(6, 2) COMMENT '面积（平方米）',
    bed_type         VARCHAR(30) COMMENT '床型',
    max_guests       INT                                NOT NULL DEFAULT 2 COMMENT '最大入住人数',
    is_active        TINYINT                            NOT NULL DEFAULT 1 COMMENT '状态（1=启用，0=停用）',
    created_time     DATETIME                           NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_time     DATETIME                           NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_room_type_hotel FOREIGN KEY (hotel_id) REFERENCES hotel (id) ON DELETE CASCADE,
    KEY idx_room_type_hotel (hotel_id),
    KEY idx_room_type_active (hotel_id, is_active)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci
  COMMENT ='房型表';

-- 具体房间表
CREATE TABLE room
(
    id                 BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '房间ID',
    hotel_id           BIGINT                             NOT NULL COMMENT '酒店ID',
    room_type_id       BIGINT                             NOT NULL COMMENT '房型ID',
    room_number        VARCHAR(20)                        NOT NULL COMMENT '房间号',
    floor              SMALLINT COMMENT '楼层',
    status             TINYINT                            NOT NULL DEFAULT 1 COMMENT '房态（1空房 2已预订 3已入住 4待打扫 5维修中）',
    last_checkout_time DATETIME COMMENT '最后退房时间',
    created_time       DATETIME                           NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_time       DATETIME                           NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_room_hotel FOREIGN KEY (hotel_id) REFERENCES hotel (id) ON DELETE CASCADE,
    CONSTRAINT fk_room_room_type FOREIGN KEY (room_type_id) REFERENCES room_type (id) ON DELETE CASCADE,
    UNIQUE KEY uk_room_hotel_no (hotel_id, room_number),
    KEY idx_room_type (room_type_id),
    KEY idx_room_status (hotel_id, status)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci
  COMMENT ='具体房间表';

-- 房型图片
CREATE TABLE room_images
(
    id           BIGINT PRIMARY KEY AUTO_INCREMENT,
    room_type_id BIGINT        NOT NULL,
    url          VARCHAR(1000) NOT NULL,
    is_primary   TINYINT(1)    NOT NULL DEFAULT 0,
    sort_order   INT           NOT NULL DEFAULT 0,
    created_at   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_room_images_type FOREIGN KEY (room_type_id) REFERENCES room_type (id) ON DELETE CASCADE,
    KEY idx_room_images_type (room_type_id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci
  COMMENT ='房型图片';

-- 房型每日库存与售价信息
CREATE TABLE room_inventory
(
    id              BIGINT PRIMARY KEY AUTO_INCREMENT,
    hotel_id        BIGINT                 NOT NULL,
    room_type_id    BIGINT                 NOT NULL,
    date            DATE                   NOT NULL,
    available_count INT                    NOT NULL,
    price           DECIMAL(10, 2)         NOT NULL,
    status          ENUM ('OPEN','CLOSED') NOT NULL DEFAULT 'OPEN',
    created_at      TIMESTAMP              NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP              NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_inventory (room_type_id, date),
    KEY idx_inventory_hotel (hotel_id, date),
    CONSTRAINT fk_inventory_room_type FOREIGN KEY (room_type_id) REFERENCES room_type (id) ON DELETE CASCADE,
    CONSTRAINT fk_inventory_hotel FOREIGN KEY (hotel_id) REFERENCES hotel (id) ON DELETE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci
  COMMENT ='房型每日库存';

-- 动态价格策略
CREATE TABLE room_price_strategy
(
    id             BIGINT PRIMARY KEY AUTO_INCREMENT,
    hotel_id       BIGINT             NOT NULL,
    room_type_id   BIGINT             NOT NULL,
    strategy_type  TINYINT            NOT NULL COMMENT '1日期加价 2会员折扣 3连住优惠',
    start_date     DATE               NOT NULL,
    end_date       DATE               NOT NULL,
    price_adjust   DECIMAL(10, 2) DEFAULT 0.00 COMMENT '加价金额（可负数）',
    discount_rate  DECIMAL(3, 2)  DEFAULT NULL COMMENT '折扣率，仅类型2/3使用',
    min_stay_days  TINYINT         DEFAULT 1 COMMENT '最小连住天数，仅类型3使用',
    status         TINYINT         DEFAULT 1 NOT NULL,
    created_time   DATETIME        DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_time   DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_price_strategy_hotel FOREIGN KEY (hotel_id) REFERENCES hotel (id) ON DELETE CASCADE,
    CONSTRAINT fk_price_strategy_type FOREIGN KEY (room_type_id) REFERENCES room_type (id) ON DELETE CASCADE,
    KEY idx_price_strategy_rt (room_type_id, start_date, end_date)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci
  COMMENT ='房型价格策略';

-- 房间维护记录
CREATE TABLE room_maintenance
(
    id               BIGINT PRIMARY KEY AUTO_INCREMENT,
    room_id          BIGINT       NOT NULL,
    maintenance_type VARCHAR(50)  NOT NULL,
    description      TEXT,
    start_time       DATETIME     NOT NULL,
    end_time         DATETIME,
    operator         VARCHAR(50)  NOT NULL,
    status           TINYINT      NOT NULL DEFAULT 1 COMMENT '1处理中 2已完成',
    created_time     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_time     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_room_maintenance_room FOREIGN KEY (room_id) REFERENCES room (id) ON DELETE CASCADE,
    KEY idx_room_maintenance_room (room_id),
    KEY idx_room_maintenance_status (status, start_time)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci
  COMMENT ='房间维护记录';

-- 订单表
CREATE TABLE bookings
(
    id            BIGINT PRIMARY KEY AUTO_INCREMENT,
    hotel_id      BIGINT                                                                     NOT NULL,
    room_type_id  BIGINT                                                                     NOT NULL,
    room_id       BIGINT                                                                     NOT NULL,
    user_id       BIGINT                                                                     NOT NULL,
    start_time    DATETIME                                                                   NOT NULL,
    end_time      DATETIME                                                                   NOT NULL,
    status        ENUM ('PENDING','CONFIRMED','CHECKED_IN','CHECKED_OUT','CANCELLED','REFUNDED') NOT NULL DEFAULT 'PENDING',
    guests        INT                                                                        NOT NULL DEFAULT 1,
    amount        DECIMAL(10, 2)                                                             NOT NULL DEFAULT 0.00,
    currency      CHAR(3)                                                                    NOT NULL DEFAULT 'CNY',
    contact_name  VARCHAR(100),
    contact_phone VARCHAR(30),
    remark        VARCHAR(500),
    created_at    TIMESTAMP                                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP                                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_bookings_hotel FOREIGN KEY (hotel_id) REFERENCES hotel (id),
    CONSTRAINT fk_bookings_room_type FOREIGN KEY (room_type_id) REFERENCES room_type (id),
    CONSTRAINT fk_bookings_room FOREIGN KEY (room_id) REFERENCES room (id),
    CONSTRAINT fk_bookings_user FOREIGN KEY (user_id) REFERENCES users (id),
    KEY idx_bookings_user (user_id),
    KEY idx_bookings_status (status),
    KEY idx_bookings_room (room_id),
    KEY idx_bookings_period (start_time, end_time)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci
  COMMENT ='订单表';

-- 支付记录
CREATE TABLE payments
(
    id             BIGINT PRIMARY KEY AUTO_INCREMENT,
    booking_id     BIGINT                                      NOT NULL,
    pay_method     ENUM ('WECHAT','ALIPAY','CARD','CASH')      NOT NULL,
    amount         DECIMAL(10, 2)                              NOT NULL,
    currency       CHAR(3)                                     NOT NULL DEFAULT 'CNY',
    status         ENUM ('INIT','SUCCESS','FAILED','REFUNDED') NOT NULL DEFAULT 'INIT',
    transaction_no VARCHAR(128),
    paid_at        DATETIME,
    created_at     TIMESTAMP                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP                                   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_payments_booking (booking_id),
    CONSTRAINT fk_payments_booking FOREIGN KEY (booking_id) REFERENCES bookings (id) ON DELETE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci
  COMMENT ='支付记录';

-- 评价
CREATE TABLE reviews
(
    id         BIGINT PRIMARY KEY AUTO_INCREMENT,
    booking_id BIGINT    NOT NULL,
    hotel_id   BIGINT    NOT NULL,
    room_type_id BIGINT  NOT NULL,
    user_id    BIGINT    NOT NULL,
    rating     TINYINT   NOT NULL CHECK (rating BETWEEN 1 AND 5),
    content    TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reviews_booking FOREIGN KEY (booking_id) REFERENCES bookings (id) ON DELETE CASCADE,
    CONSTRAINT fk_reviews_hotel FOREIGN KEY (hotel_id) REFERENCES hotel (id) ON DELETE CASCADE,
    CONSTRAINT fk_reviews_room_type FOREIGN KEY (room_type_id) REFERENCES room_type (id) ON DELETE CASCADE,
    CONSTRAINT fk_reviews_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    KEY idx_reviews_room_type (room_type_id),
    KEY idx_reviews_user (user_id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci
  COMMENT ='评价表';

-- 兼容旧代码：创建 updatable view rooms
CREATE OR REPLACE VIEW rooms AS
SELECT
    rt.id               AS id,
    rt.name             AS name,
    rt.type             AS type,
    rt.total_count      AS totalCount,
    rt.available_count  AS availableCount,
    rt.price_per_night  AS pricePerNight,
    rt.images           AS images,
    rt.description      AS description,
    rt.amenities        AS amenities,
    rt.area_sqm         AS areaSqm,
    rt.bed_type         AS bedType,
    rt.max_guests       AS maxGuests,
    rt.is_active        AS isActive,
    rt.hotel_id         AS hotelId
FROM room_type rt;

-- -----------------------------------------------------------------------------
-- 初始化数据
-- -----------------------------------------------------------------------------

INSERT INTO hotel (name, address, city, phone, star_level, status)
VALUES ('星河国际酒店', '北京市朝阳区建国路99号', '北京', '010-88886666', 5, 1),
       ('海天假日酒店', '上海市浦东新区滨江大道68号', '上海', '021-66668888', 4, 1);

INSERT INTO users (username, password, role, vip_level, phone, email)
VALUES ('admin', 'adminpass', 'ADMIN', 0, '13900000000', 'admin@example.com'),
       ('alice', 'alicepwd', 'USER', 1, '13800000001', 'alice@example.com'),
       ('bob', 'bobpwd', 'USER', 0, '13800000002', 'bob@example.com'),
       ('charlie', 'charliepwd', 'USER', 2, '13800000003', 'charlie@example.com'),
       ('diana', 'dianapwd', 'USER', 1, '13800000004', 'diana@example.com');

-- 房型数据
INSERT INTO room_type (hotel_id, name, type, description, price_per_night, total_count, available_count, images, amenities, area_sqm, bed_type, max_guests)
VALUES
    (1, '豪华大床房', 'Deluxe', '带落地窗，含早餐', 528.00, 12, 12, NULL, JSON_ARRAY('WIFI','电视','窗景','浴缸','早餐'), 32.0, 'King', 2),
    (1, '行政套房', 'Suite', '宽敞，配备商务书桌', 1088.00, 6, 6, NULL, JSON_ARRAY('WIFI','电视','浴缸','行政礼遇'), 55.0, 'King', 3),
    (1, '标准双床房', 'Standard', '干净舒适，性价比高', 388.00, 20, 20, NULL, JSON_ARRAY('WIFI','电视','淋浴'), 26.0, 'Twin', 2),
    (2, '海景大床房', 'SeaView', '面朝大海，观景阳台', 798.00, 8, 8, NULL, JSON_ARRAY('WIFI','电视','阳台','咖啡机'), 35.0, 'King', 2),
    (2, '家庭房', 'Family', '适合家庭出行，含儿童设施', 688.00, 10, 10, NULL, JSON_ARRAY('WIFI','电视','婴儿床可选'), 40.0, 'Queen+Single', 4),
    (2, '商务大床房', 'Business', '商务书桌，阅读灯', 498.00, 15, 15, NULL, JSON_ARRAY('WIFI','电视','书桌','咖啡机'), 30.0, 'Queen', 2);

-- 房型图片（示例）
INSERT INTO room_images (room_type_id, url, is_primary, sort_order)
SELECT rt.id,
       urls.url,
       urls.is_primary,
       urls.sort_order
FROM room_type rt
         JOIN (
    SELECT 1 AS seq, '豪华大床房' AS name, 'https://images.unsplash.com/photo-1505691938895-1758d7feb511?auto=format&fit=crop&w=1200&q=80' AS url, 1 AS is_primary, 1 AS sort_order
    UNION ALL SELECT 2, '豪华大床房', 'https://images.unsplash.com/photo-1505691723518-36a5ac3b2a59?auto=format&fit=crop&w=1200&q=80', 0, 2
    UNION ALL SELECT 3, '豪华大床房', 'https://images.unsplash.com/photo-1501117716987-c8e1ecb2108b?auto=format&fit=crop&w=1200&q=80', 0, 3
    UNION ALL SELECT 4, '标准双床房', 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=1200&q=80', 1, 1
    UNION ALL SELECT 5, '标准双床房', 'https://images.unsplash.com/photo-1554995207-c18c203602cb?auto=format&fit=crop&w=1200&q=80', 0, 2
    UNION ALL SELECT 6, '海景大床房', 'https://images.unsplash.com/photo-1505692256278-3f4f5566f30a?auto=format&fit=crop&w=1200&q=80', 1, 1
    UNION ALL SELECT 7, '海景大床房', 'https://images.unsplash.com/photo-1519710164239-da123dc03ef4?auto=format&fit=crop&w=1200&q=80', 0, 2
    UNION ALL SELECT 8, '家庭房', 'https://images.unsplash.com/photo-1551776235-dde6d4829804?auto=format&fit=crop&w=1200&q=80', 1, 1
    UNION ALL SELECT 9, '商务大床房', 'https://images.unsplash.com/photo-1505692794403-34d4982f88aa?auto=format&fit=crop&w=1200&q=80', 1, 1
) urls ON urls.name = rt.name;

-- 将多图聚合回房型表 images 字段
SET @old_len := @@SESSION.group_concat_max_len;
SET SESSION group_concat_max_len = 8192;
UPDATE room_type rt
SET images = (
    SELECT GROUP_CONCAT(url ORDER BY sort_order SEPARATOR ',')
    FROM room_images ri
    WHERE ri.room_type_id = rt.id
);
SET SESSION group_concat_max_len = @old_len;

-- 具体房间生成（示例：按房型数量创建房间号）
INSERT INTO room (hotel_id, room_type_id, room_number, floor, status)
SELECT rt.hotel_id,
       rt.id,
       CONCAT(LPAD(floor_num, 2, '0'), LPAD(seq, 2, '0')) AS room_number,
       floor_num,
       1 AS status
FROM (
         SELECT id, hotel_id, total_count
         FROM room_type
     ) rt
         JOIN (
    SELECT 1 AS floor_num UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
    UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
) floors
         JOIN (
    SELECT 1 AS seq UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
    UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
    UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15
) seqs
WHERE (floors.floor_num - 1) * 10 + seqs.seq <= rt.total_count;

-- 初始化每日库存（未来 30 天）
INSERT INTO room_inventory (hotel_id, room_type_id, date, available_count, price, status)
SELECT rt.hotel_id,
       rt.id,
       CURDATE() + INTERVAL d.n DAY,
       rt.total_count,
       rt.price_per_night,
       'OPEN'
FROM room_type rt
         JOIN (
    SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
    UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15
    UNION ALL SELECT 16 UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20 UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL SELECT 23
    UNION ALL SELECT 24 UNION ALL SELECT 25 UNION ALL SELECT 26 UNION ALL SELECT 27 UNION ALL SELECT 28 UNION ALL SELECT 29
) d;

-- 示例价格策略
INSERT INTO room_price_strategy (hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, min_stay_days)
VALUES
    (1, (SELECT id FROM room_type WHERE name = '豪华大床房' LIMIT 1), 1, CURDATE() + INTERVAL 5 DAY, CURDATE() + INTERVAL 7 DAY, 200.00, NULL, 1),
    (1, (SELECT id FROM room_type WHERE name = '标准双床房' LIMIT 1), 2, CURDATE(), CURDATE() + INTERVAL 30 DAY, NULL, 0.90, 1),
    (2, (SELECT id FROM room_type WHERE name = '海景大床房' LIMIT 1), 3, CURDATE() + INTERVAL 10 DAY, CURDATE() + INTERVAL 40 DAY, NULL, 0.85, 3);

-- 示例维护记录
INSERT INTO room_maintenance (room_id, maintenance_type, description, start_time, end_time, operator, status)
VALUES (
            (SELECT id FROM room WHERE room_number = '0501' AND hotel_id = 1 LIMIT 1),
            '空调维修',
            '空调制冷异常，需更换滤网',
            NOW() - INTERVAL 1 DAY,
            NULL,
            '张维修',
            1
       );

-- 示例订单
INSERT INTO bookings (hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests, amount, currency, contact_name, contact_phone, remark)
VALUES
    (
        1,
        (SELECT id FROM room_type WHERE name = '豪华大床房' AND hotel_id = 1 LIMIT 1),
        (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = '豪华大床房' AND hotel_id = 1 LIMIT 1) LIMIT 1),
        (SELECT id FROM users WHERE username = 'alice'),
        CURDATE() + INTERVAL 3 DAY + INTERVAL 15 HOUR,
        CURDATE() + INTERVAL 5 DAY + INTERVAL 12 HOUR,
        'CONFIRMED',
        2,
        1056.00,
        'CNY',
        'Alice',
        '13800000001',
        '高楼层需求'
    ),
    (
        2,
        (SELECT id FROM room_type WHERE name = '海景大床房' AND hotel_id = 2 LIMIT 1),
        (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = '海景大床房' AND hotel_id = 2 LIMIT 1) LIMIT 1),
        (SELECT id FROM users WHERE username = 'charlie'),
        CURDATE() - INTERVAL 1 DAY + INTERVAL 15 HOUR,
        CURDATE() + INTERVAL 1 DAY + INTERVAL 12 HOUR,
        'CHECKED_IN',
        2,
        1596.00,
        'CNY',
        'Charlie',
        '13800000003',
        '海景房高层'
    ),
    (
        1,
        (SELECT id FROM room_type WHERE name = '标准双床房' AND hotel_id = 1 LIMIT 1),
        (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = '标准双床房' AND hotel_id = 1 LIMIT 1) LIMIT 1 OFFSET 2),
        (SELECT id FROM users WHERE username = 'bob'),
        CURDATE() + INTERVAL 7 DAY + INTERVAL 15 HOUR,
        CURDATE() + INTERVAL 9 DAY + INTERVAL 12 HOUR,
        'PENDING',
        2,
        776.00,
        'CNY',
        'Bob',
        '13800000002',
        '靠近电梯'
    );

-- 对已完成/已入住订单创建支付记录
INSERT INTO payments (booking_id, pay_method, amount, currency, status, transaction_no, paid_at)
SELECT b.id,
       'ALIPAY',
       b.amount,
       b.currency,
       'SUCCESS',
       CONCAT('ALI', b.id, UNIX_TIMESTAMP()),
       NOW()
FROM bookings b
WHERE b.status IN ('CONFIRMED', 'CHECKED_IN');

-- 示例评价
INSERT INTO reviews (booking_id, hotel_id, room_type_id, user_id, rating, content)
SELECT b.id,
       b.hotel_id,
       b.room_type_id,
       b.user_id,
       5,
       '房间整洁，景色很好，会再来！'
FROM bookings b
WHERE b.status = 'CHECKED_IN'
LIMIT 1;

-- 根据未来一周库存同步房型可用数
UPDATE room_type rt
    JOIN (
        SELECT room_type_id, MIN(available_count) AS min_avail
        FROM room_inventory
        WHERE date BETWEEN CURDATE() AND CURDATE() + INTERVAL 6 DAY
        GROUP BY room_type_id
    ) inv ON inv.room_type_id = rt.id
SET rt.available_count = inv.min_avail;
