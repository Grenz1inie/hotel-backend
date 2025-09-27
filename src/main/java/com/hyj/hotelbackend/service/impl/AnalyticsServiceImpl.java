package com.hyj.hotelbackend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.hyj.hotelbackend.dto.analytics.VacancyAnalyticsResponse;
import com.hyj.hotelbackend.entity.Booking;
import com.hyj.hotelbackend.entity.Room;
import com.hyj.hotelbackend.service.AnalyticsService;
import com.hyj.hotelbackend.service.BookingService;
import com.hyj.hotelbackend.service.RoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AnalyticsServiceImpl implements AnalyticsService {

    private final BookingService bookingService;
    private final RoomService roomService;

    private enum Granularity {
        HOUR, DAY;

        public static Granularity from(String raw) {
            if (raw == null || raw.isBlank()) {
                return DAY;
            }
            try {
                return Granularity.valueOf(raw.trim().toUpperCase(Locale.ROOT));
            } catch (IllegalArgumentException ex) {
                return DAY;
            }
        }

        public long stepAmount() {
            return this == HOUR ? 1 : 1;
        }

        public ChronoUnit unit() {
            return this == HOUR ? ChronoUnit.HOURS : ChronoUnit.DAYS;
        }

        public LocalDateTime alignStart(LocalDateTime dateTime) {
            if (dateTime == null) {
                return null;
            }
            if (this == HOUR) {
                return dateTime.truncatedTo(ChronoUnit.HOURS);
            }
            return dateTime.toLocalDate().atStartOfDay();
        }
    }

    @Override
    public VacancyAnalyticsResponse getVacancyAnalytics(List<Long> roomTypeIds,
                                                        LocalDateTime rawStart,
                                                        LocalDateTime rawEnd,
                                                        String granularity,
                                                        Double thresholdHigh,
                                                        Double thresholdLow,
                                                        Integer forecastDays) {
        Granularity g = Granularity.from(granularity);
        LocalDateTime start = g.alignStart(rawStart != null ? rawStart : defaultStart(g));
        LocalDateTime end = g.alignStart(rawEnd != null ? rawEnd : defaultEnd(g));
        if (end.isBefore(start)) {
            LocalDateTime tmp = start;
            start = end;
            end = tmp;
        }
        Double high = thresholdHigh != null ? thresholdHigh : 0.7d;
        Double low = thresholdLow != null ? thresholdLow : 0.2d;
        int forecast = forecastDays != null ? Math.max(forecastDays, 0) : (g == Granularity.DAY ? 14 : 2);

        List<Room> rooms = resolveRooms(roomTypeIds);
        Set<Long> roomTypeIdSet = rooms.stream().map(Room::getId).collect(Collectors.toSet());
        if (roomTypeIdSet.isEmpty()) {
            VacancyAnalyticsResponse empty = new VacancyAnalyticsResponse();
            empty.setGranularity(g.name());
            empty.setStart(start);
            empty.setEnd(end);
            return empty;
        }

        LocalDateTime queryStart = start.minus(g == Granularity.HOUR ? Duration.ofHours(1) : Duration.ofDays(1));
        LocalDateTime queryEnd = end.plus(g == Granularity.HOUR ? Duration.ofHours(forecast + 1) : Duration.ofDays(forecast + 1));
        List<Booking> bookings = bookingService.list(new LambdaQueryWrapper<Booking>()
                .in(!roomTypeIdSet.isEmpty(), Booking::getRoomTypeId, roomTypeIdSet)
                .lt(Booking::getStartTime, queryEnd)
                .gt(Booking::getEndTime, queryStart));

        Map<Long, List<Booking>> bookingsByRoomType = bookings.stream()
                .collect(Collectors.groupingBy(Booking::getRoomTypeId));

        VacancyAnalyticsResponse resp = new VacancyAnalyticsResponse();
        resp.setGranularity(g.name());
        resp.setStart(start);
        resp.setEnd(end);
        resp.setEvents(eventMarkersBetween(start, end));

        List<VacancyAnalyticsResponse.ThresholdAlert> alerts = new ArrayList<>();

        for (Room room : rooms) {
            List<Booking> roomBookings = new ArrayList<>(bookingsByRoomType.getOrDefault(room.getId(), java.util.Collections.emptyList()));
            roomBookings.sort(Comparator.comparing(Booking::getStartTime));
            VacancyAnalyticsResponse.VacancySeries series = new VacancyAnalyticsResponse.VacancySeries();
            series.setRoomTypeId(room.getId());
            series.setRoomTypeName(room.getName());
            series.setTotalRooms(room.getTotalCount());

            List<VacancyAnalyticsResponse.VacancyPoint> actualPoints = buildPoints(room, roomBookings, start, end, g, high, low, alerts);
            if (!actualPoints.isEmpty()) {
                series.getPoints().addAll(actualPoints);
            }
            if (forecast > 0) {
                List<VacancyAnalyticsResponse.VacancyPoint> forecasts = forecastPoints(actualPoints, room, g, forecast);
                if (!forecasts.isEmpty()) {
                    series.getPoints().addAll(forecasts);
                }
            }
            resp.getSeries().add(series);
        }

        resp.getAlerts().addAll(alerts);
        resp.getSeries().sort(Comparator.comparing(VacancyAnalyticsResponse.VacancySeries::getRoomTypeId));
        return resp;
    }

    private List<VacancyAnalyticsResponse.VacancyPoint> buildPoints(Room room,
                                                                    List<Booking> roomBookings,
                                                                    LocalDateTime start,
                                                                    LocalDateTime end,
                                                                    Granularity granularity,
                                                                    double thresholdHigh,
                                                                    double thresholdLow,
                                                                    List<VacancyAnalyticsResponse.ThresholdAlert> alertsOut) {
        List<VacancyAnalyticsResponse.VacancyPoint> points = new ArrayList<>();
        if (room.getTotalCount() == null || room.getTotalCount() <= 0) {
            return points;
        }
    LocalDateTime cursor = start;
    while (!cursor.isAfter(end)) {
        final LocalDateTime slotStart = cursor;
        LocalDateTime slotEnd = slotStart.plus(granularity.stepAmount(), granularity.unit());
            VacancyAnalyticsResponse.VacancyPoint point = new VacancyAnalyticsResponse.VacancyPoint();
        point.setTimestamp(slotStart);

            List<Booking> overlapping = roomBookings.stream()
                    .filter(b -> isActiveStatus(b.getStatus()))
            .filter(b -> overlaps(b.getStartTime(), b.getEndTime(), slotStart, slotEnd))
                    .collect(Collectors.toList());

            int occupied = overlapping.size();
            double vacancyCount = Math.max(room.getTotalCount() - occupied, 0);
            double vacancyRate = room.getTotalCount() == 0 ? 0d : vacancyCount / room.getTotalCount();
            double bookingRate = room.getTotalCount() == 0 ? 0d : Math.min(occupied / (double) room.getTotalCount(), 1d);

            point.setVacancyCount(vacancyCount);
            point.setVacancyRate(round(vacancyRate));
            point.setBookingRate(round(bookingRate));
            point.setAveragePrice(calculateAveragePrice(overlapping));
            point.setPriceStrategy(calculatePriceStrategy(point.getAveragePrice(), room.getPricePerNight()));
            point.setStatusBreakdown(buildStatusBreakdown(overlapping));
            point.setSourceBreakdown(buildSourceBreakdown(overlapping));

            evaluateAlert(room, slotStart, slotEnd, vacancyRate, thresholdHigh, thresholdLow, alertsOut);

            points.add(point);
            cursor = slotEnd;
        }
        return points;
    }

    private boolean overlaps(LocalDateTime bookingStart, LocalDateTime bookingEnd, LocalDateTime slotStart, LocalDateTime slotEnd) {
        return bookingStart.isBefore(slotEnd) && bookingEnd.isAfter(slotStart);
    }

    private boolean isActiveStatus(String status) {
        if (status == null) return false;
        String s = status.toUpperCase(Locale.ROOT);
        return !("CANCELLED".equals(s) || "REFUNDED".equals(s) || "CHECKED_OUT".equals(s));
    }

    private BigDecimal calculateAveragePrice(List<Booking> overlapping) {
        if (CollectionUtils.isEmpty(overlapping)) {
            return BigDecimal.ZERO;
        }
        BigDecimal total = BigDecimal.ZERO;
        int nightsSum = 0;
        for (Booking booking : overlapping) {
            if (booking.getAmount() == null) continue;
            long nights = Math.max(1, Duration.between(booking.getStartTime(), booking.getEndTime()).toHours() / 24);
            total = total.add(booking.getAmount());
            nightsSum += nights;
        }
        if (nightsSum == 0) {
            return total.setScale(2, RoundingMode.HALF_UP);
        }
        return total.divide(BigDecimal.valueOf(nightsSum), 2, RoundingMode.HALF_UP);
    }

    private String calculatePriceStrategy(BigDecimal avgPrice, BigDecimal basePrice) {
        if (avgPrice == null || basePrice == null || basePrice.compareTo(BigDecimal.ZERO) <= 0) {
            return "标准价";
        }
        BigDecimal ratio = avgPrice.divide(basePrice, 4, RoundingMode.HALF_UP);
        if (ratio.compareTo(BigDecimal.valueOf(1.1)) >= 0) {
            return "高峰价";
        }
        if (ratio.compareTo(BigDecimal.valueOf(0.9)) <= 0) {
            return "折扣价";
        }
        return "标准价";
    }

    private Map<String, Integer> buildStatusBreakdown(List<Booking> bookings) {
        Map<String, Integer> map = new HashMap<>();
        for (Booking booking : bookings) {
            String key = booking.getStatus() == null ? "UNKNOWN" : booking.getStatus().toUpperCase(Locale.ROOT);
            map.merge(key, 1, Integer::sum);
        }
        return map;
    }

    private Map<String, Integer> buildSourceBreakdown(List<Booking> bookings) {
        Map<String, Integer> map = new HashMap<>();
        for (Booking booking : bookings) {
            String source = "DIRECT";
            if (booking.getContactPhone() != null) {
                if (booking.getContactPhone().startsWith("13")) {
                    source = "OTA";
                } else if (booking.getContactPhone().startsWith("15")) {
                    source = "企业协议";
                }
            }
            map.merge(source, 1, Integer::sum);
        }
        return map;
    }

    private void evaluateAlert(Room room,
                               LocalDateTime slotStart,
                               LocalDateTime slotEnd,
                               double vacancyRate,
                               double thresholdHigh,
                               double thresholdLow,
                               List<VacancyAnalyticsResponse.ThresholdAlert> alertsOut) {
        if (vacancyRate >= thresholdHigh) {
            alertsOut.add(buildAlert(room, slotStart, slotEnd, "HIGH", thresholdHigh, vacancyRate,
                    "空置率高于阈值"));
        } else if (vacancyRate <= thresholdLow) {
            alertsOut.add(buildAlert(room, slotStart, slotEnd, "LOW", thresholdLow, vacancyRate,
                    "空置率低于阈值"));
        }
    }

    private VacancyAnalyticsResponse.ThresholdAlert buildAlert(Room room,
                                                                LocalDateTime start,
                                                                LocalDateTime end,
                                                                String level,
                                                                double threshold,
                                                                double actual,
                                                                String reason) {
        VacancyAnalyticsResponse.ThresholdAlert alert = new VacancyAnalyticsResponse.ThresholdAlert();
        alert.setRoomTypeId(room.getId());
        alert.setRoomTypeName(room.getName());
        alert.setStart(start);
        alert.setEnd(end);
        alert.setLevel(level);
        alert.setThreshold(round(threshold));
        alert.setActual(round(actual));
        alert.setReason(reason);
        return alert;
    }

    private List<VacancyAnalyticsResponse.EventMarker> eventMarkersBetween(LocalDateTime start, LocalDateTime end) {
        List<VacancyAnalyticsResponse.EventMarker> events = new ArrayList<>();
        List<EventSeed> seeds = defaultEventSeeds();
        for (EventSeed seed : seeds) {
            if (!seed.date.isBefore(start.toLocalDate()) && !seed.date.isAfter(end.toLocalDate())) {
                VacancyAnalyticsResponse.EventMarker marker = new VacancyAnalyticsResponse.EventMarker();
                marker.setTimestamp(seed.date.atStartOfDay());
                marker.setTitle(seed.title);
                marker.setDescription(seed.description);
                marker.setCategory(seed.category);
                events.add(marker);
            }
        }
        return events;
    }

    private List<EventSeed> defaultEventSeeds() {
        List<EventSeed> seeds = new ArrayList<>();
        LocalDate now = LocalDate.now();
        seeds.add(new EventSeed(now.withMonth(10).withDayOfMonth(1), "国庆黄金周", "旅客高峰，建议提前备房", "节假日"));
        seeds.add(new EventSeed(now.withMonth(5).withDayOfMonth(1), "五一假期", "短途旅行热，关注家庭房型", "节假日"));
        seeds.add(new EventSeed(now.withMonth(11).withDayOfMonth(11), "双十一营销", "线上促销活动", "促销"));
        seeds.add(new EventSeed(now.withMonth(3).withDayOfMonth(18), "春季家装展", "商旅客人集中", "展会"));
        return seeds;
    }

    private double round(double value) {
        return BigDecimal.valueOf(value).setScale(4, RoundingMode.HALF_UP).doubleValue();
    }

    private List<VacancyAnalyticsResponse.VacancyPoint> forecastPoints(List<VacancyAnalyticsResponse.VacancyPoint> actualPoints,
                                                                       Room room,
                                                                       Granularity granularity,
                                                                       int horizon) {
        List<VacancyAnalyticsResponse.VacancyPoint> result = new ArrayList<>();
        if (CollectionUtils.isEmpty(actualPoints)) {
            return result;
        }
        int window = Math.min(3, actualPoints.size());
        double avgVacancy = actualPoints.subList(Math.max(actualPoints.size() - window, 0), actualPoints.size()).stream()
                .mapToDouble(VacancyAnalyticsResponse.VacancyPoint::getVacancyRate)
                .average()
                .orElse(0.0);
        double avgBooking = actualPoints.subList(Math.max(actualPoints.size() - window, 0), actualPoints.size()).stream()
                .mapToDouble(VacancyAnalyticsResponse.VacancyPoint::getBookingRate)
                .average()
                .orElse(0.0);
        double avgCount = actualPoints.subList(Math.max(actualPoints.size() - window, 0), actualPoints.size()).stream()
                .mapToDouble(VacancyAnalyticsResponse.VacancyPoint::getVacancyCount)
                .average()
                .orElse(room.getTotalCount());

        LocalDateTime cursor = actualPoints.get(actualPoints.size() - 1).getTimestamp()
                .plus(granularity.stepAmount(), granularity.unit());
        for (int i = 0; i < horizon; i++) {
            VacancyAnalyticsResponse.VacancyPoint point = new VacancyAnalyticsResponse.VacancyPoint();
            point.setTimestamp(cursor);
            point.setForecast(true);
            point.setVacancyRate(round(avgVacancy));
            point.setBookingRate(round(avgBooking));
            point.setVacancyCount(round(avgCount));
            point.setAveragePrice(BigDecimal.ZERO);
            point.setPriceStrategy("预测");
            result.add(point);
            cursor = cursor.plus(granularity.stepAmount(), granularity.unit());
        }
        return result;
    }

    private List<Room> resolveRooms(List<Long> roomTypeIds) {
        if (!CollectionUtils.isEmpty(roomTypeIds)) {
            return roomService.listByIds(roomTypeIds).stream()
                    .filter(Objects::nonNull)
                    .collect(Collectors.toList());
        }
        return roomService.list().stream()
                .filter(room -> room.getIsActive() == null || room.getIsActive() == 1)
                .sorted(Comparator.comparing(Room::getId))
                .collect(Collectors.toList());
    }

    private LocalDateTime defaultStart(Granularity g) {
        LocalDateTime now = LocalDateTime.now();
        if (g == Granularity.HOUR) {
            return now.minusDays(1).truncatedTo(ChronoUnit.HOURS);
        }
        return now.minusDays(30).toLocalDate().atStartOfDay();
    }

    private LocalDateTime defaultEnd(Granularity g) {
        LocalDateTime now = LocalDateTime.now();
        if (g == Granularity.HOUR) {
            return now.truncatedTo(ChronoUnit.HOURS);
        }
        return now.toLocalDate().atStartOfDay();
    }

    private record EventSeed(LocalDate date, String title, String description, String category) {
    }
}
