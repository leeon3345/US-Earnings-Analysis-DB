/* 1_schema.sql */
USE earnings_analysis;

DROP TABLE IF EXISTS Earnings_Reactions;
DROP TABLE IF EXISTS Earnings_Reports;
DROP TABLE IF EXISTS Companies;

-- 기업 정보 테이블
CREATE TABLE Companies (
    company_id INT PRIMARY KEY AUTO_INCREMENT,
    company_name VARCHAR(100) NOT NULL,
    ticker_symbol VARCHAR(10) NOT NULL UNIQUE,
    sector VARCHAR(50) NOT NULL,
    market_cap BIGINT,
    founded_year INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
); [cite: 2055, 2056, 2058, 2059, 2060, 2061, 2062, 2063, 2064, 2057]

-- 실적 발표 테이블
CREATE TABLE Earnings_Reports (
    report_id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    report_date DATE NOT NULL,
    quarter ENUM('Q1', 'Q2', 'Q3', 'Q4') NOT NULL,
    year INT NOT NULL,
    eps_actual DECIMAL(10,4),
    eps_estimate DECIMAL(10,4),
    revenue DECIMAL(15,2),
    revenue_estimate DECIMAL(15,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES Companies(company_id) ON DELETE CASCADE,
    INDEX idx_report_date (report_date),
    INDEX idx_company_quarter (company_id, year, quarter)
); [cite: 2065, 2066, 2067, 2068, 2069, 2070, 2071, 2072, 2073, 2074, 2075, 2076, 2077, 2078, 2080, 2081, 2079]

-- 주가 반응 테이블
CREATE TABLE Earnings_Reactions (
    reaction_id INT PRIMARY KEY AUTO_INCREMENT,
    report_id INT NOT NULL,
    price_before DECIMAL(10,2) NOT NULL,
    price_after DECIMAL(10,2) NOT NULL,
    price_change_percent DECIMAL(8,2) NOT NULL,
    volume_change_percent DECIMAL(8,2),
    reaction_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (report_id) REFERENCES Earnings_Reports (report_id) ON DELETE CASCADE,
    UNIQUE KEY unique_report_reaction (report_id),
    INDEX idx_price_change (price_change_percent)
); [cite: 2082, 2083, 2084, 2085, 2086, 2087, 2088, 2089, 2090, 2091, 2092, 2093, 2094, 2095, 2096]