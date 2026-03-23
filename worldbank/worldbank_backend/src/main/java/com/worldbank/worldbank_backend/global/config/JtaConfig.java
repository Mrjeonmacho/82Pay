package com.worldbank.worldbank_backend.global.config;

import com.atomikos.icatch.jta.UserTransactionImp;
import com.atomikos.icatch.jta.UserTransactionManager;
import jakarta.transaction.SystemException;
import jakarta.transaction.UserTransaction;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.transaction.annotation.EnableTransactionManagement;
import org.springframework.transaction.jta.JtaTransactionManager;

@Configuration
@EnableTransactionManagement
public class JtaConfig {

    @Bean(initMethod = "init", destroyMethod = "close")
    public UserTransactionManager atomikosTransactionManager() {
        UserTransactionManager tm = new UserTransactionManager();
        tm.setForceShutdown(false);
        CustomAtomikosJtaPlatform.setTransactionManager(tm);
        return tm;
    }

    @Bean
    public UserTransaction atomikosUserTransaction() throws SystemException {
        UserTransactionImp ut = new UserTransactionImp();
        ut.setTransactionTimeout(1000);
        CustomAtomikosJtaPlatform.setUserTransaction(ut);
        return (UserTransaction) ut;
    }

    @Primary
    @Bean
    public JtaTransactionManager transactionManager() throws Throwable {
        JtaTransactionManager jtaTransactionManager = new JtaTransactionManager();
        jtaTransactionManager.setUserTransaction(atomikosUserTransaction());
        jtaTransactionManager.setTransactionManager(atomikosTransactionManager());
        jtaTransactionManager.setAllowCustomIsolationLevels(true);
        return jtaTransactionManager;
    }
}
