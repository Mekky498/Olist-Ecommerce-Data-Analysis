USE Olist_Ecommerce;
GO

SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;

GO

SELECT
    TABLE_NAME,
    ORDINAL_POSITION,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME IN (
      'olist_orders',
      'olist_order_items',
      'olist_products',
      'olist_customers',
      'olist_sellers'
  )
ORDER BY
    TABLE_NAME,
    ORDINAL_POSITION;

USE Olist_Ecommerce
GO

CREATE OR ALTER VIEW dbo.vw_TotalRevenue AS
    SELECT
        SUM(price) AS TotalRevenue
FROM dbo.olist_order_items;
GO

SELECT *
FROM dbo.vw_TotalRevenue;
GO

SELECT SUM(price) AS TotalRevenue
FROM dbo.olist_order_items;
GO

CREATE OR ALTER VIEW dbo.vw_MonthlySales AS
SELECT
    YEAR(o.order_purchase_timestamp) AS SalesYear,
    MONTH(o.order_purchase_timestamp) AS SalesMonth,
    SUM(oi.price) AS MonthlyRevenue
FROM dbo.olist_orders AS o
INNER JOIN dbo.olist_order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_purchase_timestamp IS NOT NULL
GROUP BY
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp);
GO

SELECT *
FROM dbo.vw_MonthlySales;
GO

CREATE OR ALTER VIEW dbo.vw_OrderStatusBreakdown AS
SELECT
    order_status,
    COUNT(*) AS TotalOrders,
    CAST(
        100.0 * COUNT(*) /
        NULLIF(SUM(COUNT(*)) OVER (), 0)
        AS DECIMAL(5,2)
    ) AS PercentageOfOrders
FROM dbo.olist_orders
GROUP BY order_status;
GO

SELECT *
FROM dbo.vw_OrderStatusBreakdown;
GO

CREATE OR ALTER VIEW dbo.vw_TopProductCategories AS
SELECT TOP (10)
    p.product_category_name,
    SUM(oi.price) AS TotalRevenue,
    COUNT(*) AS ItemsSold
FROM dbo.olist_order_items AS oi
INNER JOIN dbo.olist_products AS p
    ON oi.product_id = p.product_id
GROUP BY
    p.product_category_name
ORDER BY
    SUM(oi.price) DESC;
GO

SELECT *
FROM dbo.vw_TopProductCategories;
GO

CREATE OR ALTER VIEW dbo.vw_AverageDeliveryTime AS
SELECT
    COUNT(*) AS DeliveredOrders,
    AVG(
        CAST(
            DATEDIFF(
                SECOND,
                order_purchase_timestamp,
                order_delivered_customer_date
            ) AS FLOAT
        ) / 86400.0
    ) AS AvgDeliveryDays
FROM dbo.olist_orders
WHERE order_status = 'delivered'
  AND order_purchase_timestamp IS NOT NULL
  AND order_delivered_customer_date IS NOT NULL;
GO

SELECT *
FROM dbo.vw_AverageDeliveryTime;
GO

    ---     Customer Geographic Distribution    ---
CREATE OR ALTER VIEW dbo.vw_CustomerGeography AS
SELECT
    c.customer_state AS CustomerState,
    COUNT(DISTINCT o.order_id) AS TotalOrders,
    COUNT(DISTINCT c.customer_unique_id)
        AS UniqueCustomers,
    SUM(oi.price) AS TotalRevenue
FROM dbo.olist_customers AS c
INNER JOIN dbo.olist_orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN dbo.olist_order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state;
GO

SELECT *
FROM dbo.vw_CustomerGeography;
GO

    ----    Seller Performance ---
CREATE OR ALTER VIEW dbo.vw_SellerPerformance AS
WITH SellerOrderMetrics AS (
    SELECT
        oi.seller_id,
        o.order_id,
        SUM(oi.price) AS OrderRevenue,
        COUNT(*) AS ItemsSold,
        MAX(o.order_status) AS OrderStatus,
        MAX(o.order_purchase_timestamp)
            AS PurchaseDate,
        MAX(o.order_delivered_customer_date)
            AS DeliveryDate
    FROM dbo.olist_order_items AS oi
    INNER JOIN dbo.olist_orders AS o
        ON oi.order_id = o.order_id
    GROUP BY
        oi.seller_id,
        o.order_id
)
SELECT
    s.seller_id AS SellerID,
    s.seller_city AS SellerCity,
    s.seller_state AS SellerState,
    SUM(sm.OrderRevenue) AS TotalRevenue,
    SUM(sm.ItemsSold) AS ItemsSold,
    COUNT(*) AS TotalOrders,
    SUM(
        CASE WHEN sm.OrderStatus = 'delivered'
             THEN 1 ELSE 0 END
    ) AS DeliveredOrders,
    AVG(
        CASE
            WHEN sm.OrderStatus = 'delivered'
             AND sm.PurchaseDate IS NOT NULL
             AND sm.DeliveryDate IS NOT NULL
            THEN CAST(
                DATEDIFF(
                    SECOND,
                    sm.PurchaseDate,
                    sm.DeliveryDate
                ) AS FLOAT
            ) / 86400.0
        END
    ) AS AvgDeliveryDays
FROM SellerOrderMetrics AS sm
INNER JOIN dbo.olist_sellers AS s
    ON sm.seller_id = s.seller_id
GROUP BY
    s.seller_id,
    s.seller_city,
    s.seller_state;
GO

SELECT *
FROM dbo.vw_SellerPerformance;
GO

--- business analysis: monthly sales
SELECT
    SalesYear,
    SalesMonth,
    MonthlyRevenue
FROM dbo.vw_MonthlySales
ORDER BY SalesYear, SalesMonth;
GO

--- Calculate overall delivery performance
SELECT
    COUNT(*) AS DeliveredOrders,

    AVG(
        DATEDIFF(
            DAY,
            order_purchase_timestamp,
            order_delivered_customer_date
        ) * 1.0
    ) AS AvgDaysFromPurchaseToDelivery,

ISNULL(
    AVG(
        CASE
            WHEN order_delivered_customer_date
                 <= order_estimated_delivery_date
            THEN 1.0
            ELSE 0.0
        END
    ) * 100,
    0
) AS OnTimeDeliveryPercent,

    SUM(
        CASE
            WHEN order_delivered_customer_date
                 > order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS LateDeliveredOrders

FROM dbo.olist_orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_purchase_timestamp IS NOT NULL;
  GO

  ---   Which products and categories generate the most revenue
  SELECT TOP (10)
    ISNULL(p.product_category_name, N'Unknown') AS ProductCategory,
    SUM(oi.price) AS TotalRevenue,
    COUNT(DISTINCT oi.order_id) AS TotalOrders,
    COUNT(*) AS TotalItemsSold
FROM dbo.olist_order_items AS oi
INNER JOIN dbo.olist_products AS p
    ON oi.product_id = p.product_id
GROUP BY
    ISNULL(p.product_category_name, N'Unknown')
ORDER BY
    TotalRevenue DESC;
    GO

---     On-Time Delivery percentage
CREATE OR ALTER VIEW dbo.vw_DeliveryPerformance AS
SELECT
    COUNT(*) AS DeliveredOrdersWithDates,

    AVG(
        DATEDIFF(
            SECOND,
            order_purchase_timestamp,
            order_delivered_customer_date
        ) / 86400.0
    ) AS AvgDeliveryDays,

    AVG(
        CASE
            WHEN order_delivered_customer_date
                 <= order_estimated_delivery_date
            THEN 1.0
            ELSE 0.0
        END
    ) * 100 AS OnTimeDeliveryPercent,

    SUM(
        CASE
            WHEN order_delivered_customer_date
                 > order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS LateDeliveredOrders

FROM dbo.olist_orders
WHERE order_status = 'delivered'
  AND order_purchase_timestamp IS NOT NULL
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;
GO

---      Create the Clean Translation View
CREATE OR ALTER VIEW vw_Product_Category_Translation AS
SELECT 
    column1 AS product_category_name,
    column2 AS product_category_name_english
FROM olist_category_translation
WHERE column1 <> 'product_category_name';
GO

----         Product Category Performance
CREATE OR ALTER VIEW vw_Product_Category_Performance AS
SELECT 
    ISNULL(t.column2, 'Uncategorized') AS product_category_name_english,
    COUNT(oi.order_item_id) AS total_items_sold,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue
FROM olist_order_items oi
JOIN olist_products p 
    ON oi.product_id = p.product_id
LEFT JOIN olist_category_translation t 
    ON p.product_category_name = t.column1 
    AND t.column1 <> 'product_category_name'
GROUP BY ISNULL(t.column2, 'Uncategorized');
GO

----        Payment Type Performance
CREATE OR ALTER VIEW dbo.vw_Payment_Type_Performance AS
SELECT
    p.payment_type,
    COUNT(DISTINCT p.order_id) AS total_orders,
    ROUND(
        SUM(p.payment_value),
        2
    ) AS total_payment_value
FROM dbo.olist_order_payments AS p
GROUP BY
    p.payment_type;
GO

---     Delivery Status & Fulfillment Days
CREATE OR ALTER VIEW vw_Delivery_Performance_Details AS
SELECT 
    o.order_id,
    c.customer_state,
    c.customer_city,
    CAST(o.order_purchase_timestamp AS DATE) AS purchase_date,
    CAST(o.order_delivered_customer_date AS DATE) AS actual_delivery_date,
    CAST(o.order_estimated_delivery_date AS DATE) AS estimated_delivery_date,
    -- Actual days taken to deliver to customer
    DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) AS actual_delivery_days,
    -- Estimated days promised by system
    DATEDIFF(DAY, o.order_purchase_timestamp, o.order_estimated_delivery_date) AS estimated_delivery_days,
    -- Difference (Positive = Days Late, Negative = Days Early)
    DATEDIFF(DAY, o.order_estimated_delivery_date, o.order_delivered_customer_date) AS days_difference,
    -- On-Time vs. Late Classification
    CASE 
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 'On-Time'
        ELSE 'Late'
    END AS delivery_status
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL;
GO

---     Delivery Speed by Customer State
CREATE OR ALTER VIEW vw_State_Delivery_Performance AS
SELECT 
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_delivered_orders,
    ROUND(AVG(CAST(DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) AS FLOAT)), 2) AS avg_delivery_days,
    ROUND(AVG(CAST(DATEDIFF(DAY, o.order_purchase_timestamp, o.order_estimated_delivery_date) AS FLOAT)), 2) AS avg_estimated_days,
    SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END) AS late_orders,
    ROUND(
        CAST(SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END) AS FLOAT) 
        / COUNT(DISTINCT o.order_id) * 100, 2
    ) AS late_delivery_rate_pct
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state;
GO

----        Delivery Delay vs. Customer Review Score
CREATE OR ALTER VIEW vw_Delivery_vs_Reviews AS
SELECT 
    r.review_score,
    COUNT(DISTINCT o.order_id) AS total_reviews,
    ROUND(AVG(CAST(DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) AS FLOAT)), 2) AS avg_delivery_days,
    SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END) AS late_deliveries
FROM olist_orders o
JOIN olist_order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY r.review_score;
GO