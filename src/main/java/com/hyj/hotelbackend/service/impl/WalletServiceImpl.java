package com.hyj.hotelbackend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.hyj.hotelbackend.entity.WalletAccount;
import com.hyj.hotelbackend.entity.WalletTransaction;
import com.hyj.hotelbackend.mapper.WalletAccountMapper;
import com.hyj.hotelbackend.mapper.WalletTransactionMapper;
import com.hyj.hotelbackend.service.WalletService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.Assert;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class WalletServiceImpl implements WalletService {

    @Autowired
    private WalletAccountMapper walletAccountMapper;

    @Autowired
    private WalletTransactionMapper walletTransactionMapper;

    @Override
    @Transactional
    public WalletAccount getOrCreateAccount(Long userId) {
        Assert.notNull(userId, "userId 必填");
        WalletAccount account = walletAccountMapper.selectOne(new LambdaQueryWrapper<WalletAccount>()
                .eq(WalletAccount::getUserId, userId));
        if (account != null) {
            if (account.getBalance() == null) {
                account.setBalance(BigDecimal.ZERO);
            }
            if (account.getFrozenBalance() == null) {
                account.setFrozenBalance(BigDecimal.ZERO);
            }
            return account;
        }
        WalletAccount created = new WalletAccount();
        created.setUserId(userId);
        created.setBalance(BigDecimal.ZERO);
        created.setFrozenBalance(BigDecimal.ZERO);
        created.setStatus("ACTIVE");
        created.setCreatedAt(LocalDateTime.now());
        created.setUpdatedAt(LocalDateTime.now());
        walletAccountMapper.insert(created);
        return created;
    }

    @Override
    @Transactional
    public WalletTransaction recharge(Long userId, BigDecimal amount, String channel, String referenceNo, String remark) {
        Assert.notNull(userId, "userId 必填");
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("充值金额需大于0");
        }
        WalletAccount account = getOrCreateAccount(userId);
        BigDecimal newBalance = safeValue(account.getBalance()).add(amount);
        account.setBalance(newBalance);
        account.setUpdatedAt(LocalDateTime.now());
        walletAccountMapper.updateById(account);
        WalletTransaction tx = buildTransaction(account, userId, amount, newBalance, "RECHARGE", "IN", channel, referenceNo, remark, null);
        walletTransactionMapper.insert(tx);
        return tx;
    }

    @Override
    @Transactional
    public WalletTransaction consume(Long userId, BigDecimal amount, String channel, Long bookingId, String remark) {
        Assert.notNull(userId, "userId 必填");
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("扣费金额需大于0");
        }
        WalletAccount account = getOrCreateAccount(userId);
        BigDecimal current = safeValue(account.getBalance());
        if (current.compareTo(amount) < 0) {
            throw new IllegalStateException("钱包余额不足");
        }
        BigDecimal newBalance = current.subtract(amount);
        account.setBalance(newBalance);
        account.setUpdatedAt(LocalDateTime.now());
        walletAccountMapper.updateById(account);
        WalletTransaction tx = buildTransaction(account, userId, amount, newBalance, "PAYMENT", "OUT", channel, null, remark, bookingId);
        walletTransactionMapper.insert(tx);
        return tx;
    }

    @Override
    @Transactional
    public WalletTransaction refund(Long userId, BigDecimal amount, String channel, Long bookingId, String remark) {
        Assert.notNull(userId, "userId 必填");
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("退款金额需大于0");
        }
        WalletAccount account = getOrCreateAccount(userId);
        BigDecimal newBalance = safeValue(account.getBalance()).add(amount);
        account.setBalance(newBalance);
        account.setUpdatedAt(LocalDateTime.now());
        walletAccountMapper.updateById(account);
        WalletTransaction tx = buildTransaction(account, userId, amount, newBalance, "REFUND", "IN", channel, null, remark, bookingId);
        walletTransactionMapper.insert(tx);
        return tx;
    }

    @Override
    public List<WalletTransaction> recentTransactions(Long userId, int limit) {
        Assert.notNull(userId, "userId 必填");
        int pageSize = limit <= 0 ? 10 : Math.min(limit, 200);
        return walletTransactionMapper.selectList(new LambdaQueryWrapper<WalletTransaction>()
                .eq(WalletTransaction::getUserId, userId)
                .orderByDesc(WalletTransaction::getCreatedAt)
                .last("LIMIT " + pageSize));
    }

    private WalletTransaction buildTransaction(WalletAccount account,
                                               Long userId,
                                               BigDecimal amount,
                                               BigDecimal balanceAfter,
                                               String type,
                                               String direction,
                                               String channel,
                                               String referenceNo,
                                               String remark,
                                               Long bookingId) {
        WalletTransaction tx = new WalletTransaction();
        tx.setWalletId(account.getId());
        tx.setUserId(userId);
        tx.setBookingId(bookingId);
        tx.setAmount(amount);
        tx.setBalanceAfter(balanceAfter);
        tx.setType(type);
        tx.setDirection(direction);
        tx.setPaymentChannel(channel);
        tx.setReferenceNo(referenceNo);
        tx.setRemark(remark);
        tx.setCreatedAt(LocalDateTime.now());
        return tx;
    }

    private BigDecimal safeValue(BigDecimal source) {
        return source == null ? BigDecimal.ZERO : source;
    }
}
