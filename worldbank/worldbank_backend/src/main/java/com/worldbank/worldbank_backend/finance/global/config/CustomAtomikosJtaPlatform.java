package com.worldbank.worldbank_backend.finance.global.config;

import jakarta.transaction.TransactionManager;
import jakarta.transaction.UserTransaction;
import org.hibernate.engine.transaction.jta.platform.internal.AbstractJtaPlatform;

public class CustomAtomikosJtaPlatform extends AbstractJtaPlatform {

    private static TransactionManager transactionManager;
    private static UserTransaction userTransaction;

    public static void setTransactionManager(TransactionManager tm) {
        transactionManager = tm;
    }

    public static void setUserTransaction(UserTransaction ut) {
        userTransaction = ut;
    }

    @Override
    protected TransactionManager locateTransactionManager() {
        return transactionManager;
    }

    @Override
    protected UserTransaction locateUserTransaction() {
        return userTransaction;
    }
}
