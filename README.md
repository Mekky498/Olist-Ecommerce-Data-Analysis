# 🛒 Olist E-Commerce End-to-End Data Analytics Portfolio

An end-to-end data analytics project using the Brazilian E-Commerce public dataset by **Olist** (100k+ orders from 2016 to 2018). 
This project showcases advanced SQL database view design in **SQL Server (SSMS)** and interactive multi-page dashboard modeling in **Power BI Desktop**.

---

## 📊 Dashboard Overview

### 1. Executive Overview
Focuses on commercial performance, monthly growth trends, category revenue breakdown, and payment preferences.

<img width="843" height="493" alt="Olist Dashboard 1" src="https://github.com/user-attachments/assets/51188c5f-b16e-4552-89fc-38f2870b2ee1" />


### 2. Logistics & Fulfillment Analysis
Analyzes regional delivery bottlenecks, state-level shipping lead times, on-time delivery rates, and the correlation between delivery delay and customer review ratings.

<img width="843" height="490" alt="Olist Dashboard 2" src="https://github.com/user-attachments/assets/eace1e9d-3e30-43e2-bbc8-e2c668439ac7" />


---

## 🎯 Key Business Insights & KPIs

- **Gross Revenue:** **$13.59M** generated across **99,441 orders**.
- **On-Time Delivery Rate:** **91.9%** overall fulfillment success rate.
- **Top Revenue Categories:** `health_beauty`, `watches_gifts`, and `bed_bath_table` lead platform total sales.
- **Payment Breakdown:** **78.34%** of transactions are completed via Credit Card, followed by **Boleto (17.92%)**.
- **Regional Bottlenecks:** Northern states (Roraima `RR`, Amapá `AP`, and Amazonas `AM`) experience the longest delivery lead times (averaging 26–29 days vs. ~10 days in São Paulo).
- **Customer Satisfaction Impact:** 5-star customer reviews correspond to an average delivery time of **10.6 days**, whereas 1-star reviews jump significantly to **21.3 days**.

---

## 🛠️ Tech Stack & Architecture

- **Database Management System:** Microsoft SQL Server (SSMS)
- **Data Visualization & BI:** Power BI Desktop
- **Data Modeling / Querying:** T-SQL Views, Advanced Aggregations, Left Joins, Conditional Logic, DAX Measures
- **Dataset:** Olist E-Commerce Public Dataset

---

## 🗄️ SQL Views Developed

1. `vw_Order_Status_Summary` – Order counts & gross revenue by order status.
2. `vw_Product_Category_Performance` – Product sales volume and gross revenue translated into English.
3. `vw_Payment_Type_Performance` – Payment method distributions and total revenue.
4. `vw_State_Performance` & `vw_City_Performance` – Regional customer order volume and average shipping costs.
5. `vw_Delivery_Performance_Details` – Calculated delivery lead times and on-time vs. late status flags.
6. `vw_Delivery_vs_Reviews` – Aggregated delivery days against star review ratings.

---

## 🚀 How to Replicate This Project

1. **Database Setup:**
   - Import the raw Olist CSV files into SQL Server (`Olist_Ecommerce`).
   - Run the scripts inside `/SQL/` to build the required analytical views.

2. **Power BI Report:**
   - Open `Olist_Ecommerce_Dashboard.pbix` in Power BI Desktop.
   - Update the SQL Server connection string to match your local instance.
