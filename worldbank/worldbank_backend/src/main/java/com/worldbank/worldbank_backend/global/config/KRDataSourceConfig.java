package com.worldbank.worldbank_backend.global.config;

import com.atomikos.jdbc.AtomikosDataSourceBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.DependsOn;
import org.springframework.context.annotation.Primary;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
import org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter;

import javax.sql.DataSource;
import java.util.Properties;

@Configuration
@EnableJpaRepositories(
        basePackages = "com.worldbank.worldbank_backend.finance.domain.repository.kr",
        entityManagerFactoryRef = "krEntityManager",
        transactionManagerRef = "transactionManager"
)
public class KRDataSourceConfig {

    @Primary
    @Bean(initMethod = "init", destroyMethod = "close")
    public DataSource krDataSource() {
        AtomikosDataSourceBean ds = new AtomikosDataSourceBean();
        ds.setUniqueResourceName("krDataSource");
        ds.setXaDataSourceClassName("com.mysql.cj.jdbc.MysqlXADataSource");
        
        ds.setMinPoolSize(5);
        ds.setMaxPoolSize(20);
        ds.setBorrowConnectionTimeout(60);
        
        Properties p = new Properties();
        p.setProperty("URL", "jdbc:mysql://localhost:3306/kr_bank");
        p.setProperty("user", "root");
        p.setProperty("password", "root");
        p.setProperty("pinGlobalTxToPhysicalConnection", "true");
        ds.setXaProperties(p);
        
        return ds;
    }

    @Primary
    @Bean(name = "krEntityManager")
    @DependsOn("transactionManager") // ✅ 트랜잭션 매니저가 먼저 초기화되도록 보장
    public LocalContainerEntityManagerFactoryBean krEntityManager() {
        LocalContainerEntityManagerFactoryBean em = new LocalContainerEntityManagerFactoryBean();
        em.setJtaDataSource(krDataSource());
        em.setPersistenceUnitName("krPersistenceUnit");
        em.setPackagesToScan("com.worldbank.worldbank_backend.finance.domain.entity.kr");
        em.setJpaVendorAdapter(new HibernateJpaVendorAdapter());

        Properties properties = new Properties();
        properties.setProperty("jakarta.persistence.transactionType", "JTA");
        properties.setProperty("hibernate.transaction.jta.platform", "com.worldbank.worldbank_backend.global.config.CustomAtomikosJtaPlatform");
        properties.setProperty("hibernate.dialect", "org.hibernate.dialect.MySQLDialect");

        em.setJpaProperties(properties);

        return em;
    }
}
