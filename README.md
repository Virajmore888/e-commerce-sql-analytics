# 🛒 E-Commerce SQL Analysis - Database Design & Business Intelligence Engine

<div align="center">

### *1,013 orders. 5 relational tables. A 19.2% revenue gap most dashboards would miss.*

[![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=for-the-badge&logo=mysql&logoColor=white)](https://www.mysql.com/)
[![Python](https://img.shields.io/badge/Python-3-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![Pandas](https://img.shields.io/badge/Pandas-2.0+-150458?style=for-the-badge&logo=pandas&logoColor=white)](https://pandas.pydata.org/)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Viraj%20More-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/viraj-uttam-more-a24a80391)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](./LICENSE)

**[📝 Full Report](https://github.com/Virajmore888/e-commerce-sql-analytics/blob/main/docs/Ecommerce_Analysis_Report.pdf) · [📊 Presentation](https://github.com/Virajmore888/e-commerce-sql-analytics/blob/main/docs/Ecommerce_SQL_Analysis_Presentation.pdf) · [💻 SQL Scripts](https://github.com/Virajmore888/e-commerce-sql-analytics/tree/main/sql)**

*Saturday, July 4, 2026*

</div>

---

## 👋 About This Project

Hi, I'm **Viraj More**, an aspiring Data Analyst who wanted to go one level deeper than a pre-cleaned CSV. This project simulates a real online retail business end-to-end: I **designed the relational schema myself**, enforced real referential integrity (foreign keys, CHECK constraints, cascading deletes), generated a large synthetic dataset against documented business rules, and then used SQL (joins, subqueries, CTEs, window functions) to answer the kind of ambiguous, multi-table questions a business stakeholder would actually ask.

> If you're a recruiter or fellow analyst, the TL;DR below tells you everything in 30 seconds. The rest of the README is for those who want to go deeper.

> ⚠️ **Data Disclaimer:** This project uses a **synthetically generated dataset**, built specifically for portfolio and learning purposes. It is not sourced from a real business and does not represent actual sales, customers, or transactions. The data was generated against documented business rules and passed every referential-integrity check before any chart was built. See the [Full Report](https://github.com/Virajmore888/e-commerce-sql-analytics/blob/main/docs/Ecommerce_Analysis_Report.pdf) for the complete disclaimer. The SQL techniques and JOIN logic demonstrated apply directly to real-world relational data at any scale.

---

## ⚡ TL;DR: 5 Findings That Change How You'd Run This Business

| # | Finding | Business Impact |
|---|---------|-----------------|
| 1 | 💸 Gross order value **Rs. 64.8L** vs. net revenue **Rs. 52.4L** | A 19.2% gap: reporting "orders" as "revenue" overstates cash collected |
| 2 | ❌ Cancellations (10.8%) **outnumber** Returns (6.7%) | More value is lost pre-payment than post-delivery: checkout fixes > returns handling |
| 3 | 📦 Electronics + Home & Kitchen = **57.7%** of order value | Category concentration risk worth tracking as a recurring KPI |
| 4 | 💳 UPI leads at **42.8%** of payment volume | Checkout reliability on one rail disproportionately affects conversion |
| 5 | 👥 **Zero** single-customer concentration risk | Top 10 customers combined are a small, healthy slice of total revenue |

---

## 🎯 What Makes This Project Different

Most beginner SQL portfolios stop at `SELECT * FROM table` against a dataset someone else cleaned.

| Typical SQL Portfolios | This Project |
|---|---|
| Downloads a ready-made CSV | Designs the **5-table schema from scratch** with enforced constraints |
| Reports "total order value" as revenue | Separates **gross order value** from **net revenue collected** via LEFT JOIN |
| Uses INNER JOIN by default | Deliberately uses LEFT JOIN where completeness matters, documented, not accidental |
| One flat query per chart | Layers **joins → subqueries → CTEs → window functions** |
| Trusts the dataset blindly | Runs 5 integrity checks (0 violations) before any chart is built |

---

## 💡 Key Business Insights

### 1. 💸 Revenue Reports That Overstate Reality
Gross order value across the dataset is **Rs. 64.8L**, but net revenue actually collected via the `payments` table is **Rs. 52.4L**, a **19.2% gap** driven by Pending and Cancelled orders that never generate a payment row. Any dashboard built off `orders` alone, without joining `payments`, silently overstates real cash collected.

<details>
<summary><b>🖼️ View Chart: Monthly Revenue Trend</b></summary>
<br>
<img src="https://raw.githubusercontent.com/Virajmore888/e-commerce-sql-analytics/main/visuals/chart1_monthly_revenue.png" alt="Monthly Revenue Trend" width="800">
</details>

---

### 2. ❌ Cancellations Outpacing Returns
**109 orders (10.8%)** were Cancelled versus **68 (6.7%)** Returned, more value is lost *before* payment than *after* delivery. That points to checkout-flow friction (payment failures, stock-availability issues) as the higher-leverage, cheaper fix compared to post-delivery returns handling.

<details>
<summary><b>🖼️ View Chart: Order Status Distribution</b></summary>
<br>
<img src="https://raw.githubusercontent.com/Virajmore888/e-commerce-sql-analytics/main/visuals/chart2_order_status.png" alt="Order Status Distribution" width="800">
</details>

---

### 3. 📦 Category Revenue Concentration
**Electronics (34.6%)** and **Home & Kitchen (23.1%)** together drive **57.7%** of gross order value, while **Beauty & Personal Care** sits at just **9.5%** despite a comparable average price point, the clearest candidate for catalog expansion.

<details>
<summary><b>🖼️ View Chart: Category-Wise Revenue</b></summary>
<br>
<img src="https://raw.githubusercontent.com/Virajmore888/e-commerce-sql-analytics/main/visuals/chart3_category_revenue.png" alt="Category-Wise Revenue" width="800">
</details>

---

### 4. 💳 Payment Rail Concentration
**UPI dominates with 42.8%** of the 820 completed payments, followed by Card (25.9%), COD (19.9%), and NetBanking (11.5%). UPI + Card + NetBanking together cover over 80% of volume, most revenue settles instantly rather than sitting in COD collection delays.

<details>
<summary><b>🖼️ View Chart: Payment Method Usage</b></summary>
<br>
<img src="https://raw.githubusercontent.com/Virajmore888/e-commerce-sql-analytics/main/visuals/chart4_payment_method.png" alt="Payment Method Usage" width="800">
</details>

---

### 5. 👥 No Single-Customer Concentration Risk
The top spender, **Arjun Mukherjee (Kolkata)**, has paid **Rs. 64,473** across 6 orders; the #10-ranked customer still paid **Rs. 47,874** across 5 orders. What separates the top 10 is **order frequency (5-7 orders each)**, not one big-ticket purchase, a healthy, loyalty-driven customer base rather than a fragile one.

<details>
<summary><b>🖼️ View Chart: Top 10 Customers by Spend</b></summary>
<br>
<img src="https://raw.githubusercontent.com/Virajmore888/e-commerce-sql-analytics/main/visuals/chart5_top_customers.png" alt="Top 10 Customers" width="800">
</details>

---

## ⚙️ Technical Architecture

| Technique | Applied To |
|---|---|
| **Multi-table JOIN (INNER + LEFT)** | 5-table chain: `customers → orders → order_items → products → payments` |
| **Subquery in FROM clause** | Order-level aggregation before joining to `payments`, to avoid fan-out inflating totals |
| **Subquery in HAVING clause** | Identifying customers spending above the average customer's total spend |
| **CTE (WITH clause)** | Monthly gross order value as a reusable, named result set |
| **Window Fn: `SUM() OVER`** | Cumulative running total of monthly revenue |
| **Window Fn: `RANK()`** | Customer spend leaderboard; best-seller per category |
| **Window Fn: `LAG()`** | Month-over-month growth % |
| **`NULLIF()` for safe division** | Avoiding a divide-by-zero crash in the first month of growth calculations |
| **`EXPLAIN`** | Verifying index usage on key filter/join columns |

### Real Bugs This Design Caught
- **Fan-out on JOIN:** Joining `order_items` straight to `payments` would've inflated totals, fixed by aggregating to order-level first.
- **Silent row loss:** An INNER JOIN would silently drop unpaid Pending/Cancelled orders, fixed with LEFT JOIN wherever completeness mattered.
- **Fragile GROUP BY:** Grouping by `customer_name` alone risked merging two people with the same name, fixed by grouping on `customer_id` too.
- **Divide-by-zero:** Growth % is undefined in month one, fixed by wrapping the denominator in `NULLIF(prev_month_value, 0)`.

---

## 🛠️ Skills Demonstrated

`MySQL 8` · `SQL Joins` · `Subqueries` · `CTEs` · `Window Functions` · `Database Schema Design` · `Referential Integrity` · `Python` · `Pandas` · `Matplotlib` · `Seaborn` · `SQLAlchemy` · `PyMySQL` · `Business Intelligence` · `Data Visualization`

---

## 🚀 Run This Project Locally

### Prerequisites
- MySQL 8
- Python 3
- pip

### Step 1: Clone
```bash
git clone https://github.com/Virajmore888/e-commerce-sql-analytics.git
cd e-commerce-sql-analytics
```

### Step 2: Build the Database
Run the SQL scripts **in order** inside your MySQL client:
```bash
mysql -u your_username -p < sql/01_schema.sql
mysql -u your_username -p < sql/02_data_insert.sql
```
📄 [View SQL Scripts](https://github.com/Virajmore888/e-commerce-sql-analytics/tree/main/sql)

### Step 3: Install Python Dependencies
```bash
pip install -r requirements.txt
```

### Step 4: Configure Credentials
Create a `.env` file in the project root with your MySQL connection details (excluded from Git via `.gitignore`):
```
DB_HOST=localhost
DB_USER=your_username
DB_PASSWORD=your_password
DB_NAME=Ecommerce_db
```

### Step 5: Run the Analysis
```bash
python python/ecommerce_analysis.py
```
📄 [View Python Script](https://github.com/Virajmore888/e-commerce-sql-analytics/tree/main/python)

### Step 6: Explore the Queries
Basic and advanced queries can be run directly in your MySQL client:
📄 [View SQL Scripts](https://github.com/Virajmore888/e-commerce-sql-analytics/tree/main/sql)

---

## 📦 Dependencies

```
pandas>=2.0.0
matplotlib>=3.7.0
seaborn>=0.12.0
SQLAlchemy>=2.0.0
PyMySQL>=1.1.0
python-dotenv>=1.0.0
```

---

## 📊 Dataset at a Glance

| Attribute | Value |
|---|---|
| **Source** | Synthetically generated in-house |
| **Customers** | 300 (289 active, 96.3%) |
| **Products** | 32 across 5 categories |
| **Orders** | 1,013 |
| **Order Line Items** | 1,922 |
| **Completed Payments** | 820 |
| **Date Range** | March 2023 – June 2026 |
| **Gross Order Value** | Rs. 64.8L |
| **Net Revenue Collected** | Rs. 52.4L |
| **Payment Collection Rate** | 80.9% |

---

## 📂 Repository Structure

```
e-commerce-sql-analytics/
│
├── 📁 sql/
│   ├── 01_schema.sql              # Table definitions, keys, constraints, indexes
│   ├── 02_data_insert.sql         # Synthetic data generation
│   ├── 03_basic_queries.sql       # Joins, filtering, aggregation
│   └── 04_advanced_queries.sql    # Subqueries, CTEs, window functions
│
├── 📁 python/
│   └── ecommerce_analysis.py      # Query execution + chart generation
│
├── 📁 visuals/
│   ├── chart1_monthly_revenue.png
│   ├── chart2_order_status.png
│   ├── chart3_category_revenue.png
│   ├── chart4_payment_method.png
│   └── chart5_top_customers.png
│
├── 📁 docs/
│   ├── Ecommerce_Analysis_Report.pdf
│   └── Ecommerce_SQL_Analysis_Presentation.pdf
│
├── .gitignore
├── CONTRIBUTING.md
├── LICENSE
├── README.md
└── requirements.txt
```

📁 [sql/](https://github.com/Virajmore888/e-commerce-sql-analytics/tree/main/sql) · [python/](https://github.com/Virajmore888/e-commerce-sql-analytics/tree/main/python) · [visuals/](https://github.com/Virajmore888/e-commerce-sql-analytics/tree/main/visuals) · [docs/](https://github.com/Virajmore888/e-commerce-sql-analytics/tree/main/docs)

---

## 🤝 Connect & Contribute

- 🔗 **LinkedIn:** [Viraj More](https://www.linkedin.com/in/viraj-uttam-more-a24a80391)
- 📧 **Email:** [virajmore.data888@gmail.com](mailto:virajmore.data888@gmail.com)
- 💻 **GitHub:** [e-commerce-sql-analytics](https://github.com/Virajmore888/e-commerce-sql-analytics)

Found something to improve? Open an **Issue** or submit a **Pull Request**, contributions are welcome!
Read the **[Contributing Guide](https://github.com/Virajmore888/e-commerce-sql-analytics/blob/main/CONTRIBUTING.md)** before submitting.

---

## 📄 License

MIT License. See [LICENSE](./LICENSE) for details.

---

<div align="center">

**Built with ❤️ · Schema Design → Synthetic Data → SQL Analytics → Python Visualization → Business Recommendations**

*Saturday, July 4, 2026*

*If this project added value, consider leaving a ⭐ on the repo, it helps others find it too.*

</div>
