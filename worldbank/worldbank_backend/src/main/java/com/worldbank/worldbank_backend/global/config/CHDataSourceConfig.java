package com.worldbank.worldbank_backend.global.config;

import com.atomikos.jdbc.AtomikosDataSourceBean;
import org.springframework.beans.factory.annotation.Value;
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
        public DataSource chDataSource(
                @Value("${spring.datasource.ch.xa-data-source-class-name}") String xaClassName,
                @Value("${spring.datasource.ch.unique-resource-name}") String uniqueName,
                @Value("${spring.datasource.ch.xa-properties.url}") String url,
                @Value("${spring.datasource.ch.xa-properties.user}") String user,
                @Value("${spring.datasource.ch.xa-properties.password}") String password
        ) {
                AtomikosDataSourceBean ds = new AtomikosDataSourceBean();
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

        @Bean(name = "chEntityManager")
        @DependsOn("transactionManager")
        public LocalContainerEntityManagerFactoryBean chEntityManager(DataSource chDataSource) {
                LocalContainerEntityManagerFactoryBean em = new LocalContainerEntityManagerFactoryBean();
                em.setJtaDataSource(chDataSource);
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
