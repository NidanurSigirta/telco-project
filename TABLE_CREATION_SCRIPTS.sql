-- *********************************************
-- TABLO OLUŞTURMA SCRIPTLERİ
-- Telekomünikasyon projesi için gerekli 3 tablo aşağıda tanımlanmıştır.
-- Tablolar arasında FOREIGN KEY kısıtlamaları uygulanmıştır.
-- Oluşturma sırası önemlidir: önce TARIFFS, sonra CUSTOMERS, son olarak MONTHLY_STATS.
-- *********************************************

CREATE TABLE TARIFFS (
    TARIFF_ID     NUMBER PRIMARY KEY,
    NAME          VARCHAR2(100) NOT NULL,
    MONTHLY_FEE   NUMBER(10,2) NOT NULL,
    DATA_LIMIT    NUMBER DEFAULT 0,
    MINUTE_LIMIT  NUMBER DEFAULT 0,
    SMS_LIMIT     NUMBER DEFAULT 0
);


CREATE TABLE CUSTOMERS (
    CUSTOMER_ID  NUMBER PRIMARY KEY,
    NAME         VARCHAR2(100) NOT NULL,
    CITY         VARCHAR2(100),
    SIGNUP_DATE  DATE,
    TARIFF_ID    NUMBER,
    CONSTRAINT fk_tariff FOREIGN KEY (TARIFF_ID) REFERENCES TARIFFS(TARIFF_ID)
);

CREATE TABLE MONTHLY_STATS (
    ID             NUMBER PRIMARY KEY,
    CUSTOMER_ID    NUMBER,
    DATA_USAGE     NUMBER(10,2) DEFAULT 0,
    MINUTE_USAGE   NUMBER DEFAULT 0,
    SMS_USAGE      NUMBER DEFAULT 0,
    PAYMENT_STATUS VARCHAR2(20),
    CONSTRAINT fk_customer FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMERS(CUSTOMER_ID)
);