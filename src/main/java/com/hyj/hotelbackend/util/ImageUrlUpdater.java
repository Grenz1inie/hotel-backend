package com.hyj.hotelbackend.util;

import com.hyj.hotelbackend.config.AliyunOssConfig;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/**
 * 图片 URL 更新工具（阿里云 OSS 版 - 纯 URL 拼接）
 * 用途：将数据库中的图片 URL 更新为阿里云 OSS 的完整访问地址
 * 前提：图片文件已手动上传至 OSS，且目录结构与本地 /images 一致
 * 执行方式：启动应用时自动执行一次（需设置 ENABLE_UPDATE = true）
 *
 * 注意：更新完成后请将 ENABLE_UPDATE 设置为 false，避免重复执行
 */
@Component
public class ImageUrlUpdater implements CommandLineRunner {

    // ⚠️ 更新开关：true = 启用更新，false = 禁用更新
    private static final boolean ENABLE_UPDATE = true;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private AliyunOssConfig ossConfig;

    // 记录相对路径 -> OSS 完整 URL 的映射
    private final Map<String, String> urlMapping = new HashMap<>();

    @Override
    public void run(String... args) {
        if (!ENABLE_UPDATE) {
            System.out.println("图片 URL 更新已禁用（ImageUrlUpdater.ENABLE_UPDATE = false）");
            return;
        }

        System.out.println("========================================");
        System.out.println("开始将数据库图片 URL 更新为阿里云 OSS 地址...");

        try {
            // 1. 收集所有需要更新的图片相对路径
            Set<String> relativePaths = collectAllImagePaths();
            System.out.println("共发现 " + relativePaths.size() + " 个图片路径待更新");

            // 2. 根据 OSS 域名拼接完整 URL
            String ossDomain = normalizeOssDomain();
            for (String relativePath : relativePaths) {
                String fullUrl = buildOssUrl(ossDomain, relativePath);
                urlMapping.put(relativePath, fullUrl);
                System.out.println("✓ 映射: " + relativePath + " -> " + fullUrl);
            }

            // 3. 更新酒店图片 URL
            updateHotelImages();

            // 4. 更新房型图片数据（删除旧数据 + 插入新数据）
            updateRoomImages();

            // 5. 更新 room_type 表的 images 聚合字段
            updateRoomTypeImages();

            System.out.println("========================================");
            System.out.println("✅ 图片 URL 更新完成！");
            System.out.println("========================================");

        } catch (Exception e) {
            System.err.println("❌ 更新图片 URL 失败: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * 收集所有需要更新的图片相对路径（与原程序保持一致）
     */
    private Set<String> collectAllImagePaths() {
        Set<String> paths = new HashSet<>();

        // 酒店图片
        paths.add("/images/hotels/xinghe-hero.jpg");
        paths.add("/images/hotels/xinghe-gallery0.jpg");
        paths.add("/images/hotels/xinghe-gallery1.jpg");

        // 房型图片
        String[] roomImageUrls = {
                "/images/rooms/xinghe-exec-1.jpg", "/images/rooms/xinghe-exec-2.jpg", "/images/rooms/xinghe-exec-3.jpg",
                "/images/rooms/xinghe-family-1.jpg", "/images/rooms/xinghe-family-2.jpg", "/images/rooms/xinghe-family-3.jpg",
                "/images/rooms/xinghe-city-1.jpg", "/images/rooms/xinghe-city-2.jpg"
        };
        for (String url : roomImageUrls) {
            paths.add(url);
        }

        return paths;
    }

    /**
     * 规范化 OSS 域名，确保末尾无斜杠
     */
    private String normalizeOssDomain() {
        String domain = ossConfig.getDomain();
        if (domain == null || domain.isBlank()) {
            // 若未配置自定义域名，则使用默认的 OSS 访问地址
            domain = "https://" + ossConfig.getBucketName() + "." + ossConfig.getEndpoint();
        }
        if (domain.endsWith("/")) {
            domain = domain.substring(0, domain.length() - 1);
        }
        return domain;
    }

    /**
     * 拼接 OSS 完整 URL
     * @param domain 规范化后的域名（不含末尾斜杠）
     * @param relativePath 相对路径（例如 "/images/hotels/xxx.jpg"）
     */
    private String buildOssUrl(String domain, String relativePath) {
        // 确保相对路径以 / 开头，但拼接时 domain 后不加额外斜杠
        String path = relativePath.startsWith("/") ? relativePath : "/" + relativePath;
        return domain + path;
    }

    /**
     * 将本地相对路径替换为 OSS URL
     */
    private String replaceWithOssUrl(String localPath) {
        if (localPath == null) return null;
        return urlMapping.getOrDefault(localPath, localPath);
    }

    /**
     * 更新酒店表的 hero_image_url 和 gallery_images 字段
     */
    private void updateHotelImages() {
        String hero1 = replaceWithOssUrl("/images/hotels/xinghe-hero.jpg");
        String gallery1 = replaceWithOssUrl("/images/hotels/xinghe-gallery0.jpg") + "," +
                replaceWithOssUrl("/images/hotels/xinghe-gallery1.jpg");

        // 星河国际大酒店 (id=1)
        jdbcTemplate.update("UPDATE hotel SET hero_image_url = ?, gallery_images = ? WHERE id = ?",
                hero1, gallery1, 1);
        System.out.println("✓ 已更新星河国际大酒店图片 URL");

        // 海滩假日酒店 (id=2)
        jdbcTemplate.update("UPDATE hotel SET hero_image_url = ?, gallery_images = ? WHERE id = ?",
                hero1, gallery1, 2);
        System.out.println("✓ 已更新海滩假日酒店图片 URL");

        // 云栖温泉度假酒店 (id=3)
        jdbcTemplate.update("UPDATE hotel SET hero_image_url = ?, gallery_images = ? WHERE id = ?",
                hero1, gallery1, 3);
        System.out.println("✓ 已更新云栖温泉度假酒店图片 URL");
    }

    /**
     * 更新房型图片数据：删除旧数据，插入新的（使用 OSS URL）
     * 房型名称采用 SQL 文件中的中文名称
     */
    private void updateRoomImages() {
        // 先删除旧数据
        jdbcTemplate.update("DELETE FROM room_images");
        System.out.println("✓ 已清除旧的房型图片数据");

        // 房型中文名称与图片的对应关系（保持和原逻辑一致）
        Object[][] roomImageData = {
                // 星河国际大酒店房型
                {"星河行政大床房", "/images/rooms/xinghe-exec-1.jpg", 1, 1},
                {"星河行政大床房", "/images/rooms/xinghe-exec-2.jpg", 0, 2},
                {"星河行政大床房", "/images/rooms/xinghe-exec-3.jpg", 0, 3},
                {"星河家庭套房", "/images/rooms/xinghe-family-1.jpg", 1, 1},
                {"星河家庭套房", "/images/rooms/xinghe-family-2.jpg", 0, 2},
                {"星河家庭套房", "/images/rooms/xinghe-family-3.jpg", 0, 3},
                {"星河城市景观房", "/images/rooms/xinghe-city-1.jpg", 1, 1},
                {"星河城市景观房", "/images/rooms/xinghe-city-2.jpg", 0, 2},

                // 海滩假日酒店房型
                {"海景观景房", "/images/rooms/xinghe-exec-1.jpg", 1, 1},
                {"海景观景房", "/images/rooms/xinghe-exec-2.jpg", 0, 2},
                {"海豚家庭主题房", "/images/rooms/xinghe-family-1.jpg", 1, 1},
                {"海豚家庭主题房", "/images/rooms/xinghe-family-2.jpg", 0, 2},
                {"海天云顶套房", "/images/rooms/xinghe-city-1.jpg", 1, 1},
                {"海天云顶套房", "/images/rooms/xinghe-city-2.jpg", 0, 2},

                // 云栖温泉度假酒店房型
                {"云栖私汤大床房", "/images/rooms/xinghe-exec-1.jpg", 1, 1},
                {"云栖私汤大床房", "/images/rooms/xinghe-exec-2.jpg", 0, 2},
                {"云栖森林木屋", "/images/rooms/xinghe-family-1.jpg", 1, 1},
                {"云栖森林木屋", "/images/rooms/xinghe-family-2.jpg", 0, 2},
                {"云栖禅意套房", "/images/rooms/xinghe-city-1.jpg", 1, 1},
                {"云栖禅意套房", "/images/rooms/xinghe-city-2.jpg", 0, 2}
        };

        String insertSql = "INSERT INTO room_images (room_type_id, url, is_primary, sort_order) " +
                "SELECT rt.id, ?, ?, ? FROM room_type rt WHERE rt.name = ?";
        for (Object[] data : roomImageData) {
            String roomTypeName = (String) data[0];
            String localPath = (String) data[1];
            int isPrimary = (int) data[2];
            int sortOrder = (int) data[3];
            String ossUrl = replaceWithOssUrl(localPath);
            jdbcTemplate.update(insertSql, ossUrl, isPrimary, sortOrder, roomTypeName);
        }
        System.out.println("✓ 已插入新的房型图片数据 (" + roomImageData.length + " 行)");
    }

    /**
     * 更新 room_type 表中的 images 字段（聚合所有图片 URL，按 sort_order 排序，逗号分隔）
     * 使用 Oracle LISTAGG 语法；若为 MySQL 请改为 GROUP_CONCAT。
     */
    private void updateRoomTypeImages() {
        String sql = "UPDATE room_type rt SET images = (" +
                "SELECT LISTAGG(url, ',') WITHIN GROUP (ORDER BY sort_order) " +
                "FROM room_images ri WHERE ri.room_type_id = rt.id)";
        int rows = jdbcTemplate.update(sql);
        System.out.println("✓ 已更新房型表的 images 字段 (" + rows + " 行)");
    }
}
