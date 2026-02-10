# E-commerce-Product-Growth-Analytics-Case-Study
Analysed an e-commerce business to understand product performance, user conversion behaviour, acquisition efficiency, growth drivers, and the financial impact of refunds.


## 📌 Project Overview
This project analyzes an e-commerce business to understand **product performance, user conversion behavior, acquisition efficiency, growth drivers, and the financial impact of refunds**.  
The goal is to translate raw behavioral and transactional data into **actionable product and business insights**.

The analysis combines **web analytics**, **order data**, and **refund data** to answer key product and growth questions typically faced by Product and Growth teams.

---

## 🎯 Business Objectives
- Identify products that cause the highest revenue and profitability loss
- Understand cross-sell (add-on) behaviour across products
- Analyze end-to-end conversion funnel and diagnose drop-offs
- Evaluate acquisition channel efficiency using revenue per session
- Determine whether growth is driven by traffic or conversion improvements
- Quantify the financial impact of refunds at a product level

---

## 🗂️ Data Used
The analysis is based on six relational tables:

- `website_sessions` – session-level acquisition data  
- `website_pageviews` – user navigation and funnel behavior  
- `orders` – order-level transactions  
- `order_items` – item-level product and cost data  
- `order_item_refunds` – item-level refund details  
- `products` – product catalog metadata  

---

## 🔍 Key Questions & Insights

---

### 1️⃣ Product Refund Performance
**Question:**  
Which products have the highest refund rates, and how does this relate to sales volume?

**Key Insights:**
- One product shows the **highest refund rate**, indicating a potential quality or expectation mismatch.
- Another product causes the **largest absolute revenue and profit loss** due to its high sales volume.
- This distinction highlights the difference between **quality problems (high refund rate)** and **scale problems (high absolute loss)**.

**Product Takeaway:**  
Prioritize high-loss products for immediate financial impact and high-refund-rate products for quality investigation.

---

### 2️⃣ Cross-Sell / Add-On Behavior
**Question:**  
Do customers who purchase Product A tend to buy more add-on products?

**Key Insights:**
- Orders with Product A as the primary item generate the **highest number of add-on items and add-on revenue**.
- Product A functions as a strong **anchor product** that increases basket size.

**Product Takeaway:**  
Use anchor products for bundling, upsells, and promotional strategies.

---

### 3️⃣ Funnel Analysis & Conversion Drop-Offs
**Question:**  
How do users move through the e-commerce funnel, and where do the largest drop-offs occur?

**Funnel Conversion Rates:**
- Landing → Product: ~44%
- Product → Cart: ~45%
- Cart → Shipping: ~68%
- Shipping → Billing: ~81%
- Billing → Purchase: ~62%

**Key Insights:**
- Major friction points occur at:
  - **Product → Cart** (product page effectiveness)
  - **Billing → Purchase** (payment friction)
- Shipping and billing form UX performs relatively well.

**Product Takeaway:**  
Focus optimization on product pages and payment experience rather than early checkout steps.

---

### 4️⃣ Revenue per Session by Traffic Source
**Question:**  
Which acquisition channels drive the highest revenue per session?

**Results (Revenue per Session):**
- Organic Search: ~$4.53  
- Direct: ~$4.37  
- Paid Search: ~$4.08  
- Paid Social: ~$2.08  

**Key Insights:**
- Organic and Direct traffic represent **high-intent users**.
- Paid Search performs competitively and appears scalable.
- Paid Social underperforms, generating ~50% of Paid Search revenue per session.

**Growth Takeaway:**  
Treat Paid Social as a discovery or retargeting channel and optimize funnel alignment before scaling spend.

---

### 5️⃣ Growth Drivers Over Time
**Question:**  
Is revenue growth driven more by traffic growth or conversion improvement?

**Key Insights:**
- Conversion rate improved structurally from ~3% to ~8% over time, indicating strong funnel optimization.
- Once conversion stabilized, **month-to-month revenue changes closely followed traffic fluctuations**.
- This indicates a shift from **optimization-led growth** to **acquisition-led growth**.

**Strategy Takeaway:**  
Future growth should focus on scaling high-quality acquisition channels rather than incremental conversion gains.

---

### 6️⃣ Refund Impact on Profitability
**Question:**  
What is the revenue and profitability impact of refunds, and which products contribute most to loss?

**Metrics Defined:**
- **Revenue Loss:** Sum of refunded amounts  
- **Profit Loss:** Refunded amount minus unrecoverable cost of goods (COGS)

**Key Insights:**
- Some products cause high financial loss due to scale despite moderate refund rates.
- Other products exhibit high refund rates but lower absolute loss, signaling quality issues.
- Evaluating both **refund rate** and **absolute profit loss** enables better prioritization.

**Business Takeaway:**  
Address scale-driven refund losses for immediate financial impact and quality-driven refunds for long-term improvement.

---

## 🛠️ Tools & Skills Demonstrated
- SQL (CTEs, window functions, joins, aggregation)
- Funnel analysis & conversion metrics
- Product analytics & growth decomposition
- Revenue and profitability analysis
- Data modeling at correct analytical grain
- Business storytelling with data


---

## 👤 Author
**[Kartik Mandlekar]**  
Aspiring Product / Product Analytics professional  
