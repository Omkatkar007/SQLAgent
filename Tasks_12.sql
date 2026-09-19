-- =====================================================================================
-- DEMO BANK ENTERPRISE SUITE: ALL-IN-ONE SQL IMPLEMENTATION SCRIPT
-- Database Target: MariaDB 10.11+ / MySQL 8.0+
-- Organization: Grouped sequentially across all 12 operational and regulatory tasks.
-- =====================================================================================

USE `httpscoo_deverp`;

-- Set session parameters for massive batch generation
SET @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS = 0;
SET @OLD_SQL_MODE = @@SQL_MODE, SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';
SET SESSION cte_max_recursion_depth = 150000;


-- =====================================================================================
-- DDL SETUP: REGULATORY, AI, FRAUD, STRESS-TESTING & ANALYTIC EXTENSIONS
-- =====================================================================================

CREATE TABLE IF NOT EXISTS `fintech_expense_head` (
  `expense_head_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `tenant_id` BIGINT NOT NULL,
  `head_code` VARCHAR(30) NOT NULL,
  `head_name` VARCHAR(100) NOT NULL,
  `category` ENUM('Capex', 'Opex', 'Administrative', 'Financial') DEFAULT 'Opex',
  `status` ENUM('Active', 'Inactive') DEFAULT 'Active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `fintech_vendor` (
  `vendor_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `tenant_id` BIGINT NOT NULL,
  `vendor_code` VARCHAR(30) NOT NULL,
  `vendor_name` VARCHAR(200) NOT NULL,
  `category` VARCHAR(100) DEFAULT NULL,
  `pan_number` VARCHAR(30) DEFAULT NULL,
  `status` ENUM('Active', 'Inactive') DEFAULT 'Active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `fintech_credit_risk_exposure` (
  `exposure_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `tenant_id` BIGINT NOT NULL,
  `loan_id` BIGINT NOT NULL,
  `customer_id` BIGINT NOT NULL,
  `credit_score` INT NOT NULL,
  `risk_grade` VARCHAR(10) NOT NULL,
  `ead_amount` DECIMAL(18,2) NOT NULL,
  `pd_rate` DECIMAL(6,4) NOT NULL,
  `lgd_rate` DECIMAL(6,4) NOT NULL,
  `risk_weight` DECIMAL(5,2) NOT NULL,
  `rwa_credit` DECIMAL(18,2) NOT NULL,
  `ifrs9_stage` ENUM('Stage 1', 'Stage 2', 'Stage 3') NOT NULL,
  `ecl_12m` DECIMAL(18,2) NOT NULL,
  `ecl_lifetime` DECIMAL(18,2) NOT NULL,
  `created_date` DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX (`loan_id`),
  INDEX (`ifrs9_stage`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `fintech_fraud_aml_alert` (
  `alert_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `tenant_id` BIGINT NOT NULL,
  `transaction_id` BIGINT NULL,
  `customer_id` BIGINT NOT NULL,
  `alert_type` ENUM('Card Fraud', 'AML Alert', 'KYC Failure', 'Large Cash Transaction', 'Suspicious Transfer', 'Money Laundering Patterns') NOT NULL,
  `severity` ENUM('Low', 'Medium', 'High', 'Critical') NOT NULL,
  `anomaly_score` DECIMAL(5,2) NOT NULL,
  `trigger_rule` VARCHAR(255) NOT NULL,
  `investigation_status` ENUM('Open', 'UnderReview', 'Cleared', 'Escalated_FIU') DEFAULT 'Open',
  `flagged_date` DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `fintech_stress_test_scenario` (
  `scenario_id` INT AUTO_INCREMENT PRIMARY KEY,
  `scenario_name` VARCHAR(100) NOT NULL,
  `ir_shock_bps` INT DEFAULT 0,
  `gdp_shock_pct` DECIMAL(5,2) DEFAULT 0.00,
  `unemployment_shock_pct` DECIMAL(5,2) DEFAULT 0.00,
  `property_price_drop_pct` DECIMAL(5,2) DEFAULT 0.00,
  `fx_depreciation_pct` DECIMAL(5,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `fintech_stress_test_result` (
  `result_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `scenario_id` INT NOT NULL,
  `baseline_rwa` DECIMAL(18,2),
  `stressed_rwa` DECIMAL(18,2),
  `baseline_ecl` DECIMAL(18,2),
  `stressed_ecl` DECIMAL(18,2),
  `baseline_car_pct` DECIMAL(5,2),
  `stressed_car_pct` DECIMAL(5,2),
  `run_timestamp` DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- =====================================================================================
-- 1. TASK: Master Data (~5,000 records)
-- (Tenants, 10 Branches, 100 Employees, 500 Customers, 700 Accounts, 20 Loan Products,
--  10 Deposit Products, 25 Transaction Types, 15 Expense Heads, 50 Vendors)
-- =====================================================================================

START TRANSACTION;

-- Tenant & Corporate Structure
INSERT INTO `fintech_tenant` (`tenant_code`, `tenant_name`, `legal_name`, `industry`, `tenant_kind`, `status`)
VALUES ('DEMOBANK', 'DEMO BANK', 'DEMO BANK Financial Services Corporation Ltd.', 'Banking', 'Internal', 'Active')
ON DUPLICATE KEY UPDATE `tenant_name` = VALUES(`tenant_name`);

SET @tenant_id = (SELECT `tenant_id` FROM `fintech_tenant` WHERE `tenant_code` = 'DEMOBANK' LIMIT 1);

INSERT INTO `fintech_organization` (`tenant_id`, `organization_code`, `organization_name`, `city`, `country`, `status`)
VALUES (@tenant_id, 'DEMO-CORP-HQ', 'DEMO BANK Corporate Headquarters', 'Pune', 'India', 'Active')
ON DUPLICATE KEY UPDATE `organization_name` = VALUES(`organization_name`);

SET @org_id = (SELECT `organization_id` FROM `fintech_organization` WHERE `tenant_id` = @tenant_id LIMIT 1);

-- 10 Branches
INSERT IGNORE INTO `fintech_branch` (`branch_id`, `tenant_id`, `organization_id`, `branch_code`, `branch_name`, `ifsc_code`, `city`, `state`, `status`)
SELECT 
    200 + seq, @tenant_id, @org_id, 
    CONCAT('BR-DEMO-', LPAD(seq, 2, '0')),
    CONCAT('DEMO BANK ', ELT(seq, 'Pune Main', 'Mumbai Nariman', 'Bengaluru Central', 'Hyderabad Hitech', 'Connaught Place Delhi', 'Chennai Mount', 'Kolkata Park St', 'Ahmedabad Ashram', 'Jaipur MI Road', 'Kochi Marine')),
    CONCAT('DEMO000', LPAD(seq, 4, '0')),
    ELT(seq, 'Pune', 'Mumbai', 'Bengaluru', 'Hyderabad', 'New Delhi', 'Chennai', 'Kolkata', 'Ahmedabad', 'Jaipur', 'Kochi'),
    ELT(seq, 'Maharashtra', 'Maharashtra', 'Karnataka', 'Telangana', 'Delhi', 'Tamil Nadu', 'West Bengal', 'Gujarat', 'Rajasthan', 'Kerala'),
    'Active'
FROM (
    SELECT 1 AS seq UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
    UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
) b_list;

-- 100 Employees
INSERT IGNORE INTO `fintech_user` (
    `user_id`, `tenant_id`, `organization_id`, `branch_id`, `employee_no`, 
    `first_name`, `last_name`, `email`, `role_label`, `bank_name`, `country`, `status`, `is_internal`
)
WITH RECURSIVE seq_emp AS (
    SELECT 1 AS n UNION ALL SELECT n + 1 FROM seq_emp WHERE n < 100
)
SELECT 
    1000 + n, @tenant_id, @org_id,
    200 + (1 + (n % 10)),
    CONCAT('EMP-DEMO-', LPAD(n, 4, '0')),
    CONCAT('EmpFirst', n), CONCAT('EmpLast', n),
    CONCAT('officer.', n, '@demobank.com'),
    ELT(1 + (n % 5), 'Branch Manager', 'Credit Analyst', 'Treasury Officer', 'Compliance Officer', 'AI Analyst'),
    'DEMO BANK', 'India', 'Active', 1
FROM seq_emp;

-- 500 Customers
INSERT IGNORE INTO `fintech_customer` (
    `customer_id`, `tenant_id`, `customer_no`, `customer_type`, `first_name`, 
    `last_name`, `company_name`, `email`, `mobile`, `kyc_status`, `risk_rating`
)
WITH RECURSIVE seq_cust AS (
    SELECT 1 AS n UNION ALL SELECT n + 1 FROM seq_cust WHERE n < 500
)
SELECT 
    2000 + n, @tenant_id, CONCAT('CUST-DB-', LPAD(n, 5, '0')),
    IF(n % 5 = 0, 'Corporate', 'Individual'),
    CONCAT('Customer', n), CONCAT('DemoCorp', n),
    IF(n % 5 = 0, CONCAT('Enterprise Holding ', n, ' Pvt Ltd'), NULL),
    CONCAT('client.', n, '@clientnetwork.com'),
    CONCAT('+91-98900', LPAD(n, 5, '0')),
    IF(n % 25 = 0, 'Pending', 'Verified'),
    ELT(1 + (n % 3), 'Low', 'Medium', 'High')
FROM seq_cust;

-- 700 Accounts
INSERT IGNORE INTO `fintech_account` (
    `account_id`, `tenant_id`, `customer_id`, `branch_id`, `account_type_id`, 
    `account_number`, `account_name`, `currency_code`, `available_balance`, `ledger_balance`, `account_status`, `account_category`
)
WITH RECURSIVE seq_acc AS (
    SELECT 1 AS n UNION ALL SELECT n + 1 FROM seq_acc WHERE n < 700
)
SELECT 
    10000 + n, @tenant_id,
    2000 + (1 + (n % 500)),
    200 + (1 + (n % 10)),
    1 + (n % 4),
    CONCAT('DB-ACC-', LPAD(n, 8, '0')),
    CONCAT('Account Operations ', n),
    'INR',
    ROUND(25000 + (RAND(n) * 4500000), 2),
    ROUND(25000 + (RAND(n) * 4500000), 2),
    'Active',
    ELT(1 + (n % 4), 'OPERATING', 'NOSTRO', 'VOSTRO', 'RESERVE')
FROM seq_acc;

-- 20 Loan Products
INSERT IGNORE INTO `fintech_loan_product` (
    `loan_product_id`, `tenant_id`, `product_code`, `product_name`, `loan_category`, 
    `minimum_amount`, `maximum_amount`, `interest_rate`, `status`
)
SELECT 
    10 + seq, @tenant_id, CONCAT('LP-DB-', LPAD(seq, 3, '0')),
    CONCAT('DEMO ', cat, ' Tier-', tier),
    cat, 50000.00, 50000000.00,
    CASE cat 
        WHEN 'Home' THEN 8.25 + (tier * 0.20)
        WHEN 'Personal' THEN 11.25 + (tier * 0.35)
        WHEN 'Vehicle' THEN 8.90 + (tier * 0.25)
        WHEN 'Education' THEN 8.50 + (tier * 0.15)
        WHEN 'Gold' THEN 7.25 + (tier * 0.10)
        WHEN 'Business' THEN 12.00 + (tier * 0.50)
        ELSE 10.00
    END,
    'Active'
FROM (SELECT 1 AS tier UNION ALL SELECT 2 UNION ALL SELECT 3) t
CROSS JOIN (
    SELECT 'Home' AS cat UNION ALL SELECT 'Personal' UNION ALL SELECT 'Vehicle'
    UNION ALL SELECT 'Education' UNION ALL SELECT 'Gold' UNION ALL SELECT 'Business'
    UNION ALL SELECT 'Mortgage'
) c
LIMIT 20;

-- 10 Deposit Products
INSERT IGNORE INTO `fintech_deposit_product` (
    `deposit_product_id`, `tenant_id`, `product_code`, `product_name`, `deposit_type`, 
    `currency_code`, `minimum_amount`, `maximum_amount`, `interest_rate`, `status`
)
SELECT 
    10 + seq, @tenant_id, CONCAT('DP-DB-', LPAD(seq, 3, '0')),
    CONCAT('Term Deposit Scheme ', seq),
    IF(seq % 2 = 0, 'Fixed', 'Recurring'),
    'INR', 10000.00, 20000000.00,
    6.00 + (seq * 0.25),
    'Active'
FROM (
    SELECT 1 AS seq UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
    UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
) dp;

-- 15 Expense Heads
INSERT IGNORE INTO `fintech_expense_head` (`expense_head_id`, `tenant_id`, `head_code`, `head_name`, `category`, `status`)
SELECT 
    seq, @tenant_id, CONCAT('EXP-HEAD-', LPAD(seq, 3, '0')),
    ELT(seq, 'Staff Salaries', 'Branch Rent & Rates', 'IT Infrastructure & Cloud', 'Core Banking SaaS Fee',
             'ATM Maintenance', 'Legal & Professional', 'Audit Fees', 'Travel & Conveyance',
             'Office Stationery', 'Electricity & Power', 'Security Agency Charges', 'Marketing & Brand',
             'Training & HR', 'Insurance Premiums', 'Depreciation Fixed Assets'),
    IF(seq IN (3, 5), 'Capex', 'Opex'), 'Active'
FROM (
    SELECT 1 AS seq UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
    UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
    UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15
) eh;

-- 50 Vendors
INSERT IGNORE INTO `fintech_vendor` (`vendor_id`, `tenant_id`, `vendor_code`, `vendor_name`, `category`, `pan_number`, `status`)
WITH RECURSIVE seq_ven AS (
    SELECT 1 AS n UNION ALL SELECT n + 1 FROM seq_ven WHERE n < 50
)
SELECT 
    seq_ven.n, @tenant_id, CONCAT('VEND-DB-', LPAD(seq_ven.n, 3, '0')),
    CONCAT('Vendor Supplier ', seq_ven.n, ' Corp'),
    ELT(1 + (seq_ven.n % 5), 'IT & Network', 'Facility & Security', 'Consulting & Legal', 'Office Supplies', 'Marketing Agency'),
    CONCAT('ABCDE', LPAD(seq_ven.n, 4, '0'), 'F'),
    'Active'
FROM seq_ven;

COMMIT;


-- =====================================================================================
-- 2. TASK: Banking Transactions (~100,000 records)
-- (UPI, NEFT, RTGS, IMPS, Cash Deposits, Cash Withdrawals, Card Payments, ATM, 
--  Merchant, Bill Payments, Standing Instructions)
-- =====================================================================================

START TRANSACTION;

INSERT INTO `fintech_transaction` (
    `tenant_id`, `account_id`, `reference_number`, `transaction_type`, 
    `channel`, `amount`, `balance_after`, `narration`, `transaction_date`, 
    `transaction_status`, `currency`, `route`
)
WITH RECURSIVE
    tens(n) AS (SELECT 0 UNION ALL SELECT n + 1 FROM tens WHERE n < 9),
    seq_100k(n) AS (
        SELECT t1.n + 10 * t2.n + 100 * t3.n + 1000 * t4.n + 10000 * t5.n + 1
        FROM tens t1
        CROSS JOIN tens t2
        CROSS JOIN tens t3
        CROSS JOIN tens t4
        CROSS JOIN tens t5
    )
SELECT 
    @tenant_id,
    10000 + (1 + (n % 700)),
    CONCAT('TXN-DB-', LPAD(n, 8, '0')),
    IF(n % 3 = 0, 'Debit', 'Credit'),
    ELT(1 + (n % 11), 'UPI', 'NEFT', 'RTGS', 'IMPS', 'Branch', 'Branch', 'Mobile', 'ATM', 'Internet', 'Mobile', 'Branch'),
    ROUND(100 + (RAND(n) * 250000), 2),
    ROUND(50000 + (RAND(n) * 3500000), 2),
    CONCAT(
        ELT(1 + (n % 11), 'UPI P2M Transfer', 'NEFT Clearing Settlement', 'RTGS Interbank Placement',
                          'IMPS Instant Transfer', 'Cash Deposit at Teller', 'Cash Withdrawal Slip',
                          'Card POS Transaction', 'ATM Cash Dispense', 'Merchant Gateway Clearance',
                          'Utility Bill Payment Auto-Debit', 'Standing Instruction Execution'),
        ' - Ref: ', n
    ),
    DATE_SUB(NOW(), INTERVAL MOD(n, 365) DAY),
    'Success', 'INR', 'Internal → Domestic Clearing'
FROM seq_100k;

COMMIT;


-- =====================================================================================
-- 3. TASK: Loan Data
-- (Home, Personal, Vehicle, Education, Gold, Business, MSME; Sanction Date,
--  Interest Rate, EMI, Outstanding Balance, DPD, Loan Status, NPA Flag, Restructured Flag)
-- =====================================================================================

START TRANSACTION;

INSERT IGNORE INTO `fintech_loan` (
    `loan_id`, `tenant_id`, `customer_id`, `account_id`, `loan_number`, 
    `sanctioned_amount`, `disbursed_amount`, `outstanding_amount`, `interest_rate`, 
    `tenure_months`, `emi_amount`, `disbursement_date`, `maturity_date`, 
    `loan_status`, `borrower_name`, `facility_type`, `credit_rating`, `country`
)
WITH RECURSIVE seq_loans AS (
    SELECT 1 AS n UNION ALL SELECT n + 1 FROM seq_loans WHERE n < 500
)
SELECT 
    1000 + n, @tenant_id,
    2000 + n,
    10000 + n,
    CONCAT('LN-DB-', LPAD(n, 6, '0')),
    ROUND(200000 + (RAND(n) * 15000000), 2),
    ROUND(200000 + (RAND(n) * 15000000), 2),
    ROUND(150000 + (RAND(n) * 12500000), 2),
    ROUND(7.5 + (RAND(n) * 7.5), 2),
    ROUND(12 + (RAND(n) * 120)),
    ROUND(5000 + (RAND(n) * 75000), 2),
    DATE_SUB(NOW(), INTERVAL MOD(n, 730) DAY),
    DATE_ADD(NOW(), INTERVAL MOD(n, 1800) DAY),
    CASE 
        WHEN n % 25 = 0 THEN 'NPA'
        WHEN n % 10 = 0 THEN 'Closed'
        ELSE 'Active'
    END,
    CONCAT('Borrower ', n, IF(n % 5 = 0, ' Ltd', ' Ind')),
    ELT(1 + (n % 7), 'Home Loan', 'Personal Loan', 'Vehicle Loan', 'Education Loan', 'Gold Loan', 'Business Loan', 'MSME Loan'),
    ELT(1 + (n % 6), 'AAA', 'AA', 'A', 'BBB', 'BB', 'B'),
    'IN'
FROM seq_loans;

COMMIT;


-- =====================================================================================
-- 4. TASK: Credit Risk Data
-- (Credit Score, PD, LGD, EAD, ECL, Risk Grade, Risk Weight)
-- =====================================================================================

START TRANSACTION;

TRUNCATE TABLE `fintech_credit_risk_exposure`;

INSERT INTO `fintech_credit_risk_exposure` (
    `tenant_id`, `loan_id`, `customer_id`, `credit_score`, `risk_grade`, 
    `ead_amount`, `pd_rate`, `lgd_rate`, `risk_weight`, `rwa_credit`, 
    `ifrs9_stage`, `ecl_12m`, `ecl_lifetime`
)
SELECT 
    l.tenant_id,
    l.loan_id,
    l.customer_id,
    sc.score,
    sc.grade,
    l.outstanding_amount AS ead,
    sc.pd,
    sc.lgd,
    sc.rw,
    ROUND(l.outstanding_amount * (sc.rw / 100.0), 2) AS rwa_credit,
    sc.stage,
    ROUND(l.outstanding_amount * sc.pd * sc.lgd, 2) AS ecl_12m,
    ROUND(l.outstanding_amount * LEAST(sc.pd * 2.35, 1.0) * sc.lgd, 2) AS ecl_lifetime
FROM fintech_loan l
JOIN (
    SELECT 
        loan_id,
        ROUND(500 + (RAND(loan_id) * 350)) AS score,
        ELT(1 + FLOOR(RAND(loan_id) * 6), 'AAA', 'AA', 'A', 'BBB', 'BB', 'B') AS grade,
        CASE 
            WHEN RAND(loan_id) > 0.88 THEN 'Stage 3'
            WHEN RAND(loan_id) > 0.68 THEN 'Stage 2'
            ELSE 'Stage 1'
        END AS stage,
        CASE 
            WHEN RAND(loan_id) > 0.88 THEN 0.5000
            WHEN RAND(loan_id) > 0.68 THEN 0.1250
            ELSE 0.0185
        END AS pd,
        0.4500 AS lgd,
        CASE 
            WHEN RAND(loan_id) > 0.88 THEN 150.00
            WHEN RAND(loan_id) > 0.68 THEN 100.00
            ELSE 75.00
        END AS rw
    FROM fintech_loan
    WHERE tenant_id = @tenant_id
) sc ON l.loan_id = sc.loan_id;

COMMIT;


-- =====================================================================================
-- 5. TASK: Basel II Reports (SQL View Engine)
-- (Risk-Weighted Assets, Capital Calculation, Credit Risk, Market Risk, Operational Risk)
-- =====================================================================================

CREATE OR REPLACE VIEW `vw_basel_ii_regulatory_report` AS
SELECT 
    t.tenant_name,
    SUM(e.rwa_credit) AS credit_risk_rwa,
    ROUND(SUM(e.rwa_credit) * 0.08, 2) AS credit_capital_charge,
    ROUND(SUM(e.rwa_credit) * 0.075, 2) AS market_risk_rwa,
    ROUND(SUM(e.rwa_credit) * 0.075 * 0.08, 2) AS market_capital_charge,
    ROUND(SUM(e.rwa_credit) * 0.12, 2) AS operational_risk_rwa,
    ROUND(SUM(e.rwa_credit) * 0.12 * 0.08, 2) AS operational_capital_charge,
    ROUND(SUM(e.rwa_credit) * 1.195, 2) AS total_basel_ii_rwa,
    ROUND((SUM(e.rwa_credit) * 1.195) * 0.09, 2) AS total_minimum_capital_required
FROM fintech_credit_risk_exposure e
JOIN fintech_tenant t ON e.tenant_id = t.tenant_id
WHERE t.tenant_code = 'DEMOBANK'
GROUP BY t.tenant_name;


-- =====================================================================================
-- 6. TASK: Basel III Capital & Liquidity Ratios (SQL View Engine)
-- (CET1, Tier 1, Tier 2, CAR, LCR, NSFR, Leverage Ratio)
-- =====================================================================================

CREATE OR REPLACE VIEW `vw_basel_iii_capital_liquidity` AS
SELECT 
    t.tenant_name,
    -- Regulatory Capital Components
    1450000000.00 AS cet1_capital,
    1850000000.00 AS tier1_capital,
    450000000.00 AS tier2_capital,
    2300000000.00 AS total_regulatory_capital,
    r.total_basel_ii_rwa AS total_rwa,
    -- Solvency Ratios
    ROUND((1450000000.00 / r.total_basel_ii_rwa) * 100, 2) AS cet1_ratio_pct,
    ROUND((1850000000.00 / r.total_basel_ii_rwa) * 100, 2) AS tier1_ratio_pct,
    ROUND((2300000000.00 / r.total_basel_ii_rwa) * 100, 2) AS car_pct,
    -- Liquidity & Structural Metrics
    148.50 AS lcr_pct,
    124.80 AS nsfr_pct,
    5.65 AS leverage_ratio_pct
FROM fintech_tenant t
CROSS JOIN vw_basel_ii_regulatory_report r
WHERE t.tenant_code = 'DEMOBANK';


-- =====================================================================================
-- 7. TASK: IFRS 9 ECL & Stage Migration Engine
-- (Stage 1, Stage 2, Stage 3, Lifetime ECL, 12 Month ECL)
-- =====================================================================================

CREATE OR REPLACE VIEW `vw_ifrs9_staging_and_ecl_summary` AS
SELECT 
    ifrs9_stage,
    COUNT(loan_id) AS total_facilities,
    SUM(ead_amount) AS total_ead_exposure,
    SUM(ecl_12m) AS provision_12m_ecl,
    SUM(ecl_lifetime) AS provision_lifetime_ecl,
    SUM(CASE 
        WHEN ifrs9_stage = 'Stage 1' THEN ecl_12m 
        ELSE ecl_lifetime 
    END) AS audited_ecl_allowance,
    ROUND(
        SUM(CASE WHEN ifrs9_stage = 'Stage 1' THEN ecl_12m ELSE ecl_lifetime END) / 
        NULLIF(SUM(ead_amount), 0) * 100, 
        2
    ) AS portfolio_coverage_ratio_pct
FROM fintech_credit_risk_exposure
GROUP BY ifrs9_stage;


-- =====================================================================================
-- 8. TASK: Fraud & AML Dataset
-- (Card Fraud, AML Alerts, KYC Failure, Large Cash, Suspicious Transfers, Money Laundering)
-- =====================================================================================

START TRANSACTION;

TRUNCATE TABLE `fintech_fraud_aml_alert`;

INSERT INTO `fintech_fraud_aml_alert` (
    `tenant_id`, `customer_id`, `alert_type`, `severity`, 
    `anomaly_score`, `trigger_rule`, `investigation_status`
)
SELECT 
    @tenant_id,
    2000 + (1 + (n % 400)),
    ELT(1 + (n % 6), 'Card Fraud', 'AML Alert', 'KYC Failure', 'Large Cash Transaction', 'Suspicious Transfer', 'Money Laundering Patterns'),
    ELT(1 + (n % 4), 'Low', 'Medium', 'High', 'Critical'),
    ROUND(65.00 + (RAND(n) * 34.99), 2),
    ELT(1 + (n % 6), 
        'Velocity Spikes in Card Authorizations > 5 within 2 min',
        'High-Frequency SWIFT Transfers to High-Risk Jurisdiction',
        'Incomplete Verification of Corporate UBO Registry',
        'Cash Deposit Exceeding Regulatory Ceiling ($10k / ₹10L Threshold)',
        'Rapid Inward Credit Followed by Immediate Layered RTGS Outward',
        'Structuring Patterns (Smurfing Just Below Verification Thresholds)'),
    ELT(1 + (n % 4), 'Open', 'UnderReview', 'Cleared', 'Escalated_FIU')
FROM (
    WITH RECURSIVE seq_f AS (SELECT 1 AS n UNION ALL SELECT n + 1 FROM seq_f WHERE n < 250)
    SELECT n FROM seq_f
) f_alerts;

COMMIT;


-- =====================================================================================
-- 9. TASK: AI Dataset
-- (AI Execution Logs, Prompt History, Token Usage, Cost, Hallucination, Audit)
-- =====================================================================================

START TRANSACTION;

INSERT INTO `fintech_ai_model` (`model_id`, `model_name`, `provider`, `deployment_name`, `supports_function_call`, `status`)
VALUES 
    (10, 'gpt-4o', 'OpenAI', 'prod-azure-openai-4o', 1, 'Active'),
    (11, 'qwen3.8-27b', 'Google', 'prod-qwen-credit-agent', 1, 'Active')
ON DUPLICATE KEY UPDATE `model_name` = VALUES(`model_name`);

INSERT INTO `fintech_ai_audit` (`agent_id`, `action_name`, `prompt_tokens`, `completion_tokens`, `latency_ms`, `estimated_cost`, `created_date`)
WITH RECURSIVE seq_ai AS (
    SELECT 1 AS n UNION ALL SELECT n + 1 FROM seq_ai WHERE n < 200
)
SELECT 
    1 + (n % 3),
    ELT(1 + (n % 5), 'AnalyzeBankStatementPDF', 'ExtractIdentityFromAadhaar', 'ScoreCreditUnderwritingRisk', 'CrossCheckSanctionList', 'GenerateLoanDecisionSummary'),
    ROUND(850 + (RAND(n) * 4500)),
    ROUND(150 + (RAND(n) * 900)),
    ROUND(450 + (RAND(n) * 3200)),
    ROUND(0.005 + (RAND(n) * 0.12), 4),
    DATE_SUB(NOW(), INTERVAL MOD(n, 30) DAY)
FROM seq_ai;

COMMIT;


-- =====================================================================================
-- 10. TASK: Power BI Dashboards (Analytical Views)
-- (Executive, Customer 360, Loan Portfolio, Collections, Branch Ranking)
-- =====================================================================================

-- 10.1 Customer 360 Profiling
CREATE OR REPLACE VIEW `vw_pbi_customer_360` AS
SELECT 
    c.customer_id,
    c.customer_no,
    c.customer_type,
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    c.company_name,
    c.kyc_status,
    c.risk_rating,
    COUNT(DISTINCT a.account_id) AS accounts_held,
    COALESCE(SUM(a.available_balance), 0) AS total_deposit_balance,
    COUNT(DISTINCT l.loan_id) AS loans_held,
    COALESCE(SUM(l.outstanding_amount), 0) AS total_outstanding_debt
FROM fintech_customer c
LEFT JOIN fintech_account a ON c.customer_id = a.customer_id
LEFT JOIN fintech_loan l ON c.customer_id = l.customer_id
WHERE c.tenant_id = @tenant_id
GROUP BY c.customer_id, c.customer_no, c.customer_type, c.first_name, c.last_name, c.company_name, c.kyc_status, c.risk_rating;

-- 10.2 Loan Portfolio Breakdown
CREATE OR REPLACE VIEW `vw_pbi_loan_portfolio` AS
SELECT 
    facility_type,
    loan_status,
    credit_rating,
    COUNT(*) AS total_facilities,
    SUM(sanctioned_amount) AS total_sanctioned,
    SUM(outstanding_amount) AS total_outstanding,
    ROUND(AVG(interest_rate), 2) AS weighted_avg_rate,
    SUM(emi_amount) AS monthly_receivable_emi
FROM fintech_loan
WHERE tenant_id = @tenant_id
GROUP BY facility_type, loan_status, credit_rating;

-- 10.3 Branch Ranking Performance
CREATE OR REPLACE VIEW `vw_pbi_branch_ranking` AS
SELECT 
    b.branch_code,
    b.branch_name,
    b.city,
    b.state,
    COUNT(DISTINCT a.account_id) AS total_accounts,
    SUM(a.available_balance) AS total_deposits,
    DENSE_RANK() OVER (ORDER BY SUM(a.available_balance) DESC) AS rank_by_deposits
FROM fintech_branch b
JOIN fintech_account a ON b.branch_id = a.branch_id
WHERE b.tenant_id = @tenant_id
GROUP BY b.branch_code, b.branch_name, b.city, b.state;


-- =====================================================================================
-- 11. TASK: Stress Testing (Macro Scenario Simulation Stored Procedure)
-- (Simulates: Rates +2%, GDP -5%, Inflation +4%, Property -25%, Unemployment +3%, FX -15%)
-- =====================================================================================

DELIMITER //

CREATE OR REPLACE PROCEDURE `sp_run_stress_testing_scenarios`()
BEGIN
    DECLARE v_tenant_id BIGINT;
    DECLARE v_base_rwa DECIMAL(18,2);
    DECLARE v_base_ecl DECIMAL(18,2);
    DECLARE v_stressed_rwa DECIMAL(18,2);
    DECLARE v_stressed_ecl DECIMAL(18,2);
    DECLARE v_tier1 DECIMAL(18,2) DEFAULT 1850000000.00;
    DECLARE v_tier2 DECIMAL(18,2) DEFAULT 450000000.00;
    DECLARE v_scen_id INT;

    SELECT tenant_id INTO v_tenant_id FROM fintech_tenant WHERE tenant_code = 'DEMOBANK' LIMIT 1;

    -- Compute Baseline Figures
    SELECT 
        COALESCE(SUM(rwa_credit), 0) * 1.195,
        COALESCE(SUM(CASE WHEN ifrs9_stage = 'Stage 1' THEN ecl_12m ELSE ecl_lifetime END), 0)
    INTO v_base_rwa, v_base_ecl
    FROM fintech_credit_risk_exposure
    WHERE tenant_id = v_tenant_id;

    -- Register Macro Scenario
    INSERT INTO fintech_stress_test_scenario (
        scenario_name, ir_shock_bps, gdp_shock_pct, unemployment_shock_pct, property_price_drop_pct, fx_depreciation_pct
    ) VALUES (
        'Severe Multi-Vector Macroeconomic Stress', 200, -5.00, 3.00, -25.00, 15.00
    );
    SET v_scen_id = LAST_INSERT_ID();

    -- Calculate Shocks: RWA inflates +32%, ECL explodes +85%
    SET v_stressed_rwa = v_base_rwa * 1.32;
    SET v_stressed_ecl = v_base_ecl * 1.85;

    -- Store and Output Comparative Assessment
    INSERT INTO fintech_stress_test_result (
        scenario_id, baseline_rwa, stressed_rwa, baseline_ecl, stressed_ecl, baseline_car_pct, stressed_car_pct
    ) VALUES (
        v_scen_id, v_base_rwa, v_stressed_rwa, v_base_ecl, v_stressed_ecl,
        ROUND(((v_tier1 + v_tier2 - v_base_ecl) / v_base_rwa) * 100, 2),
        ROUND(((v_tier1 + v_tier2 - v_stressed_ecl) / v_stressed_rwa) * 100, 2)
    );

    SELECT 
        s.scenario_name,
        r.baseline_rwa,
        r.stressed_rwa,
        r.baseline_ecl,
        r.stressed_ecl,
        r.baseline_car_pct,
        r.stressed_car_pct,
        CASE 
            WHEN r.stressed_car_pct >= 10.50 THEN 'PASS: Well-Capitalized under Macro Shock'
            ELSE 'CRITICAL: Capital Restoration Required'
        END AS regulatory_decision
    FROM fintech_stress_test_result r
    JOIN fintech_stress_test_scenario s ON r.scenario_id = s.scenario_id
    WHERE r.result_id = LAST_INSERT_ID();
END //

DELIMITER ;

CALL `sp_run_stress_testing_scenarios`();


-- =====================================================================================
-- 12. TASK: Executive KPIs (Consolidated Overview View)
-- (CAR, CET1, LCR, NSFR, Gross NPA, Net NPA, Deposit/Loan Volumes, Fraud, AI Cost)
-- =====================================================================================

CREATE OR REPLACE VIEW `vw_executive_kpis_consolidated` AS
SELECT 
    t.tenant_name,
    -- Balance Sheet Aggregates
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT a.account_id) AS total_accounts,
    COALESCE(SUM(a.available_balance), 0) AS total_deposit_book,
    COALESCE(SUM(l.outstanding_amount), 0) AS total_loan_book,
    -- Asset Quality
    ROUND(
        SUM(CASE WHEN l.loan_status = 'NPA' THEN l.outstanding_amount ELSE 0 END) / 
        NULLIF(SUM(l.outstanding_amount), 0) * 100, 
        2
    ) AS gross_npa_pct,
    ROUND(
        (SUM(CASE WHEN l.loan_status = 'NPA' THEN l.outstanding_amount ELSE 0 END) - 
         COALESCE(SUM(e.ecl_lifetime), 0)) / 
        NULLIF(SUM(l.outstanding_amount), 0) * 100, 
        2
    ) AS net_npa_pct,
    -- Regulatory Solvency & Liquidity
    b.cet1_ratio_pct,
    b.car_pct,
    b.lcr_pct,
    b.nsfr_pct,
    b.leverage_ratio_pct,
    -- Fraud & AI Operations
    (SELECT COUNT(*) FROM fintech_fraud_aml_alert WHERE tenant_id = t.tenant_id) AS active_aml_fraud_alerts,
    (SELECT ROUND(SUM(estimated_cost), 2) FROM fintech_ai_audit) AS total_ai_tokens_cost
FROM fintech_tenant t
JOIN fintech_customer c ON t.tenant_id = c.tenant_id
JOIN fintech_account a ON c.customer_id = a.customer_id
LEFT JOIN fintech_loan l ON c.customer_id = l.customer_id
LEFT JOIN fintech_credit_risk_exposure e ON l.loan_id = e.loan_id
CROSS JOIN vw_basel_iii_capital_liquidity b
WHERE t.tenant_code = 'DEMOBANK'
GROUP BY 
    t.tenant_name, b.cet1_ratio_pct, b.car_pct, 
    b.lcr_pct, b.nsfr_pct, b.leverage_ratio_pct;


-- =====================================================================================
-- CLEANUP & RESTORE CONSTRAINTS
-- =====================================================================================

SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
SET SQL_MODE = @OLD_SQL_MODE;

-- Quick status audit
SELECT * FROM `vw_executive_kpis_consolidated`;