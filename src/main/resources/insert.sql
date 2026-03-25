-- 序列定义（与 insert.sql 保持一致）
CREATE SEQUENCE seq_hotel START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_users START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_room_type START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_room_price_strategy START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_room_images START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_room START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_room_maintenance START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_bookings START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_wallet_account START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_wallet_transaction START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_payment_record START WITH 1 INCREMENT BY 1;

-- 酒店数据
INSERT INTO hotel (id, name, address, city, phone, star_level, status, introduction, hero_image_url, gallery_images)
VALUES (seq_hotel.NEXTVAL,
        'Galaxy International Hotel',
        'No. 99 Jianguo Road, Chaoyang District, Beijing',
        'Beijing',
        '010-88886666',
        5,
        1,
        'Located in the core CBD of Guomao, Galaxy International Hotel features twin landmark towers and 330 modern guest rooms, offering business travelers and high-end guests an experience of "living in the clouds." The hotel introduces digital front desk, 24-hour executive lounge, cross-border art exhibitions, and a dining scene combining Beijing cuisine and French cuisine, providing one-stop conference and social services.',
        '/images/hotels/xinghe-hero.jpg',
        '/images/hotels/xinghe-gallery0.jpg,/images/hotels/xinghe-gallery1.jpg');

INSERT INTO hotel (id, name, address, city, phone, star_level, status, introduction, hero_image_url, gallery_images)
VALUES (seq_hotel.NEXTVAL,
        'Haitan Holiday Hotel',
        'No. 68 Binjiang Avenue, Pudong New Area, Shanghai',
        'Shanghai',
        '021-66668888',
        4,
        1,
        'Haitan Holiday Hotel is built along the river, with the concept of "vacation in the city center," featuring guest rooms with balcony views, children''s adventure park, and an infinity pool with river views. The hotel introduces air purification, smart voice control, and parent-child baking classes, catering to urban families and couples for weekend getaways.',
        '/images/hotels/xinghe-hero.jpg',
        '/images/hotels/xinghe-gallery0.jpg,/images/hotels/xinghe-gallery1.jpg');

INSERT INTO hotel (id, name, address, city, phone, star_level, status, introduction, hero_image_url, gallery_images)
VALUES (seq_hotel.NEXTVAL,
        'Yunqi Hot Spring Resort',
        'No. 18 Qingchengshan Road, Dujiangyan City, Chengdu',
        'Chengdu',
        '028-86668888',
        5,
        1,
        'Built at the foot of Qingcheng Mountain, Yunqi Hot Spring Resort embraces natural woodlands and hot springs, offering private villas, open-air hot spring pools, and yoga meditation classes. Inspired by the "back to nature" lifestyle, the resort introduces farm-to-table organic dining, parent-child nature classes, and starry camping, bringing deep healing experiences to urban travelers.',
        '/images/hotels/xinghe-hero.jpg',
        '/images/hotels/xinghe-gallery0.jpg,/images/hotels/xinghe-gallery1.jpg');

-- 用户数据
INSERT INTO users (id, username, password, role, vip_level, total_consumption, phone, email)
VALUES (seq_users.NEXTVAL, 'admin', 'adminpass', 'ADMIN', 0, 0.00, '13912345678', 'admin@example.com');
INSERT INTO users (id, username, password, role, vip_level, total_consumption, phone, email)
VALUES (seq_users.NEXTVAL, 'frontdesk', 'frontdesk', 'ADMIN', 0, 0.00, '13923456789', 'frontdesk@hotel.com');
INSERT INTO users (id, username, password, role, vip_level, total_consumption, phone, email)
VALUES (seq_users.NEXTVAL, 'alice', 'alicepwd', 'USER', 1, 4309.40, '13812345678', 'alice@example.com');
INSERT INTO users (id, username, password, role, vip_level, total_consumption, phone, email)
VALUES (seq_users.NEXTVAL, 'bob', 'bobpwd', 'USER', 0, 2576.00, '15987654321', 'bob@example.com');
INSERT INTO users (id, username, password, role, vip_level, total_consumption, phone, email)
VALUES (seq_users.NEXTVAL, 'charlie', 'charliepwd', 'USER', 2, 5085.36, '13698745632', 'charlie@example.com');
INSERT INTO users (id, username, password, role, vip_level, total_consumption, phone, email)
VALUES (seq_users.NEXTVAL, 'diana', 'dianapwd', 'USER', 1, 1079.20, '18611223344', 'diana@example.com');
INSERT INTO users (id, username, password, role, vip_level, total_consumption, phone, email)
VALUES (seq_users.NEXTVAL, 'leo', 'leopwd', 'USER', 3, 0.00, '13712349876', 'leo@example.com');
INSERT INTO users (id, username, password, role, vip_level, total_consumption, phone, email)
VALUES (seq_users.NEXTVAL, 'mia', 'miapwd', 'USER', 2, 3163.12, '15712348765', 'mia@example.com');
INSERT INTO users (id, username, password, role, vip_level, total_consumption, phone, email)
VALUES (seq_users.NEXTVAL, 'nina', 'ninapwd', 'USER', 0, 1996.00, '13698761234', 'nina@example.com');
INSERT INTO users (id, username, password, role, vip_level, total_consumption, phone, email)
VALUES (seq_users.NEXTVAL, 'oscar', 'oscarpwd', 'USER', 1, 1320.96, '18623456789', 'oscar@example.com');
INSERT INTO users (id, username, password, role, vip_level, total_consumption, phone, email)
VALUES (seq_users.NEXTVAL, 'paul', 'paulpwd', 'USER', 2, 3438.96, '13787654321', 'paul@example.com');
INSERT INTO users (id, username, password, role, vip_level, total_consumption, phone, email)
VALUES (seq_users.NEXTVAL, 'quinn', 'quinnpwd', 'USER', 3, 2699.60, '15876543210', 'quinn@example.com');
INSERT INTO users (id, username, password, role, vip_level, total_consumption, phone, email)
VALUES (seq_users.NEXTVAL, 'rachel', 'rachelpwd', 'USER', 4, 2243.52, '13911112222', 'rachel@example.com');

-- VIP等级政策
INSERT INTO vip_level_policy (vip_level, name, discount_rate, checkout_hour, description)
VALUES (0, 'Standard Member', 1.000, 12, 'Free registration, standard checkout time is 12:00 noon next day');
INSERT INTO vip_level_policy (vip_level, name, discount_rate, checkout_hour, description)
VALUES (1, 'Silver Member', 0.950, 13, 'Upgrade after annual consumption of 5000 CNY, checkout extended to 13:00 next day');
INSERT INTO vip_level_policy (vip_level, name, discount_rate, checkout_hour, description)
VALUES (2, 'Gold Member', 0.900, 14, 'Upgrade after annual consumption of 15000 CNY, checkout extended to 14:00 next day');
INSERT INTO vip_level_policy (vip_level, name, discount_rate, checkout_hour, description)
VALUES (3, 'Platinum Member', 0.880, 15, 'Upgrade after annual consumption of 30000 CNY, checkout extended to 15:00 next day');
INSERT INTO vip_level_policy (vip_level, name, discount_rate, checkout_hour, description)
VALUES (4, 'Diamond Member', 0.850, 16, 'Invitation only for core customers (suggested annual consumption above 50000 CNY), additional VIP privileges and private butler service');

-- 钱包账户
INSERT INTO wallet_account (id, user_id, balance, frozen_balance)
SELECT seq_wallet_account.NEXTVAL, id,
       CASE
           WHEN vip_level >= 3 THEN 18500.00
           WHEN vip_level = 2 THEN 5000.00
           WHEN vip_level = 1 THEN 1600.00
           ELSE 400.00
       END AS balance,
       0.00
FROM users;

-- 房型
INSERT INTO room_type (id, hotel_id, name, type, theme_color, description, price_per_night, total_count, available_count, images, amenities, area_sqm, bed_type, max_guests)
VALUES (seq_room_type.NEXTVAL, 1, 'Galaxy Executive King Room', 'Executive', '#2F54EB',
        'Floor-to-ceiling window view, includes executive lounge access and breakfast for two', 568.00, 18, 11, NULL,
        '["WIFI","55-inch TV","Air Purifier","Bathtub","Executive Lounge","USB Charging Ports","High-speed Desk","Smart Curtains"]',
        35.0, 'King', 2);
INSERT INTO room_type (id, hotel_id, name, type, theme_color, description, price_per_night, total_count, available_count, images, amenities, area_sqm, bed_type, max_guests)
VALUES (seq_room_type.NEXTVAL, 1, 'Galaxy Family Suite', 'FamilySuite', '#D46B08',
        'Two-bedroom design, living room with children''s tent and play corner', 1188.00, 8, 4, NULL,
        '["WIFI","Washer/Dryer","Coffee Machine","Children''s Toys","Bathtub","Children''s Tableware","Microwave","Family Board Games"]',
        68.0, 'King+Twin', 4);
INSERT INTO room_type (id, hotel_id, name, type, theme_color, description, price_per_night, total_count, available_count, images, amenities, area_sqm, bed_type, max_guests)
VALUES (seq_room_type.NEXTVAL, 1, 'Galaxy City View Room', 'CityView', '#13C2C2',
        'High-floor city view room, includes welcome fruit and evening dessert', 468.00, 24, 15, NULL,
        '["WIFI","Bluetooth Speaker","Minibar","Bathrobe","Smart Voice Control","Turndown Service","Aroma Diffuser","Electronic Safe"]',
        30.0, 'Queen', 2);
INSERT INTO room_type (id, hotel_id, name, type, theme_color, description, price_per_night, total_count, available_count, images, amenities, area_sqm, bed_type, max_guests)
VALUES (seq_room_type.NEXTVAL, 2, 'Haitan Ocean View Room', 'SeaPremium', '#1D39C4',
        'Balcony with direct view of Huangpu River night scene', 828.00, 12, 10, NULL,
        '["WIFI","Balcony Lounge Chair","Nespresso Machine","Bathtub","Smart Curtains","Outdoor Soaking Pool","Aroma Diffuser","BOSE Speakers"]',
        36.0, 'King', 2);
INSERT INTO room_type (id, hotel_id, name, type, theme_color, description, price_per_night, total_count, available_count, images, amenities, area_sqm, bed_type, max_guests)
VALUES (seq_room_type.NEXTVAL, 2, 'Haitan Family Fun Room', 'FamilyTheme', '#EB2F96',
        'Family-themed decoration, includes children''s slide, picture books, and humidifier', 688.00, 14, 12, NULL,
        '["WIFI","Children''s Slide","Picture Book Corner","Air Humidifier","Bathrobe","Educational Puzzles","Kids Bathrobe","Glow-in-the-Dark Wall Stickers"]',
        42.0, 'Queen+Single', 4);
INSERT INTO room_type (id, hotel_id, name, type, theme_color, description, price_per_night, total_count, available_count, images, amenities, area_sqm, bed_type, max_guests)
VALUES (seq_room_type.NEXTVAL, 2, 'Haitan Sky Suite', 'SkySuite', '#722ED1',
        'Double-height living room with private butler service', 1368.00, 5, 3, NULL,
        '["WIFI","Private Butler","Home Theater","Vanity Table","Bathtub","Private Cinema","Cloud Office Desk","Champagne Minibar"]',
        92.0, 'King', 3);
INSERT INTO room_type (id, hotel_id, name, type, theme_color, description, price_per_night, total_count, available_count, images, amenities, area_sqm, bed_type, max_guests)
VALUES (seq_room_type.NEXTVAL, 3, 'Yunqi Hot Spring King Room', 'HotSpring', '#FA541C',
        'In-room private hot spring pool, includes welcome fruit and morning yoga', 998.00, 10, 9, NULL,
        '["WIFI","Private Hot Spring","Fireplace","Air Purification System","Yoga Mat","Aromatherapy Pillow","Forest Bath Soundtrack","Organic Tea Set"]',
        48.0, 'King', 2);
INSERT INTO room_type (id, hotel_id, name, type, theme_color, description, price_per_night, total_count, available_count, images, amenities, area_sqm, bed_type, max_guests)
VALUES (seq_room_type.NEXTVAL, 3, 'Yunqi Forest Chalet', 'Chalet', '#389E0D',
        'Detached wooden chalet with terrace for stargazing, ideal for small gatherings', 1288.00, 6, 4, NULL,
        '["WIFI","Terrace Fireplace","Kitchen","Projector","Coffee Machine","Camping Lantern","Outdoor BBQ Grill","Stargazing Telescope"]',
        75.0, 'King+Sofa', 4);
INSERT INTO room_type (id, hotel_id, name, type, theme_color, description, price_per_night, total_count, available_count, images, amenities, area_sqm, bed_type, max_guests)
VALUES (seq_room_type.NEXTVAL, 3, 'Yunqi Zen Suite', 'ZenSuite', '#531DAB',
        'Tatami living room and tea ceremony corner, includes double Zen meditation course', 1588.00, 4, 3, NULL,
        '["WIFI","Aromatherapy Humidifier","Tea Ceremony Corner","Meditation Cushion","BOSE Speakers","Incense Gift Set","Handcrafted Tea Set","Sleep Aromatherapy"]',
        85.0, 'Tatami', 3);

-- 常规价格策略（VIP折扣）
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 1, (SELECT id FROM room_type WHERE name = 'Galaxy Executive King Room' AND hotel_id = 1 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.95, 1, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 1, (SELECT id FROM room_type WHERE name = 'Galaxy Executive King Room' AND hotel_id = 1 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.90, 2, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 1, (SELECT id FROM room_type WHERE name = 'Galaxy Executive King Room' AND hotel_id = 1 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.88, 3, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 1, (SELECT id FROM room_type WHERE name = 'Galaxy Executive King Room' AND hotel_id = 1 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.85, 4, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 1, (SELECT id FROM room_type WHERE name = 'Galaxy Family Suite' AND hotel_id = 1 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.96, 1, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 1, (SELECT id FROM room_type WHERE name = 'Galaxy Family Suite' AND hotel_id = 1 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.92, 2, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 1, (SELECT id FROM room_type WHERE name = 'Galaxy Family Suite' AND hotel_id = 1 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.89, 3, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 1, (SELECT id FROM room_type WHERE name = 'Galaxy Family Suite' AND hotel_id = 1 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.86, 4, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 1, (SELECT id FROM room_type WHERE name = 'Galaxy City View Room' AND hotel_id = 1 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.97, 1, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 1, (SELECT id FROM room_type WHERE name = 'Galaxy City View Room' AND hotel_id = 1 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.93, 2, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 1, (SELECT id FROM room_type WHERE name = 'Galaxy City View Room' AND hotel_id = 1 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.90, 3, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 1, (SELECT id FROM room_type WHERE name = 'Galaxy City View Room' AND hotel_id = 1 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.87, 4, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 2, (SELECT id FROM room_type WHERE name = 'Haitan Ocean View Room' AND hotel_id = 2 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.94, 1, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 2, (SELECT id FROM room_type WHERE name = 'Haitan Ocean View Room' AND hotel_id = 2 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.89, 2, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 2, (SELECT id FROM room_type WHERE name = 'Haitan Ocean View Room' AND hotel_id = 2 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.86, 3, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 2, (SELECT id FROM room_type WHERE name = 'Haitan Ocean View Room' AND hotel_id = 2 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.83, 4, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 2, (SELECT id FROM room_type WHERE name = 'Haitan Family Fun Room' AND hotel_id = 2 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.96, 1, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 2, (SELECT id FROM room_type WHERE name = 'Haitan Family Fun Room' AND hotel_id = 2 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.91, 2, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 2, (SELECT id FROM room_type WHERE name = 'Haitan Family Fun Room' AND hotel_id = 2 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.88, 3, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 2, (SELECT id FROM room_type WHERE name = 'Haitan Family Fun Room' AND hotel_id = 2 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.85, 4, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 2, (SELECT id FROM room_type WHERE name = 'Haitan Sky Suite' AND hotel_id = 2 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.93, 1, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 2, (SELECT id FROM room_type WHERE name = 'Haitan Sky Suite' AND hotel_id = 2 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.88, 2, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 2, (SELECT id FROM room_type WHERE name = 'Haitan Sky Suite' AND hotel_id = 2 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.85, 3, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 2, (SELECT id FROM room_type WHERE name = 'Haitan Sky Suite' AND hotel_id = 2 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.82, 4, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 3, (SELECT id FROM room_type WHERE name = 'Yunqi Hot Spring King Room' AND hotel_id = 3 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.95, 1, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 3, (SELECT id FROM room_type WHERE name = 'Yunqi Hot Spring King Room' AND hotel_id = 3 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.90, 2, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 3, (SELECT id FROM room_type WHERE name = 'Yunqi Hot Spring King Room' AND hotel_id = 3 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.87, 3, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 3, (SELECT id FROM room_type WHERE name = 'Yunqi Hot Spring King Room' AND hotel_id = 3 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.84, 4, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 3, (SELECT id FROM room_type WHERE name = 'Yunqi Forest Chalet' AND hotel_id = 3 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.94, 1, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 3, (SELECT id FROM room_type WHERE name = 'Yunqi Forest Chalet' AND hotel_id = 3 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.89, 2, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 3, (SELECT id FROM room_type WHERE name = 'Yunqi Forest Chalet' AND hotel_id = 3 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.86, 3, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 3, (SELECT id FROM room_type WHERE name = 'Yunqi Forest Chalet' AND hotel_id = 3 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.83, 4, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 3, (SELECT id FROM room_type WHERE name = 'Yunqi Zen Suite' AND hotel_id = 3 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.93, 1, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 3, (SELECT id FROM room_type WHERE name = 'Yunqi Zen Suite' AND hotel_id = 3 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.88, 2, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 3, (SELECT id FROM room_type WHERE name = 'Yunqi Zen Suite' AND hotel_id = 3 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.85, 3, 1, 1);
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 3, (SELECT id FROM room_type WHERE name = 'Yunqi Zen Suite' AND hotel_id = 3 FETCH FIRST 1 ROWS ONLY), 2, DATE '2024-01-01', DATE '2030-12-31', 0.00, 0.82, 4, 1, 1);

-- 房型图片
INSERT INTO room_images (id, room_type_id, url, is_primary, sort_order)
SELECT seq_room_images.NEXTVAL, rt.id, urls.url, urls.is_primary, urls.sort_order
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

-- 更新房型图片字段
UPDATE room_type rt
SET images = (
    SELECT LISTAGG(url, ',') WITHIN GROUP (ORDER BY sort_order)
    FROM room_images ri
    WHERE ri.room_type_id = rt.id
);

-- 插入房间
INSERT INTO room (id, hotel_id, room_type_id, room_number, floor, status)
WITH room_type_ranked AS (
    SELECT id, hotel_id, total_count,
           ROW_NUMBER() OVER (PARTITION BY hotel_id ORDER BY id) AS type_rank
    FROM room_type
),
numbers AS (
    SELECT LEVEL AS n
    FROM DUAL
    CONNECT BY LEVEL <= (SELECT MAX(total_count) FROM room_type)
)
SELECT seq_room.NEXTVAL, rt.hotel_id, rt.id,
       CHR(64 + rt.type_rank) || LPAD(FLOOR((n-1)/8) + 1, 2, '0') || LPAD(MOD(n-1,8) + 1, 2, '0') AS room_number,
       FLOOR((n-1)/8) + 1 AS floor,
       1 AS status
FROM room_type_ranked rt
JOIN numbers ON n <= rt.total_count;

-- 额外价格策略
INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 1,
        (SELECT id FROM room_type WHERE name = 'Galaxy City View Room' AND hotel_id = 1 FETCH FIRST 1 ROWS ONLY),
        2, TRUNC(SYSDATE), TRUNC(SYSDATE) + 30, NULL, 0.92, 1, 1, 1);

INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 1,
        (SELECT id FROM room_type WHERE name = 'Galaxy Executive King Room' AND hotel_id = 1 FETCH FIRST 1 ROWS ONLY),
        1, TRUNC(SYSDATE) + 5, TRUNC(SYSDATE) + 12, 180.00, NULL, NULL, 1, 1);

INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 2,
        (SELECT id FROM room_type WHERE name = 'Haitan Family Fun Room' AND hotel_id = 2 FETCH FIRST 1 ROWS ONLY),
        3, TRUNC(SYSDATE) + 14, TRUNC(SYSDATE) + 45, NULL, 0.88, NULL, 2, 1);

INSERT INTO room_price_strategy (id, hotel_id, room_type_id, strategy_type, start_date, end_date, price_adjust, discount_rate, vip_level, min_stay_days, status)
VALUES (seq_room_price_strategy.NEXTVAL, 3,
        (SELECT id FROM room_type WHERE name = 'Yunqi Hot Spring King Room' AND hotel_id = 3 FETCH FIRST 1 ROWS ONLY),
        1, TRUNC(SYSDATE) + 20, TRUNC(SYSDATE) + 35, -120.00, NULL, NULL, 1, 1);

-- 维护记录
INSERT INTO room_maintenance (id, room_id, maintenance_type, description, start_time, end_time, operator, status)
VALUES (seq_room_maintenance.NEXTVAL,
        (SELECT id FROM (
            SELECT id FROM room
            WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Galaxy City View Room' AND hotel_id = 1)
            ORDER BY room_number
            OFFSET 4 ROWS FETCH NEXT 1 ROWS ONLY
        )),
        'Air Conditioning Repair',
        'Temperature sensor malfunction, supplier contacted to replace sensor',
        SYSDATE - 1, NULL, 'Zhang Maintenance', 1);

INSERT INTO room_maintenance (id, room_id, maintenance_type, description, start_time, end_time, operator, status)
VALUES (seq_room_maintenance.NEXTVAL,
        (SELECT id FROM (
            SELECT id FROM room
            WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Haitan Family Fun Room' AND hotel_id = 2)
            ORDER BY room_number
            OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY
        )),
        'Carpet Cleaning',
        'Chocolate stain on carpet in family room, needs deep cleaning',
        SYSDATE - 3, SYSDATE - 2, 'Li Cleaning', 2);

-- 预订记录
INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 1,
        (SELECT id FROM room_type WHERE name = 'Galaxy Executive King Room' AND hotel_id = 1 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Galaxy Executive King Room' AND hotel_id = 1) ORDER BY room_number FETCH FIRST 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'alice'),
        TRUNC(SYSDATE) + 3 + 15/24, TRUNC(SYSDATE) + 5 + 12/24,
        'CONFIRMED', 2, 1079.20, 1136.00, 56.80, 1079.20, 1079.20, 0.95,
        'PAID', 'WALLET', 'WALLET', 'CNY', 'Alice', '13812345678', 'High floor request',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 1,
        (SELECT id FROM room_type WHERE name = 'Galaxy City View Room' AND hotel_id = 1 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Galaxy City View Room' AND hotel_id = 1) ORDER BY room_number FETCH FIRST 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'alice'),
        TRUNC(SYSDATE) - 12 + 15/24, TRUNC(SYSDATE) - 9 + 12/24,
        'CHECKED_OUT', 2, 1333.80, 1404.00, 70.20, 1333.80, 1333.80, 0.95,
        'PAID', 'WALLET', 'WALLET', 'CNY', 'Alice', '13812345678', 'Completed stay, good experience',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 2,
        (SELECT id FROM room_type WHERE name = 'Haitan Family Fun Room' AND hotel_id = 2 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Haitan Family Fun Room' AND hotel_id = 2) ORDER BY room_number FETCH FIRST 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'alice'),
        TRUNC(SYSDATE) + 25 + 15/24, TRUNC(SYSDATE) + 28 + 12/24,
        'CANCELLED', 3, 1981.44, 2064.00, 82.56, 1981.44, 0.00, 0.96,
        'UNPAID', NULL, NULL, 'CNY', 'Alice', '13812345678', 'User cancelled trip',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 1,
        (SELECT id FROM room_type WHERE name = 'Galaxy Family Suite' AND hotel_id = 1 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Galaxy Family Suite' AND hotel_id = 1) ORDER BY room_number FETCH FIRST 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'bob'),
        TRUNC(SYSDATE) + 5 + 15/24, TRUNC(SYSDATE) + 7 + 12/24,
        'PENDING_PAYMENT', 4, 2376.00, 2376.00, 0.00, 2376.00, 0.00, 1.00,
        'UNPAID', NULL, NULL, 'CNY', 'Bob', '15987654321', 'Awaiting payment',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 3,
        (SELECT id FROM room_type WHERE name = 'Yunqi Forest Chalet' AND hotel_id = 3 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Yunqi Forest Chalet' AND hotel_id = 3) ORDER BY room_number FETCH FIRST 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'bob'),
        TRUNC(SYSDATE) - 40 + 15/24, TRUNC(SYSDATE) - 37 + 12/24,
        'CHECKED_OUT', 4, 2576.00, 2576.00, 0.00, 2576.00, 2576.00, 1.00,
        'PAID', 'DIRECT', 'ARRIVAL', 'CNY', 'Bob', '15987654321', 'Friends gathering, positive feedback',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 2,
        (SELECT id FROM room_type WHERE name = 'Haitan Ocean View Room' AND hotel_id = 2 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Haitan Ocean View Room' AND hotel_id = 2) ORDER BY room_number FETCH FIRST 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'bob'),
        TRUNC(SYSDATE) - 20 + 15/24, TRUNC(SYSDATE) - 18 + 12/24,
        'CANCELLED', 2, 1656.00, 1656.00, 0.00, 1656.00, 0.00, 1.00,
        'UNPAID', NULL, NULL, 'CNY', 'Bob', '15987654321', 'Expired unpaid automatically cancelled',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 2,
        (SELECT id FROM room_type WHERE name = 'Haitan Ocean View Room' AND hotel_id = 2 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Haitan Ocean View Room' AND hotel_id = 2) ORDER BY room_number OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'charlie'),
        TRUNC(SYSDATE) - 1 + 15/24, TRUNC(SYSDATE) + 1 + 12/24,
        'CHECKED_IN', 2, 1473.84, 1656.00, 182.16, 1473.84, 1473.84, 0.89,
        'PAID', 'WALLET', 'WALLET', 'CNY', 'Charlie', '13698745632', 'Currently staying',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 2,
        (SELECT id FROM room_type WHERE name = 'Haitan Sky Suite' AND hotel_id = 2 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Haitan Sky Suite' AND hotel_id = 2) ORDER BY room_number FETCH FIRST 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'charlie'),
        TRUNC(SYSDATE) - 30 + 15/24, TRUNC(SYSDATE) - 27 + 12/24,
        'CHECKED_OUT', 2, 3611.52, 4104.00, 492.48, 3611.52, 3611.52, 0.88,
        'PAID', 'WALLET', 'WALLET', 'CNY', 'Charlie', '13698745632', 'Anniversary stay',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 3,
        (SELECT id FROM room_type WHERE name = 'Yunqi Hot Spring King Room' AND hotel_id = 3 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Yunqi Hot Spring King Room' AND hotel_id = 3) ORDER BY room_number FETCH FIRST 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'charlie'),
        TRUNC(SYSDATE) + 15 + 15/24, TRUNC(SYSDATE) + 17 + 12/24,
        'REFUNDED', 2, 1796.40, 1996.00, 199.60, 1796.40, 0.00, 0.90,
        'REFUNDED', 'ONLINE', 'VISA', 'CNY', 'Charlie', '13698745632', 'Full refund processed',
        'Itinerary changed, need refund', TRUNC(SYSDATE) + 10, TRUNC(SYSDATE) + 11, NULL,
        (SELECT id FROM users WHERE username = 'admin' FETCH FIRST 1 ROWS ONLY));

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 2,
        (SELECT id FROM room_type WHERE name = 'Haitan Family Fun Room' AND hotel_id = 2 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Haitan Family Fun Room' AND hotel_id = 2) ORDER BY room_number OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'diana'),
        TRUNC(SYSDATE) + 10 + 15/24, TRUNC(SYSDATE) + 13 + 12/24,
        'PENDING', 3, 1881.36, 1980.00, 98.64, 1881.36, 0.00, 0.95,
        'UNPAID', NULL, NULL, 'CNY', 'Diana', '18611223344', 'Need crib rail',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 1,
        (SELECT id FROM room_type WHERE name = 'Galaxy Executive King Room' AND hotel_id = 1 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Galaxy Executive King Room' AND hotel_id = 1) ORDER BY room_number OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'diana'),
        TRUNC(SYSDATE) + 1 + 15/24, TRUNC(SYSDATE) + 3 + 12/24,
        'CONFIRMED', 2, 1079.20, 1136.00, 56.80, 1079.20, 1079.20, 0.95,
        'PAID', 'ONLINE', 'ALIPAY', 'CNY', 'Diana', '18611223344', 'Arrange crib in advance',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 3,
        (SELECT id FROM room_type WHERE name = 'Yunqi Zen Suite' AND hotel_id = 3 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Yunqi Zen Suite' AND hotel_id = 3) ORDER BY room_number FETCH FIRST 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'diana'),
        TRUNC(SYSDATE) + 20 + 15/24, TRUNC(SYSDATE) + 23 + 12/24,
        'PENDING_CONFIRMATION', 2, 4525.80, 4764.00, 238.20, 4525.80, 0.00, 0.95,
        'UNPAID', NULL, NULL, 'CNY', 'Diana', '18611223344', 'Awaiting hotel confirmation for Zen course',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 1,
        (SELECT id FROM room_type WHERE name = 'Galaxy City View Room' AND hotel_id = 1 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Galaxy City View Room' AND hotel_id = 1) ORDER BY room_number OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'bob'),
        TRUNC(SYSDATE) + 8 + 15/24, TRUNC(SYSDATE) + 10 + 12/24,
        'PENDING', 2, 936.00, 936.00, 0.00, 936.00, 0.00, 1.00,
        'UNPAID', NULL, NULL, 'CNY', 'Bob', '15987654321', 'Business trip booking',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 3,
        (SELECT id FROM room_type WHERE name = 'Yunqi Hot Spring King Room' AND hotel_id = 3 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Yunqi Hot Spring King Room' AND hotel_id = 3) ORDER BY room_number OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'alice'),
        TRUNC(SYSDATE) + 30 + 15/24, TRUNC(SYSDATE) + 32 + 12/24,
        'CONFIRMED', 2, 1896.40, 1996.00, 99.60, 1896.40, 1896.40, 0.95,
        'PAID', 'WALLET', 'WALLET', 'CNY', 'Alice', '13812345678', 'Hot spring relaxation',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 3,
        (SELECT id FROM room_type WHERE name = 'Yunqi Forest Chalet' AND hotel_id = 3 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Yunqi Forest Chalet' AND hotel_id = 3) ORDER BY room_number OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'mia'),
        TRUNC(SYSDATE) + 2 + 14/24, TRUNC(SYSDATE) + 4 + 11/24,
        'CONFIRMED', 4, 2292.64, 2576.00, 283.36, 2292.64, 2292.64, 0.89,
        'PAID', 'WALLET', 'WALLET', 'CNY', 'Mia', '15712348765', 'Need BBQ ingredients arranged',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 1,
        (SELECT id FROM room_type WHERE name = 'Galaxy City View Room' AND hotel_id = 1 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Galaxy City View Room' AND hotel_id = 1) ORDER BY room_number OFFSET 5 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'mia'),
        TRUNC(SYSDATE) - 8 + 15/24, TRUNC(SYSDATE) - 6 + 12/24,
        'CHECKED_OUT', 2, 870.48, 936.00, 65.52, 870.48, 870.48, 0.93,
        'PAID', 'WALLET', 'WALLET', 'CNY', 'Mia', '15712348765', 'City stroll stay',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 2,
        (SELECT id FROM room_type WHERE name = 'Haitan Family Fun Room' AND hotel_id = 2 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Haitan Family Fun Room' AND hotel_id = 2) ORDER BY room_number OFFSET 5 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'mia'),
        TRUNC(SYSDATE) + 7 + 15/24, TRUNC(SYSDATE) + 10 + 12/24,
        'REFUNDED', 3, 1878.24, 2064.00, 185.76, 1878.24, 0.00, 0.91,
        'REFUNDED', 'ONLINE', 'WECHAT', 'CNY', 'Mia', '15712348765', 'Refunded due to schedule change',
        'Child ill, cannot travel', TRUNC(SYSDATE) + 7 - 10, TRUNC(SYSDATE) + 7 - 9, NULL,
        (SELECT id FROM users WHERE username = 'admin' FETCH FIRST 1 ROWS ONLY));

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 1,
        (SELECT id FROM room_type WHERE name = 'Galaxy City View Room' AND hotel_id = 1 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Galaxy City View Room' AND hotel_id = 1) ORDER BY room_number OFFSET 7 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'nina'),
        TRUNC(SYSDATE) + 6 + 15/24, TRUNC(SYSDATE) + 8 + 12/24,
        'PENDING', 1, 936.00, 936.00, 0.00, 936.00, 0.00, 1.00,
        'UNPAID', 'ONLINE', 'WECHAT', 'CNY', 'Nina', '13698761234', 'First stay experience',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 3,
        (SELECT id FROM room_type WHERE name = 'Yunqi Hot Spring King Room' AND hotel_id = 3 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Yunqi Hot Spring King Room' AND hotel_id = 3) ORDER BY room_number OFFSET 5 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'nina'),
        TRUNC(SYSDATE) - 5 + 15/24, TRUNC(SYSDATE) - 3 + 12/24,
        'CHECKED_OUT', 1, 1996.00, 1996.00, 0.00, 1996.00, 1996.00, 1.00,
        'PAID', 'DIRECT', 'ARRIVAL', 'CNY', 'Nina', '13698761234', 'Hot spring relaxation',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 2,
        (SELECT id FROM room_type WHERE name = 'Haitan Ocean View Room' AND hotel_id = 2 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Haitan Ocean View Room' AND hotel_id = 2) ORDER BY room_number OFFSET 3 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'oscar'),
        TRUNC(SYSDATE) + 4 + 15/24, TRUNC(SYSDATE) + 6 + 12/24,
        'PENDING_PAYMENT', 2, 1556.64, 1656.00, 99.36, 1556.64, 0.00, 0.94,
        'UNPAID', 'ONLINE', 'WECHAT', 'CNY', 'Oscar', '18623456789', 'Awaiting corporate approval for payment',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 2,
        (SELECT id FROM room_type WHERE name = 'Haitan Family Fun Room' AND hotel_id = 2 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Haitan Family Fun Room' AND hotel_id = 2) ORDER BY room_number OFFSET 6 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'oscar'),
        TRUNC(SYSDATE) - 3 + 15/24, TRUNC(SYSDATE) - 1 + 12/24,
        'CONFIRMED', 3, 1320.96, 1376.00, 55.04, 1320.96, 1320.96, 0.96,
        'PAID', 'WALLET', 'WALLET', 'CNY', 'Oscar', '18623456789', 'Family weekend getaway',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 1,
        (SELECT id FROM room_type WHERE name = 'Galaxy Executive King Room' AND hotel_id = 1 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Galaxy Executive King Room' AND hotel_id = 1) ORDER BY room_number OFFSET 4 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'paul'),
        TRUNC(SYSDATE) + 9 + 15/24, TRUNC(SYSDATE) + 11 + 12/24,
        'PENDING_CONFIRMATION', 2, 1022.40, 1136.00, 113.60, 1022.40, 0.00, 0.90,
        'UNPAID', 'ONLINE', 'VISA', 'CNY', 'Paul', '13787654321', 'Awaiting company approval',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 3,
        (SELECT id FROM room_type WHERE name = 'Yunqi Forest Chalet' AND hotel_id = 3 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Yunqi Forest Chalet' AND hotel_id = 3) ORDER BY room_number OFFSET 2 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'paul'),
        TRUNC(SYSDATE) - 18 + 15/24, TRUNC(SYSDATE) - 15 + 12/24,
        'CHECKED_OUT', 3, 3438.96, 3864.00, 425.04, 3438.96, 3438.96, 0.89,
        'PAID', 'WALLET', 'WALLET', 'CNY', 'Paul', '13787654321', 'Team building activity',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 3,
        (SELECT id FROM room_type WHERE name = 'Yunqi Zen Suite' AND hotel_id = 3 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Yunqi Zen Suite' AND hotel_id = 3) ORDER BY room_number OFFSET 2 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'quinn'),
        TRUNC(SYSDATE) + 3 + 15/24, TRUNC(SYSDATE) + 5 + 12/24,
        'CHECKED_IN', 2, 2699.60, 3176.00, 476.40, 2699.60, 2699.60, 0.85,
        'PAID', 'DIRECT', 'MANUAL', 'CNY', 'Quinn', '15876543210', 'VIP salon attendance',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 2,
        (SELECT id FROM room_type WHERE name = 'Haitan Sky Suite' AND hotel_id = 2 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Haitan Sky Suite' AND hotel_id = 2) ORDER BY room_number OFFSET 3 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'quinn'),
        TRUNC(SYSDATE) + 14 + 15/24, TRUNC(SYSDATE) + 17 + 12/24,
        'REFUNDED', 3, 3488.40, 4104.00, 615.60, 3488.40, 0.00, 0.85,
        'REFUNDED', 'ONLINE', 'VISA', 'CNY', 'Quinn', '15876543210', 'Rescheduled to next year',
        'Plan changed, rescheduled to same period next year', TRUNC(SYSDATE) + 14 - 7, TRUNC(SYSDATE) + 14 - 6, NULL,
        (SELECT id FROM users WHERE username = 'admin' FETCH FIRST 1 ROWS ONLY));

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 2,
        (SELECT id FROM room_type WHERE name = 'Haitan Sky Suite' AND hotel_id = 2 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Haitan Sky Suite' AND hotel_id = 2) ORDER BY room_number OFFSET 4 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'rachel'),
        TRUNC(SYSDATE) + 8 + 15/24, TRUNC(SYSDATE) + 10 + 12/24,
        'CONFIRMED', 2, 2243.52, 2736.00, 492.48, 2243.52, 2243.52, 0.82,
        'PAID', 'WALLET', 'WALLET', 'CNY', 'Rachel', '13598761234', 'Enjoy diamond exclusive benefits',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 3,
        (SELECT id FROM room_type WHERE name = 'Yunqi Zen Suite' AND hotel_id = 3 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Yunqi Zen Suite' AND hotel_id = 3) ORDER BY room_number OFFSET 3 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'rachel'),
        TRUNC(SYSDATE) + 26 + 15/24, TRUNC(SYSDATE) + 29 + 12/24,
        'PENDING', 2, 4001.76, 4764.00, 762.24, 4001.76, 0.00, 0.84,
        'UNPAID', 'ONLINE', 'WECHAT', 'CNY', 'Rachel', '13598761234', 'Awaiting confirmation for private Zen master',
        NULL, NULL, NULL, NULL, NULL);

-- 额外预订记录
INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 1,
        (SELECT id FROM room_type WHERE name = 'Galaxy Executive King Room' AND hotel_id = 1 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Galaxy Executive King Room' AND hotel_id = 1) ORDER BY room_number OFFSET 5 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'alice'),
        TRUNC(SYSDATE) + 2 + 13/24, TRUNC(SYSDATE) + 4 + 11/24,
        'CONFIRMED', 2, 1045.12, 1136.00, 90.88, 1045.12, 1045.12, 0.92,
        'PAID', 'WALLET', 'WALLET', 'CNY', 'Alice', '13812345678', 'Additional booking for executive room',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 1,
        (SELECT id FROM room_type WHERE name = 'Galaxy Executive King Room' AND hotel_id = 1 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Galaxy Executive King Room' AND hotel_id = 1) ORDER BY room_number OFFSET 6 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'bob'),
        TRUNC(SYSDATE) + 6 + 16/24, TRUNC(SYSDATE) + 9 + 11/24,
        'PENDING_CONFIRMATION', 2, 1618.80, 1704.00, 85.20, 1618.80, 0.00, 0.95,
        'UNPAID', 'ONLINE', 'ALIPAY', 'CNY', 'Bob', '15987654321', 'Awaiting approval confirmation',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 1,
        (SELECT id FROM room_type WHERE name = 'Galaxy Family Suite' AND hotel_id = 1 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Galaxy Family Suite' AND hotel_id = 1) ORDER BY room_number OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'charlie'),
        TRUNC(SYSDATE) + 4 + 14/24, TRUNC(SYSDATE) + 7 + 11/24,
        'REFUND_REQUESTED', 4, 2138.40, 2376.00, 237.60, 2138.40, 2138.40, 0.90,
        'PAID', 'WALLET', 'WALLET', 'CNY', 'Charlie', '13698745632', 'Family trip booking',
        'Family emergency, need refund', TRUNC(SYSDATE) - 1, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 1,
        (SELECT id FROM room_type WHERE name = 'Galaxy Family Suite' AND hotel_id = 1 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Galaxy Family Suite' AND hotel_id = 1) ORDER BY room_number OFFSET 2 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'nina'),
        TRUNC(SYSDATE) + 1 + 12/24, TRUNC(SYSDATE) + 3 + 10/24,
        'CHECKED_IN', 4, 1140.48, 1188.00, 47.52, 1140.48, 1140.48, 0.96,
        'PAID', 'WALLET', 'WALLET', 'CNY', 'Nina', '13698761234', 'Family stay in progress',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 1,
        (SELECT id FROM room_type WHERE name = 'Galaxy City View Room' AND hotel_id = 1 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Galaxy City View Room' AND hotel_id = 1) ORDER BY room_number OFFSET 8 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'oscar'),
        TRUNC(SYSDATE) + 5 + 15/24, TRUNC(SYSDATE) + 7 + 12/24,
        'CONFIRMED', 2, 842.40, 936.00, 93.60, 842.40, 842.40, 0.90,
        'PAID', 'ONLINE', 'WECHAT', 'CNY', 'Oscar', '18623456789', 'City view room high floor request',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 1,
        (SELECT id FROM room_type WHERE name = 'Galaxy City View Room' AND hotel_id = 1 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Galaxy City View Room' AND hotel_id = 1) ORDER BY room_number OFFSET 9 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'paul'),
        TRUNC(SYSDATE) + 10 + 17/24, TRUNC(SYSDATE) + 13 + 11/24,
        'PENDING_CONFIRMATION', 2, 1333.80, 1404.00, 70.20, 1333.80, 0.00, 0.95,
        'UNPAID', 'ONLINE', 'WECHAT', 'CNY', 'Paul', '13787654321', 'Awaiting travel approval',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 2,
        (SELECT id FROM room_type WHERE name = 'Haitan Ocean View Room' AND hotel_id = 2 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Haitan Ocean View Room' AND hotel_id = 2) ORDER BY room_number OFFSET 4 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'quinn'),
        TRUNC(SYSDATE) + 2 + 15/24, TRUNC(SYSDATE) + 5 + 12/24,
        'CHECKED_IN', 2, 1457.28, 1656.00, 198.72, 1457.28, 1457.28, 0.88,
        'PAID', 'WALLET', 'WALLET', 'CNY', 'Quinn', '15876543210', 'Checked in',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 2,
        (SELECT id FROM room_type WHERE name = 'Haitan Ocean View Room' AND hotel_id = 2 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Haitan Ocean View Room' AND hotel_id = 2) ORDER BY room_number OFFSET 5 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'rachel'),
        TRUNC(SYSDATE) + 11 + 15/24, TRUNC(SYSDATE) + 14 + 12/24,
        'CONFIRMED', 2, 2111.40, 2484.00, 372.60, 2111.40, 2111.40, 0.85,
        'PAID', 'WALLET', 'WALLET', 'CNY', 'Rachel', '13598761234', 'Arrange evening dessert',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 2,
        (SELECT id FROM room_type WHERE name = 'Haitan Family Fun Room' AND hotel_id = 2 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Haitan Family Fun Room' AND hotel_id = 2) ORDER BY room_number OFFSET 7 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'diana'),
        TRUNC(SYSDATE) + 3 + 14/24, TRUNC(SYSDATE) + 6 + 11/24,
        'CONFIRMED', 3, 1238.40, 1376.00, 137.60, 1238.40, 1238.40, 0.90,
        'PAID', 'ONLINE', 'WECHAT', 'CNY', 'Diana', '18611223344', 'Family activity reservation successful',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 2,
        (SELECT id FROM room_type WHERE name = 'Haitan Family Fun Room' AND hotel_id = 2 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Haitan Family Fun Room' AND hotel_id = 2) ORDER BY room_number OFFSET 8 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'mia'),
        TRUNC(SYSDATE) + 8 + 16/24, TRUNC(SYSDATE) + 10 + 12/24,
        'PENDING_PAYMENT', 4, 1307.20, 1376.00, 68.80, 1307.20, 0.00, 0.95,
        'UNPAID', 'WALLET', 'WALLET', 'CNY', 'Mia', '15712348765', 'Awaiting balance payment',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 2,
        (SELECT id FROM room_type WHERE name = 'Haitan Sky Suite' AND hotel_id = 2 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Haitan Sky Suite' AND hotel_id = 2) ORDER BY room_number OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'leo'),
        TRUNC(SYSDATE) + 1 + 15/24, TRUNC(SYSDATE) + 3 + 12/24,
        'CONFIRMED', 2, 2407.68, 2736.00, 328.32, 2407.68, 2407.68, 0.88,
        'PAID', 'WALLET', 'WALLET', 'CNY', 'Leo', '13712349876', 'Reserve private butler service',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 3,
        (SELECT id FROM room_type WHERE name = 'Yunqi Hot Spring King Room' AND hotel_id = 3 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Yunqi Hot Spring King Room' AND hotel_id = 3) ORDER BY room_number OFFSET 6 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'alice'),
        TRUNC(SYSDATE) + 4 + 15/24, TRUNC(SYSDATE) + 6 + 12/24,
        'CONFIRMED', 2, 1796.40, 1996.00, 199.60, 1796.40, 1796.40, 0.90,
        'PAID', 'WALLET', 'WALLET', 'CNY', 'Alice', '13812345678', 'Hot spring experience booked',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 3,
        (SELECT id FROM room_type WHERE name = 'Yunqi Forest Chalet' AND hotel_id = 3 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Yunqi Forest Chalet' AND hotel_id = 3) ORDER BY room_number OFFSET 3 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'bob'),
        TRUNC(SYSDATE) + 2 + 14/24, TRUNC(SYSDATE) + 4 + 12/24,
        'CHECKED_IN', 4, 2318.40, 2576.00, 257.60, 2318.40, 2318.40, 0.90,
        'PAID', 'DIRECT', 'ARRIVAL', 'CNY', 'Bob', '15987654321', 'Chalet experience in progress',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 3,
        (SELECT id FROM room_type WHERE name = 'Yunqi Forest Chalet' AND hotel_id = 3 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Yunqi Forest Chalet' AND hotel_id = 3) ORDER BY room_number OFFSET 4 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'paul'),
        TRUNC(SYSDATE) + 9 + 15/24, TRUNC(SYSDATE) + 12 + 12/24,
        'CONFIRMED', 3, 3554.88, 3864.00, 309.12, 3554.88, 3554.88, 0.92,
        'PAID', 'WALLET', 'WALLET', 'CNY', 'Paul', '13787654321', 'Team autumn outing, whole chalet',
        NULL, NULL, NULL, NULL, NULL);

INSERT INTO bookings (id, hotel_id, room_type_id, room_id, user_id, start_time, end_time, status, guests,
                      amount, original_amount, discount_amount, payable_amount, paid_amount, discount_rate,
                      payment_status, payment_method, payment_channel, currency, contact_name, contact_phone, remark,
                      refund_reason, refund_requested_at, refund_approved_at, refund_rejected_at, refund_approved_by)
VALUES (seq_bookings.NEXTVAL, 3,
        (SELECT id FROM room_type WHERE name = 'Yunqi Hot Spring King Room' AND hotel_id = 3 FETCH FIRST 1 ROWS ONLY),
        (SELECT id FROM (SELECT id FROM room WHERE room_type_id = (SELECT id FROM room_type WHERE name = 'Yunqi Hot Spring King Room' AND hotel_id = 3) ORDER BY room_number OFFSET 7 ROWS FETCH NEXT 1 ROWS ONLY)),
        (SELECT id FROM users WHERE username = 'quinn'),
        TRUNC(SYSDATE) + 7 + 16/24, TRUNC(SYSDATE) + 9 + 12/24,
        'PENDING_CONFIRMATION', 2, 1856.28, 1996.00, 139.72, 1856.28, 0.00, 0.93,
        'UNPAID', 'ONLINE', 'WECHAT', 'CNY', 'Quinn', '15876543210', 'Awaiting hot spring time confirmation',
        NULL, NULL, NULL, NULL, NULL);

-- 更新房间状态
UPDATE room r
SET status = CASE
                 WHEN EXISTS (SELECT 1 FROM room_maintenance m WHERE m.room_id = r.id AND m.status = 1) THEN 5
                 WHEN EXISTS (SELECT 1 FROM bookings b WHERE b.room_id = r.id AND b.status = 'CHECKED_IN') THEN 3
                 WHEN EXISTS (SELECT 1 FROM bookings b WHERE b.room_id = r.id AND b.status IN ('PENDING','PENDING_CONFIRMATION','PENDING_PAYMENT','CONFIRMED')) THEN 2
                 ELSE 1
             END;

UPDATE room r
SET last_checkout_time = (
    SELECT MAX(b.end_time)
    FROM bookings b
    WHERE b.room_id = r.id AND b.status = 'CHECKED_OUT'
)
WHERE EXISTS (SELECT 1 FROM bookings b WHERE b.room_id = r.id AND b.status = 'CHECKED_OUT');

UPDATE room_type rt
SET available_count = (
    SELECT COUNT(*) FROM room r WHERE r.room_type_id = rt.id AND r.status = 1
);

COMMIT;