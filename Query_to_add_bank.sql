-- Wrap in a transaction to ensure all-or-nothing execution
START TRANSACTION;

-- 1. Create Tenant (The Root Entity)
INSERT INTO `fintech_tenant` (
    `tenant_code`, `tenant_name`, `legal_name`, `industry`, `tenant_kind`, `status`
) VALUES (
    'DEMOBANK', 'DEMO BANK', 'DEMO BANK Financial Technologies Ltd.', 'Banking & Financial Services', 'Internal', 'Active'
);
SET @tenant_id = LAST_INSERT_ID();


-- 2. Create Organization
INSERT INTO `fintech_organization` (
    `tenant_id`, `organization_code`, `organization_name`, `city`, `state`, `country`, `status`
) VALUES (
    @tenant_id, 'DEMO-CORP', 'DEMO BANK Corporate HQ', 'Pune', 'Maharashtra', 'India', 'Active'
);
SET @org_id = LAST_INSERT_ID();


-- 3. Create Branch
INSERT INTO `fintech_branch` (
    `tenant_id`, `organization_id`, `branch_code`, `branch_name`, `ifsc_code`, `city`, `state`, `status`
) VALUES (
    @tenant_id, @org_id, 'BR-DEMO-01', 'DEMO BANK Main Branch', 'DEMO0001001', 'Pune', 'Maharashtra', 'Active'
);
SET @branch_id = LAST_INSERT_ID();


-- 4. Create Role & Permissions
INSERT INTO `fintech_role` (
    `tenant_id`, `role_name`, `description`
) VALUES (
    @tenant_id, 'bank-admin', 'DEMO BANK Root Administrator with full system control'
);
SET @role_id = LAST_INSERT_ID();

INSERT INTO `fintech_permission` (
    `permission_name`, `module_name`, `api_name`
) VALUES (
    'Full Administrative Access', 'CoreBanking', '/api/v1/admin/*'
);
SET @permission_id = LAST_INSERT_ID();

INSERT INTO `fintech_role_permission` (
    `role_id`, `permission_id`
) VALUES (
    @role_id, @permission_id
);


-- 5. Create Internal Bank User & Map Role
INSERT INTO `fintech_user` (
    `tenant_id`, `organization_id`, `branch_id`, `first_name`, `last_name`, 
    `email`, `status`, `role_label`, `bank_name`, `country`, `auth_provider`, `is_internal`
) VALUES (
    @tenant_id, @org_id, @branch_id, 'System', 'Administrator', 
    'admin@demobank.com', 'Active', 'Super Administrator', 'DEMO BANK', 'India', 'password', 1
);
SET @user_id = LAST_INSERT_ID();

INSERT INTO `fintech_user_role` (
    `user_id`, `role_id`
) VALUES (
    @user_id, @role_id
);


-- 6. Create Customer
INSERT INTO `fintech_customer` (
    `tenant_id`, `customer_no`, `customer_type`, `first_name`, `last_name`, 
    `company_name`, `email`, `mobile`, `kyc_status`, `risk_rating`
) VALUES (
    @tenant_id, 'CUST-DEMO-001', 'Corporate', 'Demo', 'Client', 
    'Demo Technologies Pvt Ltd', 'contact@demotech.com', '+91-9876543210', 'Verified', 'Low'
);
SET @customer_id = LAST_INSERT_ID();


-- 7. Create Account Type
INSERT INTO `fintech_account_type` (
    `tenant_id`, `account_code`, `account_name`, `minimum_balance`, `interest_rate`, `overdraft_allowed`, `status`
) VALUES (
    @tenant_id, 'OPERATING', 'DEMO BANK Corporate Operating Account', 10000.00, 3.50, 1, 'Active'
);
SET @account_type_id = LAST_INSERT_ID();


-- 8. Create Bank Account
INSERT INTO `fintech_account` (
    `tenant_id`, `customer_id`, `branch_id`, `account_type_id`, 
    `account_number`, `account_name`, `currency_code`, `available_balance`, 
    `ledger_balance`, `account_status`, `account_category`
) VALUES (
    @tenant_id, @customer_id, @branch_id, @account_type_id, 
    'ACC-DEMO-1001', 'DEMO BANK Main Corporate Ledger', 'INR', 5000000.00, 
    5000000.00, 'Active', 'OPERATING'
);
SET @account_id = LAST_INSERT_ID();


-- 9. Create First Transaction (Opening Balance / Inward Credit)
INSERT INTO `fintech_transaction` (
    `tenant_id`, `account_id`, `reference_number`, `transaction_type`, 
    `channel`, `amount`, `balance_after`, `narration`, `transaction_date`, 
    `transaction_status`, `sender_name`, `receiver_name`, `currency`, `route`
) VALUES (
    @tenant_id, @account_id, 'TXN-DEMO-0001', 'Credit', 
    'RTGS', 5000000.00, 5000000.00, 'Initial capital deposit for DEMO BANK account setup', 
    NOW(), 'Success', 'RBI Settlement Desk', 'DEMO BANK Corporate Ledger', 'INR', 'Internal → Operating'
);


-- 10. Issue a Card for the Account
INSERT INTO `fintech_card` (
    `tenant_id`, `account_id`, `card_number`, `card_type`, `card_network`, 
    `expiry_month`, `expiry_year`, `daily_limit`, `status`
) VALUES (
    @tenant_id, @account_id, '4532XXXXXXXX1099', 'Debit', 'Visa', 
    12, 2030, 200000.00, 'Active'
);


-- 11. Create a Loan Linked to the Bank & Customer
INSERT INTO `fintech_loan` (
    `tenant_id`, `customer_id`, `account_id`, `loan_number`, 
    `sanctioned_amount`, `disbursed_amount`, `outstanding_amount`, 
    `interest_rate`, `tenure_months`, `emi_amount`, `loan_status`, 
    `borrower_name`, `facility_type`, `credit_rating`, `country`
) VALUES (
    @tenant_id, @customer_id, @account_id, 'LN-DEMO-001', 
    1000000.00, 1000000.00, 1000000.00, 
    8.50, 36, 31568.00, 'Active', 
    'Demo Technologies Pvt Ltd', 'Working Capital Term Loan', 'AA', 'IN'
);

COMMIT;