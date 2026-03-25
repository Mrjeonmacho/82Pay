package com.worldbank.worldbank_backend.global.config;

import com.atomikos.jdbc.AtomikosDataSourceBean;
import org.springframework.beans.factory.annotation.Value;
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
@EnableJpaRepositories(basePackages = { "com.worldbank.worldbank_backend.finance.domain.repository.kr",
        "com.worldbank.worldbank_backend.user.repository.kr"
}, entityManagerFactoryRef = "krEntityManager", transactionManagerRef = "transactionManager")
public class KRDataSourceConfig {

    // yml에서 값을 가져옵니다.

    // @Primary
    @Bean(initMethod = "init", destroyMethod = "close")
    public DataSource krDataSource(
            @Value("${spring.datasource.kr.xa-data-source-class-name}") String xaClassName,
            @Value("${spring.datasource.kr.unique-resource-name}") String uniqueName,
            @Value("${spring.datasource.kr.xa-properties.url}") String url,
            @Value("${spring.datasource.kr.xa-properties.user}") String user,
            @Value("${spring.datasource.kr.xa-properties.password}") String password) {
        AtomikosDataSourceBean ds = new AtomikosDataSourceBean();
        // yml에서 가져온 값을 세팅합니다.
        ds.setUniqueResourceName(uniqueName);
        ds.setXaDataSourceClassName(xaClassName);

        ds.setMinPoolSize(5);
        ds.setMaxPoolSize(20);
        ds.setBorrowConnectionTimeout(60);

        Properties p = new Properties();
        p.setProperty("URL", url);
        p.setProperty("user", user);
        p.setProperty("password", password);
        p.setProperty("pinGlobalTxToPhysicalConnection", "true");
        ds.setXaProperties(p);

        return ds;
    }

    // @Primary
    @Bean(name = "krEntityManager")
    @DependsOn("transactionManager") // ✅ 트랜잭션 매니저가 먼저 초기화되도록 보장
    public LocalContainerEntityManagerFactoryBean krEntityManager(DataSource krDataSource) {
        LocalContainerEntityManagerFactoryBean em = new LocalContainerEntityManagerFactoryBean();
        em.setJtaDataSource(krDataSource);
        em.setPersistenceUnitName("krPersistenceUnit");
        em.setPackagesToScan("com.worldbank.worldbank_backend.finance.domain.entity.kr",
                "com.worldbank.worldbank_backend.user.entity.kr");
        em.setJpaVendorAdapter(new HibernateJpaVendorAdapter());

        Properties properties = new Properties();
        properties.setProperty("jakarta.persistence.transactionType", "JTA");
        properties.setProperty("hibernate.transaction.jta.platform",
                "com.worldbank.worldbank_backend.global.config.CustomAtomikosJtaPlatform");
        properties.setProperty("hibernate.dialect", "org.hibernate.dialect.MySQLDialect");

        em.setJpaProperties(properties);

        return em;
    }
}
