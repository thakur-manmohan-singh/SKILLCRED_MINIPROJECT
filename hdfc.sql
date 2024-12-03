--Priyanshu Dubey
--sec AE
--uni roll no.:2215500115
--class roll no.:35
--Group no.:25
--  SQL query template to help you calculate HDFC's market share and compare it with competitors. 
--  Let's assume we're loading the data into SQL tables named bank_sector,
--  atm_pos_stats, and transaction_data.


-- Aggregation and Transformation for Market Share and Per Card Performance

-- Step 1: Calculate monthly total values for credit and debit cards
WITH Monthly_Totals AS (
    SELECT
        Month,
        SUM(CC_Base) AS Total_CC_Base,
        SUM(DC_Base) AS Total_DC_Base,
        SUM(CC_TXNs) AS Total_CC_TXNs,
        SUM(DC_TXNs) AS Total_DC_TXNs,
        SUM(CC_Value) AS Total_CC_Value,
        SUM(DC_Value) AS Total_DC_Value
    FROM
        consolidated_data
    GROUP BY
        Month
)

-- Step 2: Calculate market share and per card performance for each bank
SELECT
    Bank_Name,
    Month,
    CC_Base,
    DC_Base,
    CC_TXNs,
    DC_TXNs,
    CC_Value,
    DC_Value,
    
    -- Market Share Calculations
    (CC_Base / Total_CC_Base) * 100 AS CC_Customer_Share_Percentage,
    (CC_Value / Total_CC_Value) * 100 AS CC_Spends_Share_Percentage,
    (CC_TXNs / Total_CC_TXNs) * 100 AS CC_TXN_Share_Percentage,
    (DC_Base / Total_DC_Base) * 100 AS DC_Customer_Share_Percentage,
    (DC_Value / Total_DC_Value) * 100 AS DC_Spends_Share_Percentage,
    (DC_TXNs / Total_DC_TXNs) * 100 AS DC_TXN_Share_Percentage,
    
    -- Per Card Performance Calculations
    (CC_Value / NULLIF(CC_TXNs, 0)) AS CC_Average_TXN_Size,
    (CC_Value / NULLIF(CC_Base, 0)) AS CC_Spend_Per_Card,
    (CC_TXNs / NULLIF(CC_Base, 0)) AS CC_TXN_Per_Card,
    (DC_Value / NULLIF(DC_TXNs, 0)) AS DC_Average_TXN_Size,
    (DC_Value / NULLIF(DC_Base, 0)) AS DC_Spend_Per_Card,
    (DC_TXNs / NULLIF(DC_Base, 0)) AS DC_TXN_Per_Card

FROM
    consolidated_data
JOIN
    Monthly_Totals ON consolidated_data.Month = Monthly_Totals.Month;



-- 1. Calculating HDFC’s market share in credit and debit cards by month
WITH industry_totals AS (
    SELECT 
        month,
        SUM(num_credit_cards) AS total_credit_cards,
        SUM(num_debit_cards) AS total_debit_cards
    FROM transaction_data
    GROUP BY month
),
hdfc_data AS (
    SELECT 
        month,
        num_credit_cards,
        num_debit_cards
    FROM transaction_data
    WHERE bank_name = 'HDFC Bank'
)

SELECT 
    hdfc_data.month,
    (hdfc_data.num_credit_cards * 100.0 / industry_totals.total_credit_cards) AS credit_card_market_share,
    (hdfc_data.num_debit_cards * 100.0 / industry_totals.total_debit_cards) AS debit_card_market_share
FROM hdfc_data
JOIN industry_totals ON hdfc_data.month = industry_totals.month;

-- 2. Comparing HDFC’s transaction trends with industry averages
SELECT 
    hdfc_data.month,
    hdfc_data.num_credit_card_transactions,
    industry_avg.num_credit_card_transactions AS industry_avg_credit,
    hdfc_data.num_debit_card_transactions,
    industry_avg.num_debit_card_transactions AS industry_avg_debit
FROM hdfc_data
JOIN (
    SELECT 
        month,
        AVG(num_credit_card_transactions) AS num_credit_card_transactions,
        AVG(num_debit_card_transactions) AS num_debit_card_transactions
    FROM transaction_data
    GROUP BY month
) AS industry_avg
ON hdfc_data.month = industry_avg.month;

-- 3. POS and ATM trends: HDFC vs. Industry at POS terminals
SELECT 
    hdfc_data.month,
    hdfc_data.pos_transactions,
    industry_avg.pos_transactions AS industry_avg_pos,
    hdfc_data.atm_transactions,
    industry_avg.atm_transactions AS industry_avg_atm
FROM hdfc_data
JOIN (
    SELECT 
        month,
        AVG(pos_transactions) AS pos_transactions,
        AVG(atm_transactions) AS atm_transactions
    FROM atm_pos_stats
    GROUP BY month
) AS industry_avg
ON hdfc_data.month = industry_avg.month;
