package com.hyj.hotelbackend.service.impl;

import com.hyj.hotelbackend.entity.PaymentRecord;
import com.hyj.hotelbackend.mapper.PaymentRecordMapper;
import com.hyj.hotelbackend.service.PaymentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.Assert;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Service
public class PaymentServiceImpl implements PaymentService {

    @Autowired
    private PaymentRecordMapper paymentRecordMapper;

    @Override
    @Transactional
    public PaymentRecord recordDirectPayment(Long bookingId, Long userId, BigDecimal amount, String method, String channel, String referenceNo) {
        Assert.notNull(bookingId, "bookingId 必填");
        Assert.notNull(userId, "userId 必填");
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("支付金额需大于0");
        }
        PaymentRecord record = new PaymentRecord();
        record.setBookingId(bookingId);
        record.setUserId(userId);
        record.setAmount(amount);
        record.setMethod(method);
        record.setChannel(channel);
        record.setStatus("PAID");
        record.setPaidAt(LocalDateTime.now());
        record.setReferenceNo(referenceNo);
        record.setCreatedAt(LocalDateTime.now());
        record.setUpdatedAt(LocalDateTime.now());
        paymentRecordMapper.insert(record);
        return record;
    }

    @Override
    @Transactional
    public PaymentRecord markRefund(Long recordId, String status) {
        Assert.notNull(recordId, "recordId 必填");
        PaymentRecord record = paymentRecordMapper.selectById(recordId);
        if (record == null) {
            return null;
        }
        record.setStatus(status == null ? "REFUNDED" : status);
        record.setRefundedAt(LocalDateTime.now());
        record.setUpdatedAt(LocalDateTime.now());
        paymentRecordMapper.updateById(record);
        return record;
    }
}
