"""
E-commerce Data Analysis - Chart Generation Script
----------------------------------------------------
Fetches data from the Ecommerce_db MySQL database (created via
E-commerce_db.sql) and generates 5 business-insight visualizations
using Pandas, Matplotlib, and Seaborn.

Install dependencies:
    pip install pandas matplotlib seaborn sqlalchemy pymysql python-dotenv

Setup:
    1. Copy .env.example to .env
    2. Fill in your actual MySQL credentials in .env
    3. Never commit .env to GitHub (already listed in .gitignore)

Usage:
    python ecommerce_analysis.py
"""

import os
import pandas as pd
import matplotlib
matplotlib.use('Agg')  # remove this line if running with a GUI/Jupyter
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import seaborn as sns
from sqlalchemy import create_engine
from dotenv import load_dotenv

# ------------------------------------------------------------------
# 1. DATABASE CONNECTION (credentials loaded from .env, not hardcoded)
# ------------------------------------------------------------------
load_dotenv()  # reads the .env file in the project root

DB_CONFIG = {
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD"),
    "host": os.getenv("DB_HOST", "localhost"),
    "port": os.getenv("DB_PORT", "3306"),
    "database": os.getenv("DB_NAME"),
}

missing = [k for k, v in DB_CONFIG.items() if v is None]
if missing:
    raise EnvironmentError(
        f"Missing required .env variables: {missing}. "
        f"Copy .env.example to .env and fill in your credentials."
    )

engine = create_engine(
    f"mysql+pymysql://{DB_CONFIG['user']}:{DB_CONFIG['password']}"
    f"@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}"
)

sns.set_style("whitegrid")

# Output folder — defaults to a local "visualizations" folder next to this
# script (works on Windows/Mac/Linux). On Android/Termux/Pydroid3, set the
# OUTPUT_DIR environment variable (e.g. in .env) to override, for example:
#   OUTPUT_DIR=/sdcard/Termux
OUTPUT_DIR = os.getenv("OUTPUT_DIR", os.path.join(os.path.dirname(os.path.abspath(__file__)), "visualizations"))

# Create folder if it does not exist (prevents save errors)
os.makedirs(OUTPUT_DIR, exist_ok=True)


# ------------------------------------------------------------------
# 2. FETCH DATA (SQL -> Pandas)
# ------------------------------------------------------------------
def fetch_monthly_revenue():
    """Gross order value vs net revenue collected, month by month."""
    gross_q = """
        SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS month,
               SUM(oi.quantity * oi.price_at_purchase) AS gross_value
        FROM orders o
        JOIN order_items oi ON o.order_id = oi.order_id
        GROUP BY month
        ORDER BY month;
    """
    net_q = """
        SELECT DATE_FORMAT(payment_date, '%Y-%m') AS month,
               SUM(amount) AS net_collected
        FROM payments
        GROUP BY month
        ORDER BY month;
    """
    gross_df = pd.read_sql(gross_q, engine)
    net_df = pd.read_sql(net_q, engine)
    # LEFT join on gross_df (order-driven months) intentionally, not "outer".
    # A payment can land 1-2 days after the last order date, spilling into
    # a calendar month that has zero orders yet. An outer join would add a
    # phantom trailing month (gross=0, net>0) that reads as a revenue crash
    # on the chart. Left join keeps only months where orders actually exist.
    merged = pd.merge(gross_df, net_df, on="month", how="left").fillna(0)
    return merged.sort_values("month")


def fetch_order_status():
    """Count of orders in each status."""
    q = """
        SELECT order_status, COUNT(*) AS cnt
        FROM orders
        GROUP BY order_status
        ORDER BY cnt DESC;
    """
    return pd.read_sql(q, engine)


def fetch_category_revenue():
    """Gross order value grouped by product category."""
    q = """
        SELECT p.category, SUM(oi.quantity * oi.price_at_purchase) AS revenue
        FROM order_items oi
        JOIN products p ON oi.product_id = p.product_id
        GROUP BY p.category
        ORDER BY revenue DESC;
    """
    return pd.read_sql(q, engine)


def fetch_payment_methods():
    """Count and total amount per payment method."""
    q = """
        SELECT payment_method, COUNT(*) AS cnt, SUM(amount) AS amt
        FROM payments
        GROUP BY payment_method
        ORDER BY cnt DESC;
    """
    return pd.read_sql(q, engine)


def fetch_top_customers():
    """
    Top 10 customers by total amount paid.
    Joins all 5 tables: customers + orders + order_items + products + payments.

    IMPORTANT: order_items is aggregated to order-level in a subquery BEFORE
    joining with payments. Joining order_items directly to payments would
    cause fan-out (payment amount duplicated once per line item), inflating
    totals. Products is joined only to make the query touch every table;
    it isn't needed for the aggregation itself.
    """
    q = """
        SELECT
            c.customer_name,
            c.city,
            COUNT(DISTINCT o.order_id) AS num_orders,
            SUM(ot.order_value) AS total_order_value,
            SUM(pay.amount) AS total_paid
        FROM customers c
        JOIN orders o ON c.customer_id = o.customer_id
        JOIN (
            SELECT oi.order_id, SUM(oi.quantity * oi.price_at_purchase) AS order_value
            FROM order_items oi
            JOIN products p ON oi.product_id = p.product_id
            GROUP BY oi.order_id
        ) ot ON o.order_id = ot.order_id
        LEFT JOIN payments pay ON o.order_id = pay.order_id
        GROUP BY c.customer_id, c.customer_name, c.city
        ORDER BY total_paid DESC
        LIMIT 10;
    """
    return pd.read_sql(q, engine)


# ------------------------------------------------------------------
# 3. BUILD CHARTS
# ------------------------------------------------------------------
def chart_monthly_revenue(df):
    fig, ax = plt.subplots(figsize=(13, 6))
    ax.plot(df["month"], df["gross_value"], marker="o", markersize=4,
            label="Gross Order Value", color="#4C72B0", linewidth=2.2)
    ax.plot(df["month"], df["net_collected"], marker="o", markersize=4,
            label="Net Revenue Collected", color="#DD8452", linewidth=2.2)
    ax.fill_between(df["month"], df["gross_value"], df["net_collected"],
                     color="#DD8452", alpha=0.08)
    ax.set_title("Monthly Trend: Gross Order Value vs Net Revenue Collected",
                 fontsize=15, fontweight="bold", pad=14)
    ax.set_xlabel("Month", fontsize=11, labelpad=8)
    ax.set_ylabel("Amount (Rs.)", fontsize=11)
    ax.yaxis.set_major_formatter(mticker.FuncFormatter(lambda x, _: f"{x/1000:.0f}K"))
    # show every other month label so long date ranges stay readable
    tick_idx = list(range(0, len(df), 2))
    if (len(df) - 1) not in tick_idx:
        tick_idx.append(len(df) - 1)
    ax.set_xticks([df["month"].iloc[i] for i in tick_idx])
    plt.xticks(rotation=45, ha="right", fontsize=9)
    ax.legend(fontsize=10, frameon=True)
    ax.grid(axis="y", alpha=0.3)
    plt.tight_layout()
    plt.savefig(f"{OUTPUT_DIR}/chart1_monthly_revenue.png", dpi=300)
    plt.close()


def chart_order_status(df):
    colors = {"Delivered": "#55A868", "Shipped": "#4C72B0", "Cancelled": "#C44E52",
              "Pending": "#DD8452", "Returned": "#8172B2"}
    fig, ax = plt.subplots(figsize=(9, 5.5))
    bars = ax.bar(df["order_status"], df["cnt"],
                   color=[colors.get(s, "#999") for s in df["order_status"]])
    total = df["cnt"].sum()
    for b, cnt in zip(bars, df["cnt"]):
        pct = cnt / total * 100
        ax.text(b.get_x() + b.get_width() / 2, b.get_height() + 5,
                f"{int(cnt)}\n({pct:.1f}%)", ha="center", fontweight="bold")
    ax.set_title(f"Order Status Distribution (Total {total:,} Orders)",
                 fontsize=13, fontweight="bold")
    ax.set_ylabel("Number of Orders")
    plt.tight_layout()
    plt.savefig(f"{OUTPUT_DIR}/chart2_order_status.png", dpi=300)
    plt.close()


def chart_category_revenue(df):
    fig, ax = plt.subplots(figsize=(9, 5.5))
    bars = ax.barh(df["category"][::-1], df["revenue"][::-1], color="#4C72B0")
    total = df["revenue"].sum()
    for b in bars:
        pct = b.get_width() / total * 100
        ax.text(b.get_width() + 10000, b.get_y() + b.get_height() / 2,
                f"Rs. {b.get_width()/100000:.1f}L ({pct:.1f}%)", va="center", fontsize=9)
    ax.set_title("Gross Order Value by Product Category", fontsize=13, fontweight="bold")
    ax.set_xlabel("Revenue (Rs.)")
    ax.xaxis.set_major_formatter(mticker.FuncFormatter(lambda x, _: f"{x/100000:.1f}L"))
    plt.tight_layout()
    plt.savefig(f"{OUTPUT_DIR}/chart3_category_revenue.png", dpi=300)
    plt.close()


def chart_payment_methods(df):
    fig, ax = plt.subplots(figsize=(9, 5.5))
    bars = ax.bar(df["payment_method"], df["cnt"], color="#55A868")
    total = df["cnt"].sum()
    for b, cnt in zip(bars, df["cnt"]):
        pct = cnt / total * 100
        ax.text(b.get_x() + b.get_width() / 2, b.get_height() + 3,
                f"{int(cnt)}\n({pct:.1f}%)", ha="center", fontsize=9, fontweight="bold")
    ax.set_title(f"Payment Method Usage ({total:,} Completed Payments)",
                 fontsize=13, fontweight="bold")
    ax.set_ylabel("Number of Payments")
    plt.tight_layout()
    plt.savefig(f"{OUTPUT_DIR}/chart4_payment_method.png", dpi=300)
    plt.close()


def chart_top_customers(df):
    df = df.sort_values("total_paid")  # ascending so highest spender is at the top of the barh
    fig, ax = plt.subplots(figsize=(10, 6))
    labels = df["customer_name"] + " (" + df["city"] + ")"
    bars = ax.barh(labels, df["total_paid"], color="#4C72B0")
    for b, orders in zip(bars, df["num_orders"]):
        ax.text(b.get_width() + 2000, b.get_y() + b.get_height() / 2,
                f"Rs. {b.get_width():,.0f} ({orders} orders)", va="center", fontsize=8.5)
    ax.set_title(
        "Top 10 Customers by Total Spend\n"
        "(Joins: customers + orders + order_items + products + payments)",
        fontsize=12, fontweight="bold"
    )
    ax.set_xlabel("Total Amount Paid (Rs.)")
    ax.xaxis.set_major_formatter(mticker.FuncFormatter(lambda x, _: f"{x/1000:.0f}K"))
    plt.tight_layout()
    plt.savefig(f"{OUTPUT_DIR}/chart5_top_customers.png", dpi=300)
    plt.close()


# ------------------------------------------------------------------
# 4. MAIN
# ------------------------------------------------------------------
def main():
    print("Fetching data from MySQL and building charts...")

    monthly_df = fetch_monthly_revenue()
    chart_monthly_revenue(monthly_df)
    print(f"  {OUTPUT_DIR}/chart1_monthly_revenue.png done")

    status_df = fetch_order_status()
    chart_order_status(status_df)
    print(f"  {OUTPUT_DIR}/chart2_order_status.png done")

    category_df = fetch_category_revenue()
    chart_category_revenue(category_df)
    print(f"  {OUTPUT_DIR}/chart3_category_revenue.png done")

    payment_df = fetch_payment_methods()
    chart_payment_methods(payment_df)
    print(f"  {OUTPUT_DIR}/chart4_payment_method.png done")

    top_customers_df = fetch_top_customers()
    chart_top_customers(top_customers_df)
    print(f"  {OUTPUT_DIR}/chart5_top_customers.png done")

    print(f"All charts saved successfully in '{OUTPUT_DIR}/' folder.")


if __name__ == "__main__":
    main()
