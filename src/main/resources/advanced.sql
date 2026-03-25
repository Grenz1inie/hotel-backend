-- 1. Views -----------------------------------------------------------------
-- 1.1 Hotel room type availability overview view
CREATE OR REPLACE VIEW hotel_user.v_hotel_room_availability AS
SELECT
    h.id AS hotel_id,
    h.name AS hotel_name,
    rt.id AS room_type_id,
    rt.name AS room_type_name,
    rt.price_per_night,
    rt.total_count,
    rt.available_count,
    rt.is_active,
    (SELECT COUNT(*) FROM hotel_user.room r WHERE r.room_type_id = rt.id AND r.status = 1) AS actual_vacant_rooms
FROM hotel_user.hotel h
JOIN hotel_user.room_type rt ON rt.hotel_id = h.id
WHERE rt.is_active = 1;
COMMENT ON TABLE hotel_user.v_hotel_room_availability IS 'Hotel Room Type Availability Overview View';

-- 1.2 User VIP member information view (with level benefits)
CREATE OR REPLACE VIEW hotel_user.v_user_vip_info AS
SELECT
    u.id AS user_id,
    u.username,
    u.vip_level,
    v.name AS level_name,
    v.discount_rate,
    v.checkout_hour,
    u.total_consumption,
    u.status
FROM hotel_user.users u
JOIN hotel_user.vip_level_policy v ON v.vip_level = u.vip_level;
COMMENT ON TABLE hotel_user.v_user_vip_info IS 'User VIP Member Information View (with level benefits)';

-- 1.3 Daily booking statistics view (by hotel and date)
CREATE OR REPLACE VIEW hotel_user.v_daily_booking_stats AS
SELECT
    h.id AS hotel_id,
    h.name AS hotel_name,
    TRUNC(b.start_time) AS stat_date,
    COUNT(b.id) AS total_bookings,
    SUM(CASE WHEN b.status IN ('CONFIRMED','CHECKED_IN','CHECKED_OUT') THEN 1 ELSE 0 END) AS confirmed_bookings,
    SUM(CASE WHEN b.status = 'CANCELLED' THEN 1 ELSE 0 END) AS cancelled_bookings,
    SUM(b.amount) AS total_revenue
FROM hotel_user.hotel h
LEFT JOIN hotel_user.bookings b ON b.hotel_id = h.id
GROUP BY h.id, h.name, TRUNC(b.start_time);
COMMENT ON TABLE hotel_user.v_daily_booking_stats IS 'Daily Booking Statistics View';

-- 2. Triggers -----------------------------------------------------------------
-- 2.1 Automatically sync room status when booking status changes
CREATE OR REPLACE TRIGGER hotel_user.trg_booking_status_update
AFTER UPDATE OF status ON hotel_user.bookings
FOR EACH ROW
DECLARE
    v_room_status NUMBER(3);
BEGIN
    -- When booking status becomes CHECKED_IN, set room status to 3 (occupied)
    IF :NEW.status = 'CHECKED_IN' THEN
        UPDATE hotel_user.room
        SET status = 3,
            updated_time = SYSDATE
        WHERE id = :NEW.room_id;
    -- When booking status becomes CHECKED_OUT, set room status to 1 (vacant) and record last checkout time
    ELSIF :NEW.status = 'CHECKED_OUT' THEN
        UPDATE hotel_user.room
        SET status = 1,
            last_checkout_time = SYSDATE,
            updated_time = SYSDATE
        WHERE id = :NEW.room_id;
    -- When booking is cancelled or refunded, restore room status to 1 (vacant), but ensure no other valid bookings exist
    ELSIF :NEW.status IN ('CANCELLED', 'REFUNDED') THEN
        -- Check if there are other valid bookings (checked in or future)
        DECLARE
            v_other_bookings NUMBER;
        BEGIN
            SELECT COUNT(*)
            INTO v_other_bookings
            FROM hotel_user.bookings
            WHERE room_id = :NEW.room_id
              AND id != :NEW.id
              AND status IN ('CONFIRMED', 'CHECKED_IN', 'PENDING', 'PENDING_CONFIRMATION', 'PENDING_PAYMENT');
            IF v_other_bookings = 0 THEN
                UPDATE hotel_user.room
                SET status = 1,
                    updated_time = SYSDATE
                WHERE id = :NEW.room_id;
            END IF;
        END;
    END IF;
END;
/

-- 2.2 Automatically reduce room type available count when booking created (prevent overbooking)
CREATE OR REPLACE TRIGGER hotel_user.trg_booking_insert
AFTER INSERT ON hotel_user.bookings
FOR EACH ROW
DECLARE
    v_available_count NUMBER;
BEGIN
    -- Only effective for booking statuses that require room occupancy
    IF :NEW.status IN ('PENDING', 'PENDING_CONFIRMATION', 'PENDING_PAYMENT', 'CONFIRMED', 'CHECKED_IN') THEN
        -- Lock the room type row to avoid concurrency
        UPDATE hotel_user.room_type
        SET available_count = available_count - 1,
            updated_time = SYSDATE
        WHERE id = :NEW.room_type_id
          AND available_count > 0
        RETURNING available_count INTO v_available_count;

        IF SQL%NOTFOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'Insufficient room type inventory, cannot book');
        END IF;
    END IF;
END;
/

-- 2.3 Restore room type available count on cancellation or refund
CREATE OR REPLACE TRIGGER hotel_user.trg_booking_cancel_refund
AFTER UPDATE OF status ON hotel_user.bookings
FOR EACH ROW
BEGIN
    IF :OLD.status IN ('PENDING', 'PENDING_CONFIRMATION', 'PENDING_PAYMENT', 'CONFIRMED', 'CHECKED_IN')
       AND :NEW.status IN ('CANCELLED', 'REFUNDED') THEN
        UPDATE hotel_user.room_type
        SET available_count = available_count + 1,
            updated_time = SYSDATE
        WHERE id = :NEW.room_type_id;
    END IF;
END;
/

-- 2.4 Automatically update VIP level when user total consumption changes
CREATE OR REPLACE TRIGGER hotel_user.trg_user_vip_upgrade
AFTER UPDATE OF total_consumption ON hotel_user.users
FOR EACH ROW
DECLARE
    v_new_level NUMBER(3);
BEGIN
    -- Determine VIP level based on total consumption (thresholds correspond to vip_level_policy table: level0=0, level1=5000, level2=15000, level3=30000, level4=50000)
    v_new_level := CASE
        WHEN :NEW.total_consumption >= 50000 THEN 4
        WHEN :NEW.total_consumption >= 30000 THEN 3
        WHEN :NEW.total_consumption >= 15000 THEN 2
        WHEN :NEW.total_consumption >= 5000  THEN 1
        ELSE 0
    END;
    IF v_new_level != :NEW.vip_level THEN
        UPDATE hotel_user.users
        SET vip_level = v_new_level,
            updated_at = SYSDATE
        WHERE id = :NEW.id;
    END IF;
END;
/

-- 3. Stored Procedures -----------------------------------------------------------------
-- 3.1 Generate daily room statistics for a given date range (write to vacancy_statistics)
CREATE OR REPLACE PROCEDURE hotel_user.generate_daily_stats(
    p_start_date DATE,
    p_end_date   DATE
) IS
    v_stat_date DATE;
    v_hotel_id  hotel_user.hotel.id%TYPE;
    v_room_type_id hotel_user.room_type.id%TYPE;
    v_total_rooms NUMBER;
    v_available_rooms NUMBER;
    v_occupied_rooms NUMBER;
    v_reserved_rooms NUMBER;
    v_maintenance_rooms NUMBER;
    v_locked_rooms NUMBER;
    v_vacancy_rate NUMBER(5,4);
BEGIN
    -- Loop over dates
    FOR v_stat_date IN p_start_date .. p_end_date LOOP
        -- Loop over all hotel-room type combinations
        FOR rec IN (SELECT h.id AS hotel_id, rt.id AS room_type_id, rt.total_count
                    FROM hotel_user.hotel h
                    JOIN hotel_user.room_type rt ON rt.hotel_id = h.id
                    WHERE rt.is_active = 1) LOOP
            -- Count room statuses
            SELECT COUNT(*),
                   COUNT(CASE WHEN r.status = 1 THEN 1 END),
                   COUNT(CASE WHEN r.status = 3 THEN 1 END),   -- occupied
                   COUNT(CASE WHEN r.status = 2 THEN 1 END),   -- booked
                   COUNT(CASE WHEN r.status = 5 THEN 1 END)    -- maintenance
            INTO v_total_rooms, v_available_rooms, v_occupied_rooms, v_reserved_rooms, v_maintenance_rooms
            FROM hotel_user.room r
            WHERE r.room_type_id = rec.room_type_id;

            v_locked_rooms := 0; -- No locked status currently

            -- Calculate vacancy rate (simple available/total)
            IF v_total_rooms > 0 THEN
                v_vacancy_rate := v_available_rooms / v_total_rooms;
            ELSE
                v_vacancy_rate := 0;
            END IF;

            -- Insert or update statistics
            MERGE INTO hotel_user.vacancy_statistics vs
            USING (SELECT rec.hotel_id AS hid, rec.room_type_id AS rtid, v_stat_date AS sdate, NULL AS shour FROM DUAL) src
            ON (vs.hotel_id = src.hid AND vs.room_type_id = src.rtid AND vs.stat_date = src.sdate AND vs.stat_hour IS NULL)
            WHEN MATCHED THEN
                UPDATE SET
                    total_rooms = v_total_rooms,
                    available_rooms = v_available_rooms,
                    occupied_rooms = v_occupied_rooms,
                    reserved_rooms = v_reserved_rooms,
                    maintenance_rooms = v_maintenance_rooms,
                    locked_rooms = v_locked_rooms,
                    vacancy_count = v_available_rooms,
                    vacancy_rate = v_vacancy_rate,
                    occupancy_rate = v_occupied_rooms / NULLIF(v_total_rooms,0),
                    booking_rate = v_reserved_rooms / NULLIF(v_total_rooms,0),
                    updated_at = SYSDATE
            WHEN NOT MATCHED THEN
                INSERT (id, hotel_id, room_type_id, stat_date, stat_hour, total_rooms, available_rooms,
                        occupied_rooms, reserved_rooms, maintenance_rooms, locked_rooms,
                        vacancy_count, vacancy_rate, occupancy_rate, booking_rate, created_at, updated_at)
                VALUES (hotel_user.seq_vacancy_statistics.NEXTVAL, rec.hotel_id, rec.room_type_id, v_stat_date, NULL,
                        v_total_rooms, v_available_rooms, v_occupied_rooms, v_reserved_rooms,
                        v_maintenance_rooms, v_locked_rooms, v_available_rooms, v_vacancy_rate,
                        v_occupied_rooms/NULLIF(v_total_rooms,0), v_reserved_rooms/NULLIF(v_total_rooms,0),
                        SYSDATE, SYSDATE);
        END LOOP;
    END LOOP;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Statistics generation completed, date range: ' || TO_CHAR(p_start_date, 'YYYY-MM-DD') || ' to ' || TO_CHAR(p_end_date, 'YYYY-MM-DD'));
END generate_daily_stats;
/

-- 3.2 Perform monthly VIP level batch upgrade (based on annual total consumption)
CREATE OR REPLACE PROCEDURE hotel_user.monthly_vip_upgrade IS
    CURSOR c_user IS
        SELECT id, total_consumption, vip_level FROM hotel_user.users;
BEGIN
    FOR u IN c_user LOOP
        DECLARE
            v_new_level NUMBER(3);
        BEGIN
            v_new_level := CASE
                WHEN u.total_consumption >= 50000 THEN 4
                WHEN u.total_consumption >= 30000 THEN 3
                WHEN u.total_consumption >= 15000 THEN 2
                WHEN u.total_consumption >= 5000  THEN 1
                ELSE 0
            END;
            IF v_new_level != u.vip_level THEN
                UPDATE hotel_user.users
                SET vip_level = v_new_level,
                    updated_at = SYSDATE
                WHERE id = u.id;
            END IF;
        END;
    END LOOP;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Monthly VIP upgrade completed');
END monthly_vip_upgrade;
/

-- 4. Functions -----------------------------------------------------------------
-- 4.1 Return applicable VIP discount rate for a user ID
CREATE OR REPLACE FUNCTION hotel_user.get_user_discount(p_user_id NUMBER) RETURN NUMBER IS
    v_discount_rate NUMBER(4,3);
BEGIN
    SELECT v.discount_rate
    INTO v_discount_rate
    FROM hotel_user.users u
    JOIN hotel_user.vip_level_policy v ON v.vip_level = u.vip_level
    WHERE u.id = p_user_id;
    RETURN v_discount_rate;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 1.000;
END get_user_discount;
/

-- 4.2 Calculate total booking amount (based on nights, base price, and VIP discount)
-- Simplified: assumes daily price is constant, dynamic pricing not considered
CREATE OR REPLACE FUNCTION hotel_user.calculate_booking_amount(
    p_room_type_id NUMBER,
    p_start_date DATE,
    p_end_date DATE,
    p_user_id NUMBER
) RETURN NUMBER IS
    v_base_price NUMBER(10,2);
    v_days NUMBER;
    v_discount NUMBER(4,3);
BEGIN
    SELECT price_per_night INTO v_base_price
    FROM hotel_user.room_type WHERE id = p_room_type_id;
    v_days := p_end_date - p_start_date;
    IF v_days <= 0 THEN
        RETURN 0;
    END IF;
    v_discount := hotel_user.get_user_discount(p_user_id);
    RETURN v_base_price * v_days * v_discount;
END calculate_booking_amount;
/

-- 4.3 Calculate refundable amount for a booking ID (simple full refund if check-in hasn't started)
CREATE OR REPLACE FUNCTION hotel_user.calculate_refund_amount(p_booking_id NUMBER) RETURN NUMBER IS
    v_paid_amount NUMBER(10,2);
    v_status VARCHAR2(30);
    v_start_date DATE;
BEGIN
    SELECT paid_amount, status, start_time INTO v_paid_amount, v_status, v_start_date
    FROM hotel_user.bookings WHERE id = p_booking_id;
    -- If paid, not already refunded/cancelled/checked out, and check-in hasn't started, full refund is possible
    IF v_paid_amount > 0 AND v_status NOT IN ('REFUNDED','CANCELLED','CHECKED_OUT') AND v_start_date > SYSDATE THEN
        RETURN v_paid_amount;
    ELSE
        RETURN 0;
    END IF;
END calculate_refund_amount;
/

-- Create sequence for vacancy_statistics if it does not exist
DECLARE
    v_cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_cnt FROM all_sequences WHERE sequence_owner = 'HOTEL_USER' AND sequence_name = 'SEQ_VACANCY_STATISTICS';
    IF v_cnt = 0 THEN
        EXECUTE IMMEDIATE 'CREATE SEQUENCE hotel_user.seq_vacancy_statistics START WITH 1 INCREMENT BY 1';
    END IF;
END;
/

-- Output completion message
SELECT 'Advanced features (views, triggers, procedures, functions) added successfully.' AS status FROM DUAL;
COMMIT;