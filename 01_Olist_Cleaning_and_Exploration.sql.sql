SELECT TOP 10 * FROM olist_order_items;
SELECT TOP 10 * FROM olist_order_payments;
SELECT TOP 10 * FROM olist_order_reviews;
SELECT TOP 10 * FROM olist_geolocation;
SELECT TOP 10 * FROM olist_category_translation;
SELECT TOP 10 * FROM olist_sellers;
SELECT TOP 10 * FROM olist_customers;
SELECT TOP 10 * FROM olist_orders;
SELECT TOP 10 * FROM olist_products;
SELECT COUNT (*) AS TOTAL_CUSTOMERS
FROM olist_customers;
SELECT COUNT (*) AS TOTAL_order_items
FROM olist_order_items;
SELECT COUNT (*) AS TOTAL_order_payments
FROM olist_order_payments;
SELECT COUNT (*) AS TOTAL_geolocation
FROM olist_geolocation;
SELECT COUNT (*) AS TOTAL_order_reviews
FROM olist_order_reviews;
SELECT COUNT (*) AS TOTAL_orders
FROM olist_orders;
SELECT COUNT (*) AS TOTAL_products
FROM olist_products;
SELECT COUNT (*) AS TOTAL_sellers
FROM olist_sellers;

SELECT 
	COUNT (*) AS TOTAL_CUSTOMERS,
	COUNT(DISTINCT customer_id) AS unique_customer
FROM olist_customers;

SELECT TOP 10 * FROM olist_category_translation;
SELECT 
	COUNT (*) AS TOTAL_geolocation,
	COUNT(DISTINCT geolocation_zip_code_prefix) AS unique_geolocation
FROM olist_geolocation;

SELECT
	MAX(order_estimated_delivery_date) AS latest_delivery,
	MIN(order_estimated_delivery_date) AS earlier_delivery
FROM olist_orders;

SELECT
	COUNT(*) AS total_orders,
	COUNT(order_approved_at) AS approved_orders,
	COUNT(*) - COUNT(order_approved_at) AS denied_orders
FROM olist_orders;

SELECT
	YEAR(order_approved_at) AS approved_orders_years,
	COUNT(*) AS total_orders
FROM olist_orders
WHERE order_approved_at IS NOT NULL
GROUP BY YEAR(order_approved_at)
ORDER BY approved_orders_years;

SELECT
	COUNT(*) AS total_orders,
	SUM(CASE WHEN order_approved_at IS NULL
	THEN 1 ELSE 0 END) AS missing_orders,
	SUM(CASE WHEN customer_id IS NULL
	THEN 1 ELSE 0 END) AS missing_customer_id
FROM olist_orders;

SELECT order_id,
	count(*) AS total_orders
FROM olist_orders
GROUP BY order_id
HAVING COUNT (*) > 0;

SELECT f.*
FROM olist_orders AS f;

SELECT
	c.customer_unique_id,
	o.order_id,
	o.order_status
FROM olist_customers AS c
INNER JOIN olist_orders AS o
	ON c.customer_id = o.customer_id;

SELECT COUNT(*) AS unmatched_items
FROM olist_order_items AS oi
LEFT JOIN olist_orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT TOP 10 * FROM olist_orders;
SELECT TOP 10 * FROM olist_order_items;
SELECT TOP 10 * FROM olist_products;

SELECT
	o.order_id,
	o.order_status,
	oi.product_id,
	oi.price,
	p.product_category_name
FROM olist_orders AS o
INNER JOIN olist_order_items AS oi
	ON o.order_id = oi.order_id
INNER JOIN olist_products AS p
	ON oi.product_id = p.product_id;

SELECT COUNT(*) AS unmatched_items
FROM olist_order_items AS oi
LEFT JOIN olist_orders AS o
	ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(*) AS unmatched_items
FROM olist_order_items AS oi
LEFT JOIN olist_products AS p
	ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT SUM(price) AS TotalRevenue
FROM olist_order_items;

SELECT
	SUM(price) AS delivered_revenue
FROM olist_order_items AS oi
INNER JOIN olist_orders AS o
ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered';

SELECT
	YEAR(o.order_purchase_timestamp) AS salesyear,
	MONTH(o.order_purchase_timestamp) AS salesmonth,
	SUM(oi.price) AS monthly_revenue
FROM olist_orders AS o
JOIN olist_order_items AS oi
	ON o.order_id = oi.order_id
GROUP BY 
	YEAR(o.order_purchase_timestamp),
	MONTH(o.order_purchase_timestamp)
ORDER BY 
	salesyear,
	salesmonth;

SELECT
	order_status,
	COUNT(*) AS total_orders,
	CAST(
		100.0*COUNT(*) / SUM(COUNT(*)) OVER()
		AS DECIMAL (5,2)
	) AS percentage_orders
FROM olist_orders
GROUP BY order_status
ORDER BY total_orders DESC;

SELECT TOP 10 * FROM olist_products;
SELECT TOP 10 * FROM olist_order_items;
SELECT TOP 10 * FROM olist_category_translation;
SELECT TOP 10 * FROM olist_orders;

SELECT TOP 10 
 p.product_category_name AS product_name,
 CAST(SUM(oi.price) AS DECIMAL (9,2)) AS total_revenue,
 Count(*) AS item_sold
FROM olist_order_items AS oi
JOIN olist_products AS p
ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC;

SELECT
	AVG(
		CAST(
			DATEDIFF(
				SECOND,
				order_purchase_timestamp,
				order_delivered_customer_date
			) AS FLOAT
		) / 86400.0
	) AS AvgDeliveryDays
FROM olist_orders
WHERE order_status = 'delivered'
	AND	order_purchase_timestamp IS NOT NULL
	AND order_delivered_customer_date IS NOT NULL;

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
    ) AS AvgDeliveryDays,
    AVG(
        CASE
            WHEN order_delivered_customer_date
                 <= order_estimated_delivery_date
            THEN 100.0
            ELSE 0.0
        END
    ) AS OnTimeDeliveryPercent
FROM olist_orders
WHERE order_status = 'delivered'
  AND order_purchase_timestamp IS NOT NULL
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;

  SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS TotalOrders,
    COUNT(DISTINCT c.customer_unique_id) AS UniqueCustomers
FROM olist_customers AS c
INNER JOIN olist_orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY TotalOrders DESC;

SELECT
	c.customer_state,
	COUNT(DISTINCT o.order_id) AS total_orders,
	SUM(oi.price) AS total_revenue
FROM olist_customers AS C
JOIN olist_orders AS o
ON o.customer_id = c.customer_id
INNER JOIN olist_order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

SELECT TOP (10)
    s.seller_id,
    s.seller_city,
    s.seller_state,
    SUM(oi.price) AS TotalRevenue,
    COUNT(*) AS ItemsSold,
    COUNT(DISTINCT oi.order_id) AS TotalOrders
FROM olist_sellers AS s
INNER JOIN olist_order_items AS oi
    ON s.seller_id = oi.seller_id
GROUP BY
    s.seller_id,
    s.seller_city,
    s.seller_state
ORDER BY TotalRevenue DESC;

WITH SellerOrders AS (
    SELECT DISTINCT
        oi.seller_id,
        o.order_id,
        o.order_purchase_timestamp,
        o.order_delivered_customer_date
    FROM olist_order_items AS oi
    INNER JOIN olist_orders AS o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp IS NOT NULL
      AND o.order_delivered_customer_date IS NOT NULL
)
SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(*) AS DeliveredOrders,
    AVG(
        CAST(
            DATEDIFF(
                SECOND,
                so.order_purchase_timestamp,
                so.order_delivered_customer_date
            ) AS FLOAT
        ) / 86400.0
    ) AS AvgDeliveryDays
FROM SellerOrders AS so
INNER JOIN olist_sellers AS s
    ON so.seller_id = s.seller_id
GROUP BY
    s.seller_id,
    s.seller_city,
    s.seller_state
ORDER BY AvgDeliveryDays ASC;

     --  Check for broken relationships  --   
-- Order items with no matching order
SELECT COUNT(*) AS MissingOrders
FROM dbo.olist_order_items AS oi
LEFT JOIN dbo.olist_orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Order items with no matching product
SELECT COUNT(*) AS MissingProducts
FROM dbo.olist_order_items AS oi
LEFT JOIN dbo.olist_products AS p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Order items with no matching seller
SELECT COUNT(*) AS MissingSellers
FROM dbo.olist_order_items AS oi
LEFT JOIN dbo.olist_sellers AS s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- Orders with no matching customer
SELECT COUNT(*) AS MissingCustomers
FROM dbo.olist_orders AS o
LEFT JOIN dbo.olist_customers AS c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

    --  Check order status and missing dates    --
SELECT
    order_status,
    COUNT(*) AS TotalOrders
FROM dbo.olist_orders
GROUP BY order_status
ORDER BY TotalOrders DESC;

SELECT
    COUNT(*) AS TotalOrders,
    SUM(CASE
        WHEN order_purchase_timestamp IS NULL THEN 1
        ELSE 0
    END) AS MissingPurchaseDates,
    SUM(CASE
        WHEN order_delivered_customer_date IS NULL THEN 1
        ELSE 0
    END) AS MissingDeliveryDates
FROM dbo.olist_orders;

--- investigate MissingDeliveryDates 2,965 orders
SELECT
    order_status,
    COUNT(*) AS OrdersWithoutDeliveryDate
FROM dbo.olist_orders
WHERE order_delivered_customer_date IS NULL
GROUP BY order_status
ORDER BY OrdersWithoutDeliveryDate DESC;

SELECT
    order_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM dbo.olist_orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL
ORDER BY order_purchase_timestamp;

    --- data-quality finding    ---
SELECT
    COUNT(*) AS DeliveredOrders,
    SUM(
        CASE
            WHEN order_delivered_customer_date IS NULL
            THEN 1
            ELSE 0
        END
    ) AS MissingCustomerDeliveryDates,
    CAST(
        100.0 * SUM(
            CASE
                WHEN order_delivered_customer_date IS NULL
                THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS MissingDeliveryDatePercent
FROM dbo.olist_orders
WHERE order_status = 'delivered';

---     Verify the latest month before drawing conclusions
SELECT
    YEAR(o.order_purchase_timestamp) AS SalesYear,
    MONTH(o.order_purchase_timestamp) AS SalesMonth,
    COUNT(DISTINCT o.order_id) AS TotalOrders,
    COUNT(*) AS TotalOrderItems,
    SUM(oi.price) AS MonthlyRevenue
FROM dbo.olist_orders AS o
INNER JOIN dbo.olist_order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_purchase_timestamp IS NOT NULL
GROUP BY
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp)
ORDER BY
    SalesYear,
    SalesMonth;
    GO

