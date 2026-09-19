-- --------------------------------------------------------
-- Host:                         wish.grabweb.in
-- Server version:               10.11.13-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             12.21.0.7344
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for httpscoo_deverp
CREATE DATABASE IF NOT EXISTS `httpscoo_deverp` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `httpscoo_deverp`;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.BudgetvsActual
DELIMITER //
CREATE PROCEDURE `Fin.xx.BudgetvsActual`()
BEGIN
SELECT
    b.budget_id,
    b.budget_name,
    b.start_date,
    b.end_date,
    b.amount AS budget_amount,
    COALESCE(
        (
            SELECT SUM(e.amount)
            FROM finance_expenses e
            WHERE e.expense_date
                  BETWEEN b.start_date AND b.end_date
        ), 0
    ) AS actual_expense,
    b.amount -
    COALESCE(
        (
            SELECT SUM(e.amount)
            FROM finance_expenses e
            WHERE e.expense_date
                  BETWEEN b.start_date AND b.end_date
        ), 0
    ) AS variance
FROM finance_budgets b;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.Business Operations Queries_Category Performance
DELIMITER //
CREATE PROCEDURE `Fin.xx.Business Operations Queries_Category Performance`()
BEGIN
SELECT
    category,
    COUNT(*) AS transactions,
    SUM(quantity) AS quantity_sold,
    SUM(sales) AS revenue,
    SUM(cost) AS cost,
    SUM(sales - cost) AS profit,
    ROUND(
        SUM(sales - cost) / NULLIF(SUM(sales), 0) * 100,
        2
    ) AS margin_pct
FROM financialtransactions
GROUP BY category
ORDER BY revenue DESC;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.Business Operations Queries_Daily Sales Performance
DELIMITER //
CREATE PROCEDURE `Fin.xx.Business Operations Queries_Daily Sales Performance`()
BEGIN
SELECT
    transactiondate,
    COUNT(*) AS transaction_count,
    SUM(quantity) AS total_quantity,
    SUM(sales) AS total_sales,
    SUM(cost) AS total_cost,
    SUM(sales - cost) AS gross_profit,
    ROUND(
        (SUM(sales - cost) / NULLIF(SUM(sales), 0)) * 100,
        2
    ) AS gross_margin_pct
FROM financialtransactions
GROUP BY transactiondate
ORDER BY transactiondate;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.Business Operations Queries_Region Performance
DELIMITER //
CREATE PROCEDURE `Fin.xx.Business Operations Queries_Region Performance`()
BEGIN
SELECT
    region,
    COUNT(*) AS transactions,
    COUNT(DISTINCT customerid) AS customers,
    SUM(quantity) AS units_sold,
    SUM(sales) AS revenue,
    SUM(cost) AS cost,
    SUM(sales - cost) AS profit,
    ROUND(
        SUM(sales - cost) / NULLIF(SUM(sales), 0) * 100,
        2
    ) AS margin_pct
FROM financialtransactions
GROUP BY region
ORDER BY revenue DESC;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.BusinessOperationsQueries_Monthly Business Performance
DELIMITER //
CREATE PROCEDURE `Fin.xx.BusinessOperationsQueries_Monthly Business Performance`()
BEGIN

SELECT
    YEAR(transactiondate) AS year,
    MONTH(transactiondate) AS MONTH,
    DATE_FORMAT(transactiondate, '%Y-%m') AS year_months,
    SUM(sales) AS revenue,
    SUM(cost) AS cost,
    SUM(sales - cost) AS gross_profit,
    SUM(quantity) AS units_sold,
    COUNT(DISTINCT customerid) AS active_customers
FROM financialtransactions
GROUP BY
    YEAR(transactiondate),
    MONTH(transactiondate),
    DATE_FORMAT(transactiondate, '%Y-%m')
ORDER BY year, MONTH;

END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.CashFlowAnalysis_CreditvsDebit
DELIMITER //
CREATE PROCEDURE `Fin.xx.CashFlowAnalysis_CreditvsDebit`()
BEGIN
SELECT
    transaction_date,
    SUM(
        CASE
            WHEN transaction_type = 'Credit'
            THEN amount
            ELSE 0
        END
    ) AS credit_amount,
    SUM(
        CASE
            WHEN transaction_type = 'Debit'
            THEN amount
            ELSE 0
        END
    ) AS debit_amount
FROM finance_transactions
GROUP BY transaction_date
ORDER BY transaction_date;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.CashFlowAnalysis_NetCashFlow
DELIMITER //
CREATE PROCEDURE `Fin.xx.CashFlowAnalysis_NetCashFlow`()
BEGIN
SELECT
    transaction_date,
    SUM(
        CASE
            WHEN transaction_type = 'Credit'
            THEN amount
            WHEN transaction_type = 'Debit'
            THEN -amount
            ELSE 0
        END
    ) AS net_cash_flow
FROM finance_transactions
GROUP BY transaction_date
ORDER BY transaction_date;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.CustomerBusinessAnalysis_Customer Profitability
DELIMITER //
CREATE PROCEDURE `Fin.xx.CustomerBusinessAnalysis_Customer Profitability`()
BEGIN
SELECT
    customerid,
    SUM(sales) AS revenue,
    SUM(cost) AS cost,
    SUM(sales - cost) AS gross_profit,
    ROUND(
        SUM(sales - cost) / NULLIF(SUM(sales),0) * 100,
        2
    ) AS margin_pct
FROM financialtransactions
GROUP BY customerid
ORDER BY gross_profit DESC;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.CustomerBusinessAnalysis_Customer Revenue
DELIMITER //
CREATE PROCEDURE `Fin.xx.CustomerBusinessAnalysis_Customer Revenue`()
BEGIN
SELECT
    customerid,
    COUNT(*) AS transactions,
    SUM(quantity) AS units_purchased,
    SUM(sales) AS revenue,
    SUM(cost) AS cost,
    SUM(sales - cost) AS profit
FROM financialtransactions
GROUP BY customerid
ORDER BY revenue DESC;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.CustomerBusinessAnalysis_CustomerPurchaseFrequency
DELIMITER //
CREATE PROCEDURE `Fin.xx.CustomerBusinessAnalysis_CustomerPurchaseFrequency`()
BEGIN
SELECT
    customerid,
    COUNT(*) AS purchase_count,
    MIN(transactiondate) AS first_purchase,
    MAX(transactiondate) AS last_purchase,
    SUM(sales) AS lifetime_revenue
FROM financialtransactions
GROUP BY customerid
ORDER BY lifetime_revenue DESC;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.CustomerBusinessAnalysis_Top 20 Customers
DELIMITER //
CREATE PROCEDURE `Fin.xx.CustomerBusinessAnalysis_Top 20 Customers`()
BEGIN
SELECT
    customerid,
    SUM(sales) AS revenue,
    SUM(sales - cost) AS profit,
    SUM(quantity) AS quantity
FROM financialtransactions
GROUP BY customerid
ORDER BY revenue DESC
LIMIT 20;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.Discount Analysis_Discount Impact
DELIMITER //
CREATE PROCEDURE `Fin.xx.Discount Analysis_Discount Impact`()
BEGIN
SELECT
    ROUND(SUM(discount), 2) AS total_discount,
    SUM(sales) AS revenue,
    SUM(cost) AS cost,
    SUM(sales - cost) AS profit
FROM financialtransactions;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.Discount Analysis_Discount vs Profit
DELIMITER //
CREATE PROCEDURE `Fin.xx.Discount Analysis_Discount vs Profit`()
BEGIN
SELECT
    CASE
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount <= 5 THEN '0-5%'
        WHEN discount <= 10 THEN '5-10%'
        WHEN discount <= 20 THEN '10-20%'
        ELSE '20%+'
    END AS discount_bucket,
    COUNT(*) AS transactions,
    SUM(sales) AS revenue,
    SUM(cost) AS cost,
    SUM(sales - cost) AS profit
FROM financialtransactions
GROUP BY discount_bucket
ORDER BY revenue DESC;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.ExecutiveKPIQuery
DELIMITER //
CREATE PROCEDURE `Fin.xx.ExecutiveKPIQuery`()
BEGIN
SELECT
    SUM(sales) AS total_revenue,
    SUM(cost) AS total_cost,
    SUM(sales - cost) AS gross_profit,
    ROUND(
        SUM(sales - cost) /
        NULLIF(SUM(sales),0) * 100,
        2
    ) AS gross_margin_pct,
    SUM(quantity) AS units_sold,
    COUNT(*) AS transactions,
    COUNT(DISTINCT customerid) AS customers,
    COUNT(DISTINCT productid) AS products,
    COUNT(DISTINCT region) AS regions
FROM financialtransactions;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.ExpenseManagement_ExpensebyCategory
DELIMITER //
CREATE PROCEDURE `Fin.xx.ExpenseManagement_ExpensebyCategory`()
BEGIN
SELECT
    ec.category_name,
    COUNT(e.expense_id) AS expense_count,
    SUM(e.amount) AS total_expense
FROM finance_expenses e
JOIN finance_expense_categories ec
    ON e.category_id = ec.category_id
GROUP BY ec.category_name
ORDER BY total_expense DESC;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.ExpenseManagement_ExpenseCategoryTrend
DELIMITER //
CREATE PROCEDURE `Fin.xx.ExpenseManagement_ExpenseCategoryTrend`()
BEGIN
SELECT
    DATE_FORMAT(e.expense_date, '%Y-%m') AS year_months,
    ec.category_name,
    SUM(e.amount) AS expense
FROM finance_expenses e
JOIN finance_expense_categories ec
    ON e.category_id = ec.category_id
GROUP BY
    DATE_FORMAT(e.expense_date, '%Y-%m'),
    ec.category_name
ORDER BY year_months, expense DESC;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.ExpenseManagement_MonthlyExpenses
DELIMITER //
CREATE PROCEDURE `Fin.xx.ExpenseManagement_MonthlyExpenses`()
BEGIN
SELECT
    YEAR(expense_date) AS year,
    MONTH(expense_date) AS month,
    DATE_FORMAT(expense_date, '%Y-%m') AS year_months,
    SUM(amount) AS total_expense
FROM finance_expenses
GROUP BY
    YEAR(expense_date),
    MONTH(expense_date),
    DATE_FORMAT(expense_date, '%Y-%m')
ORDER BY year, month;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.FinanceOperations_AssetvsLiability
DELIMITER //
CREATE PROCEDURE `Fin.xx.FinanceOperations_AssetvsLiability`()
BEGIN
SELECT
    r.reporting_period,
    r.total_assets,
    r.total_liabilities,
    r.total_assets - r.total_liabilities AS net_assets
FROM finance_revenue r
ORDER BY r.reporting_period;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.FinanceOperations_ProfitMargin
DELIMITER //
CREATE PROCEDURE `Fin.xx.FinanceOperations_ProfitMargin`()
BEGIN
SELECT
    reporting_period,
    revenue,
    net_profit,
    ROUND(
        net_profit / NULLIF(revenue,0) * 100,
        2
    ) AS profit_margin_pct
FROM finance_revenue
ORDER BY reporting_period;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.FinanceOperations_RevenueTrend
DELIMITER //
CREATE PROCEDURE `Fin.xx.FinanceOperations_RevenueTrend`()
BEGIN
SELECT
    reporting_period,
    revenue,
    net_profit,
    investment_cost,
    investment_gain,
    net_income
FROM finance_revenue
ORDER BY reporting_period;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.FinanceOperations_Total Revenue
DELIMITER //
CREATE PROCEDURE `Fin.xx.FinanceOperations_Total Revenue`()
BEGIN
SELECT
    SUM(revenue) AS total_revenue
FROM finance_revenue;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.FinanceOperations_TotalRevenue
DELIMITER //
CREATE PROCEDURE `Fin.xx.FinanceOperations_TotalRevenue`()
BEGIN
SELECT
    SUM(revenue) AS total_revenue
FROM finance_revenue;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.GeneralLedgerAnalysis
DELIMITER //
CREATE PROCEDURE `Fin.xx.GeneralLedgerAnalysis`()
BEGIN
SELECT
    l.entry_date,
    a.account_name,
    a.account_type,
    t.transaction_type,
    t.amount,
    t.description
FROM finance_ledger l
JOIN finance_accounts a
    ON l.account_id = a.account_id
JOIN finance_transactions t
    ON l.transaction_id = t.transaction_id
ORDER BY l.entry_date;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.GeneralLedgerAnalysis_Account-wiseBalance
DELIMITER //
CREATE PROCEDURE `Fin.xx.GeneralLedgerAnalysis_Account-wiseBalance`()
BEGIN
SELECT
    a.account_id,
    a.account_name,
    a.account_type,
    SUM(
        CASE
            WHEN t.transaction_type = 'Credit'
            THEN t.amount
            ELSE -t.amount
        END
    ) AS account_balance
FROM finance_accounts a
JOIN finance_transactions t
    ON a.account_id = t.account_id
GROUP BY
    a.account_id,
    a.account_name,
    a.account_type
ORDER BY account_balance DESC;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.InvestmentAnalysis_InvestmentGain
DELIMITER //
CREATE PROCEDURE `Fin.xx.InvestmentAnalysis_InvestmentGain`()
BEGIN
SELECT
    i.investment_id,
    i.investment_name,
    i.investment_type,
    i.amount_invested,
    COALESCE(SUM(g.gain),0) AS total_gain
FROM finance_investments i
LEFT JOIN finance_gain_from_investment g
    ON i.investment_id = g.investment_id
GROUP BY
    i.investment_id,
    i.investment_name,
    i.investment_type,
    i.amount_invested
ORDER BY total_gain DESC;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.InvestmentAnalysis_InvestmentPortfolio
DELIMITER //
CREATE PROCEDURE `Fin.xx.InvestmentAnalysis_InvestmentPortfolio`()
BEGIN
SELECT
    investment_type,
    COUNT(*) AS investments,
    SUM(amount_invested) AS invested_amount
FROM finance_investments
GROUP BY investment_type
ORDER BY invested_amount DESC;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.Invoice&AccountsReceivable_AgingAnalysis
DELIMITER //
CREATE PROCEDURE `Fin.xx.Invoice&AccountsReceivable_AgingAnalysis`()
BEGIN
SELECT
    CASE
        WHEN DATEDIFF(CURRENT_DATE, due_date) <= 0
            THEN 'Not Due'
        WHEN DATEDIFF(CURRENT_DATE, due_date) <= 30
            THEN '1-30 Days'
        WHEN DATEDIFF(CURRENT_DATE, due_date) <= 60
            THEN '31-60 Days'
        WHEN DATEDIFF(CURRENT_DATE, due_date) <= 90
            THEN '61-90 Days'
        ELSE '90+ Days'
    END AS aging_bucket,
    COUNT(*) AS invoices,
    SUM(total_amount) AS outstanding_amount
FROM finance_invoices
WHERE status = 'Pending'
GROUP BY aging_bucket
ORDER BY outstanding_amount DESC;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.Invoice&AccountsReceivable_InvoiceStatus
DELIMITER //
CREATE PROCEDURE `Fin.xx.Invoice&AccountsReceivable_InvoiceStatus`()
BEGIN
SELECT
    status,
    COUNT(*) AS invoice_count,
    SUM(total_amount) AS invoice_value
FROM finance_invoices
GROUP BY status;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.LoanManagement_OutstandingLoanAmount
DELIMITER //
CREATE PROCEDURE `Fin.xx.LoanManagement_OutstandingLoanAmount`()
BEGIN
SELECT
    l.loan_id,
    l.loan_name,
    l.principal_amount,
    COALESCE(SUM(lp.amount_paid),0) AS total_paid,
    l.principal_amount -
        COALESCE(SUM(lp.amount_paid),0) AS outstanding_principal,
    l.interest_rate,
    l.start_date,
    l.end_date
FROM finance_loans l
LEFT JOIN finance_loan_payments lp
    ON l.loan_id = lp.loan_id
GROUP BY
    l.loan_id,
    l.loan_name,
    l.principal_amount,
    l.interest_rate,
    l.start_date,
    l.end_date
ORDER BY outstanding_principal DESC;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.OperationalExceptionQueries_Highdiscounttransactions
DELIMITER //
CREATE PROCEDURE `Fin.xx.OperationalExceptionQueries_Highdiscounttransactions`()
BEGIN
SELECT *
FROM financialtransactions
WHERE discount >= 20
ORDER BY discount DESC;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.OperationalExceptionQueries_High-valuetransactions
DELIMITER //
CREATE PROCEDURE `Fin.xx.OperationalExceptionQueries_High-valuetransactions`()
BEGIN
SELECT *
FROM financialtransactions
WHERE sales >= 100000
ORDER BY sales DESC;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.OperationalExceptionQueries_Low-margintransactions
DELIMITER //
CREATE PROCEDURE `Fin.xx.OperationalExceptionQueries_Low-margintransactions`()
BEGIN
SELECT
    *,
    sales - cost AS profit,
    ROUND(
        (sales - cost) / NULLIF(sales,0) * 100,
        2
    ) AS margin_pct
FROM financialtransactions
WHERE sales > 0
  AND ((sales - cost) / sales) < 0.10
ORDER BY margin_pct;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.OperationalExceptionQueries_Potentiallosstransactions
DELIMITER //
CREATE PROCEDURE `Fin.xx.OperationalExceptionQueries_Potentiallosstransactions`()
BEGIN
SELECT
    *,
    sales - cost AS profit
FROM financialtransactions
WHERE sales < cost
ORDER BY profit;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.PaymentAnalysis_PaymentMethodbyRegion
DELIMITER //
CREATE PROCEDURE `Fin.xx.PaymentAnalysis_PaymentMethodbyRegion`()
BEGIN
SELECT
    region,
    paymentmethod,
    COUNT(*) AS transactions,
    SUM(sales) AS revenue
FROM financialtransactions
GROUP BY
    region,
    paymentmethod
ORDER BY region, revenue DESC;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.PaymentAnalysis_RevenuebyPaymentMethod
DELIMITER //
CREATE PROCEDURE `Fin.xx.PaymentAnalysis_RevenuebyPaymentMethod`()
BEGIN
SELECT
    paymentmethod,
    COUNT(*) AS transactions,
    SUM(sales) AS revenue,
    SUM(quantity) AS quantity
FROM financialtransactions
GROUP BY paymentmethod
ORDER BY revenue DESC;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.PaymentCollectionAnalysis_CollectionbyMonth
DELIMITER //
CREATE PROCEDURE `Fin.xx.PaymentCollectionAnalysis_CollectionbyMonth`()
BEGIN
SELECT
    YEAR(payment_date) AS year,
    MONTH(payment_date) AS month,
    DATE_FORMAT(payment_date, '%Y-%m') AS year_months,
    SUM(amount_paid) AS collection
FROM finance_payments
GROUP BY
    YEAR(payment_date),
    MONTH(payment_date),
    DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY year, month;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.PaymentCollectionAnalysis_CollectionbyPaymentMethod
DELIMITER //
CREATE PROCEDURE `Fin.xx.PaymentCollectionAnalysis_CollectionbyPaymentMethod`()
BEGIN
SELECT
    payment_method,
    COUNT(*) AS payment_count,
    SUM(amount_paid) AS amount_collected
FROM finance_payments
GROUP BY payment_method
ORDER BY amount_collected DESC;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.PaymentCollectionAnalysis_InvoicevsCollection
DELIMITER //
CREATE PROCEDURE `Fin.xx.PaymentCollectionAnalysis_InvoicevsCollection`()
BEGIN
SELECT
    i.invoice_id,
    i.invoice_number,
    i.invoice_date,
    i.due_date,
    i.total_amount,
    COALESCE(SUM(p.amount_paid), 0) AS amount_paid,
    i.total_amount -
        COALESCE(SUM(p.amount_paid), 0) AS outstanding_amount
FROM finance_invoices i
LEFT JOIN finance_payments p
    ON i.invoice_id = p.invoice_id
GROUP BY
    i.invoice_id,
    i.invoice_number,
    i.invoice_date,
    i.due_date,
    i.total_amount;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.PowerBIMonthlyKPIDataset
DELIMITER //
CREATE PROCEDURE `Fin.xx.PowerBIMonthlyKPIDataset`()
BEGIN
SELECT
    YEAR(transactiondate) AS year,
    MONTH(transactiondate) AS month,
    DATE_FORMAT(transactiondate, '%Y-%m') AS year_months,

    SUM(sales) AS revenue,
    SUM(cost) AS cost,
    SUM(sales - cost) AS gross_profit,

    SUM(quantity) AS units_sold,
    COUNT(*) AS transactions,

    COUNT(DISTINCT customerid) AS customers,
    COUNT(DISTINCT productid) AS products,

    ROUND(
        SUM(sales - cost) /
        NULLIF(SUM(sales),0) * 100,
        2
    ) AS gross_margin_pct,

    AVG(sales) AS avg_transaction_value

FROM financialtransactions
GROUP BY
    YEAR(transactiondate),
    MONTH(transactiondate),
    DATE_FORMAT(transactiondate, '%Y-%m')
ORDER BY year, month;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.Product/Business Analysis_Best-Selling Products
DELIMITER //
CREATE PROCEDURE `Fin.xx.Product/Business Analysis_Best-Selling Products`()
BEGIN
SELECT
    productid,
    SUM(quantity) AS units_sold,
    SUM(sales) AS revenue
FROM financialtransactions
GROUP BY productid
ORDER BY units_sold DESC
LIMIT 10;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.Product/Business Analysis_Most Profitable Products
DELIMITER //
CREATE PROCEDURE `Fin.xx.Product/Business Analysis_Most Profitable Products`()
BEGIN
SELECT
    productid,
    SUM(sales) AS revenue,
    SUM(cost) AS cost,
    SUM(sales - cost) AS profit
FROM financialtransactions
GROUP BY productid
ORDER BY profit DESC
LIMIT 10;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.Product/BusinessAnalysis_Loss-Making Products
DELIMITER //
CREATE PROCEDURE `Fin.xx.Product/BusinessAnalysis_Loss-Making Products`()
BEGIN
SELECT
    productid,
    SUM(sales) AS revenue,
    SUM(cost) AS cost,
    SUM(sales - cost) AS profit
FROM financialtransactions
GROUP BY productid
HAVING SUM(sales - cost) < 0
ORDER BY profit ASC;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.Product/BusinessAnalysis_Product Revenue
DELIMITER //
CREATE PROCEDURE `Fin.xx.Product/BusinessAnalysis_Product Revenue`()
BEGIN
SELECT
    productid,
    SUM(quantity) AS units_sold,
    SUM(sales) AS revenue,
    SUM(cost) AS cost,
    SUM(sales - cost) AS profit,
    ROUND(
        SUM(sales - cost) / NULLIF(SUM(sales), 0) * 100,
        2
    ) AS margin_pct
FROM financialtransactions
GROUP BY productid
ORDER BY revenue DESC;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.Region×CategoryPowerBIDataset
DELIMITER //
CREATE PROCEDURE `Fin.xx.Region×CategoryPowerBIDataset`()
BEGIN
SELECT
    region,
    category,
    SUM(quantity) AS units_sold,
    SUM(sales) AS revenue,
    SUM(cost) AS cost,
    SUM(sales - cost) AS profit,
    COUNT(*) AS transactions,
    COUNT(DISTINCT customerid) AS customers,

    ROUND(
        SUM(sales - cost) /
        NULLIF(SUM(sales),0) * 100,
        2
    ) AS margin_pct

FROM financialtransactions
GROUP BY
    region,
    category
ORDER BY
    region,
    revenue DESC;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xx.Year-over-YearDataset
DELIMITER //
CREATE PROCEDURE `Fin.xx.Year-over-YearDataset`()
BEGIN
SELECT
    YEAR(transactiondate) AS year,
    SUM(sales) AS revenue,
    SUM(cost) AS cost,
    SUM(sales - cost) AS profit,
    SUM(quantity) AS units
FROM financialtransactions
GROUP BY YEAR(transactiondate)
ORDER BY year;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin.xxInvoice&AccountsReceivable_OutstandingInvoices
DELIMITER //
CREATE PROCEDURE `Fin.xxInvoice&AccountsReceivable_OutstandingInvoices`()
BEGIN
SELECT
    invoice_id,
    invoice_number,
    invoice_date,
    due_date,
    total_amount,
    status,
    DATEDIFF(CURRENT_DATE, due_date) AS days_overdue
FROM finance_invoices
WHERE status = 'Pending'
ORDER BY days_overdue DESC;
END//
DELIMITER ;

-- Dumping structure for procedure httpscoo_deverp.Fin_xx_BusinessOperationsQueries_DailySalesPerformance
DELIMITER //
CREATE PROCEDURE `Fin_xx_BusinessOperationsQueries_DailySalesPerformance`()
BEGIN
SELECT
    TransactionDate,
    COUNT(*) AS transaction_count,
    SUM(quantity) AS total_quantity,
    SUM(sales) AS total_sales,
    SUM(cost) AS total_cost,
    SUM(sales - cost) AS gross_profit,
    ROUND(
        (SUM(sales - cost) / NULLIF(SUM(sales), 0)) * 100,
        2
    ) AS gross_margin_pct
FROM financialtransactions
GROUP BY TransactionDate
ORDER BY TransactionDate;
END//
DELIMITER ;

-- Dumping structure for table httpscoo_deverp.fintech_account
CREATE TABLE IF NOT EXISTS `fintech_account` (
  `account_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) NOT NULL,
  `customer_id` bigint(20) NOT NULL,
  `branch_id` bigint(20) NOT NULL,
  `account_type_id` bigint(20) NOT NULL,
  `account_number` varchar(30) NOT NULL,
  `account_name` varchar(200) DEFAULT NULL,
  `iban` varchar(60) DEFAULT NULL,
  `currency_code` varchar(10) DEFAULT 'INR',
  `available_balance` decimal(18,2) DEFAULT 0.00,
  `ledger_balance` decimal(18,2) DEFAULT 0.00,
  `account_status` enum('Pending','Active','Frozen','Closed') DEFAULT 'Pending',
  `opened_date` date DEFAULT NULL,
  `closed_date` date DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  `account_category` enum('NOSTRO','VOSTRO','OPERATING','RESERVE') DEFAULT 'NOSTRO',
  PRIMARY KEY (`account_id`),
  UNIQUE KEY `account_number` (`account_number`),
  KEY `tenant_id` (`tenant_id`),
  KEY `customer_id` (`customer_id`),
  KEY `branch_id` (`branch_id`),
  KEY `account_type_id` (`account_type_id`),
  CONSTRAINT `fintech_account_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`),
  CONSTRAINT `fintech_account_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `fintech_customer` (`customer_id`),
  CONSTRAINT `fintech_account_ibfk_3` FOREIGN KEY (`branch_id`) REFERENCES `fintech_branch` (`branch_id`),
  CONSTRAINT `fintech_account_ibfk_4` FOREIGN KEY (`account_type_id`) REFERENCES `fintech_account_type` (`account_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_account: ~13 rows (approximately)
INSERT INTO `fintech_account` (`account_id`, `tenant_id`, `customer_id`, `branch_id`, `account_type_id`, `account_number`, `account_name`, `iban`, `currency_code`, `available_balance`, `ledger_balance`, `account_status`, `opened_date`, `closed_date`, `created_date`, `account_category`) VALUES
	(1, 1, 1, 3, 1, 'ACC-001', 'USD Nostro - JPMorgan Chase NY', 'US89JPMC00001', 'USD', 278400000.00, 284000000.00, 'Active', NULL, NULL, '2026-09-04 14:15:45', 'NOSTRO'),
	(2, 1, 2, 4, 1, 'ACC-002', 'EUR Nostro - Deutsche Bank FFM', 'DE89DB000002', 'EUR', 195200000.00, 198500000.00, 'Active', NULL, NULL, '2026-09-04 14:15:45', 'NOSTRO'),
	(3, 1, 3, 2, 1, 'ACC-003', 'GBP Nostro - Barclays London', 'GB89BARC00003', 'GBP', 139800000.00, 142000000.00, 'Active', NULL, NULL, '2026-09-04 14:15:45', 'NOSTRO'),
	(4, 1, 4, 5, 1, 'ACC-004', 'JPY Nostro - MUFG Tokyo', 'JP89MUFG00004', 'JPY', 41900000000.00, 42800000000.00, 'Active', NULL, NULL, '2026-09-04 14:15:45', 'NOSTRO'),
	(5, 1, 5, 1, 2, 'ACC-005', 'SGD Corporate Current', 'SG89TMAS00005', 'SGD', 82100000.00, 88400000.00, 'Active', NULL, NULL, '2026-09-04 14:15:45', 'VOSTRO'),
	(6, 1, 5, 6, 1, 'ACC-006', 'CHF Treasury Account', 'CH89UBS000006', 'CHF', 76200000.00, 76200000.00, 'Active', NULL, NULL, '2026-09-04 14:15:45', 'NOSTRO'),
	(7, 1, 1, 1, 1, 'ACC-007', 'AUD Correspondent - ANZ', 'AU89ANZ000007', 'AUD', 62400000.00, 64100000.00, 'Active', NULL, NULL, '2026-09-04 14:15:45', 'NOSTRO'),
	(8, 1, 1, 1, 1, 'ACC-008', 'HKD Operations - HSBC HK', 'HK89HSBC00008', 'HKD', 480000000.00, 488000000.00, 'Active', NULL, NULL, '2026-09-04 14:15:45', 'NOSTRO'),
	(9, 1, 1, 1, 1, 'ACC-009', 'Client Treasury Holding Alpha', NULL, 'USD', 0.00, 0.00, 'Active', '2026-09-04', NULL, '2026-09-04 16:12:11', 'NOSTRO'),
	(10, 1, 1, 1, 1, 'ACC-010', 'Nordic Sovereign Fund', NULL, 'EUR', 55000000.00, 55000000.00, 'Active', '2026-09-04', NULL, '2026-09-04 16:16:14', 'VOSTRO'),
	(11, 5, 1, 3, 1, 'ACC-011', 'JPM Operations Nostro', NULL, 'USD', 50000000.00, 50000000.00, 'Active', '2026-09-05', NULL, '2026-09-05 04:07:31', 'NOSTRO'),
	(12, 5, 1, 3, 1, 'ACC-012', 'JPM Operations Nostro', NULL, 'USD', 50000000.00, 50000000.00, 'Active', '2026-09-05', NULL, '2026-09-05 04:08:12', 'NOSTRO'),
	(13, 1, 1, 1, 1, 'ACC-013', 'FintechBank', NULL, 'USD', 10000000.00, 10000000.00, 'Active', '2026-09-05', NULL, '2026-09-05 20:14:33', 'NOSTRO');

-- Dumping structure for table httpscoo_deverp.fintech_account_limit
CREATE TABLE IF NOT EXISTS `fintech_account_limit` (
  `limit_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `account_id` bigint(20) DEFAULT NULL,
  `daily_atm_limit` decimal(18,2) DEFAULT NULL,
  `daily_pos_limit` decimal(18,2) DEFAULT NULL,
  `daily_upi_limit` decimal(18,2) DEFAULT NULL,
  `daily_transfer_limit` decimal(18,2) DEFAULT NULL,
  `modified_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`limit_id`),
  KEY `account_id` (`account_id`),
  CONSTRAINT `fintech_account_limit_ibfk_1` FOREIGN KEY (`account_id`) REFERENCES `fintech_account` (`account_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_account_limit: ~4 rows (approximately)
INSERT INTO `fintech_account_limit` (`limit_id`, `account_id`, `daily_atm_limit`, `daily_pos_limit`, `daily_upi_limit`, `daily_transfer_limit`, `modified_date`) VALUES
	(1, 1, 20000.00, 10000.00, 10000.00, 50000.00, '2026-09-17 16:11:23'),
	(2, 4, 30000.00, 25000.00, 50000.00, 60000.00, '2026-09-17 16:11:23'),
	(3, 5, 10000.00, 10000.00, 10000.00, 42000.00, '2026-09-17 16:41:52'),
	(4, 11, 2000.00, 50000.00, 0.00, 50000.00, '2026-09-17 16:44:01');

-- Dumping structure for table httpscoo_deverp.fintech_account_nominee
CREATE TABLE IF NOT EXISTS `fintech_account_nominee` (
  `nominee_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `account_id` bigint(20) DEFAULT NULL,
  `nominee_name` varchar(200) DEFAULT NULL,
  `relationship` varchar(100) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `mobile` varchar(30) DEFAULT NULL,
  `percentage_share` decimal(5,2) DEFAULT NULL,
  PRIMARY KEY (`nominee_id`),
  KEY `account_id` (`account_id`),
  CONSTRAINT `fintech_account_nominee_ibfk_1` FOREIGN KEY (`account_id`) REFERENCES `fintech_account` (`account_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_account_nominee: ~7 rows (approximately)
INSERT INTO `fintech_account_nominee` (`nominee_id`, `account_id`, `nominee_name`, `relationship`, `dob`, `mobile`, `percentage_share`) VALUES
	(1, 1, 'Vikas M', 'Son', '2016-09-17', '9562677898', 60.00),
	(2, 2, 'Nikita S', 'Wife', '2017-09-02', '9966778800', 70.00),
	(3, 4, 'Rima K', 'Sister', '2010-10-01', '7567766887', 40.00),
	(4, 4, 'Shubhra K', 'Sister', '2006-09-10', '8997766554', 40.00),
	(5, 8, 'Gautam R', 'Busniess Patner', '1998-07-12', '9882245673', 50.00),
	(6, 12, 'Akash N', 'Grand son', '2022-10-17', '7887504030', 80.00),
	(7, 13, 'Rutvika J', 'Daughter', '1996-12-17', '9050554466', 80.00);

-- Dumping structure for table httpscoo_deverp.fintech_account_statement
CREATE TABLE IF NOT EXISTS `fintech_account_statement` (
  `statement_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `account_id` bigint(20) DEFAULT NULL,
  `statement_month` int(11) DEFAULT NULL,
  `statement_year` int(11) DEFAULT NULL,
  `opening_balance` decimal(18,2) DEFAULT NULL,
  `closing_balance` decimal(18,2) DEFAULT NULL,
  `debit_amount` decimal(18,2) DEFAULT NULL,
  `credit_amount` decimal(18,2) DEFAULT NULL,
  `pdf_url` varchar(500) DEFAULT NULL,
  `generated_date` datetime DEFAULT NULL,
  PRIMARY KEY (`statement_id`),
  KEY `tenant_id` (`tenant_id`),
  KEY `account_id` (`account_id`),
  CONSTRAINT `fintech_account_statement_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`),
  CONSTRAINT `fintech_account_statement_ibfk_2` FOREIGN KEY (`account_id`) REFERENCES `fintech_account` (`account_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_account_statement: ~4 rows (approximately)
INSERT INTO `fintech_account_statement` (`statement_id`, `tenant_id`, `account_id`, `statement_month`, `statement_year`, `opening_balance`, `closing_balance`, `debit_amount`, `credit_amount`, `pdf_url`, `generated_date`) VALUES
	(1, 6, 4, 2, 2025, 60000.00, 65000.00, 75000.00, 80000.00, 'https://example.com/statements/february-2025.pdf', '2025-02-02 17:18:27'),
	(2, 1, 2, 1, 2026, 20000.00, 28000.00, 32000.00, 40000.00, NULL, '2026-01-30 17:51:06'),
	(3, 4, 4, 4, 2026, 50000.00, 18500.00, 75000.00, 43500.00, NULL, '2026-04-17 17:53:26'),
	(4, 6, 6, 9, 2026, 12000.00, 8000.00, 14000.00, 10000.00, NULL, '2026-09-07 17:56:17');

-- Dumping structure for table httpscoo_deverp.fintech_account_type
CREATE TABLE IF NOT EXISTS `fintech_account_type` (
  `account_type_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) NOT NULL,
  `account_code` varchar(20) NOT NULL,
  `account_name` varchar(100) NOT NULL,
  `minimum_balance` decimal(18,2) DEFAULT 0.00,
  `interest_rate` decimal(5,2) DEFAULT NULL,
  `overdraft_allowed` tinyint(1) DEFAULT 0,
  `overdraft_limit` decimal(18,2) DEFAULT NULL,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`account_type_id`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `fintech_account_type_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_account_type: ~4 rows (approximately)
INSERT INTO `fintech_account_type` (`account_type_id`, `tenant_id`, `account_code`, `account_name`, `minimum_balance`, `interest_rate`, `overdraft_allowed`, `overdraft_limit`, `status`, `created_date`) VALUES
	(1, 1, 'NOSTRO', 'NOSTRO Correspondent Account', 0.00, 1.25, 1, 50000000.00, 'Active', '2026-09-04 14:15:44'),
	(2, 1, 'VOSTRO', 'VOSTRO Domestic Account', 0.00, 1.10, 0, 0.00, 'Active', '2026-09-04 14:15:44'),
	(3, 1, 'OPERATING', 'Corporate Operating Account', 10000.00, 0.50, 1, 10000000.00, 'Active', '2026-09-04 14:15:44'),
	(4, 1, 'RESERVE', 'Central Bank Reserve Placement', 0.00, 2.00, 0, 0.00, 'Active', '2026-09-04 14:15:44');

-- Dumping structure for table httpscoo_deverp.fintech_ai_agent
CREATE TABLE IF NOT EXISTS `fintech_ai_agent` (
  `agent_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) NOT NULL,
  `agent_name` varchar(200) NOT NULL,
  `agent_code` varchar(50) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `agent_type` enum('Supervisor','Planner','Executor','Reviewer','Finance','Banking','Lending','Insurance','Investment','Support','Compliance','RAG','Custom') DEFAULT NULL,
  `model_id` bigint(20) DEFAULT NULL,
  `default_prompt_id` bigint(20) DEFAULT NULL,
  `temperature` decimal(4,2) DEFAULT NULL,
  `max_tokens` int(11) DEFAULT NULL,
  `status` enum('Draft','Active','Inactive') DEFAULT NULL,
  `created_by` bigint(20) DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  `updated_date` datetime DEFAULT NULL,
  PRIMARY KEY (`agent_id`),
  UNIQUE KEY `agent_code` (`agent_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_ai_agent: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_ai_agent_tool
CREATE TABLE IF NOT EXISTS `fintech_ai_agent_tool` (
  `agent_tool_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `agent_id` bigint(20) DEFAULT NULL,
  `tool_id` bigint(20) DEFAULT NULL,
  `permission_level` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`agent_tool_id`),
  KEY `agent_id` (`agent_id`),
  KEY `tool_id` (`tool_id`),
  CONSTRAINT `fintech_ai_agent_tool_ibfk_1` FOREIGN KEY (`agent_id`) REFERENCES `fintech_ai_agent` (`agent_id`),
  CONSTRAINT `fintech_ai_agent_tool_ibfk_2` FOREIGN KEY (`tool_id`) REFERENCES `fintech_ai_tool` (`tool_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_ai_agent_tool: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_ai_audit
CREATE TABLE IF NOT EXISTS `fintech_ai_audit` (
  `audit_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `agent_id` bigint(20) DEFAULT NULL,
  `action_name` varchar(200) DEFAULT NULL,
  `prompt_tokens` int(11) DEFAULT NULL,
  `completion_tokens` int(11) DEFAULT NULL,
  `latency_ms` int(11) DEFAULT NULL,
  `estimated_cost` decimal(18,4) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`audit_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_ai_audit: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_ai_conversation
CREATE TABLE IF NOT EXISTS `fintech_ai_conversation` (
  `conversation_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `customer_id` bigint(20) DEFAULT NULL,
  `agent_id` bigint(20) DEFAULT NULL,
  `session_id` varchar(200) DEFAULT NULL,
  `title` varchar(500) DEFAULT NULL,
  `started_date` datetime DEFAULT NULL,
  `ended_date` datetime DEFAULT NULL,
  `status` enum('Open','Closed') DEFAULT NULL,
  PRIMARY KEY (`conversation_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_ai_conversation: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_ai_cost
CREATE TABLE IF NOT EXISTS `fintech_ai_cost` (
  `cost_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `execution_id` bigint(20) DEFAULT NULL,
  `model_id` bigint(20) DEFAULT NULL,
  `prompt_tokens` int(11) DEFAULT NULL,
  `completion_tokens` int(11) DEFAULT NULL,
  `total_cost` decimal(18,4) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`cost_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_ai_cost: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_ai_document
CREATE TABLE IF NOT EXISTS `fintech_ai_document` (
  `document_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `document_name` varchar(500) DEFAULT NULL,
  `document_type` varchar(100) DEFAULT NULL,
  `blob_url` varchar(1000) DEFAULT NULL,
  `checksum` varchar(200) DEFAULT NULL,
  `indexed` tinyint(1) DEFAULT NULL,
  `uploaded_by` bigint(20) DEFAULT NULL,
  `uploaded_date` datetime DEFAULT NULL,
  PRIMARY KEY (`document_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_ai_document: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_ai_document_chunk
CREATE TABLE IF NOT EXISTS `fintech_ai_document_chunk` (
  `chunk_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `document_id` bigint(20) DEFAULT NULL,
  `chunk_number` int(11) DEFAULT NULL,
  `page_number` int(11) DEFAULT NULL,
  `chunk_text` longtext DEFAULT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `embedding_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`chunk_id`),
  KEY `document_id` (`document_id`),
  CONSTRAINT `fintech_ai_document_chunk_ibfk_1` FOREIGN KEY (`document_id`) REFERENCES `fintech_ai_document` (`document_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_ai_document_chunk: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_ai_embedding
CREATE TABLE IF NOT EXISTS `fintech_ai_embedding` (
  `embedding_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `vector_id` varchar(200) DEFAULT NULL,
  `embedding_model` varchar(100) DEFAULT NULL,
  `vector_store` enum('AzureAISearch','PGVector','Pinecone','Qdrant') DEFAULT NULL,
  `dimension` int(11) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`embedding_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_ai_embedding: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_ai_execution
CREATE TABLE IF NOT EXISTS `fintech_ai_execution` (
  `execution_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `workflow_id` bigint(20) DEFAULT NULL,
  `conversation_id` bigint(20) DEFAULT NULL,
  `execution_status` varchar(50) DEFAULT NULL,
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `total_tokens` int(11) DEFAULT NULL,
  `estimated_cost` decimal(18,4) DEFAULT NULL,
  PRIMARY KEY (`execution_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_ai_execution: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_ai_feedback
CREATE TABLE IF NOT EXISTS `fintech_ai_feedback` (
  `feedback_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `conversation_id` bigint(20) DEFAULT NULL,
  `rating` int(11) DEFAULT NULL,
  `comments` text DEFAULT NULL,
  `reviewed_by` bigint(20) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`feedback_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_ai_feedback: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_ai_mcp_server
CREATE TABLE IF NOT EXISTS `fintech_ai_mcp_server` (
  `mcp_server_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `server_name` varchar(200) DEFAULT NULL,
  `endpoint` varchar(500) DEFAULT NULL,
  `authentication_type` varchar(100) DEFAULT NULL,
  `protocol_version` varchar(50) DEFAULT NULL,
  `status` enum('Active','Inactive') DEFAULT NULL,
  PRIMARY KEY (`mcp_server_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_ai_mcp_server: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_ai_memory
CREATE TABLE IF NOT EXISTS `fintech_ai_memory` (
  `memory_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `conversation_id` bigint(20) DEFAULT NULL,
  `memory_type` enum('Working','ShortTerm','LongTerm','Semantic','Episodic') DEFAULT NULL,
  `memory_text` longtext DEFAULT NULL,
  `importance_score` decimal(5,2) DEFAULT NULL,
  `embedding_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`memory_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_ai_memory: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_ai_message
CREATE TABLE IF NOT EXISTS `fintech_ai_message` (
  `message_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `conversation_id` bigint(20) DEFAULT NULL,
  `role` enum('System','User','Assistant','Tool') DEFAULT NULL,
  `content` longtext DEFAULT NULL,
  `token_count` int(11) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`message_id`),
  KEY `conversation_id` (`conversation_id`),
  CONSTRAINT `fintech_ai_message_ibfk_1` FOREIGN KEY (`conversation_id`) REFERENCES `fintech_ai_conversation` (`conversation_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_ai_message: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_ai_model
CREATE TABLE IF NOT EXISTS `fintech_ai_model` (
  `model_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `model_name` varchar(200) DEFAULT NULL,
  `provider` enum('AzureOpenAI','OpenAI','Anthropic','Google','Meta','Mistral') DEFAULT NULL,
  `deployment_name` varchar(200) DEFAULT NULL,
  `endpoint` varchar(500) DEFAULT NULL,
  `api_version` varchar(50) DEFAULT NULL,
  `embedding_dimension` int(11) DEFAULT NULL,
  `supports_function_call` tinyint(1) DEFAULT NULL,
  `supports_vision` tinyint(1) DEFAULT NULL,
  `supports_audio` tinyint(1) DEFAULT NULL,
  `status` enum('Active','Inactive') DEFAULT NULL,
  PRIMARY KEY (`model_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_ai_model: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_ai_prompt
CREATE TABLE IF NOT EXISTS `fintech_ai_prompt` (
  `prompt_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `prompt_name` varchar(200) DEFAULT NULL,
  `prompt_category` varchar(100) DEFAULT NULL,
  `system_prompt` longtext DEFAULT NULL,
  `user_prompt` longtext DEFAULT NULL,
  `output_schema` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`output_schema`)),
  `version` varchar(20) DEFAULT NULL,
  `status` enum('Draft','Published') DEFAULT NULL,
  `created_by` bigint(20) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`prompt_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_ai_prompt: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_ai_prompt_version
CREATE TABLE IF NOT EXISTS `fintech_ai_prompt_version` (
  `version_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `prompt_id` bigint(20) DEFAULT NULL,
  `version_no` varchar(20) DEFAULT NULL,
  `system_prompt` longtext DEFAULT NULL,
  `user_prompt` longtext DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`version_id`),
  KEY `prompt_id` (`prompt_id`),
  CONSTRAINT `fintech_ai_prompt_version_ibfk_1` FOREIGN KEY (`prompt_id`) REFERENCES `fintech_ai_prompt` (`prompt_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_ai_prompt_version: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_ai_recommendation
CREATE TABLE IF NOT EXISTS `fintech_ai_recommendation` (
  `recommendation_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `customer_id` bigint(20) DEFAULT NULL,
  `recommendation_type` varchar(100) DEFAULT NULL,
  `recommendation_text` longtext DEFAULT NULL,
  `confidence_score` decimal(5,2) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`recommendation_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_ai_recommendation: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_ai_tool
CREATE TABLE IF NOT EXISTS `fintech_ai_tool` (
  `tool_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tool_name` varchar(200) DEFAULT NULL,
  `tool_type` varchar(100) DEFAULT NULL,
  `endpoint` varchar(500) DEFAULT NULL,
  `authentication_type` varchar(100) DEFAULT NULL,
  `timeout_seconds` int(11) DEFAULT NULL,
  `status` enum('Active','Inactive') DEFAULT NULL,
  PRIMARY KEY (`tool_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_ai_tool: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_ai_workflow
CREATE TABLE IF NOT EXISTS `fintech_ai_workflow` (
  `workflow_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `workflow_name` varchar(200) DEFAULT NULL,
  `workflow_type` varchar(100) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `status` enum('Draft','Published') DEFAULT NULL,
  PRIMARY KEY (`workflow_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_ai_workflow: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_ai_workflow_step
CREATE TABLE IF NOT EXISTS `fintech_ai_workflow_step` (
  `step_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `workflow_id` bigint(20) DEFAULT NULL,
  `step_order` int(11) DEFAULT NULL,
  `agent_id` bigint(20) DEFAULT NULL,
  `tool_id` bigint(20) DEFAULT NULL,
  `action_type` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`step_id`),
  KEY `workflow_id` (`workflow_id`),
  CONSTRAINT `fintech_ai_workflow_step_ibfk_1` FOREIGN KEY (`workflow_id`) REFERENCES `fintech_ai_workflow` (`workflow_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_ai_workflow_step: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_api_key
CREATE TABLE IF NOT EXISTS `fintech_api_key` (
  `api_key_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `api_name` varchar(200) DEFAULT NULL,
  `api_key` varchar(500) DEFAULT NULL,
  `secret_key` varchar(500) DEFAULT NULL,
  `expires_on` date DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  `Api_Url` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`api_key_id`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `fintech_api_key_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_api_key: ~2 rows (approximately)
INSERT INTO `fintech_api_key` (`api_key_id`, `tenant_id`, `api_name`, `api_key`, `secret_key`, `expires_on`, `created_date`, `Api_Url`) VALUES
	(1, 2, 'OpenRouter', 'sk-or-v1-SAMPLE-KEY-MASKED-FOR-SECURITY-PURPOSES', '1', '2026-09-09', '2026-09-04 20:20:51', 'https://openrouter.ai/api/v1/chat/completions'),
	(2, 2, 'SMTP_Hostinger', 'smtp.hostinger.com', '2', '2026-09-10', '2026-09-04 20:23:28', NULL);

-- Dumping structure for table httpscoo_deverp.fintech_api_provider
CREATE TABLE IF NOT EXISTS `fintech_api_provider` (
  `provider_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `provider_name` varchar(200) NOT NULL,
  `provider_type` enum('Email','SMS','Payment','Bank','AI','Storage','Identity','Notification') DEFAULT NULL,
  `description` text DEFAULT NULL,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`provider_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_api_provider: ~0 rows (approximately)
INSERT INTO `fintech_api_provider` (`provider_id`, `provider_name`, `provider_type`, `description`, `status`, `created_date`) VALUES
	(1, 'Hostinger Email', 'Email', 'Hostinger Business Email Service', 'Active', '2026-09-04 20:27:07');

-- Dumping structure for table httpscoo_deverp.fintech_audit_log
CREATE TABLE IF NOT EXISTS `fintech_audit_log` (
  `audit_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `module_name` varchar(100) DEFAULT NULL,
  `entity_name` varchar(100) DEFAULT NULL,
  `entity_id` bigint(20) DEFAULT NULL,
  `action` varchar(100) DEFAULT NULL,
  `old_value` longtext DEFAULT NULL,
  `new_value` longtext DEFAULT NULL,
  `ip_address` varchar(50) DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`audit_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `fintech_audit_log_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `fintech_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_audit_log: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_beneficiary
CREATE TABLE IF NOT EXISTS `fintech_beneficiary` (
  `beneficiary_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `customer_id` bigint(20) DEFAULT NULL,
  `nickname` varchar(100) DEFAULT NULL,
  `beneficiary_name` varchar(200) DEFAULT NULL,
  `account_number` varchar(40) DEFAULT NULL,
  `ifsc_code` varchar(20) DEFAULT NULL,
  `bank_name` varchar(150) DEFAULT NULL,
  `branch_name` varchar(150) DEFAULT NULL,
  `mobile` varchar(30) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `verified` tinyint(1) DEFAULT 0,
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`beneficiary_id`),
  KEY `tenant_id` (`tenant_id`),
  KEY `customer_id` (`customer_id`),
  CONSTRAINT `fintech_beneficiary_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`),
  CONSTRAINT `fintech_beneficiary_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `fintech_customer` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_beneficiary: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_branch
CREATE TABLE IF NOT EXISTS `fintech_branch` (
  `branch_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `organization_id` bigint(20) DEFAULT NULL,
  `branch_code` varchar(30) DEFAULT NULL,
  `branch_name` varchar(200) DEFAULT NULL,
  `ifsc_code` varchar(20) DEFAULT NULL,
  `address` varchar(300) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `state` varchar(100) DEFAULT NULL,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`branch_id`),
  KEY `tenant_id` (`tenant_id`),
  KEY `organization_id` (`organization_id`),
  CONSTRAINT `fintech_branch_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`),
  CONSTRAINT `fintech_branch_ibfk_2` FOREIGN KEY (`organization_id`) REFERENCES `fintech_organization` (`organization_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_branch: ~10 rows (approximately)
INSERT INTO `fintech_branch` (`branch_id`, `tenant_id`, `organization_id`, `branch_code`, `branch_name`, `ifsc_code`, `address`, `city`, `state`, `status`, `created_date`) VALUES
	(1, 1, 1, 'BR-SG-01', 'Singapore HQ', 'SGIN001', 'Marina Bay Financial Centre', 'Singapore', 'Singapore', 'Active', '2026-09-04 14:15:43'),
	(2, 1, 1, 'BR-UK-01', 'London Branch', 'GBUK001', '100 Bishopsgate', 'London', 'UK', 'Active', '2026-09-04 14:15:43'),
	(3, 1, 1, 'BR-US-01', 'New York HQ', 'USNY001', 'Wall Street Plaza', 'New York', 'US', 'Active', '2026-09-04 14:15:43'),
	(4, 1, 1, 'BR-DE-01', 'Frankfurt Branch', 'DEFF001', 'Mainzer Landstrasse', 'Frankfurt', 'Germany', 'Active', '2026-09-04 14:15:43'),
	(5, 1, 1, 'BR-JP-01', 'Tokyo Branch', 'JPTK001', 'Marunouchi Financial District', 'Tokyo', 'Japan', 'Active', '2026-09-04 14:15:43'),
	(6, 1, 1, 'BR-CH-01', 'Zurich Branch', 'CHZH001', 'Bahnhofstrasse', 'Zurich', 'Switzerland', 'Active', '2026-09-04 14:15:43'),
	(7, 2, 2, 'BR-IN-01', 'India PU', 'IND002', 'India Pune', 'Pune', 'MahaRashtra', 'Active', '2026-09-04 20:12:36'),
	(8, 2, 2, 'BR-IN-02', 'India Mu', 'IND002', 'India Mumbai', 'mumbai', 'Maharashtra', 'Active', '2026-09-04 20:14:08'),
	(9, 3, 3, 'BR-USA-01', 'USA HQ', 'UGUS001', 'New York Bank', 'USA', 'USA', 'Active', '2026-09-04 20:13:23'),
	(10, 3, 3, 'BR-USA-02', 'Washington', 'WSUS002', 'Washington', 'USA', 'USA', 'Active', '2026-09-04 20:14:35');

-- Dumping structure for table httpscoo_deverp.fintech_budget
CREATE TABLE IF NOT EXISTS `fintech_budget` (
  `budget_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `fiscal_year_id` bigint(20) DEFAULT NULL,
  `gl_account_id` bigint(20) DEFAULT NULL,
  `budget_amount` decimal(18,2) DEFAULT NULL,
  `approved_amount` decimal(18,2) DEFAULT NULL,
  `actual_amount` decimal(18,2) DEFAULT NULL,
  `variance` decimal(18,2) DEFAULT NULL,
  PRIMARY KEY (`budget_id`),
  KEY `gl_account_id` (`gl_account_id`),
  KEY `fiscal_year_id` (`fiscal_year_id`),
  CONSTRAINT `fintech_budget_ibfk_1` FOREIGN KEY (`gl_account_id`) REFERENCES `fintech_gl_account` (`gl_account_id`),
  CONSTRAINT `fintech_budget_ibfk_2` FOREIGN KEY (`fiscal_year_id`) REFERENCES `fintech_fiscal_year` (`fiscal_year_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_budget: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_card
CREATE TABLE IF NOT EXISTS `fintech_card` (
  `card_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `account_id` bigint(20) DEFAULT NULL,
  `card_number` varchar(30) DEFAULT NULL,
  `card_type` enum('Debit','Credit','Prepaid') DEFAULT NULL,
  `card_network` enum('Visa','Master','RuPay','Amex') DEFAULT NULL,
  `expiry_month` int(11) DEFAULT NULL,
  `expiry_year` int(11) DEFAULT NULL,
  `cvv_hash` varchar(200) DEFAULT NULL,
  `daily_limit` decimal(18,2) DEFAULT NULL,
  `international_enabled` tinyint(1) DEFAULT 0,
  `contactless_enabled` tinyint(1) DEFAULT 1,
  `status` enum('Active','Blocked','Expired') DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`card_id`),
  KEY `tenant_id` (`tenant_id`),
  KEY `account_id` (`account_id`),
  CONSTRAINT `fintech_card_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`),
  CONSTRAINT `fintech_card_ibfk_2` FOREIGN KEY (`account_id`) REFERENCES `fintech_account` (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_card: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_card_transaction
CREATE TABLE IF NOT EXISTS `fintech_card_transaction` (
  `card_transaction_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `card_id` bigint(20) DEFAULT NULL,
  `merchant_name` varchar(250) DEFAULT NULL,
  `merchant_category` varchar(100) DEFAULT NULL,
  `terminal_id` varchar(100) DEFAULT NULL,
  `transaction_amount` decimal(18,2) DEFAULT NULL,
  `currency` varchar(10) DEFAULT NULL,
  `transaction_date` datetime DEFAULT NULL,
  `authorization_code` varchar(50) DEFAULT NULL,
  `status` enum('Approved','Declined','Reversed') DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`card_transaction_id`),
  KEY `tenant_id` (`tenant_id`),
  KEY `card_id` (`card_id`),
  CONSTRAINT `fintech_card_transaction_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`),
  CONSTRAINT `fintech_card_transaction_ibfk_2` FOREIGN KEY (`card_id`) REFERENCES `fintech_card` (`card_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_card_transaction: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_claim
CREATE TABLE IF NOT EXISTS `fintech_claim` (
  `claim_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `policy_id` bigint(20) DEFAULT NULL,
  `claim_number` varchar(50) DEFAULT NULL,
  `claim_type` enum('Death','Hospitalization','Accident','Vehicle','Property','Travel') DEFAULT NULL,
  `incident_date` date DEFAULT NULL,
  `claim_amount` decimal(18,2) DEFAULT NULL,
  `approved_amount` decimal(18,2) DEFAULT NULL,
  `claim_status` enum('Submitted','UnderReview','Approved','Rejected','Settled') DEFAULT NULL,
  `assigned_to` bigint(20) DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`claim_id`),
  UNIQUE KEY `claim_number` (`claim_number`),
  KEY `policy_id` (`policy_id`),
  KEY `assigned_to` (`assigned_to`),
  CONSTRAINT `fintech_claim_ibfk_1` FOREIGN KEY (`policy_id`) REFERENCES `fintech_policy` (`policy_id`),
  CONSTRAINT `fintech_claim_ibfk_2` FOREIGN KEY (`assigned_to`) REFERENCES `fintech_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_claim: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_claim_document
CREATE TABLE IF NOT EXISTS `fintech_claim_document` (
  `document_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `claim_id` bigint(20) DEFAULT NULL,
  `document_type` varchar(100) DEFAULT NULL,
  `file_name` varchar(250) DEFAULT NULL,
  `blob_url` varchar(500) DEFAULT NULL,
  `verified` tinyint(1) DEFAULT 0,
  `uploaded_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`document_id`),
  KEY `claim_id` (`claim_id`),
  CONSTRAINT `fintech_claim_document_ibfk_1` FOREIGN KEY (`claim_id`) REFERENCES `fintech_claim` (`claim_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_claim_document: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_collateral
CREATE TABLE IF NOT EXISTS `fintech_collateral` (
  `collateral_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `application_id` bigint(20) DEFAULT NULL,
  `collateral_type` enum('Property','Vehicle','Gold','FixedDeposit','Shares','Other') DEFAULT NULL,
  `description` varchar(500) DEFAULT NULL,
  `market_value` decimal(18,2) DEFAULT NULL,
  `loan_value` decimal(18,2) DEFAULT NULL,
  `valuation_date` date DEFAULT NULL,
  `document_url` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`collateral_id`),
  KEY `application_id` (`application_id`),
  CONSTRAINT `fintech_collateral_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `fintech_loan_application` (`application_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_collateral: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_collection
CREATE TABLE IF NOT EXISTS `fintech_collection` (
  `collection_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) DEFAULT NULL,
  `emi_id` bigint(20) DEFAULT NULL,
  `assigned_agent` bigint(20) DEFAULT NULL,
  `collection_date` date DEFAULT NULL,
  `overdue_days` int(11) DEFAULT NULL,
  `outstanding_amount` decimal(18,2) DEFAULT NULL,
  `collection_status` enum('Pending','Collected','Legal','Skipped') DEFAULT NULL,
  `remarks` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`collection_id`),
  KEY `loan_id` (`loan_id`),
  KEY `emi_id` (`emi_id`),
  KEY `assigned_agent` (`assigned_agent`),
  CONSTRAINT `fintech_collection_ibfk_1` FOREIGN KEY (`loan_id`) REFERENCES `fintech_loan` (`loan_id`),
  CONSTRAINT `fintech_collection_ibfk_2` FOREIGN KEY (`emi_id`) REFERENCES `fintech_emi_schedule` (`emi_id`),
  CONSTRAINT `fintech_collection_ibfk_3` FOREIGN KEY (`assigned_agent`) REFERENCES `fintech_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_collection: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_compliance_check
CREATE TABLE IF NOT EXISTS `fintech_compliance_check` (
  `check_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT 1,
  `check_name` varchar(100) NOT NULL,
  `status` enum('pass','flag','failed') DEFAULT 'pass',
  `detail` varchar(255) DEFAULT NULL,
  `checked_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`check_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_compliance_check: ~5 rows (approximately)
INSERT INTO `fintech_compliance_check` (`check_id`, `tenant_id`, `check_name`, `status`, `detail`, `checked_at`) VALUES
	(1, 1, 'Sanctions Screening', 'pass', '28,427 items cleared', '2026-09-04 14:15:46'),
	(2, 1, 'AML Monitoring', 'flag', '14 flagged transactions', '2026-09-04 14:15:46'),
	(3, 1, 'FX Reporting', 'pass', 'G20 regulatory compliance filed', '2026-09-04 14:15:46'),
	(4, 1, 'FATF Compliance', 'pass', '100% adherence score', '2026-09-04 14:15:46'),
	(5, 1, 'PEP Screening', 'pass', 'All entities verified clear', '2026-09-04 14:15:46');

-- Dumping structure for table httpscoo_deverp.fintech_configuration
CREATE TABLE IF NOT EXISTS `fintech_configuration` (
  `configuration_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `config_key` varchar(200) DEFAULT NULL,
  `config_value` text DEFAULT NULL,
  PRIMARY KEY (`configuration_id`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `fintech_configuration_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_configuration: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_corporate_action
CREATE TABLE IF NOT EXISTS `fintech_corporate_action` (
  `corporate_action_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `investment_product_id` bigint(20) DEFAULT NULL,
  `action_type` enum('Bonus','Split','Rights','Merger','Dividend') DEFAULT NULL,
  `action_date` date DEFAULT NULL,
  `description` text DEFAULT NULL,
  PRIMARY KEY (`corporate_action_id`),
  KEY `investment_product_id` (`investment_product_id`),
  CONSTRAINT `fintech_corporate_action_ibfk_1` FOREIGN KEY (`investment_product_id`) REFERENCES `fintech_investment_product` (`investment_product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_corporate_action: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_cost_center
CREATE TABLE IF NOT EXISTS `fintech_cost_center` (
  `cost_center_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `cost_center_code` varchar(30) DEFAULT NULL,
  `cost_center_name` varchar(200) DEFAULT NULL,
  `manager_name` varchar(150) DEFAULT NULL,
  `status` enum('Active','Inactive') DEFAULT NULL,
  PRIMARY KEY (`cost_center_id`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `fintech_cost_center_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_cost_center: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_credit_assessment
CREATE TABLE IF NOT EXISTS `fintech_credit_assessment` (
  `assessment_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `application_id` bigint(20) DEFAULT NULL,
  `credit_score` int(11) DEFAULT NULL,
  `risk_grade` varchar(20) DEFAULT NULL,
  `annual_income` decimal(18,2) DEFAULT NULL,
  `debt_to_income` decimal(8,2) DEFAULT NULL,
  `recommendation` enum('Approve','Reject','Review') DEFAULT NULL,
  `assessed_by` bigint(20) DEFAULT NULL,
  `assessed_date` datetime DEFAULT NULL,
  PRIMARY KEY (`assessment_id`),
  KEY `application_id` (`application_id`),
  KEY `assessed_by` (`assessed_by`),
  CONSTRAINT `fintech_credit_assessment_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `fintech_loan_application` (`application_id`),
  CONSTRAINT `fintech_credit_assessment_ibfk_2` FOREIGN KEY (`assessed_by`) REFERENCES `fintech_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_credit_assessment: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_customer
CREATE TABLE IF NOT EXISTS `fintech_customer` (
  `customer_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `customer_no` varchar(50) DEFAULT NULL,
  `customer_type` enum('Individual','Corporate') DEFAULT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `middle_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `company_name` varchar(250) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `gender` varchar(20) DEFAULT NULL,
  `mobile` varchar(30) DEFAULT NULL,
  `email` varchar(200) DEFAULT NULL,
  `aadhaar_number` varchar(30) DEFAULT NULL,
  `pan_number` varchar(30) DEFAULT NULL,
  `occupation` varchar(100) DEFAULT NULL,
  `annual_income` decimal(18,2) DEFAULT NULL,
  `kyc_status` enum('Pending','Verified','Rejected') DEFAULT NULL,
  `risk_rating` varchar(20) DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`customer_id`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `fintech_customer_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_customer: ~7 rows (approximately)
INSERT INTO `fintech_customer` (`customer_id`, `tenant_id`, `customer_no`, `customer_type`, `first_name`, `middle_name`, `last_name`, `company_name`, `dob`, `gender`, `mobile`, `email`, `aadhaar_number`, `pan_number`, `occupation`, `annual_income`, `kyc_status`, `risk_rating`, `created_date`) VALUES
	(1, 1, 'CUST-001', 'Corporate', 'JPMorgan', '', 'Chase', 'JPMorgan Chase NY', NULL, NULL, '+1-212-555-0100', 'treasury@jpmorgan.com', NULL, NULL, NULL, NULL, 'Verified', 'Low', '2026-09-04 14:15:44'),
	(2, 1, 'CUST-002', 'Corporate', 'Deutsche', '', 'Bank', 'Deutsche Bank AG', NULL, NULL, '+49-69-555-0200', 'settlement@db.com', NULL, NULL, NULL, NULL, 'Verified', 'Low', '2026-09-04 14:15:44'),
	(3, 1, 'CUST-003', 'Corporate', 'Barclays', '', 'Bank', 'Barclays London', NULL, NULL, '+44-20-555-0300', 'markets@barclays.com', NULL, NULL, NULL, NULL, 'Verified', 'Low', '2026-09-04 14:15:44'),
	(4, 1, 'CUST-004', 'Corporate', 'MUFG', '', 'Bank', 'MUFG Tokyo', NULL, NULL, '+81-3-555-0400', 'fxdesk@mufg.jp', NULL, NULL, NULL, NULL, 'Verified', 'Low', '2026-09-04 14:15:44'),
	(5, 1, 'CUST-005', 'Corporate', 'Temasek', '', 'Holdings', 'Temasek Treasury', NULL, NULL, '+65-6555-0500', 'treasury@temasek.sg', NULL, NULL, NULL, NULL, 'Verified', 'Low', '2026-09-04 14:15:45'),
	(7, 1, 'CUST-006', 'Corporate', 'Apex', '', 'Sovereign Wealth Fund', 'Apex Sovereign Wealth Fund', NULL, NULL, '+65-6800-1122', 'treasury@apex.sg', NULL, NULL, 'Platinum', 100000000.00, 'Verified', 'Low', '2026-09-04 16:29:47'),
	(8, 1, 'CUST-008', 'Corporate', 'Vertex', '', 'Capital Partners', 'Vertex Capital Partners', NULL, NULL, '+65-6900-3344', 'ir@vertex.sg', NULL, NULL, 'Platinum', 100000000.00, 'Verified', 'Low', '2026-09-04 16:30:52');

-- Dumping structure for table httpscoo_deverp.fintech_customer_address
CREATE TABLE IF NOT EXISTS `fintech_customer_address` (
  `address_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `customer_id` bigint(20) DEFAULT NULL,
  `address_type` enum('Home','Office','Communication') DEFAULT NULL,
  `address1` varchar(250) DEFAULT NULL,
  `address2` varchar(250) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `state` varchar(100) DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`address_id`),
  KEY `customer_id` (`customer_id`),
  CONSTRAINT `fintech_customer_address_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `fintech_customer` (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_customer_address: ~7 rows (approximately)
INSERT INTO `fintech_customer_address` (`address_id`, `customer_id`, `address_type`, `address1`, `address2`, `city`, `state`, `country`, `postal_code`) VALUES
	(2, 7, 'Office', '', '', '', '', 'Singapore', ''),
	(3, 8, 'Office', '', '', '', '', 'Singapore', ''),
	(4, 1, 'Office', NULL, NULL, NULL, NULL, 'United States', NULL),
	(5, 2, 'Office', NULL, NULL, NULL, NULL, 'Germany', NULL),
	(6, 3, 'Office', NULL, NULL, NULL, NULL, 'United Kingdom', NULL),
	(7, 4, 'Office', NULL, NULL, NULL, NULL, 'Japan', NULL),
	(8, 5, 'Office', NULL, NULL, NULL, NULL, 'Singapore', NULL);

-- Dumping structure for table httpscoo_deverp.fintech_customer_document
CREATE TABLE IF NOT EXISTS `fintech_customer_document` (
  `document_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `customer_id` bigint(20) DEFAULT NULL,
  `document_type` varchar(100) DEFAULT NULL,
  `document_number` varchar(100) DEFAULT NULL,
  `blob_url` varchar(500) DEFAULT NULL,
  `verified` tinyint(1) DEFAULT 0,
  `uploaded_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`document_id`),
  KEY `customer_id` (`customer_id`),
  CONSTRAINT `fintech_customer_document_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `fintech_customer` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_customer_document: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_deposit_account
CREATE TABLE IF NOT EXISTS `fintech_deposit_account` (
  `deposit_account_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `customer_id` bigint(20) DEFAULT NULL,
  `account_id` bigint(20) DEFAULT NULL,
  `deposit_product_id` bigint(20) DEFAULT NULL,
  `deposit_number` varchar(30) DEFAULT NULL,
  `deposit_type` enum('FD','RD') DEFAULT NULL,
  `principal_amount` decimal(18,2) DEFAULT NULL,
  `interest_rate` decimal(5,2) DEFAULT NULL,
  `tenure_months` int(11) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `maturity_date` date DEFAULT NULL,
  `maturity_amount` decimal(18,2) DEFAULT NULL,
  `maturity_instruction` enum('CreditSavings','RenewPrincipal','RenewPrincipalInterest') DEFAULT NULL,
  `status` enum('Pending','Active','Closed','Premature') DEFAULT 'Pending',
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`deposit_account_id`),
  UNIQUE KEY `deposit_number` (`deposit_number`),
  KEY `tenant_id` (`tenant_id`),
  KEY `customer_id` (`customer_id`),
  KEY `account_id` (`account_id`),
  KEY `deposit_product_id` (`deposit_product_id`),
  CONSTRAINT `fintech_deposit_account_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`),
  CONSTRAINT `fintech_deposit_account_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `fintech_customer` (`customer_id`),
  CONSTRAINT `fintech_deposit_account_ibfk_3` FOREIGN KEY (`account_id`) REFERENCES `fintech_account` (`account_id`),
  CONSTRAINT `fintech_deposit_account_ibfk_4` FOREIGN KEY (`deposit_product_id`) REFERENCES `fintech_deposit_product` (`deposit_product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_deposit_account: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_deposit_nominee
CREATE TABLE IF NOT EXISTS `fintech_deposit_nominee` (
  `nominee_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `deposit_account_id` bigint(20) DEFAULT NULL,
  `nominee_name` varchar(200) DEFAULT NULL,
  `relationship` varchar(100) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `mobile` varchar(30) DEFAULT NULL,
  `percentage_share` decimal(5,2) DEFAULT NULL,
  PRIMARY KEY (`nominee_id`),
  KEY `deposit_account_id` (`deposit_account_id`),
  CONSTRAINT `fintech_deposit_nominee_ibfk_1` FOREIGN KEY (`deposit_account_id`) REFERENCES `fintech_deposit_account` (`deposit_account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_deposit_nominee: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_deposit_product
CREATE TABLE IF NOT EXISTS `fintech_deposit_product` (
  `deposit_product_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) NOT NULL,
  `product_code` varchar(30) DEFAULT NULL,
  `product_name` varchar(100) DEFAULT NULL,
  `deposit_type` enum('Fixed','Recurring') DEFAULT NULL,
  `currency_code` varchar(10) DEFAULT 'INR',
  `minimum_amount` decimal(18,2) DEFAULT NULL,
  `maximum_amount` decimal(18,2) DEFAULT NULL,
  `minimum_tenure_months` int(11) DEFAULT NULL,
  `maximum_tenure_months` int(11) DEFAULT NULL,
  `interest_rate` decimal(5,2) DEFAULT NULL,
  `senior_citizen_extra` decimal(5,2) DEFAULT NULL,
  `premature_penalty` decimal(5,2) DEFAULT NULL,
  `tax_deducted` tinyint(1) DEFAULT 1,
  `auto_renewal_allowed` tinyint(1) DEFAULT 1,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`deposit_product_id`),
  UNIQUE KEY `product_code` (`product_code`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `fintech_deposit_product_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_deposit_product: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_deposit_renewal
CREATE TABLE IF NOT EXISTS `fintech_deposit_renewal` (
  `renewal_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `deposit_account_id` bigint(20) DEFAULT NULL,
  `renewal_date` date DEFAULT NULL,
  `previous_maturity_amount` decimal(18,2) DEFAULT NULL,
  `renewed_amount` decimal(18,2) DEFAULT NULL,
  `new_interest_rate` decimal(5,2) DEFAULT NULL,
  `new_maturity_date` date DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`renewal_id`),
  KEY `deposit_account_id` (`deposit_account_id`),
  CONSTRAINT `fintech_deposit_renewal_ibfk_1` FOREIGN KEY (`deposit_account_id`) REFERENCES `fintech_deposit_account` (`deposit_account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_deposit_renewal: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_deposit_transaction
CREATE TABLE IF NOT EXISTS `fintech_deposit_transaction` (
  `deposit_transaction_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `deposit_account_id` bigint(20) DEFAULT NULL,
  `transaction_type` enum('Open','Installment','Interest','Penalty','Renewal','Closure','Premature') DEFAULT NULL,
  `amount` decimal(18,2) DEFAULT NULL,
  `transaction_date` datetime DEFAULT NULL,
  `narration` varchar(500) DEFAULT NULL,
  `reference_number` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`deposit_transaction_id`),
  KEY `deposit_account_id` (`deposit_account_id`),
  CONSTRAINT `fintech_deposit_transaction_ibfk_1` FOREIGN KEY (`deposit_account_id`) REFERENCES `fintech_deposit_account` (`deposit_account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_deposit_transaction: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_dividend
CREATE TABLE IF NOT EXISTS `fintech_dividend` (
  `dividend_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `holding_id` bigint(20) DEFAULT NULL,
  `declaration_date` date DEFAULT NULL,
  `record_date` date DEFAULT NULL,
  `payment_date` date DEFAULT NULL,
  `dividend_per_unit` decimal(18,4) DEFAULT NULL,
  `total_dividend` decimal(18,2) DEFAULT NULL,
  PRIMARY KEY (`dividend_id`),
  KEY `holding_id` (`holding_id`),
  CONSTRAINT `fintech_dividend_ibfk_1` FOREIGN KEY (`holding_id`) REFERENCES `fintech_holding` (`holding_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_dividend: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_email_configuration
CREATE TABLE IF NOT EXISTS `fintech_email_configuration` (
  `email_configuration_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) NOT NULL,
  `api_key_id` bigint(20) NOT NULL,
  `email_address` varchar(255) DEFAULT NULL,
  `display_name` varchar(200) DEFAULT NULL,
  `smtp_host` varchar(255) DEFAULT NULL,
  `smtp_port` int(11) DEFAULT NULL,
  `smtp_encryption` enum('SSL','TLS','STARTTLS') DEFAULT NULL,
  `imap_host` varchar(255) DEFAULT NULL,
  `imap_port` int(11) DEFAULT NULL,
  `imap_encryption` enum('SSL','TLS') DEFAULT NULL,
  `pop3_host` varchar(255) DEFAULT NULL,
  `pop3_port` int(11) DEFAULT NULL,
  `pop3_encryption` enum('SSL','TLS') DEFAULT NULL,
  `enable_smtp` tinyint(1) DEFAULT 1,
  `enable_imap` tinyint(1) DEFAULT 1,
  `enable_pop3` tinyint(1) DEFAULT 0,
  `status` enum('Active','Inactive') DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`email_configuration_id`),
  KEY `api_key_id` (`api_key_id`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `fintech_email_configuration_ibfk_1` FOREIGN KEY (`api_key_id`) REFERENCES `fintech_api_key` (`api_key_id`),
  CONSTRAINT `fintech_email_configuration_ibfk_2` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_email_configuration: ~1 rows (approximately)
INSERT INTO `fintech_email_configuration` (`email_configuration_id`, `tenant_id`, `api_key_id`, `email_address`, `display_name`, `smtp_host`, `smtp_port`, `smtp_encryption`, `imap_host`, `imap_port`, `imap_encryption`, `pop3_host`, `pop3_port`, `pop3_encryption`, `enable_smtp`, `enable_imap`, `enable_pop3`, `status`, `created_date`) VALUES
	(1, 1, 1, 'admin@fintech.ai', 'FinTech Support', 'smtp.hostinger.com', 465, 'SSL', 'imap.hostinger.com', 993, 'SSL', 'pop.hostinger.com', 995, 'SSL', 1, 1, 0, NULL, '2026-09-04 20:27:24');

-- Dumping structure for table httpscoo_deverp.fintech_emi_schedule
CREATE TABLE IF NOT EXISTS `fintech_emi_schedule` (
  `emi_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) DEFAULT NULL,
  `installment_no` int(11) DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `opening_balance` decimal(18,2) DEFAULT NULL,
  `principal_amount` decimal(18,2) DEFAULT NULL,
  `interest_amount` decimal(18,2) DEFAULT NULL,
  `emi_amount` decimal(18,2) DEFAULT NULL,
  `closing_balance` decimal(18,2) DEFAULT NULL,
  `payment_status` enum('Pending','Paid','Overdue') DEFAULT 'Pending',
  `payment_date` date DEFAULT NULL,
  PRIMARY KEY (`emi_id`),
  KEY `loan_id` (`loan_id`),
  CONSTRAINT `fintech_emi_schedule_ibfk_1` FOREIGN KEY (`loan_id`) REFERENCES `fintech_loan` (`loan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_emi_schedule: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_financial_statement
CREATE TABLE IF NOT EXISTS `fintech_financial_statement` (
  `statement_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `statement_type` enum('TrialBalance','BalanceSheet','ProfitLoss','CashFlow') DEFAULT NULL,
  `fiscal_year_id` bigint(20) DEFAULT NULL,
  `generated_date` datetime DEFAULT NULL,
  `generated_by` bigint(20) DEFAULT NULL,
  `pdf_url` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`statement_id`),
  KEY `fiscal_year_id` (`fiscal_year_id`),
  KEY `generated_by` (`generated_by`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `fintech_financial_statement_ibfk_1` FOREIGN KEY (`fiscal_year_id`) REFERENCES `fintech_fiscal_year` (`fiscal_year_id`),
  CONSTRAINT `fintech_financial_statement_ibfk_2` FOREIGN KEY (`generated_by`) REFERENCES `fintech_user` (`user_id`),
  CONSTRAINT `fintech_financial_statement_ibfk_3` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_financial_statement: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_fiscal_year
CREATE TABLE IF NOT EXISTS `fintech_fiscal_year` (
  `fiscal_year_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) NOT NULL,
  `fiscal_year_name` varchar(20) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `status` enum('Open','Closed') DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`fiscal_year_id`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `fintech_fiscal_year_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_fiscal_year: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_fixed_deposit
CREATE TABLE IF NOT EXISTS `fintech_fixed_deposit` (
  `fd_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `deposit_account_id` bigint(20) DEFAULT NULL,
  `fd_number` varchar(30) DEFAULT NULL,
  `compounding_frequency` enum('Monthly','Quarterly','HalfYearly','Yearly') DEFAULT NULL,
  `payout_frequency` enum('Maturity','Monthly','Quarterly') DEFAULT NULL,
  `auto_renew` tinyint(1) DEFAULT 0,
  `lien_marked` tinyint(1) DEFAULT 0,
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`fd_id`),
  KEY `deposit_account_id` (`deposit_account_id`),
  CONSTRAINT `fintech_fixed_deposit_ibfk_1` FOREIGN KEY (`deposit_account_id`) REFERENCES `fintech_deposit_account` (`deposit_account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_fixed_deposit: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_fund_transfer
CREATE TABLE IF NOT EXISTS `fintech_fund_transfer` (
  `transfer_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `from_account` bigint(20) DEFAULT NULL,
  `beneficiary_id` bigint(20) DEFAULT NULL,
  `transfer_mode` enum('UPI','IMPS','NEFT','RTGS','Internal') DEFAULT NULL,
  `amount` decimal(18,2) DEFAULT NULL,
  `remarks` varchar(500) DEFAULT NULL,
  `status` enum('Pending','Success','Failed','Cancelled') DEFAULT NULL,
  `transfer_date` datetime DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`transfer_id`),
  KEY `tenant_id` (`tenant_id`),
  KEY `from_account` (`from_account`),
  KEY `beneficiary_id` (`beneficiary_id`),
  CONSTRAINT `fintech_fund_transfer_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`),
  CONSTRAINT `fintech_fund_transfer_ibfk_2` FOREIGN KEY (`from_account`) REFERENCES `fintech_account` (`account_id`),
  CONSTRAINT `fintech_fund_transfer_ibfk_3` FOREIGN KEY (`beneficiary_id`) REFERENCES `fintech_beneficiary` (`beneficiary_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_fund_transfer: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_fx_rate
CREATE TABLE IF NOT EXISTS `fintech_fx_rate` (
  `rate_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT 1,
  `pair` varchar(20) NOT NULL,
  `rate` decimal(12,4) NOT NULL,
  `change_amount` varchar(20) DEFAULT '+0.0000',
  `change_pct` varchar(20) DEFAULT '+0.00%',
  `is_positive` tinyint(1) DEFAULT 1,
  `updated_date` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`rate_id`),
  UNIQUE KEY `pair_tenant` (`tenant_id`,`pair`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_fx_rate: ~8 rows (approximately)
INSERT INTO `fintech_fx_rate` (`rate_id`, `tenant_id`, `pair`, `rate`, `change_amount`, `change_pct`, `is_positive`, `updated_date`) VALUES
	(1, 1, 'EUR/USD', 1.0847, '+0.0012', '+0.11%', 1, '2026-09-04 14:15:45'),
	(2, 1, 'GBP/USD', 1.2691, '+0.0034', '+0.27%', 1, '2026-09-04 14:15:46'),
	(3, 1, 'USD/JPY', 149.8200, '-0.4800', '-0.32%', 0, '2026-09-04 14:15:46'),
	(4, 1, 'USD/CHF', 0.8834, '+0.0006', '+0.07%', 1, '2026-09-04 14:15:46'),
	(5, 1, 'AUD/USD', 0.6512, '-0.0018', '-0.28%', 0, '2026-09-04 14:15:46'),
	(6, 1, 'USD/SGD', 1.3362, '+0.0044', '+0.33%', 1, '2026-09-04 14:15:46'),
	(7, 1, 'USD/HKD', 7.8120, '+0.0008', '+0.01%', 1, '2026-09-04 14:15:46'),
	(8, 1, 'EUR/GBP', 0.8545, '-0.0021', '-0.25%', 0, '2026-09-04 14:15:46');

-- Dumping structure for table httpscoo_deverp.fintech_gl_account
CREATE TABLE IF NOT EXISTS `fintech_gl_account` (
  `gl_account_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `account_type_id` bigint(20) DEFAULT NULL,
  `account_code` varchar(30) DEFAULT NULL,
  `account_name` varchar(200) DEFAULT NULL,
  `parent_account_id` bigint(20) DEFAULT NULL,
  `normal_balance` enum('Debit','Credit') DEFAULT NULL,
  `currency_code` varchar(10) DEFAULT 'INR',
  `status` enum('Active','Inactive') DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`gl_account_id`),
  UNIQUE KEY `account_code` (`account_code`),
  KEY `account_type_id` (`account_type_id`),
  KEY `parent_account_id` (`parent_account_id`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `fintech_gl_account_ibfk_1` FOREIGN KEY (`account_type_id`) REFERENCES `fintech_gl_account_type` (`account_type_id`),
  CONSTRAINT `fintech_gl_account_ibfk_2` FOREIGN KEY (`parent_account_id`) REFERENCES `fintech_gl_account` (`gl_account_id`),
  CONSTRAINT `fintech_gl_account_ibfk_3` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_gl_account: ~7 rows (approximately)
INSERT INTO `fintech_gl_account` (`gl_account_id`, `tenant_id`, `account_type_id`, `account_code`, `account_name`, `parent_account_id`, `normal_balance`, `currency_code`, `status`, `created_date`) VALUES
	(1, 1, 1, '100100', 'Cash In Hand', NULL, 'Debit', 'INR', 'Active', '2026-09-02 21:58:42'),
	(2, 1, 2, '100200', 'Bank Account', NULL, 'Debit', 'INR', 'Active', '2026-09-02 21:58:42'),
	(3, 1, 3, '200100', 'Customer Deposits', NULL, 'Credit', 'INR', 'Active', '2026-09-02 21:58:42'),
	(4, 1, 4, '110100', 'Loan Receivable', NULL, 'Debit', 'INR', 'Active', '2026-09-02 21:58:42'),
	(5, 1, 5, '400100', 'Interest Income', NULL, 'Credit', 'INR', 'Active', '2026-09-02 21:58:42'),
	(6, 1, 6, '500100', 'Office Expense', NULL, 'Debit', 'INR', 'Active', '2026-09-02 21:58:42'),
	(7, 1, 7, '300100', 'Share Capital', NULL, 'Credit', 'INR', 'Active', '2026-09-02 21:58:42');

-- Dumping structure for table httpscoo_deverp.fintech_gl_account_type
CREATE TABLE IF NOT EXISTS `fintech_gl_account_type` (
  `account_type_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `account_type_name` varchar(50) DEFAULT NULL,
  `account_category` enum('Asset','Liability','Equity','Income','Expense') DEFAULT NULL,
  PRIMARY KEY (`account_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_gl_account_type: ~7 rows (approximately)
INSERT INTO `fintech_gl_account_type` (`account_type_id`, `account_type_name`, `account_category`) VALUES
	(1, 'Cash', 'Asset'),
	(2, 'Bank', 'Asset'),
	(3, 'Customer Deposit', 'Liability'),
	(4, 'Loan Receivable', 'Asset'),
	(5, 'Interest Income', 'Income'),
	(6, 'Operating Expense', 'Expense'),
	(7, 'Share Capital', 'Equity');

-- Dumping structure for table httpscoo_deverp.fintech_gl_balance
CREATE TABLE IF NOT EXISTS `fintech_gl_balance` (
  `balance_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `gl_account_id` bigint(20) DEFAULT NULL,
  `fiscal_year_id` bigint(20) DEFAULT NULL,
  `opening_balance` decimal(18,2) DEFAULT NULL,
  `debit_total` decimal(18,2) DEFAULT NULL,
  `credit_total` decimal(18,2) DEFAULT NULL,
  `closing_balance` decimal(18,2) DEFAULT NULL,
  PRIMARY KEY (`balance_id`),
  KEY `gl_account_id` (`gl_account_id`),
  KEY `fiscal_year_id` (`fiscal_year_id`),
  CONSTRAINT `fintech_gl_balance_ibfk_1` FOREIGN KEY (`gl_account_id`) REFERENCES `fintech_gl_account` (`gl_account_id`),
  CONSTRAINT `fintech_gl_balance_ibfk_2` FOREIGN KEY (`fiscal_year_id`) REFERENCES `fintech_fiscal_year` (`fiscal_year_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_gl_balance: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_holding
CREATE TABLE IF NOT EXISTS `fintech_holding` (
  `holding_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `portfolio_id` bigint(20) DEFAULT NULL,
  `investment_product_id` bigint(20) DEFAULT NULL,
  `quantity` decimal(18,4) DEFAULT NULL,
  `average_purchase_price` decimal(18,4) DEFAULT NULL,
  `current_price` decimal(18,4) DEFAULT NULL,
  `market_value` decimal(18,2) DEFAULT NULL,
  `gain_loss` decimal(18,2) DEFAULT NULL,
  PRIMARY KEY (`holding_id`),
  KEY `portfolio_id` (`portfolio_id`),
  KEY `investment_product_id` (`investment_product_id`),
  CONSTRAINT `fintech_holding_ibfk_1` FOREIGN KEY (`portfolio_id`) REFERENCES `fintech_portfolio` (`portfolio_id`),
  CONSTRAINT `fintech_holding_ibfk_2` FOREIGN KEY (`investment_product_id`) REFERENCES `fintech_investment_product` (`investment_product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_holding: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_insurance_agent
CREATE TABLE IF NOT EXISTS `fintech_insurance_agent` (
  `agent_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `agent_code` varchar(30) DEFAULT NULL,
  `agent_name` varchar(200) DEFAULT NULL,
  `license_number` varchar(100) DEFAULT NULL,
  `mobile` varchar(30) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `commission_percentage` decimal(5,2) DEFAULT NULL,
  `status` enum('Active','Inactive') DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`agent_id`),
  UNIQUE KEY `agent_code` (`agent_code`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `fintech_insurance_agent_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_insurance_agent: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_insurance_product
CREATE TABLE IF NOT EXISTS `fintech_insurance_product` (
  `insurance_product_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) NOT NULL,
  `product_code` varchar(30) DEFAULT NULL,
  `product_name` varchar(200) DEFAULT NULL,
  `insurance_type` enum('Life','Health','Motor','Travel','Home','Business','Accident') DEFAULT NULL,
  `minimum_age` int(11) DEFAULT NULL,
  `maximum_age` int(11) DEFAULT NULL,
  `minimum_sum_assured` decimal(18,2) DEFAULT NULL,
  `maximum_sum_assured` decimal(18,2) DEFAULT NULL,
  `minimum_tenure` int(11) DEFAULT NULL,
  `maximum_tenure` int(11) DEFAULT NULL,
  `premium_frequency` enum('Monthly','Quarterly','HalfYearly','Yearly') DEFAULT NULL,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`insurance_product_id`),
  UNIQUE KEY `product_code` (`product_code`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `fintech_insurance_product_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_insurance_product: ~3 rows (approximately)
INSERT INTO `fintech_insurance_product` (`insurance_product_id`, `tenant_id`, `product_code`, `product_name`, `insurance_type`, `minimum_age`, `maximum_age`, `minimum_sum_assured`, `maximum_sum_assured`, `minimum_tenure`, `maximum_tenure`, `premium_frequency`, `status`, `created_date`) VALUES
	(1, 1, 'LIFE001', 'Life Secure Plan', 'Life', 18, 65, 100000.00, 10000000.00, 5, 30, 'Yearly', 'Active', '2026-09-02 21:50:47'),
	(2, 1, 'HEALTH001', 'Health Protect', 'Health', 18, 70, 50000.00, 5000000.00, 1, 5, 'Yearly', 'Active', '2026-09-02 21:50:47'),
	(3, 1, 'MOTOR001', 'Motor Shield', 'Motor', 18, 80, 50000.00, 5000000.00, 1, 1, 'Yearly', 'Active', '2026-09-02 21:50:47');

-- Dumping structure for table httpscoo_deverp.fintech_interest_schedule
CREATE TABLE IF NOT EXISTS `fintech_interest_schedule` (
  `interest_schedule_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `deposit_account_id` bigint(20) DEFAULT NULL,
  `interest_date` date DEFAULT NULL,
  `principal` decimal(18,2) DEFAULT NULL,
  `interest_amount` decimal(18,2) DEFAULT NULL,
  `tax_amount` decimal(18,2) DEFAULT NULL,
  `net_interest` decimal(18,2) DEFAULT NULL,
  `processed` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`interest_schedule_id`),
  KEY `deposit_account_id` (`deposit_account_id`),
  CONSTRAINT `fintech_interest_schedule_ibfk_1` FOREIGN KEY (`deposit_account_id`) REFERENCES `fintech_deposit_account` (`deposit_account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_interest_schedule: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_investment_account
CREATE TABLE IF NOT EXISTS `fintech_investment_account` (
  `investment_account_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `customer_id` bigint(20) DEFAULT NULL,
  `account_id` bigint(20) DEFAULT NULL,
  `portfolio_name` varchar(200) DEFAULT NULL,
  `investment_account_number` varchar(50) DEFAULT NULL,
  `broker_name` varchar(200) DEFAULT NULL,
  `demat_number` varchar(50) DEFAULT NULL,
  `status` enum('Active','Inactive') DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`investment_account_id`),
  KEY `customer_id` (`customer_id`),
  KEY `account_id` (`account_id`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `fintech_investment_account_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `fintech_customer` (`customer_id`),
  CONSTRAINT `fintech_investment_account_ibfk_2` FOREIGN KEY (`account_id`) REFERENCES `fintech_account` (`account_id`),
  CONSTRAINT `fintech_investment_account_ibfk_3` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_investment_account: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_investment_product
CREATE TABLE IF NOT EXISTS `fintech_investment_product` (
  `investment_product_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) NOT NULL,
  `product_code` varchar(30) DEFAULT NULL,
  `product_name` varchar(200) DEFAULT NULL,
  `investment_type` enum('MutualFund','Stock','ETF','Bond','Gold','NPS','FixedIncome','Crypto','REIT') DEFAULT NULL,
  `isin_code` varchar(20) DEFAULT NULL,
  `exchange_name` varchar(100) DEFAULT NULL,
  `currency_code` varchar(10) DEFAULT 'INR',
  `risk_level` enum('Low','Medium','High') DEFAULT NULL,
  `expense_ratio` decimal(6,3) DEFAULT NULL,
  `fund_house` varchar(200) DEFAULT NULL,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`investment_product_id`),
  UNIQUE KEY `product_code` (`product_code`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `fintech_investment_product_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_investment_product: ~3 rows (approximately)
INSERT INTO `fintech_investment_product` (`investment_product_id`, `tenant_id`, `product_code`, `product_name`, `investment_type`, `isin_code`, `exchange_name`, `currency_code`, `risk_level`, `expense_ratio`, `fund_house`, `status`, `created_date`) VALUES
	(1, 1, 'MF001', 'Nifty Index Fund', 'MutualFund', 'INF000001', NULL, 'INR', 'Medium', NULL, 'ABC Mutual Fund', 'Active', '2026-09-02 21:51:35'),
	(2, 1, 'EQ001', 'TCS Limited', 'Stock', 'INE467B01029', NULL, 'INR', 'Medium', NULL, 'NSE', 'Active', '2026-09-02 21:51:35'),
	(3, 1, 'ETF001', 'Gold ETF', 'ETF', 'INF000010', NULL, 'INR', 'Low', NULL, 'XYZ Asset Management', 'Active', '2026-09-02 21:51:35');

-- Dumping structure for table httpscoo_deverp.fintech_journal
CREATE TABLE IF NOT EXISTS `fintech_journal` (
  `journal_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `journal_number` varchar(50) DEFAULT NULL,
  `journal_type` enum('Manual','Payment','Receipt','Adjustment','Accrual','Depreciation','Closing') DEFAULT NULL,
  `transaction_date` date DEFAULT NULL,
  `narration` varchar(500) DEFAULT NULL,
  `created_by` bigint(20) DEFAULT NULL,
  `approved_by` bigint(20) DEFAULT NULL,
  `status` enum('Draft','Approved','Posted','Cancelled') DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`journal_id`),
  UNIQUE KEY `journal_number` (`journal_number`),
  KEY `created_by` (`created_by`),
  KEY `approved_by` (`approved_by`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `fintech_journal_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `fintech_user` (`user_id`),
  CONSTRAINT `fintech_journal_ibfk_2` FOREIGN KEY (`approved_by`) REFERENCES `fintech_user` (`user_id`),
  CONSTRAINT `fintech_journal_ibfk_3` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_journal: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_journal_entry
CREATE TABLE IF NOT EXISTS `fintech_journal_entry` (
  `journal_entry_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `journal_id` bigint(20) DEFAULT NULL,
  `gl_account_id` bigint(20) DEFAULT NULL,
  `cost_center_id` bigint(20) DEFAULT NULL,
  `description` varchar(500) DEFAULT NULL,
  `debit_amount` decimal(18,2) DEFAULT 0.00,
  `credit_amount` decimal(18,2) DEFAULT 0.00,
  `reference_module` varchar(100) DEFAULT NULL,
  `reference_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`journal_entry_id`),
  KEY `journal_id` (`journal_id`),
  KEY `gl_account_id` (`gl_account_id`),
  KEY `cost_center_id` (`cost_center_id`),
  CONSTRAINT `fintech_journal_entry_ibfk_1` FOREIGN KEY (`journal_id`) REFERENCES `fintech_journal` (`journal_id`),
  CONSTRAINT `fintech_journal_entry_ibfk_2` FOREIGN KEY (`gl_account_id`) REFERENCES `fintech_gl_account` (`gl_account_id`),
  CONSTRAINT `fintech_journal_entry_ibfk_3` FOREIGN KEY (`cost_center_id`) REFERENCES `fintech_cost_center` (`cost_center_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_journal_entry: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_loan
CREATE TABLE IF NOT EXISTS `fintech_loan` (
  `loan_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `application_id` bigint(20) DEFAULT NULL,
  `loan_number` varchar(40) DEFAULT NULL,
  `customer_id` bigint(20) DEFAULT NULL,
  `account_id` bigint(20) DEFAULT NULL,
  `sanctioned_amount` decimal(18,2) DEFAULT NULL,
  `disbursed_amount` decimal(18,2) DEFAULT NULL,
  `outstanding_amount` decimal(18,2) DEFAULT NULL,
  `interest_rate` decimal(5,2) DEFAULT NULL,
  `tenure_months` int(11) DEFAULT NULL,
  `emi_amount` decimal(18,2) DEFAULT NULL,
  `disbursement_date` date DEFAULT NULL,
  `maturity_date` date DEFAULT NULL,
  `loan_status` enum('Active','Closed','NPA','WrittenOff') DEFAULT NULL,
  `borrower_name` varchar(200) DEFAULT NULL,
  `facility_type` varchar(100) DEFAULT NULL,
  `credit_rating` varchar(20) DEFAULT NULL,
  `country` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`loan_id`),
  UNIQUE KEY `loan_number` (`loan_number`),
  KEY `tenant_id` (`tenant_id`),
  KEY `application_id` (`application_id`),
  KEY `customer_id` (`customer_id`),
  KEY `account_id` (`account_id`),
  CONSTRAINT `fintech_loan_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`),
  CONSTRAINT `fintech_loan_ibfk_2` FOREIGN KEY (`application_id`) REFERENCES `fintech_loan_application` (`application_id`),
  CONSTRAINT `fintech_loan_ibfk_3` FOREIGN KEY (`customer_id`) REFERENCES `fintech_customer` (`customer_id`),
  CONSTRAINT `fintech_loan_ibfk_4` FOREIGN KEY (`account_id`) REFERENCES `fintech_account` (`account_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_loan: ~6 rows (approximately)
INSERT INTO `fintech_loan` (`loan_id`, `tenant_id`, `application_id`, `loan_number`, `customer_id`, `account_id`, `sanctioned_amount`, `disbursed_amount`, `outstanding_amount`, `interest_rate`, `tenure_months`, `emi_amount`, `disbursement_date`, `maturity_date`, `loan_status`, `borrower_name`, `facility_type`, `credit_rating`, `country`) VALUES
	(1, 1, NULL, 'LN-48291', 1, 1, 120.00, 105.00, 105000000.00, 6.45, 60, 2345000.00, NULL, '2029-06-30', 'Active', 'Meridian Logistics Corp', 'Syndicated Term Loan', 'A+', '🇺🇸'),
	(2, 1, NULL, 'LN-48292', 2, 2, 85000000.00, 60000000.00, 60000000.00, 5.80, 48, 1968000.00, NULL, '2028-09-15', 'Active', 'Nordic Renewable Energy AG', 'Green Infrastructure Facility', 'AA', '🇩🇪'),
	(3, 1, NULL, 'LN-48293', 3, 3, 45000000.00, 45000000.00, 45000000.00, 7.20, 36, 1394000.00, NULL, '2027-04-30', 'Active', 'Vertex BioPharma UK', 'Revolving Credit Facility', 'BBB+', '🇬🇧'),
	(4, 1, NULL, 'LN-48294', 4, 4, 30000000.00, 15000000.00, 15000000.00, 8.10, 24, 1358000.00, NULL, '2026-11-30', 'Active', 'Pacific Shipping Lines', 'Trade Finance Line', 'BBB', '🇸🇬'),
	(5, 1, NULL, 'LN-40005', 1, 1, 0.00, 0.00, 0.00, 5.85, NULL, NULL, NULL, NULL, 'Active', 'Apex Aerospace Technologies', 'Syndicated Facility', 'AA', '🇺🇸'),
	(6, 1, NULL, 'LN-40006', 1, 1, 75000000.00, 75000000.00, 75000000.00, 4.50, NULL, NULL, NULL, NULL, 'Active', 'Nordic Energy Systems', 'Green Energy Facility', 'AAA', '🌐');

-- Dumping structure for table httpscoo_deverp.fintech_loan_application
CREATE TABLE IF NOT EXISTS `fintech_loan_application` (
  `application_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `customer_id` bigint(20) DEFAULT NULL,
  `loan_product_id` bigint(20) DEFAULT NULL,
  `requested_amount` decimal(18,2) DEFAULT NULL,
  `tenure_months` int(11) DEFAULT NULL,
  `purpose` varchar(500) DEFAULT NULL,
  `application_date` date DEFAULT NULL,
  `application_status` enum('Draft','Submitted','UnderReview','Approved','Rejected','Disbursed') DEFAULT 'Draft',
  `assigned_to` bigint(20) DEFAULT NULL,
  `remarks` text DEFAULT NULL,
  `borrower_name` varchar(200) DEFAULT NULL,
  `facility_type` varchar(100) DEFAULT NULL,
  `credit_rating` varchar(20) DEFAULT NULL,
  `country` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`application_id`),
  KEY `tenant_id` (`tenant_id`),
  KEY `customer_id` (`customer_id`),
  KEY `loan_product_id` (`loan_product_id`),
  KEY `assigned_to` (`assigned_to`),
  CONSTRAINT `fintech_loan_application_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`),
  CONSTRAINT `fintech_loan_application_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `fintech_customer` (`customer_id`),
  CONSTRAINT `fintech_loan_application_ibfk_3` FOREIGN KEY (`loan_product_id`) REFERENCES `fintech_loan_product` (`loan_product_id`),
  CONSTRAINT `fintech_loan_application_ibfk_4` FOREIGN KEY (`assigned_to`) REFERENCES `fintech_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_loan_application: ~3 rows (approximately)
INSERT INTO `fintech_loan_application` (`application_id`, `tenant_id`, `customer_id`, `loan_product_id`, `requested_amount`, `tenure_months`, `purpose`, `application_date`, `application_status`, `assigned_to`, `remarks`, `borrower_name`, `facility_type`, `credit_rating`, `country`) VALUES
	(1, 1, 1, NULL, 500000.00, 36, 'Home renovation', NULL, 'UnderReview', NULL, NULL, 'Aditya Kumar', 'Personal Loan', NULL, NULL),
	(2, 1, 1, NULL, 2500000.00, 60, 'Working capital expansion', NULL, 'UnderReview', NULL, NULL, 'Priya Sharma', 'Business Loan', NULL, NULL),
	(3, 5, 1, NULL, 500000.00, 36, 'Corporate Facility Application', '2026-09-05', 'UnderReview', NULL, NULL, 'Institutional Applicant', 'Term Facility', 'BBB', '🌐');

-- Dumping structure for table httpscoo_deverp.fintech_loan_attachment
CREATE TABLE IF NOT EXISTS `fintech_loan_attachment` (
  `attachment_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) NOT NULL DEFAULT 1,
  `application_id` bigint(20) NOT NULL,
  `customer_id` bigint(20) NOT NULL DEFAULT 1,
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_type` varchar(50) NOT NULL,
  `file_size_kb` decimal(10,2) DEFAULT NULL,
  `file_hash` varchar(64) DEFAULT NULL,
  `uploaded_at` datetime NOT NULL DEFAULT current_timestamp(),
  `ai_verdict` enum('Genuine','Suspicious','Fraudulent') DEFAULT NULL,
  `ai_confidence` decimal(5,2) DEFAULT NULL,
  `document_type` varchar(100) DEFAULT NULL,
  `extracted_data` text DEFAULT NULL,
  `fraud_indicators` text DEFAULT NULL,
  `eligibility_status` enum('Eligible','NotEligible','NeedsChanges') DEFAULT NULL,
  `max_eligible_amount` decimal(18,2) DEFAULT NULL,
  `required_changes` text DEFAULT NULL,
  `ai_reasoning` text DEFAULT NULL,
  `ai_model_used` varchar(100) DEFAULT NULL,
  `reviewed_by_human` enum('Pending','Reviewed') NOT NULL DEFAULT 'Pending',
  `analyzed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`attachment_id`),
  KEY `idx_fla_application` (`application_id`),
  KEY `idx_fla_tenant` (`tenant_id`),
  KEY `idx_fla_uploaded_at` (`uploaded_at`),
  CONSTRAINT `fk_fla_application` FOREIGN KEY (`application_id`) REFERENCES `fintech_loan_application` (`application_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table httpscoo_deverp.fintech_loan_attachment: ~9 rows (approximately)
INSERT INTO `fintech_loan_attachment` (`attachment_id`, `tenant_id`, `application_id`, `customer_id`, `file_name`, `file_path`, `file_type`, `file_size_kb`, `file_hash`, `uploaded_at`, `ai_verdict`, `ai_confidence`, `document_type`, `extracted_data`, `fraud_indicators`, `eligibility_status`, `max_eligible_amount`, `required_changes`, `ai_reasoning`, `ai_model_used`, `reviewed_by_human`, `analyzed_at`) VALUES
	(1, 1, 2, 1, 'AI Report Film industry.pdf', 'E:\\SaaS Fintech App Design\\backend\\storage\\loan_docs\\b51293acf6de41018b95d4aa674d8864.pdf', 'pdf', 1055.84, 'a29e0d3dbca8046f051ff25258da7743bb14e48db00f83aed717378d9a088e84', '2026-09-04 20:07:43', 'Fraudulent', 98.00, 'Unknown', '{"monthly_income": "N/A", "employer": "N/A", "account_balance": "N/A"}', '["Document is a student academic project (BBA-CA) unrelated to financial standing", "Name on document (Richa Darekar) does not match borrower name (Priya Sharma)", "No financial data, income proof, or business records present", "Content is a theoretical essay on AI in Film Industry, not a financial statement"]', 'NotEligible', 0.00, '["Submit valid financial documents such as audited financial statements, bank statements, or tax returns for the business entity", "Ensure all submitted documents bear the name of the borrower or authorized signatory"]', 'The submitted document is a student academic project titled \'AI used in Film Industry\' by a different individual (Richa Darekar) and contains no financial information. It is completely irrelevant to a business loan application and provides no evidence of income or creditworthiness. The document is fraudulent in the context of this loan application due to identity mismatch and lack of relevant content.', 'qwen/qwen3.8-27b', 'Pending', '2026-09-04 20:07:43'),
	(2, 1, 2, 1, 'bank_loan_request_document_checklist_india.pdf', 'E:\\SaaS Fintech App Design\\backend\\storage\\loan_docs\\aa9516fe50f34dc493443d356865b7fa.pdf', 'pdf', 34.17, '6555bdc9dfb3d0c9df2a0197206e3bd2de9f43e5bd650c0d75e8278a0eb662fa', '2026-09-04 20:11:40', 'Genuine', 95.00, 'Unknown', '{"monthly_income": "Not provided", "employer": "Not provided", "account_balance": "Not provided"}', '[]', 'NotEligible', 0.00, '["Submit valid KYC documents (Aadhaar/PAN) for Priya Sharma", "Provide recent bank statements (6 months) to verify income and cash flow", "Submit Income Tax Returns and financial statements for the business", "Provide business registration documents (GST, Certificate of Incorporation, etc.)", "Submit a detailed business plan or project report justifying the $2.5M request", "Provide collateral valuation reports if security is offered"]', 'The submitted document is a generic \'Bank Loan Request Document Checklist\' template, not an actual financial or identity document. It contains no specific data regarding the borrower\'s income, assets, or identity, making it impossible to assess creditworthiness or verify the applicant\'s identity. The application is incomplete and cannot be processed without the actual supporting documents listed in the guide.', 'qwen/qwen3.8-27b', 'Pending', '2026-09-04 20:11:40'),
	(3, 1, 2, 1, 'bank_loan_request_sample_filled.pdf', 'E:\\SaaS Fintech App Design\\backend\\storage\\loan_docs\\a0c36618c03e4099ac77826c124a949a.pdf', 'pdf', 28.02, 'eeddc8d19496d38144babfd69be6538bed7b8d053ef02da81ac69e4c3110b3fb', '2026-09-04 20:14:20', 'Fraudulent', 98.00, 'Loan Application Form', '{"monthly_income": "n75,000", "employer": "ABC Technologies Private Limited", "account_balance": "n2,50,000"}', '["Document explicitly states \'SAMPLE FILLED DETAILS\' and \'illustrative sample values\'", "Document contains a disclaimer: \'Do not use the sample employer, income, balance, EMI or credit-history figures as your real financial information\'", "Currency symbols are corrupted/incorrect (using \'n\' instead of \'\\u20b9\' or \'$\')", "Requested amount in document ($500,000) does not match the loan application context ($2,500,000)", "Applicant name \'Priya Sharma\' is missing from the document fields"]', 'NotEligible', 0.00, '["Submit a genuine, non-sample loan application form with accurate personal and financial details", "Provide valid supporting documents (salary slips, bank statements, tax returns) that match the actual applicant\'s identity and financials", "Correct the currency formatting and ensure all figures are in the correct currency"]', 'The submitted document is explicitly labeled as a sample template with placeholder data and a warning against using it for real applications. It does not contain the applicant\'s actual financial information, making it unusable for credit assessment. The document is fraudulent in the context of a real loan application because it is a generic template rather than a verified submission.', 'qwen/qwen3.8-27b', 'Pending', '2026-09-04 20:14:20'),
	(4, 1, 1, 1, 'salary_slip_march.png', 'E:\\SaaS Fintech App Design\\backend\\storage\\loan_docs\\c797cc2b04a042329f01fc88e0247fd1.png', 'png', 0.21, '10d9d01adc2b7368f4f899e141f8ac245704006300e28e3ab11d1e9a41e64e68', '2026-09-04 20:24:15', 'Fraudulent', 100.00, 'Unknown', '{"monthly_income": "Not visible", "employer": "Not visible", "account_balance": "Not visible"}', '["The submitted document is completely blank and contains no visible text, figures, or identifying information.", "Missing all standard elements required for a salary slip (employer name, employee name, pay period, gross/net pay)."]', 'NotEligible', 0.00, '["Submit a legible, complete copy of the salary slip or bank statement to verify income."]', 'The provided document is a blank white image with no visible content. It is impossible to verify the identity of the borrower, the employer, or the income level from this file. The application cannot be processed until a valid document is provided.', 'qwen/qwen3.8-27b', 'Pending', '2026-09-04 20:24:15'),
	(5, 1, 2, 1, 'bank_loan_request_sample_filled.pdf', 'E:\\SaaS Fintech App Design\\backend\\storage\\loan_docs\\8103f29d349e47c79980c17c592ffadf.pdf', 'pdf', 28.02, 'eeddc8d19496d38144babfd69be6538bed7b8d053ef02da81ac69e4c3110b3fb', '2026-09-04 20:26:29', 'Fraudulent', 98.00, 'Loan Application Form', '{"monthly_income": "75,000 (Sample)", "employer": "ABC Technologies Private Limited (Sample)", "account_balance": "2,50,000 (Sample)"}', '["Document explicitly states \'SAMPLE FILLED DETAILS\' and \'illustrative sample values\'", "Contains explicit warning: \'Do not use the sample employer, income, balance, EMI or credit-history figures as your real financial information\'", "Currency symbols are corrupted (displayed as \'n\' instead of \'\\u20b9\' or \'$\')", "Requested amount in document ($500,000) does not match the loan application context ($2,500,000)", "Applicant name \'Priya Sharma\' is missing from the document, which lists generic \'Applicant\' fields"]', 'NotEligible', 0.00, '["Submit a genuine, non-sample loan application form with the applicant\'s actual name", "Provide verified salary slips, bank statements, and tax documents that match the actual financial profile", "Correct the requested loan amount to match the actual business loan requirement"]', 'The submitted document is explicitly labeled as a sample template containing illustrative data and warnings against using it for real applications. It does not contain the applicant\'s actual name or verified financial information, making it invalid for underwriting. The discrepancy between the sample figures and the requested $2.5M business loan further confirms this is not a legitimate application document.', 'qwen/qwen3.8-27b', 'Pending', '2026-09-04 20:26:29'),
	(6, 1, 2, 1, 'honest_bank_loan_application_template.pdf', 'E:\\SaaS Fintech App Design\\backend\\storage\\loan_docs\\c28a58d2361e4f4b919be989fd460e3a.pdf', 'pdf', 31.01, '81120538af089d9107f4918fe07cee2fca69e1601f9fefe42d55223c41559b86', '2026-09-04 20:40:33', 'Suspicious', 60.00, 'Unknown', '{"monthly_income": "n", "employer": "n", "account_balance": "n"}', '["Incomplete fields with placeholders", "Lack of specific applicant information"]', 'NeedsChanges', 0.00, '["Provide actual applicant information in all fields", "Submit supporting documents as indicated"]', 'The document contains many placeholders instead of actual information, which raises concerns about its authenticity. To proceed, the applicant must fill in the required details and provide supporting documents.', 'openai/gpt-4o-mini', 'Pending', '2026-09-04 20:40:33'),
	(7, 1, 2, 1, 'bank_loan_request_sample_filled.pdf', 'E:\\SaaS Fintech App Design\\backend\\storage\\loan_docs\\92f5438ac01644eb81a547092cfa6dca.pdf', 'pdf', 28.02, 'eeddc8d19496d38144babfd69be6538bed7b8d053ef02da81ac69e4c3110b3fb', '2026-09-04 20:42:08', 'Suspicious', 60.00, 'Unknown', '{"monthly_income": "n75,000", "employer": "ABC Technologies Private Limited", "account_balance": "n2,50,000"}', '["Sample values used instead of actual figures", "Inconsistent loan amount requested compared to the context"]', 'NeedsChanges', 0.00, '["Replace sample values with actual verified information", "Ensure requested loan amount matches the application context"]', 'The document contains sample values rather than actual financial information, which raises concerns about its authenticity. The requested loan amount also does not align with the context provided, indicating that the applicant needs to submit accurate and verifiable details.', 'openai/gpt-4o-mini', 'Pending', '2026-09-04 20:42:08'),
	(8, 5, 3, 1, 'bank_loan_request_document_checklist_india.pdf', 'E:\\SaaS Fintech App Design\\backend\\storage\\loan_docs\\77059feb79b14dacb3085bea92923e43.pdf', 'pdf', 34.17, '6555bdc9dfb3d0c9df2a0197206e3bd2de9f43e5bd650c0d75e8278a0eb662fa', '2026-09-05 12:54:59', 'Genuine', 90.00, 'Unknown', '{"monthly_income": "Not specified", "employer": "Not specified", "account_balance": "Not specified"}', '[]', 'NeedsChanges', 0.00, '["Complete the loan amount requested section", "Provide specific purpose of the loan", "Include monthly income and employer details"]', 'The document is a checklist for preparing a loan application and does not contain specific financial information. The requested loan amount is noted, but key details such as the purpose of the loan and income information are missing, which are necessary for eligibility assessment.', 'openai/gpt-4o-mini', 'Pending', '2026-09-05 12:54:59'),
	(9, 5, 3, 1, 'honest_bank_loan_application_template.pdf', 'E:\\SaaS Fintech App Design\\backend\\storage\\loan_docs\\5f88b0570ea0435e99760a2d23190d07.pdf', 'pdf', 31.01, '81120538af089d9107f4918fe07cee2fca69e1601f9fefe42d55223c41559b86', '2026-09-05 12:55:53', 'Suspicious', 60.00, 'Unknown', '{"monthly_income": "Not filled", "employer": "Not specified", "account_balance": "Not filled"}', '["All financial fields are unfilled, raising concerns about the applicant\'s financial situation."]', 'NeedsChanges', 0.00, '["Provide actual income figures and financial details to support the loan application."]', 'The document lacks critical financial information, such as monthly income and account balance, which are essential for assessing eligibility. Without these details, the application cannot be properly evaluated.', 'openai/gpt-4o-mini', 'Pending', '2026-09-05 12:55:53');

-- Dumping structure for table httpscoo_deverp.fintech_loan_document
CREATE TABLE IF NOT EXISTS `fintech_loan_document` (
  `document_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `application_id` bigint(20) DEFAULT NULL,
  `document_type` varchar(100) DEFAULT NULL,
  `file_name` varchar(250) DEFAULT NULL,
  `blob_url` varchar(500) DEFAULT NULL,
  `verified` tinyint(1) DEFAULT 0,
  `uploaded_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`document_id`),
  KEY `application_id` (`application_id`),
  CONSTRAINT `fintech_loan_document_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `fintech_loan_application` (`application_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_loan_document: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_loan_payment
CREATE TABLE IF NOT EXISTS `fintech_loan_payment` (
  `payment_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) DEFAULT NULL,
  `emi_id` bigint(20) DEFAULT NULL,
  `payment_mode` enum('UPI','NEFT','IMPS','Cash','Cheque','AutoDebit') DEFAULT NULL,
  `payment_amount` decimal(18,2) DEFAULT NULL,
  `principal_paid` decimal(18,2) DEFAULT NULL,
  `interest_paid` decimal(18,2) DEFAULT NULL,
  `penalty_paid` decimal(18,2) DEFAULT NULL,
  `payment_date` datetime DEFAULT NULL,
  `reference_number` varchar(100) DEFAULT NULL,
  `status` enum('Success','Pending','Failed') DEFAULT NULL,
  PRIMARY KEY (`payment_id`),
  KEY `loan_id` (`loan_id`),
  KEY `emi_id` (`emi_id`),
  CONSTRAINT `fintech_loan_payment_ibfk_1` FOREIGN KEY (`loan_id`) REFERENCES `fintech_loan` (`loan_id`),
  CONSTRAINT `fintech_loan_payment_ibfk_2` FOREIGN KEY (`emi_id`) REFERENCES `fintech_emi_schedule` (`emi_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_loan_payment: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_loan_product
CREATE TABLE IF NOT EXISTS `fintech_loan_product` (
  `loan_product_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) NOT NULL,
  `product_code` varchar(30) DEFAULT NULL,
  `product_name` varchar(100) DEFAULT NULL,
  `loan_category` enum('Home','Personal','Vehicle','Education','Business','Gold','Mortgage') DEFAULT NULL,
  `minimum_amount` decimal(18,2) DEFAULT NULL,
  `maximum_amount` decimal(18,2) DEFAULT NULL,
  `minimum_tenure` int(11) DEFAULT NULL,
  `maximum_tenure` int(11) DEFAULT NULL,
  `interest_rate` decimal(5,2) DEFAULT NULL,
  `processing_fee` decimal(5,2) DEFAULT NULL,
  `penalty_rate` decimal(5,2) DEFAULT NULL,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`loan_product_id`),
  UNIQUE KEY `product_code` (`product_code`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `fintech_loan_product_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`)

) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_loan_product: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_loan_transaction
CREATE TABLE IF NOT EXISTS `fintech_loan_transaction` (
  `transaction_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `loan_id` bigint(20) DEFAULT NULL,
  `transaction_type` enum('Disbursement','EMI','Interest','Penalty','Foreclosure','Adjustment') DEFAULT NULL,
  `transaction_amount` decimal(18,2) DEFAULT NULL,
  `transaction_date` datetime DEFAULT NULL,
  `reference_number` varchar(100) DEFAULT NULL,
  `narration` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`transaction_id`),
  KEY `loan_id` (`loan_id`),
  CONSTRAINT `fintech_loan_transaction_ibfk_1` FOREIGN KEY (`loan_id`) REFERENCES `fintech_loan` (`loan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_loan_transaction: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_merchant
CREATE TABLE IF NOT EXISTS `fintech_merchant` (
  `merchant_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `merchant_code` varchar(50) DEFAULT NULL,
  `merchant_name` varchar(200) DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `gst_number` varchar(30) DEFAULT NULL,
  `bank_account` varchar(50) DEFAULT NULL,
  `ifsc_code` varchar(20) DEFAULT NULL,
  `settlement_cycle` enum('T0','T1','T2') DEFAULT NULL,
  `status` enum('Active','Inactive') DEFAULT NULL,
  PRIMARY KEY (`merchant_id`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `fintech_merchant_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_merchant: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_mobile_device
CREATE TABLE IF NOT EXISTS `fintech_mobile_device` (
  `device_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `customer_id` bigint(20) DEFAULT NULL,
  `device_uuid` varchar(200) DEFAULT NULL,
  `device_name` varchar(100) DEFAULT NULL,
  `device_type` varchar(50) DEFAULT NULL,
  `os_name` varchar(50) DEFAULT NULL,
  `os_version` varchar(50) DEFAULT NULL,
  `app_version` varchar(50) DEFAULT NULL,
  `push_token` varchar(500) DEFAULT NULL,
  `trusted_device` tinyint(1) DEFAULT 0,
  `last_login` datetime DEFAULT NULL,
  PRIMARY KEY (`device_id`),
  KEY `tenant_id` (`tenant_id`),
  KEY `customer_id` (`customer_id`),
  CONSTRAINT `fintech_mobile_device_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`),
  CONSTRAINT `fintech_mobile_device_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `fintech_customer` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_mobile_device: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_notification
CREATE TABLE IF NOT EXISTS `fintech_notification` (
  `notification_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `notification_type` enum('Email','SMS','Push','WhatsApp') DEFAULT NULL,
  `subject` varchar(300) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `status` enum('Pending','Sent','Failed') DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`notification_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `fintech_notification_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `fintech_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_notification: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_organization
CREATE TABLE IF NOT EXISTS `fintech_organization` (
  `organization_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) NOT NULL,
  `organization_code` varchar(50) DEFAULT NULL,
  `organization_name` varchar(200) DEFAULT NULL,
  `gst_number` varchar(30) DEFAULT NULL,
  `pan_number` varchar(30) DEFAULT NULL,
  `cin_number` varchar(30) DEFAULT NULL,
  `address1` varchar(200) DEFAULT NULL,
  `address2` varchar(200) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `state` varchar(100) DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `pincode` varchar(20) DEFAULT NULL,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`organization_id`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `fintech_organization_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_organization: ~4 rows (approximately)
INSERT INTO `fintech_organization` (`organization_id`, `tenant_id`, `organization_code`, `organization_name`, `gst_number`, `pan_number`, `cin_number`, `address1`, `address2`, `city`, `state`, `country`, `pincode`, `status`, `created_date`) VALUES
	(1, 1, 'GB-CORP', 'GlobalBank Institutional Banking', NULL, NULL, NULL, NULL, NULL, 'Singapore', NULL, 'Singapore', NULL, 'Active', '2026-09-04 14:15:43'),
	(2, 2, 'SB-CORP', 'Shantanu Bank', NULL, NULL, NULL, NULL, NULL, 'Pune', NULL, 'India', NULL, 'Active', '2026-09-04 19:57:45'),
	(3, 3, 'YB-CORP', 'Yash Bank', NULL, NULL, NULL, NULL, NULL, 'USA', NULL, NULL, NULL, 'Active', '2026-09-04 20:03:20'),
	(4, 5, 'JPM-US', 'JPMorgan Chase HQ', NULL, NULL, NULL, NULL, NULL, 'New York', NULL, 'United States', NULL, 'Active', '2026-09-05 03:58:48');

-- Dumping structure for table httpscoo_deverp.fintech_payment_beneficiary
CREATE TABLE IF NOT EXISTS `fintech_payment_beneficiary` (
  `beneficiary_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `customer_id` bigint(20) DEFAULT NULL,
  `beneficiary_name` varchar(200) DEFAULT NULL,
  `account_number` varchar(50) DEFAULT NULL,
  `ifsc_code` varchar(20) DEFAULT NULL,
  `upi_handle` varchar(100) DEFAULT NULL,
  `mobile` varchar(20) DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`beneficiary_id`),
  KEY `customer_id` (`customer_id`),
  CONSTRAINT `fintech_payment_beneficiary_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `fintech_customer` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_payment_beneficiary: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_payment_order
CREATE TABLE IF NOT EXISTS `fintech_payment_order` (
  `payment_order_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `customer_id` bigint(20) DEFAULT NULL,
  `wallet_id` bigint(20) DEFAULT NULL,
  `account_id` bigint(20) DEFAULT NULL,
  `payment_reference` varchar(100) DEFAULT NULL,
  `payment_channel` enum('UPI','Wallet','Card','NetBanking','IMPS','NEFT','RTGS') DEFAULT NULL,
  `payment_type` enum('P2P','P2M','Bill','Recharge') DEFAULT NULL,
  `amount` decimal(18,2) DEFAULT NULL,
  `currency` varchar(10) DEFAULT NULL,
  `payment_status` enum('Pending','Processing','Success','Failed','Refunded') DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  `sender_name` varchar(200) DEFAULT NULL,
  `receiver_name` varchar(200) DEFAULT NULL,
  `bic_code` varchar(30) DEFAULT NULL,
  `compliance_status` enum('clear','screening','aml-flag') DEFAULT 'clear',
  `priority` enum('normal','same-day','urgent','instant') DEFAULT 'normal',
  `rail_type` varchar(50) DEFAULT 'SWIFT MT103',
  PRIMARY KEY (`payment_order_id`),
  UNIQUE KEY `payment_reference` (`payment_reference`),
  KEY `customer_id` (`customer_id`),
  KEY `wallet_id` (`wallet_id`),
  KEY `account_id` (`account_id`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `fintech_payment_order_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `fintech_customer` (`customer_id`),
  CONSTRAINT `fintech_payment_order_ibfk_2` FOREIGN KEY (`wallet_id`) REFERENCES `fintech_wallet` (`wallet_id`),
  CONSTRAINT `fintech_payment_order_ibfk_3` FOREIGN KEY (`account_id`) REFERENCES `fintech_account` (`account_id`),
  CONSTRAINT `fintech_payment_order_ibfk_4` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_payment_order: ~6 rows (approximately)
INSERT INTO `fintech_payment_order` (`payment_order_id`, `tenant_id`, `customer_id`, `wallet_id`, `account_id`, `payment_reference`, `payment_channel`, `payment_type`, `amount`, `currency`, `payment_status`, `created_date`, `sender_name`, `receiver_name`, `bic_code`, `compliance_status`, `priority`, `rail_type`) VALUES
	(1, 1, 1, NULL, 1, 'PMT-882194', 'RTGS', 'P2M', 28500000.00, 'USD', 'Success', '2026-09-04 14:15:47', 'Citadel Treasury Corp', 'Barclays Prime Settlement', 'BARCGB22', 'clear', 'same-day', 'SWIFT MT103'),
	(2, 1, 2, NULL, 2, 'PMT-882195', 'RTGS', 'P2M', 14200000.00, 'EUR', 'Processing', '2026-09-04 14:15:47', 'BASF SE Frankfurt', 'Siemens Energy AG', 'DEUTDEDB', 'clear', 'urgent', 'SEPA Credit Transfer'),
	(3, 1, 3, NULL, 3, 'PMT-882196', 'RTGS', 'P2M', 8900000.00, 'GBP', 'Pending', '2026-09-04 14:15:47', 'Anglo American PLC', 'Glencore International', 'LOYDGB2L', 'screening', 'same-day', 'CHAPS'),
	(4, 1, 5, NULL, 5, 'PMT-882197', 'RTGS', 'P2M', 52000000.00, 'USD', 'Pending', '2026-09-04 14:15:47', 'PetroChina Singapore', 'Aramco Trading Ltd', 'SCBLSG22', 'aml-flag', 'urgent', 'SWIFT MT202'),
	(5, 1, 1, NULL, 1, 'PMT-100005', 'RTGS', 'P2M', 500000.00, 'USD', 'Processing', '2026-09-04 16:12:13', 'Global Treasury Operating', 'BNP Paribas Paris', 'BNPAFRPP', 'clear', 'urgent', 'SWIFT MT103'),
	(6, 1, 1, NULL, 1, 'PMT-100006', 'RTGS', 'P2M', 18500000.00, 'USD', 'Processing', '2026-09-04 16:16:15', 'Nordic Treasury', 'HSBC London', 'MIDLGB22', 'clear', 'normal', 'SWIFT MT103');

-- Dumping structure for table httpscoo_deverp.fintech_payment_provider
CREATE TABLE IF NOT EXISTS `fintech_payment_provider` (
  `provider_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `provider_code` varchar(30) DEFAULT NULL,
  `provider_name` varchar(100) DEFAULT NULL,
  `provider_type` enum('UPI','Wallet','Gateway','Card','Bank') DEFAULT NULL,
  `api_url` varchar(500) DEFAULT NULL,
  `api_key` varchar(500) DEFAULT NULL,
  `api_secret` varchar(500) DEFAULT NULL,
  `webhook_url` varchar(500) DEFAULT NULL,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`provider_id`),
  UNIQUE KEY `provider_code` (`provider_code`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `fintech_payment_provider_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_payment_provider: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_payment_transaction
CREATE TABLE IF NOT EXISTS `fintech_payment_transaction` (
  `payment_transaction_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `payment_order_id` bigint(20) DEFAULT NULL,
  `provider_id` bigint(20) DEFAULT NULL,
  `gateway_transaction_id` varchar(100) DEFAULT NULL,
  `bank_reference` varchar(100) DEFAULT NULL,
  `authorization_code` varchar(100) DEFAULT NULL,
  `transaction_amount` decimal(18,2) DEFAULT NULL,
  `transaction_fee` decimal(18,2) DEFAULT NULL,
  `gst_amount` decimal(18,2) DEFAULT NULL,
  `transaction_date` datetime DEFAULT NULL,
  `status` enum('Success','Pending','Failed','Reversed') DEFAULT NULL,
  PRIMARY KEY (`payment_transaction_id`),
  KEY `payment_order_id` (`payment_order_id`),
  KEY `provider_id` (`provider_id`),
  CONSTRAINT `fintech_payment_transaction_ibfk_1` FOREIGN KEY (`payment_order_id`) REFERENCES `fintech_payment_order` (`payment_order_id`),
  CONSTRAINT `fintech_payment_transaction_ibfk_2` FOREIGN KEY (`provider_id`) REFERENCES `fintech_payment_provider` (`provider_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_payment_transaction: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_permission
CREATE TABLE IF NOT EXISTS `fintech_permission` (
  `permission_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `permission_name` varchar(200) DEFAULT NULL,
  `module_name` varchar(100) DEFAULT NULL,
  `api_name` varchar(200) DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`permission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_permission: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_policy
CREATE TABLE IF NOT EXISTS `fintech_policy` (
  `policy_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `customer_id` bigint(20) DEFAULT NULL,
  `insurance_product_id` bigint(20) DEFAULT NULL,
  `agent_id` bigint(20) DEFAULT NULL,
  `policy_number` varchar(50) DEFAULT NULL,
  `proposal_number` varchar(50) DEFAULT NULL,
  `policy_start_date` date DEFAULT NULL,
  `policy_end_date` date DEFAULT NULL,
  `sum_assured` decimal(18,2) DEFAULT NULL,
  `premium_amount` decimal(18,2) DEFAULT NULL,
  `premium_frequency` enum('Monthly','Quarterly','HalfYearly','Yearly') DEFAULT NULL,
  `nominee_name` varchar(200) DEFAULT NULL,
  `nominee_relationship` varchar(100) DEFAULT NULL,
  `status` enum('Proposal','Active','Expired','Lapsed','Cancelled','Claimed') DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`policy_id`),
  UNIQUE KEY `policy_number` (`policy_number`),
  KEY `customer_id` (`customer_id`),
  KEY `insurance_product_id` (`insurance_product_id`),
  KEY `agent_id` (`agent_id`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `fintech_policy_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `fintech_customer` (`customer_id`),
  CONSTRAINT `fintech_policy_ibfk_2` FOREIGN KEY (`insurance_product_id`) REFERENCES `fintech_insurance_product` (`insurance_product_id`),
  CONSTRAINT `fintech_policy_ibfk_3` FOREIGN KEY (`agent_id`) REFERENCES `fintech_insurance_agent` (`agent_id`),
  CONSTRAINT `fintech_policy_ibfk_4` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_policy: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_policy_beneficiary
CREATE TABLE IF NOT EXISTS `fintech_policy_beneficiary` (
  `beneficiary_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `policy_id` bigint(20) DEFAULT NULL,
  `beneficiary_name` varchar(200) DEFAULT NULL,
  `relationship` varchar(100) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `percentage_share` decimal(5,2) DEFAULT NULL,
  `mobile` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`beneficiary_id`),
  KEY `policy_id` (`policy_id`),
  CONSTRAINT `fintech_policy_beneficiary_ibfk_1` FOREIGN KEY (`policy_id`) REFERENCES `fintech_policy` (`policy_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_policy_beneficiary: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_policy_document
CREATE TABLE IF NOT EXISTS `fintech_policy_document` (
  `document_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `policy_id` bigint(20) DEFAULT NULL,
  `document_type` varchar(100) DEFAULT NULL,
  `blob_url` varchar(500) DEFAULT NULL,
  `uploaded_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`document_id`),
  KEY `policy_id` (`policy_id`),
  CONSTRAINT `fintech_policy_document_ibfk_1` FOREIGN KEY (`policy_id`) REFERENCES `fintech_policy` (`policy_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_policy_document: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_policy_renewal
CREATE TABLE IF NOT EXISTS `fintech_policy_renewal` (
  `renewal_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `policy_id` bigint(20) DEFAULT NULL,
  `renewal_date` date DEFAULT NULL,
  `premium_amount` decimal(18,2) DEFAULT NULL,
  `renewed_until` date DEFAULT NULL,
  `renewal_status` enum('Pending','Completed','Failed') DEFAULT NULL,
  PRIMARY KEY (`renewal_id`),
  KEY `policy_id` (`policy_id`),
  CONSTRAINT `fintech_policy_renewal_ibfk_1` FOREIGN KEY (`policy_id`) REFERENCES `fintech_policy` (`policy_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_policy_renewal: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_portfolio
CREATE TABLE IF NOT EXISTS `fintech_portfolio` (
  `portfolio_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `investment_account_id` bigint(20) DEFAULT NULL,
  `portfolio_code` varchar(30) DEFAULT NULL,
  `portfolio_name` varchar(200) DEFAULT NULL,
  `investment_goal` enum('Retirement','Education','WealthCreation','TaxSaving','EmergencyFund') DEFAULT NULL,
  `total_investment` decimal(18,2) DEFAULT NULL,
  `current_market_value` decimal(18,2) DEFAULT NULL,
  `unrealized_gain` decimal(18,2) DEFAULT NULL,
  `realized_gain` decimal(18,2) DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`portfolio_id`),
  KEY `investment_account_id` (`investment_account_id`),
  CONSTRAINT `fintech_portfolio_ibfk_1` FOREIGN KEY (`investment_account_id`) REFERENCES `fintech_investment_account` (`investment_account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_portfolio: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_portfolio_performance
CREATE TABLE IF NOT EXISTS `fintech_portfolio_performance` (
  `performance_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `portfolio_id` bigint(20) DEFAULT NULL,
  `performance_date` date DEFAULT NULL,
  `invested_amount` decimal(18,2) DEFAULT NULL,
  `market_value` decimal(18,2) DEFAULT NULL,
  `xirr` decimal(8,4) DEFAULT NULL,
  `absolute_return` decimal(8,4) DEFAULT NULL,
  `annual_return` decimal(8,4) DEFAULT NULL,
  PRIMARY KEY (`performance_id`),
  KEY `portfolio_id` (`portfolio_id`),
  CONSTRAINT `fintech_portfolio_performance_ibfk_1` FOREIGN KEY (`portfolio_id`) REFERENCES `fintech_portfolio` (`portfolio_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_portfolio_performance: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_premature_closure
CREATE TABLE IF NOT EXISTS `fintech_premature_closure` (
  `closure_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `deposit_account_id` bigint(20) DEFAULT NULL,
  `closure_date` date DEFAULT NULL,
  `principal_paid` decimal(18,2) DEFAULT NULL,
  `interest_paid` decimal(18,2) DEFAULT NULL,
  `penalty_amount` decimal(18,2) DEFAULT NULL,
  `tds_amount` decimal(18,2) DEFAULT NULL,
  `final_amount` decimal(18,2) DEFAULT NULL,
  `approved_by` bigint(20) DEFAULT NULL,
  `remarks` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`closure_id`),
  KEY `deposit_account_id` (`deposit_account_id`),
  KEY `approved_by` (`approved_by`),
  CONSTRAINT `fintech_premature_closure_ibfk_1` FOREIGN KEY (`deposit_account_id`) REFERENCES `fintech_deposit_account` (`deposit_account_id`),
  CONSTRAINT `fintech_premature_closure_ibfk_2` FOREIGN KEY (`approved_by`) REFERENCES `fintech_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_premature_closure: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_premium
CREATE TABLE IF NOT EXISTS `fintech_premium` (
  `premium_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `policy_id` bigint(20) DEFAULT NULL,
  `installment_no` int(11) DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `premium_amount` decimal(18,2) DEFAULT NULL,
  `gst_amount` decimal(18,2) DEFAULT NULL,
  `total_amount` decimal(18,2) DEFAULT NULL,
  `payment_status` enum('Pending','Paid','Overdue') DEFAULT NULL,
  `payment_date` date DEFAULT NULL,
  PRIMARY KEY (`premium_id`),
  KEY `policy_id` (`policy_id`),
  CONSTRAINT `fintech_premium_ibfk_1` FOREIGN KEY (`policy_id`) REFERENCES `fintech_policy` (`policy_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_premium: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_qr_code
CREATE TABLE IF NOT EXISTS `fintech_qr_code` (
  `qr_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `merchant_name` varchar(200) DEFAULT NULL,
  `merchant_upi` varchar(150) DEFAULT NULL,
  `qr_type` enum('Static','Dynamic') DEFAULT NULL,
  `qr_data` text DEFAULT NULL,
  `qr_image_url` varchar(500) DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`qr_id`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `fintech_qr_code_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_qr_code: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_rd_installment
CREATE TABLE IF NOT EXISTS `fintech_rd_installment` (
  `installment_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `rd_id` bigint(20) DEFAULT NULL,
  `installment_number` int(11) DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `payment_date` date DEFAULT NULL,
  `amount` decimal(18,2) DEFAULT NULL,
  `penalty` decimal(18,2) DEFAULT NULL,
  `payment_status` enum('Pending','Paid','Missed') DEFAULT NULL,
  PRIMARY KEY (`installment_id`),
  KEY `rd_id` (`rd_id`),
  CONSTRAINT `fintech_rd_installment_ibfk_1` FOREIGN KEY (`rd_id`) REFERENCES `fintech_recurring_deposit` (`rd_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_rd_installment: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_reconciliation
CREATE TABLE IF NOT EXISTS `fintech_reconciliation` (
  `reconciliation_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `settlement_id` bigint(20) DEFAULT NULL,
  `bank_reference` varchar(100) DEFAULT NULL,
  `transaction_count` int(11) DEFAULT NULL,
  `expected_amount` decimal(18,2) DEFAULT NULL,
  `actual_amount` decimal(18,2) DEFAULT NULL,
  `difference_amount` decimal(18,2) DEFAULT NULL,
  `reconciliation_status` enum('Matched','Mismatch','Pending') DEFAULT NULL,
  `reconciliation_date` datetime DEFAULT NULL,
  PRIMARY KEY (`reconciliation_id`),
  KEY `settlement_id` (`settlement_id`),
  CONSTRAINT `fintech_reconciliation_ibfk_1` FOREIGN KEY (`settlement_id`) REFERENCES `fintech_settlement` (`settlement_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_reconciliation: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_recurring_deposit
CREATE TABLE IF NOT EXISTS `fintech_recurring_deposit` (
  `rd_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `deposit_account_id` bigint(20) DEFAULT NULL,
  `monthly_installment` decimal(18,2) DEFAULT NULL,
  `installment_day` int(11) DEFAULT NULL,
  `total_installments` int(11) DEFAULT NULL,
  `paid_installments` int(11) DEFAULT 0,
  `missed_installments` int(11) DEFAULT 0,
  `next_due_date` date DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`rd_id`),
  KEY `deposit_account_id` (`deposit_account_id`),
  CONSTRAINT `fintech_recurring_deposit_ibfk_1` FOREIGN KEY (`deposit_account_id`) REFERENCES `fintech_deposit_account` (`deposit_account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_recurring_deposit: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_refund
CREATE TABLE IF NOT EXISTS `fintech_refund` (
  `refund_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `payment_transaction_id` bigint(20) DEFAULT NULL,
  `refund_reference` varchar(100) DEFAULT NULL,
  `refund_amount` decimal(18,2) DEFAULT NULL,
  `refund_reason` varchar(500) DEFAULT NULL,
  `refund_status` enum('Pending','Completed','Rejected') DEFAULT NULL,
  `refund_date` datetime DEFAULT NULL,
  PRIMARY KEY (`refund_id`),
  KEY `payment_transaction_id` (`payment_transaction_id`),
  CONSTRAINT `fintech_refund_ibfk_1` FOREIGN KEY (`payment_transaction_id`) REFERENCES `fintech_payment_transaction` (`payment_transaction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_refund: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_risk_profile
CREATE TABLE IF NOT EXISTS `fintech_risk_profile` (
  `risk_profile_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `customer_id` bigint(20) DEFAULT NULL,
  `investment_horizon` int(11) DEFAULT NULL,
  `annual_income` decimal(18,2) DEFAULT NULL,
  `risk_score` decimal(6,2) DEFAULT NULL,
  `risk_category` enum('Conservative','Balanced','Aggressive') DEFAULT NULL,
  `recommended_asset_allocation` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`recommended_asset_allocation`)),
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`risk_profile_id`),
  KEY `customer_id` (`customer_id`),
  CONSTRAINT `fintech_risk_profile_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `fintech_customer` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_risk_profile: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_role
CREATE TABLE IF NOT EXISTS `fintech_role` (
  `role_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `role_name` varchar(100) DEFAULT NULL,
  `description` varchar(500) DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`role_id`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `fintech_role_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_role: ~6 rows (approximately)
INSERT INTO `fintech_role` (`role_id`, `tenant_id`, `role_name`, `description`, `created_date`) VALUES
	(1, 1, 'super-admin', 'Super Administrator with complete governance access', '2026-09-04 14:15:43'),
	(2, 1, 'branch-manager', 'Branch Manager with local branch ledger authority', '2026-09-04 14:15:43'),
	(3, 1, 'risk-analyst', 'Risk & Compliance Analyst for underwriting & oversight', '2026-09-04 14:15:44'),
	(4, 1, 'investment-officer', 'Investment Officer with mandate allocation control', '2026-09-04 14:15:44'),
	(5, 1, 'ai-analyst', 'AI & Algorithmic Trading Operations Analyst', '2026-09-04 14:15:44'),
	(6, 1, 'compliance-officer', 'Sanctions & AML Compliance Officer', '2026-09-04 14:15:44');

-- Dumping structure for table httpscoo_deverp.fintech_role_permission
CREATE TABLE IF NOT EXISTS `fintech_role_permission` (
  `role_permission_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `role_id` bigint(20) DEFAULT NULL,
  `permission_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`role_permission_id`),
  KEY `role_id` (`role_id`),
  KEY `permission_id` (`permission_id`),
  CONSTRAINT `fintech_role_permission_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `fintech_role` (`role_id`),
  CONSTRAINT `fintech_role_permission_ibfk_2` FOREIGN KEY (`permission_id`) REFERENCES `fintech_permission` (`permission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_role_permission: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_settlement
CREATE TABLE IF NOT EXISTS `fintech_settlement` (
  `settlement_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `merchant_id` bigint(20) DEFAULT NULL,
  `settlement_reference` varchar(100) DEFAULT NULL,
  `settlement_date` date DEFAULT NULL,
  `gross_amount` decimal(18,2) DEFAULT NULL,
  `charges` decimal(18,2) DEFAULT NULL,
  `tax_amount` decimal(18,2) DEFAULT NULL,
  `net_amount` decimal(18,2) DEFAULT NULL,
  `settlement_status` enum('Pending','Completed','Failed') DEFAULT NULL,
  PRIMARY KEY (`settlement_id`),
  KEY `merchant_id` (`merchant_id`),
  CONSTRAINT `fintech_settlement_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `fintech_merchant` (`merchant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_settlement: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_sip
CREATE TABLE IF NOT EXISTS `fintech_sip` (
  `sip_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `portfolio_id` bigint(20) DEFAULT NULL,
  `investment_product_id` bigint(20) DEFAULT NULL,
  `sip_amount` decimal(18,2) DEFAULT NULL,
  `frequency` enum('Daily','Weekly','Monthly','Quarterly') DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `next_execution_date` date DEFAULT NULL,
  `auto_debit` tinyint(1) DEFAULT 1,
  `status` enum('Active','Paused','Cancelled') DEFAULT NULL,
  PRIMARY KEY (`sip_id`),
  KEY `portfolio_id` (`portfolio_id`),
  KEY `investment_product_id` (`investment_product_id`),
  CONSTRAINT `fintech_sip_ibfk_1` FOREIGN KEY (`portfolio_id`) REFERENCES `fintech_portfolio` (`portfolio_id`),
  CONSTRAINT `fintech_sip_ibfk_2` FOREIGN KEY (`investment_product_id`) REFERENCES `fintech_investment_product` (`investment_product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_sip: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_tax
CREATE TABLE IF NOT EXISTS `fintech_tax` (
  `tax_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tax_code` varchar(30) DEFAULT NULL,
  `tax_name` varchar(100) DEFAULT NULL,
  `tax_percentage` decimal(8,2) DEFAULT NULL,
  `status` enum('Active','Inactive') DEFAULT NULL,
  PRIMARY KEY (`tax_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_tax: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_tenant
CREATE TABLE IF NOT EXISTS `fintech_tenant` (
  `tenant_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_code` varchar(50) NOT NULL,
  `tenant_name` varchar(200) NOT NULL,
  `legal_name` varchar(250) DEFAULT NULL,
  `industry` varchar(100) DEFAULT NULL,
  `website` varchar(250) DEFAULT NULL,
  `email` varchar(200) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `subscription_plan` varchar(100) DEFAULT NULL,
  `subscription_start` date DEFAULT NULL,
  `subscription_end` date DEFAULT NULL,
  `status` enum('Active','Inactive','Suspended','Pending') DEFAULT 'Active',
  `created_date` datetime DEFAULT current_timestamp(),
  `updated_date` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `tenant_kind` enum('Internal','External') DEFAULT 'External',
  `oauth_domain` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`tenant_id`),
  UNIQUE KEY `tenant_code` (`tenant_code`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_tenant: ~6 rows (approximately)
INSERT INTO `fintech_tenant` (`tenant_id`, `tenant_code`, `tenant_name`, `legal_name`, `industry`, `website`, `email`, `phone`, `subscription_plan`, `subscription_start`, `subscription_end`, `status`, `created_date`, `updated_date`, `tenant_kind`, `oauth_domain`) VALUES
	(1, 'GLOBALBANK', 'GlobalBank HQ', 'GlobalBank International Corp', 'Banking & Financial Services', NULL, NULL, NULL, NULL, NULL, NULL, 'Active', '2026-09-04 14:15:43', '2026-09-05 03:58:47', 'Internal', 'globalbank.com'),
	(2, 'SBank', 'Sbank IN', 'Shantanu Bank', 'Banking & Financial Services', NULL, NULL, NULL, NULL, NULL, NULL, 'Active', '2026-09-04 19:33:59', '2026-09-04 19:34:01', 'External', NULL),
	(3, 'YBank', 'YBank USA', 'Yash Badak', 'Banking & Financial Services', NULL, NULL, NULL, NULL, NULL, NULL, 'Active', '2026-09-04 19:35:04', '2026-09-04 19:35:04', 'External', NULL),
	(4, 'PBank', 'PBank Dubai', 'PDCC', 'Banking &Financial Services', NULL, NULL, NULL, NULL, NULL, NULL, 'Active', '2026-09-04 19:58:57', '2026-09-04 19:59:17', 'External', NULL),
	(5, 'JPMORGAN', 'JPMorgan Chase & Co.', 'JPMorgan Chase Bank, N.A.', 'Investment Banking', NULL, NULL, NULL, NULL, NULL, NULL, 'Active', '2026-09-05 03:58:47', '2026-09-05 03:58:47', 'External', 'jpmorgan.com'),
	(6, 'CITIBANK', 'Citibank Organization', 'Citibank Organization', 'Financial Services', NULL, NULL, NULL, NULL, NULL, NULL, 'Active', '2026-09-05 04:10:49', '2026-09-05 19:33:44', 'External', 'citibank.com');

-- Dumping structure for table httpscoo_deverp.fintech_trade
CREATE TABLE IF NOT EXISTS `fintech_trade` (
  `trade_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `portfolio_id` bigint(20) DEFAULT NULL,
  `investment_product_id` bigint(20) DEFAULT NULL,
  `trade_reference` varchar(50) DEFAULT NULL,
  `trade_type` enum('Buy','Sell') DEFAULT NULL,
  `quantity` decimal(18,4) DEFAULT NULL,
  `price` decimal(18,4) DEFAULT NULL,
  `brokerage` decimal(18,2) DEFAULT NULL,
  `taxes` decimal(18,2) DEFAULT NULL,
  `total_amount` decimal(18,2) DEFAULT NULL,
  `trade_date` datetime DEFAULT NULL,
  `settlement_date` date DEFAULT NULL,
  `trade_status` enum('Pending','Executed','Cancelled') DEFAULT NULL,
  PRIMARY KEY (`trade_id`),
  KEY `portfolio_id` (`portfolio_id`),
  KEY `investment_product_id` (`investment_product_id`),
  CONSTRAINT `fintech_trade_ibfk_1` FOREIGN KEY (`portfolio_id`) REFERENCES `fintech_portfolio` (`portfolio_id`),
  CONSTRAINT `fintech_trade_ibfk_2` FOREIGN KEY (`investment_product_id`) REFERENCES `fintech_investment_product` (`investment_product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_trade: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_transaction
CREATE TABLE IF NOT EXISTS `fintech_transaction` (
  `transaction_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `account_id` bigint(20) DEFAULT NULL,
  `reference_number` varchar(100) DEFAULT NULL,
  `transaction_type` enum('Credit','Debit') DEFAULT NULL,
  `channel` enum('Branch','ATM','UPI','IMPS','NEFT','RTGS','Internet','Mobile') DEFAULT NULL,
  `amount` decimal(18,2) DEFAULT NULL,
  `balance_after` decimal(18,2) DEFAULT NULL,
  `narration` varchar(500) DEFAULT NULL,
  `transaction_date` datetime DEFAULT NULL,
  `transaction_status` enum('Pending','Success','Failed','Reversed') DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  `sender_name` varchar(200) DEFAULT NULL,
  `receiver_name` varchar(200) DEFAULT NULL,
  `currency` varchar(10) DEFAULT 'USD',
  `route` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`transaction_id`),
  KEY `tenant_id` (`tenant_id`),
  KEY `account_id` (`account_id`),
  CONSTRAINT `fintech_transaction_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`),
  CONSTRAINT `fintech_transaction_ibfk_2` FOREIGN KEY (`account_id`) REFERENCES `fintech_account` (`account_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_transaction: ~21 rows (approximately)
INSERT INTO `fintech_transaction` (`transaction_id`, `tenant_id`, `account_id`, `reference_number`, `transaction_type`, `channel`, `amount`, `balance_after`, `narration`, `transaction_date`, `transaction_status`, `created_date`, `sender_name`, `receiver_name`, `currency`, `route`) VALUES
	(1, 1, 1, 'TXN-984102', 'Credit', 'RTGS', 14200000.00, 284000000.00, 'SWIFT MT103 Settlement from Barclays London', '2026-09-04 14:15:47', 'Success', '2026-09-04 14:15:47', 'Barclays London', 'GlobalBank NY', 'USD', 'UK → US'),
	(2, 1, 2, 'TXN-984101', 'Debit', 'RTGS', 8500000.00, 198500000.00, 'SEPA Instant Transfer to Siemens AG', '2026-09-04 14:15:47', 'Success', '2026-09-04 14:15:47', 'GlobalBank FFM', 'Siemens AG Treasury', 'EUR', 'DE → DE'),
	(3, 1, 5, 'TXN-984100', 'Credit', 'IMPS', 25000000.00, 88400000.00, 'CHAPS Wholesale Settlement from HSBC SG', '2026-09-04 14:15:47', 'Success', '2026-09-04 14:15:47', 'HSBC Singapore', 'Temasek Account', 'SGD', 'SG → SG'),
	(4, 1, 1, 'TXN-984099', 'Debit', 'RTGS', 50000000.00, 269800000.00, 'Fedwire Interbank Placement to Citi NY', '2026-09-04 14:15:47', 'Success', '2026-09-04 14:15:47', 'GlobalBank NY', 'Citigroup NY', 'USD', 'US → US'),
	(5, 1, 4, 'TXN-984098', 'Credit', 'RTGS', 1200000000.00, 42800000000.00, 'FX Swap Leg 2 from Nomura Tokyo', '2026-09-04 14:15:47', 'Success', '2026-09-04 14:15:47', 'Nomura Securities', 'MUFG Tokyo', 'JPY', 'JP → JP'),
	(6, 1, 1, 'TXN-353473', 'Credit', 'RTGS', 500000.00, 0.00, NULL, '2026-09-04 14:35:35', 'Success', '2026-09-04 14:35:35', 'Corporate Reserve', 'Bank of England', 'USD', 'Corporate Reserve → Bank of England'),
	(7, 1, 1, 'TXN-435278', 'Credit', 'RTGS', 500000.00, 0.00, NULL, '2026-09-04 14:43:53', 'Success', '2026-09-04 14:43:53', 'USD Nostro - JPMorgan Chase NY', 'Bank of China HK', 'USD', 'USD Nostro - JPMorgan Chase NY → Bank of China HK'),
	(8, 1, 1, 'TXN-441148', 'Credit', 'RTGS', 500000.00, 0.00, NULL, '2026-09-04 14:44:11', 'Success', '2026-09-04 14:44:11', 'USD Nostro - JPMorgan Chase NY', 'Bank of China HK', 'USD', 'USD Nostro - JPMorgan Chase NY → Bank of China HK'),
	(9, 1, 1, 'TXN-442663', 'Credit', 'RTGS', 14500000.00, 0.00, NULL, '2026-09-04 14:44:26', 'Success', '2026-09-04 14:44:26', 'USD Nostro - JPMorgan Chase NY', 'Bank of China HK', 'USD', 'USD Nostro - JPMorgan Chase NY → Bank of China HK'),
	(10, 1, 1, 'TXN-522376', 'Credit', 'RTGS', 14500000.00, 0.00, NULL, '2026-09-04 14:52:23', 'Success', '2026-09-04 14:52:23', 'USD Nostro - JPMorgan Chase NY', 'Bank of China HK', 'USD', 'USD Nostro - JPMorgan Chase NY → Bank of China HK'),
	(11, 1, 1, 'TXN-242082', 'Credit', 'RTGS', 14500000.00, 0.00, NULL, '2026-09-04 15:24:20', 'Success', '2026-09-04 15:24:20', 'USD Nostro - JPMorgan Chase NY', 'Bank of China HK', 'USD', 'USD Nostro - JPMorgan Chase NY → Bank of China HK'),
	(12, 1, 1, 'TXN-242396', 'Credit', 'RTGS', 14500000.00, 0.00, NULL, '2026-09-04 15:24:23', 'Success', '2026-09-04 15:24:23', 'USD Nostro - JPMorgan Chase NY', 'Bank of China HK', 'USD', 'USD Nostro - JPMorgan Chase NY → Bank of China HK'),
	(13, 1, 1, 'TXN-244091', 'Credit', 'RTGS', 14500000.00, 0.00, NULL, '2026-09-04 15:24:40', 'Success', '2026-09-04 15:24:40', 'USD Nostro - JP', 'Bank of China ', 'USD', 'USD Nostro - JP → Bank of China '),
	(14, 1, 1, 'TXN-250667', 'Credit', 'RTGS', 1.00, 0.00, NULL, '2026-09-04 15:25:06', 'Success', '2026-09-04 15:25:06', 'USD Nostro - JPMorgan Chase NY', 'Bank of China HK', 'USD', 'USD Nostro - JPMorgan Chase NY → Bank of China HK'),
	(15, 1, 1, 'TXN-253524', 'Credit', 'RTGS', 14500000.00, 0.00, NULL, '2026-09-04 15:25:35', 'Success', '2026-09-04 15:25:35', 'USD Nostro - JPMorgan Chase NY', 'Bank of China HK', 'USD', 'USD Nostro - JPMorgan Chase NY → Bank of China HK'),
	(16, 1, 1, 'TXN-085943', 'Credit', 'RTGS', 14500.00, 0.00, NULL, '2026-09-04 16:08:59', 'Success', '2026-09-04 16:08:59', 'USD Nostro - JPMorgan Chase NY', 'Bank of China HK', 'EUR', 'USD Nostro - JPMorgan Chase NY → Bank of China HK'),
	(17, 1, 1, 'TXN-121411', 'Credit', 'RTGS', 0.00, 0.00, NULL, '2026-09-04 16:12:14', 'Success', '2026-09-04 16:12:14', 'USD Nostro - JPMorgan Chase NY', 'Deutsche Bank Frankfurt', 'USD', 'New York → Frankfurt'),
	(18, 1, 1, 'TXN-161578', 'Credit', 'RTGS', 30000000.00, 0.00, NULL, '2026-09-04 16:16:15', 'Success', '2026-09-04 16:16:15', 'Nordic Treasury', 'HSBC London', 'EUR', 'Nordic Treasury → HSBC London'),
	(19, 1, 1, 'TXN-112490', 'Credit', 'RTGS', 14500000.00, 0.00, NULL, '2026-09-04 19:11:24', 'Success', '2026-09-04 19:11:24', 'USD Nostro - JPMorgan Chase NY', 'Bank of China HK', 'USD', 'USD Nostro - JPMorgan Chase NY → Bank of China HK'),
	(20, 1, 1, 'TXN-275654', 'Credit', 'RTGS', 120000000.00, 0.00, NULL, '2026-09-05 02:27:55', 'Success', '2026-09-05 02:27:55', 'Yash Badak', 'Bank of India', 'USD', 'Yash Badak → Bank of India'),
	(21, 5, 1, 'TXN-095966', 'Credit', 'RTGS', 14500000.00, 0.00, NULL, '2026-09-05 04:09:59', 'Success', '2026-09-05 04:09:59', 'USD Nostro - JPMorgan Chase NY', 'Bank of China HK', 'USD', 'USD Nostro - JPMorgan Chase NY → Bank of China HK');

-- Dumping structure for table httpscoo_deverp.fintech_underwriting
CREATE TABLE IF NOT EXISTS `fintech_underwriting` (
  `underwriting_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `policy_id` bigint(20) DEFAULT NULL,
  `medical_required` tinyint(1) DEFAULT NULL,
  `medical_status` enum('Pending','Completed','Waived') DEFAULT NULL,
  `credit_score` int(11) DEFAULT NULL,
  `risk_score` decimal(5,2) DEFAULT NULL,
  `underwriting_result` enum('Approved','Rejected','Pending') DEFAULT NULL,
  `underwriter` bigint(20) DEFAULT NULL,
  `remarks` text DEFAULT NULL,
  `decision_date` datetime DEFAULT NULL,
  PRIMARY KEY (`underwriting_id`),
  KEY `policy_id` (`policy_id`),
  KEY `underwriter` (`underwriter`),
  CONSTRAINT `fintech_underwriting_ibfk_1` FOREIGN KEY (`policy_id`) REFERENCES `fintech_policy` (`policy_id`),
  CONSTRAINT `fintech_underwriting_ibfk_2` FOREIGN KEY (`underwriter`) REFERENCES `fintech_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_underwriting: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_upi_profile
CREATE TABLE IF NOT EXISTS `fintech_upi_profile` (
  `upi_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `customer_id` bigint(20) DEFAULT NULL,
  `account_id` bigint(20) DEFAULT NULL,
  `upi_handle` varchar(100) DEFAULT NULL,
  `mobile_number` varchar(20) DEFAULT NULL,
  `default_account` tinyint(1) DEFAULT 1,
  `status` enum('Active','Inactive') DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`upi_id`),
  UNIQUE KEY `upi_handle` (`upi_handle`),
  KEY `customer_id` (`customer_id`),
  KEY `account_id` (`account_id`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `fintech_upi_profile_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `fintech_customer` (`customer_id`),
  CONSTRAINT `fintech_upi_profile_ibfk_2` FOREIGN KEY (`account_id`) REFERENCES `fintech_account` (`account_id`),
  CONSTRAINT `fintech_upi_profile_ibfk_3` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_upi_profile: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_user
CREATE TABLE IF NOT EXISTS `fintech_user` (
  `user_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `organization_id` bigint(20) DEFAULT NULL,
  `branch_id` bigint(20) DEFAULT NULL,
  `employee_no` varchar(50) DEFAULT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `email` varchar(200) DEFAULT NULL,
  `mobile` varchar(30) DEFAULT NULL,
  `password_hash` text DEFAULT NULL,
  `aadhaar_number` varchar(30) DEFAULT NULL,
  `pan_number` varchar(30) DEFAULT NULL,
  `status` enum('Active','Locked','Disabled') DEFAULT 'Active',
  `last_login` datetime DEFAULT NULL,
  `created_date` datetime DEFAULT current_timestamp(),
  `mfa_secret` varchar(100) DEFAULT NULL,
  `mfa_enabled` tinyint(1) DEFAULT 0,
  `role_label` varchar(100) DEFAULT NULL,
  `bank_name` varchar(100) DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `flag_emoji` varchar(20) DEFAULT NULL,
  `auth_provider` enum('password','google','microsoft') DEFAULT 'password',
  `oauth_subject_id` varchar(255) DEFAULT NULL,
  `is_internal` smallint(6) DEFAULT 0,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`),
  KEY `tenant_id` (`tenant_id`),
  KEY `organization_id` (`organization_id`),
  KEY `branch_id` (`branch_id`),
  CONSTRAINT `fintech_user_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`),
  CONSTRAINT `fintech_user_ibfk_2` FOREIGN KEY (`organization_id`) REFERENCES `fintech_organization` (`organization_id`),
  CONSTRAINT `fintech_user_ibfk_3` FOREIGN KEY (`branch_id`) REFERENCES `fintech_branch` (`branch_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_user: ~3 rows (approximately)
INSERT INTO `fintech_user` (`user_id`, `tenant_id`, `organization_id`, `branch_id`, `employee_no`, `first_name`, `last_name`, `email`, `mobile`, `password_hash`, `aadhaar_number`, `pan_number`, `status`, `last_login`, `created_date`, `mfa_secret`, `mfa_enabled`, `role_label`, `bank_name`, `country`, `flag_emoji`, `auth_provider`, `oauth_subject_id`, `is_internal`) VALUES
	(1, 1, 1, 1, NULL, 'Alexandra', 'Chen', 'a.chen@globalbank.com', NULL, '$2b$12$2nZRecQHXWkKziuZiwzuWOX8fR.Y1dvSjWYA7ll.7LpmaIrqTl77C', NULL, NULL, 'Active', NULL, '2026-09-04 14:15:44', NULL, 0, 'Super Administrator', 'GlobalBank HQ', 'Singapore', '🇸🇬', 'password', NULL, 1),
	(2, 5, 1, 1, NULL, 'Sarah.Lee', 'Member', 'sarah.lee@jpmorgan.com', NULL, NULL, NULL, NULL, 'Active', NULL, '2026-09-05 04:07:10', NULL, 0, 'Super Administrator', 'GlobalBank HQ', 'Singapore', '🇸🇬', 'google', NULL, 0),
	(3, 6, 1, 1, NULL, 'Alex', 'Turner', 'alex.turner@citibank.com', NULL, NULL, NULL, NULL, 'Active', NULL, '2026-09-05 19:51:35', NULL, 0, 'Citibank Organization Member', 'Citibank Organization', 'United States', '🏢', 'google', 'sub_google_dev_9912', 0);

-- Dumping structure for table httpscoo_deverp.fintech_user_role
CREATE TABLE IF NOT EXISTS `fintech_user_role` (
  `user_role_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) DEFAULT NULL,
  `role_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`user_role_id`),
  KEY `user_id` (`user_id`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `fintech_user_role_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `fintech_user` (`user_id`),
  CONSTRAINT `fintech_user_role_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `fintech_role` (`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_user_role: ~1 rows (approximately)
INSERT INTO `fintech_user_role` (`user_role_id`, `user_id`, `role_id`) VALUES
	(1, 1, 1);

-- Dumping structure for table httpscoo_deverp.fintech_wallet
CREATE TABLE IF NOT EXISTS `fintech_wallet` (
  `wallet_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `customer_id` bigint(20) DEFAULT NULL,
  `wallet_number` varchar(40) DEFAULT NULL,
  `wallet_type` enum('Customer','Merchant','Corporate') DEFAULT NULL,
  `balance` decimal(18,2) DEFAULT 0.00,
  `status` enum('Active','Blocked','Closed') DEFAULT 'Active',
  `created_date` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`wallet_id`),
  UNIQUE KEY `wallet_number` (`wallet_number`),
  KEY `customer_id` (`customer_id`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `fintech_wallet_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `fintech_customer` (`customer_id`),
  CONSTRAINT `fintech_wallet_ibfk_2` FOREIGN KEY (`tenant_id`) REFERENCES `fintech_tenant` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_wallet: ~0 rows (approximately)

-- Dumping structure for table httpscoo_deverp.fintech_watchlist
CREATE TABLE IF NOT EXISTS `fintech_watchlist` (
  `watchlist_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `customer_id` bigint(20) DEFAULT NULL,
  `investment_product_id` bigint(20) DEFAULT NULL,
  `target_price` decimal(18,2) DEFAULT NULL,
  `alert_enabled` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`watchlist_id`),
  KEY `customer_id` (`customer_id`),
  KEY `investment_product_id` (`investment_product_id`),
  CONSTRAINT `fintech_watchlist_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `fintech_customer` (`customer_id`),
  CONSTRAINT `fintech_watchlist_ibfk_2` FOREIGN KEY (`investment_product_id`) REFERENCES `fintech_investment_product` (`investment_product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table httpscoo_deverp.fintech_watchlist: ~0 rows (approximately)

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;

use httpscoo_deverp;
select * from fintech_tenant;
