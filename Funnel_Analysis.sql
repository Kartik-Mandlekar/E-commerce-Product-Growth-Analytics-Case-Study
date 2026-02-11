use mavenfuzzyfactory;


# 1) Which product has the highest refund rate, and how does it compare to its sales volume?
# 2) Do customers who purchase Product A tend to buy more add-on products compared to other products?
# 3) How does conversion rate differ by product landing page?
# 4) Which traffic sources drive the highest revenue per session?
# 5) How has overall conversion rate changed over time, and is revenue growth driven more by traffic or better conversion?
# 6) What is the revenue impact of refunds on overall profitability, and which products contribute most to revenue loss?



-- 1) Which product has the highest refund rate, and how does it compare to its sales volume?
		# Total Ordered Products and revenue for each product ----> product, total orders, total refunds, revenue, refund amount
        

WITH product_sales AS (
    SELECT
        oi.product_id,
        COUNT(oi.order_item_id) AS units_sold,
        SUM(oi.price_usd) AS gross_revenue
    FROM order_items oi
    GROUP BY oi.product_id
),

product_refunds AS (
    SELECT
        oi.product_id,
        COUNT(oir.order_item_id) AS units_refunded,
        SUM(oir.refund_amount_usd) AS total_refund_amount
    FROM order_items oi
    JOIN order_item_refunds oir
        ON oi.order_item_id = oir.order_item_id
    GROUP BY oi.product_id
)

SELECT
    ps.product_id,
    ps.units_sold,
    COALESCE(pr.units_refunded, 0) AS units_refunded,
    ROUND(100.0 * COALESCE(pr.units_refunded, 0) / ps.units_sold, 2) AS refund_rate,
    ps.gross_revenue,
    COALESCE(pr.total_refund_amount, 0) AS total_refund_amount,
    ROUND(100.0 * COALESCE(pr.total_refund_amount, 0) / ps.gross_revenue, 2) AS refund_monetary_share
FROM product_sales ps
LEFT JOIN product_refunds pr
    ON ps.product_id = pr.product_id
ORDER BY refund_rate DESC;



#Q2) Do customers who purchase Product A tend to buy more add-on products compared to other products?
	# get orders where product A is primary product. ----- > add-on items= (items_purchased - 1) 
    # price of 1 product A is 49.99
    # same order_id but different product_id from primary_product_id
    
WITH order_level_items AS (
    SELECT
        oi.order_id,
        SUM(CASE WHEN oi.is_primary_item = 0 THEN 1 ELSE 0 END) AS addon_items_count,
        SUM(CASE WHEN oi.is_primary_item = 0 THEN oi.price_usd ELSE 0 END) AS addon_revenue
    FROM order_items oi
    GROUP BY oi.order_id
)

SELECT
    o.primary_product_id,
    SUM(COALESCE(ol.addon_items_count, 0)) AS addon_items_count,
    SUM(COALESCE(ol.addon_revenue, 0)) AS addon_revenue
FROM orders o
LEFT JOIN order_level_items ol
    ON o.order_id = ol.order_id
GROUP BY o.primary_product_id;


# 3) How does conversion rate differ by product landing page?
# How do users move through the e-commerce funnel, 
# and where do the largest drop-offs occur across different landing pages and product views?

-- CHECKING ALL PAGES
SELECT distinct pageview_url
FROM website_pageviews;



-- To check the flow of funnel channel
SELECT website_session_id, website_pageview_id, created_at, pageview_url
FROM website_pageviews
WHERE website_session_id in 
	(SELECT website_session_id
	FROM website_pageviews
	WHERE pageview_url = "/thank-you-for-your-order")
ORDER BY website_session_id, created_at
LIMIT 10000;

-- Funnel >> # First Page -  Lander/ Home ---> product_page --> specific_product ---> cart ----> shipping ----> billing ----> thank-you message


WITH pageview_level AS (
    SELECT 
        website_session_id,
        CASE
            WHEN pageview_url IN (
                '/home', '/lander-1', '/lander-2',
                '/lander-3', '/lander-4', '/lander-5'
            ) THEN 1 ELSE 0
        END AS landing_page_visit,

        CASE
            WHEN pageview_url IN (
                '/the-original-mr-fuzzy',
                '/the-forever-love-bear',
                '/the-birthday-sugar-panda',
                '/the-hudson-river-mini-bear'
            ) THEN 1 ELSE 0
        END AS product_visit,

        CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page_visit,
        CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page_visit,
        CASE WHEN pageview_url IN ('/billing', '/billing-2') THEN 1 ELSE 0 END AS billing_page_visit,
        CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thank_you_page_visit
    FROM website_pageviews) ,

		website_flow_flag AS (
			SELECT 
				website_session_id,
				MAX(landing_page_visit) AS landing_page_visit,
				MAX(product_visit) AS product_visit,
				MAX(cart_page_visit) AS cart_page_visit,
				MAX(shipping_page_visit) AS shipping_page_visit,
				MAX(billing_page_visit) AS billing_page_visit,
				MAX(thank_you_page_visit) AS thank_you_page_visit
			FROM pageview_level
			GROUP BY website_session_id
		)


SELECT
    COUNT(*) AS total_sessions,
    SUM(landing_page_visit) AS landing_page_sessions,
    100*SUM(product_visit)/SUM(landing_page_visit) AS landing_to_product_conv_rate,
    100*SUM(cart_page_visit)/SUM(product_visit) AS product_to_cart_conv_rate,
    100*SUM(shipping_page_visit)/SUM(cart_page_visit) AS cart_to_shipping_conv_rate,
    100*SUM(billing_page_visit)/SUM(shipping_page_visit) AS shipping_to_billing_conv_rate,
    100*SUM(thank_you_page_visit)/SUM(billing_page_visit) AS billing_to_purchase_conv_rate
FROM website_flow_flag;



# 4) Which traffic sources drive the highest revenue per session?
	-- Revenue per session is the total order revenue 
	-- attributed to a traffic source divided by the total number of website sessions from that source.


SELECT DISTINCT utm_source, utm_campaign, utm_content, http_referer
FROM website_sessions;

WITH channel_data as 
		(SELECT
			website_session_id, 
			utm_source, 
			http_referer,
				CASE
					WHEN utm_source IN ('bsearch','gsearch') THEN 'Paid Search'
					WHEN utm_source = 'socialbook' THEN 'Paid Social'
                    WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com','https://www.bsearch.com') THEN 'Organic Search'
                    WHEN utm_source IS NULL AND http_referer IS NULL then 'Direct'										
					ELSE 'Other Channel'
				END AS Channel_info
		FROM website_sessions),
	sessions_revenue_data	as
		(SELECT  SUM(coalesce(OS.price_usd,0)) as revenue, count(cd.website_session_id) as total_sessions, cd.Channel_info
		FROM channel_data cd 
		LEFT JOIN orders os on cd.website_session_id = os.website_session_id
		GROUP BY cd.channel_info)

SELECT 
	Channel_info, 
    revenue,
    total_sessions, 
    1.0 *(revenue/total_sessions) as revenue_per_session
FROM sessions_revenue_data;

# 5) How has overall conversion rate changed over time, and is revenue growth driven more by traffic or better conversion?
		/* 
		What time granularity will you use (monthly / quarterly)? -- using month
		Which tables will you need to answer this question? -- website and orders table
		What two metrics will you directly compare over time? revenue growth, total_sessions_growth, conversion_rate
        */
	
    -- Conversion_rate - total_orders/total_sessions
    -- Traffic - total_website_sessions

with total_sessions_data AS
	(SELECT
		year(ws.created_at) as year, 
		MONTH(ws.created_at) as month,
		count(ws.website_session_id) as total_sessions,
		LAG(count(ws.website_session_id), 1, null) OVER(order by year(ws.created_at), MONTH(ws.created_at)) as previous_month_total_sessions,
		(count(ws.website_session_id) -
		LAG(count(ws.website_session_id), 1, null) OVER(order by year(ws.created_at), MONTH(ws.created_at)))*100.00/
		LAG(count(ws.website_session_id), 1, null) OVER(order by year(ws.created_at), MONTH(ws.created_at)) as growth_percent_total_sessions
	FROM website_sessions ws
	group by year(ws.created_at),month(ws.created_at)),
	orders_data as
		(SELECT
			YEAR(created_at) as year, 
			MONTH(created_at) as month,
			SUM(price_usd) as total_revenue,
            LAG(SUM(price_usd), 1, null) OVER(ORDER BY YEAR(created_at), MONTH(created_at)) as revenue_previous_month,
            100.0*(SUM(price_usd) -
            LAG(SUM(price_usd), 1, null) OVER(ORDER BY YEAR(created_at), MONTH(created_at)))/             
            LAG(SUM(price_usd), 1, null) OVER(ORDER BY YEAR(created_at), MONTH(created_at)) as revenue_growth,
			count(order_id) as total_orders
		FROM orders
		GROUP BY year(created_at),month(created_at))
        
SELECT 
	td.year, 
    td.month,
    td.total_sessions,
    td.previous_month_total_sessions,
    od.total_orders,
    LAG(100.0*od.total_orders/td.total_sessions,1, NULL) OVER(ORDER BY td.year ,td.month) AS previous_conversion_rate,
    od.total_revenue,
    od.revenue_growth,
    100.0*od.total_orders/td.total_sessions as conversion_rate,
    td.growth_percent_total_sessions
    
FROM total_sessions_data td
LEFT JOIN orders_data od ON (td.year = od.year) AND (td.month = od.month)
;
-- Conclusion 
-- > conversion rate has steadily increased over the period of time which was 2-3 % in intial years and 7-8% after 3 years.
-- > growth of revenue looks to be more correlated with total traffic as compared to conversion rate.


# 6) What is the revenue impact of refunds on overall profitability, and which products contribute most to revenue loss?

	# revenue loss = value of products that has been returned
    # impact on profitability refers to profit margin loss on the products that has been returned =  value of products that has been returned - cost of goods
    # order_item_refund_id, created_at, order_item_id, order_id, refund_amount_usd


WITH order_refunds_data as
		(SELECT o.order_item_id, o.order_id, o.product_id, o.price_usd as order_price, o.cogs_usd as order_cost,
				oir.order_item_refund_id, oir.refund_amount_usd
		FROM order_items o
		LEFT JOIN order_item_refunds oir ON o.order_item_id = oir.order_item_id)

SELECT 
	product_id, 
    COUNT(order_item_id) as units_ordered, 
    count(order_item_refund_id) as units_refunded,
    SUM(refund_amount_usd) AS revenue_lost,
    SUM(refund_amount_usd - order_cost) AS Profit_loss,
    100.0*count(order_item_refund_id)/COUNT(order_item_id) as refund_rate_percent
FROM order_refunds_data
GROUP BY product_id