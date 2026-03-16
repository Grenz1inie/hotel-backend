package com.hyj.hotelbackend.util;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/**
 * 图片URL更新工具
 * 用途：将数据库中的图片URL从网络链接更新为本地路径
 * 执行方式：启动应用时自动执行一次
 * 
 * 注意：更新完成后请将 ENABLE_UPDATE 设置为 false，避免重复执行
 */
@Component
public class ImageUrlUpdater implements CommandLineRunner {

    // ⚠️ 更新开关：true = 启用更新，false = 禁用更新
    // 更新完成后请改为 false
    private static final boolean ENABLE_UPDATE = true;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Override
    public void run(String... args) throws Exception {
        if (!ENABLE_UPDATE) {
            System.out.println("图片URL更新已禁用（ImageUrlUpdater.ENABLE_UPDATE = false）");
            return;
        }
        
        System.out.println("========================================");
        System.out.println("开始更新图片URL...");
        
        try {
            // 更新星河国际酒店
            int rows1 = jdbcTemplate.update(
                "UPDATE hotel SET hero_image_url = ?, gallery_images = ? WHERE id = ?",
                "/images/hotels/xinghe-hero.jpg",
                "/images/hotels/xinghe-gallery0.jpg,/images/hotels/xinghe-gallery1.jpg",
                1
            );
            System.out.println("✓ 已更新星河国际酒店图片URL (" + rows1 + " 行)");

            // 更新海天假日酒店（临时使用星河图片）
            int rows2 = jdbcTemplate.update(
                "UPDATE hotel SET hero_image_url = ?, gallery_images = ? WHERE id = ?",
                "/images/hotels/xinghe-hero.jpg",
                "/images/hotels/xinghe-gallery0.jpg,/images/hotels/xinghe-gallery1.jpg",
                2
            );
            System.out.println("✓ 已更新海天假日酒店图片URL (" + rows2 + " 行)");

            // 更新云栖温泉度假村（临时使用星河图片）
            int rows3 = jdbcTemplate.update(
                "UPDATE hotel SET hero_image_url = ?, gallery_images = ? WHERE id = ?",
                "/images/hotels/xinghe-hero.jpg",
                "/images/hotels/xinghe-gallery0.jpg,/images/hotels/xinghe-gallery1.jpg",
                3
            );
            System.out.println("✓ 已更新云栖温泉度假村图片URL (" + rows3 + " 行)");

            // 删除旧的房型图片数据
            jdbcTemplate.update("DELETE FROM room_images");
            System.out.println("✓ 已清除旧的房型图片数据");

            // 插入新的房型图片数据
            String insertSql = "INSERT INTO room_images (room_type_id, url, is_primary, sort_order) " +
                "SELECT rt.id, urls.url, urls.is_primary, urls.sort_order " +
                "FROM room_type rt " +
                "JOIN ( " +
                "    SELECT '星河行政大床房' AS name, '/images/rooms/xinghe-exec-1.jpg' AS url, 1 AS is_primary, 1 AS sort_order " +
                "    UNION ALL SELECT '星河行政大床房', '/images/rooms/xinghe-exec-2.jpg', 0, 2 " +
                "    UNION ALL SELECT '星河行政大床房', '/images/rooms/xinghe-exec-3.jpg', 0, 3 " +
                "    UNION ALL SELECT '星河家庭套房', '/images/rooms/xinghe-family-1.jpg', 1, 1 " +
                "    UNION ALL SELECT '星河家庭套房', '/images/rooms/xinghe-family-2.jpg', 0, 2 " +
                "    UNION ALL SELECT '星河家庭套房', '/images/rooms/xinghe-family-3.jpg', 0, 3 " +
                "    UNION ALL SELECT '星河城市景观房', '/images/rooms/xinghe-city-1.jpg', 1, 1 " +
                "    UNION ALL SELECT '星河城市景观房', '/images/rooms/xinghe-city-2.jpg', 0, 2 " +
                "    UNION ALL SELECT '海天无边海景房', '/images/rooms/xinghe-exec-1.jpg', 1, 1 " +
                "    UNION ALL SELECT '海天无边海景房', '/images/rooms/xinghe-exec-2.jpg', 0, 2 " +
                "    UNION ALL SELECT '海天亲子乐园房', '/images/rooms/xinghe-family-1.jpg', 1, 1 " +
                "    UNION ALL SELECT '海天亲子乐园房', '/images/rooms/xinghe-family-2.jpg', 0, 2 " +
                "    UNION ALL SELECT '海天尊享套房', '/images/rooms/xinghe-city-1.jpg', 1, 1 " +
                "    UNION ALL SELECT '海天尊享套房', '/images/rooms/xinghe-city-2.jpg', 0, 2 " +
                "    UNION ALL SELECT '云栖温泉大床房', '/images/rooms/xinghe-exec-1.jpg', 1, 1 " +
                "    UNION ALL SELECT '云栖温泉大床房', '/images/rooms/xinghe-exec-2.jpg', 0, 2 " +
                "    UNION ALL SELECT '云栖森林木屋', '/images/rooms/xinghe-family-1.jpg', 1, 1 " +
                "    UNION ALL SELECT '云栖森林木屋', '/images/rooms/xinghe-family-2.jpg', 0, 2 " +
                "    UNION ALL SELECT '云栖禅意套房', '/images/rooms/xinghe-city-1.jpg', 1, 1 " +
                "    UNION ALL SELECT '云栖禅意套房', '/images/rooms/xinghe-city-2.jpg', 0, 2 " +
                ") urls ON urls.name = rt.name";
            
            int rows4 = jdbcTemplate.update(insertSql);
            System.out.println("✓ 已插入新的房型图片数据 (" + rows4 + " 行)");

            // 更新room_type表的images字段
            String updateRoomTypeSql = "UPDATE room_type rt SET images = (" +
                "SELECT GROUP_CONCAT(url ORDER BY sort_order SEPARATOR ',') " +
                "FROM room_images ri WHERE ri.room_type_id = rt.id)";
            int rows5 = jdbcTemplate.update(updateRoomTypeSql);
            System.out.println("✓ 已更新房型表的images字段 (" + rows5 + " 行)");

            System.out.println("========================================");
            System.out.println("✅ 图片URL更新完成！");
            System.out.println("========================================");
            
        } catch (Exception e) {
            System.err.println("❌ 更新图片URL失败: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
