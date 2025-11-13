/* 3_analysis_queries.sql */
USE earnings_analysis;

-- 시나리오 1: 실적 발표 후 주가가 15% 이상 상승한 기업 목록
SELECT
    c.company_name,
    c.ticker_symbol,
    c.sector,
    c.market_cap,
    e.report_date,
    e.eps_actual,
    e.eps_estimate,
    (e.eps_actual - e.eps_estimate) AS eps_surprise,
    r.price_change_percent
FROM Companies c
JOIN Earnings_Reports e ON c.company_id = e.company_id
JOIN Earnings_Reactions r ON e.report_id = r.report_id
WHERE r.price_change_percent >= 15.0
ORDER BY r.price_change_percent DESC; [cite: 1929, 1930, 1931, 1932, 1933, 1934, 1935, 1936, 1937, 1938, 1939, 1940, 1941, 1942, 1943]

-- 시나리오 2: 2025년 1분기 EPS 서프라이즈가 큰 상위 10개 기업
SELECT
    c.company_name,
    c.ticker_symbol,
    e.report_date,
    e.eps_actual,
    e.eps_estimate,
    (e.eps_actual - e.eps_estimate) AS eps_surprise,
    r.price_change_percent,
    CASE
        WHEN c.market_cap >= 1000000000000 THEN 'Large Cap'
        WHEN c.market_cap >= 10000000000 THEN 'Mid Cap'
        ELSE 'Small Cap'
    END AS company_size
FROM Companies c
JOIN Earnings_Reports e ON c.company_id = e.company_id
JOIN Earnings_Reactions r ON e.report_id = r.report_id
WHERE e.report_date BETWEEN '2025-01-01' AND '2025-03-31'
-- AND e.quarter = 'Q1'  -- PDF 원본 쿼리에 오류가 있을 수 있어(Q1 데이터가 아닐 수 있음) 날짜 기준으로 변경
-- AND e.year = 2025
ORDER BY (e.eps_actual - e.eps_estimate) DESC
LIMIT 10; [cite: 1951, 1952, 1953, 1954, 1955, 1956, 1957, 1958, 1959, 1960, 1961, 1962, 1963, 1964, 1965, 2316, 1969, 1970, 1971]
-- 참고: PDF 원본 [cite: 1966, 1968] 에는 Q1, 2025년 조건이 있으나, 실제 삽입된 데이터 기준 [cite: 2127, 2131, 2134, 2137, 2146, 2151, 2156, 2159, 2165, 2169, 2172, 2176, 2181, 2184, 2186, 2193, 2199, 2205] 2025년 Q1 데이터가 10개가 안 될 수 있습니다. WHERE e.report_date BETWEEN '2025-01-01' AND '2025-03-31' [cite: 2316] 로 날짜 범위를 지정하는 것이 더 정확합니다.

-- 시나리오 3: 시가총액별 평균 주가 반응률 분석
SELECT
    CASE
        WHEN c.market_cap >= 1000000000000 THEN 'Large Cap (1T+)'
        WHEN c.market_cap >= 100000000000 THEN 'Mid Cap (100B-1T)'
        WHEN c.market_cap >= 10000000000 THEN 'Small Cap (10B-100B)'
        ELSE 'Micro Cap (<10B)'
    END AS market_cap_category,
    COUNT(*) AS total_reports,
    AVG(r.price_change_percent) AS avg_price_reaction,
    AVG(ABS(r.price_change_percent)) AS avg_absolute_reaction,
    MAX(r.price_change_percent) AS max_positive_reaction,
    MIN(r.price_change_percent) AS max_negative_reaction,
    AVG(e.eps_actual - e.eps_estimate) AS avg_eps_surprise
FROM Companies c
JOIN Earnings_Reports e ON c.company_id = e.company_id
JOIN Earnings_Reactions r ON e.report_id = r.report_id
WHERE e.report_date >= '2024-10-01'
GROUP BY market_cap_category
ORDER BY avg_absolute_reaction DESC; [cite: 1978, 1979, 1980, 1981, 1982, 1983, 1984, 1985, 1986, 1987, 1988, 1989, 2334]

-- 시나리오 4: 소형주 중 실적 좋아서 급등한 기업들 (서브쿼리 활용)
SELECT
    main_query.company_name,
    main_query.ticker_symbol,
    main_query.eps_surprise,
    main_query.price_change_percent,
    main_query.market_cap
FROM (
    SELECT
        c.company_name,
        c.ticker_symbol,
        (e.eps_actual - e.eps_estimate) AS eps_surprise,
        r.price_change_percent,
        c.market_cap
    FROM Companies c
    JOIN Earnings_Reports e ON c.company_id = e.company_id
    JOIN Earnings_Reactions r ON e.report_id = r.report_id
    WHERE c.market_cap < 50000000000 -- 500억 달러 미만 소형주
    AND (e.eps_actual - e.eps_estimate) > 0.10 -- EPS 서프라이즈 큰 경우
    AND r.price_change_percent > 15.0 -- 15% 이상 상승
) AS main_query
WHERE main_query.eps_surprise > (
    SELECT AVG(e.eps_actual - e.Seps_estimate)
    FROM Earnings_Reports e
    WHERE e.report_date >= '2024-10-01'
)
ORDER BY main_query.price_change_percent DESC; [cite: 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021]

-- 시나리오 5: 섹터별 실적 발표 후 주가 반응 패턴 분석
SELECT
    c.sector,
    COUNT(*) AS total_reports,
    AVG(r.price_change_percent) AS avg_price_reaction,
    STDDEV(r.price_change_percent) AS volatility,
    COUNT(CASE WHEN r.price_change_percent > 10 THEN 1 END) AS big_winners,
    COUNT(CASE WHEN r.price_change_percent < -10 THEN 1 END) AS big_losers,
    AVG(e.eps_actual - e.eps_estimate) AS avg_eps_surprise
FROM Companies c
JOIN Earnings_Reports e ON c.company_id = e.company_id
JOIN Earnings_Reactions r ON e.report_id = r.report_id
WHERE e.report_date >= '2024-01-01'
GROUP BY c.sector
HAVING COUNT(*) >= 3
ORDER BY avg_price_reaction DESC; [cite: 2028, 2029, 2030, 2031, 2032, 2033, 2034, 2035, 2036, 2037, 2038, 2039, 2040, 2041, 2042, 2043, 2044]