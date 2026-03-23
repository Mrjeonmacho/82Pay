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
@EnableJpaRepositories(basePackages = { "com.worldbank.worldbank_backend.finance.domain.repository.us",
                "com.worldbank.worldbank_backend.user.repository.us"
}, entityManagerFactoryRef = "usEntityManager", transactionManagerRef = "transactionManager")
public class USDataSourceConfig {

        @Bean(initMethod = "init", destroyMethod = "close")
        public DataSource usDataSource() {
                AtomikosDataSourceBean ds = new AtomikosDataSourceBean();
                ds.setUniqueResourceName("usDataSource");
                ds.setXaDataSourceClassName("com.mysql.cj.jdbc.MysqlXADataSource");

                ds.setMinPoolSize(5);
                ds.setMaxPoolSize(20);
                ds.setBorrowConnectionTimeout(60);

                Properties p = new Properties();
                p.setProperty("URL", "jdbc:mysql://localhost:3306/us_bank");
                p.setProperty("user", "root");
                p.setProperty("password", "root");
                p.setProperty("pinGlobalTxToPhysicalConnection", "true");
                ds.setXaProperties(p);

                return ds;
        }

        @Bean(name = "usEntityManager")
        @DependsOn("transactionManager")
        public LocalContainerEntityManagerFactoryBean usEntityManager() {
                LocalContainerEntityManagerFactoryBean em = new LocalContainerEntityManagerFactoryBean();
                em.setJtaDataSource(usDataSource());
                em.setPersistenceUnitName("usPersistenceUnit");
                em.setPackagesToScan("com.worldbank.worldbank_backend.finance.domain.entity.us",
                                "com.worldbank.worldbank_backend.user.entity.us");
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
