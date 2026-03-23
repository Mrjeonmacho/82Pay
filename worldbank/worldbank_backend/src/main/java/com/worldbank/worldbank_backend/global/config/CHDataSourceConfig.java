package com.worldbank.worldbank_backend.global.config;

import com.atomikos.jdbc.AtomikosDataSourceBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.DependsOn;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
import org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter;

import javax.sql.DataSource;
import java.util.Properties;

@Configuration
@EnableJpaRepositories(basePackages = { "com.worldbank.worldbank_backend.finance.domain.repository.ch",
                "com.worldbank.worldbank_backend.user.repository.ch"
}, entityManagerFactoryRef = "chEntityManager", transactionManagerRef = "transactionManager")
public class CHDataSourceConfig {

        @Bean(initMethod = "init", destroyMethod = "close")
        public DataSource chDataSource() {
                AtomikosDataSourceBean ds = new AtomikosDataSourceBean();
                ds.setUniqueResourceName("chDataSource");
                ds.setXaDataSourceClassName("com.mysql.cj.jdbc.MysqlXADataSource");

                ds.setMinPoolSize(5);
                ds.setMaxPoolSize(20);
                ds.setBorrowConnectionTimeout(60);

                Properties p = new Properties();
                p.setProperty("URL", "jdbc:mysql://localhost:3306/ch_bank");
                p.setProperty("user", "root");
                p.setProperty("password", "root");
                p.setProperty("pinGlobalTxToPhysicalConnection", "true");
                ds.setXaProperties(p);

                return ds;
        }

        @Bean(name = "chEntityManager")
        @DependsOn("transactionManager")
        public LocalContainerEntityManagerFactoryBean chEntityManager() {
                LocalContainerEntityManagerFactoryBean em = new LocalContainerEntityManagerFactoryBean();
                em.setJtaDataSource(chDataSource());
                em.setPersistenceUnitName("chPersistenceUnit");
                em.setPackagesToScan("com.worldbank.worldbank_backend.finance.domain.entity.ch",
                                "com.worldbank.worldbank_backend.user.entity.ch");
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
