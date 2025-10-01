package com.hyj.hotelbackend.service;

import com.hyj.hotelbackend.entity.WalletAccount;
import com.hyj.hotelbackend.entity.WalletTransaction;

import java.math.BigDecimal;
import java.util.List;

public interface WalletService {
    WalletAccount getOrCreateAccount(Long userId);

    WalletTransaction recharge(Long userId, BigDecimal amount, String channel, String referenceNo, String remark);

    WalletTransaction consume(Long userId, BigDecimal amount, String channel, Long bookingId, String remark);

    WalletTransaction refund(Long userId, BigDecimal amount, String channel, Long bookingId, String remark);

    List<WalletTransaction> recentTransactions(Long userId, int limit);
}
