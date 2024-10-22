# MySQL Project: Financial Analytics, Top Customers & Products, and Supply Chain Analytics

## Project Overview
This project involves various aspects of data analysis using MySQL, focusing on financial analytics, customer/product performance, market ranking, and supply chain efficiency.

## Objectives
- To analyze gross sales and net sales data.
- To generate detailed reports and views for top customers, products, and markets.
- To automate database updates and improve forecast accuracy for the supply chain.

## Technologies Used
- **Database Management System:** MySQL
- **Programming Languages:** SQL

## Key Features

### 1. Financial Analytics
- **Gross Sales Report**: Created to evaluate overall sales performance.
- **User-Defined Functions**: Developed custom functions for:
  - **Fiscal Year**
  - **Fiscal Quarter**
- **Monthly Product Transaction Reports**: Generated detailed reports on monthly product transactions.
- **Total Sales Amount**: Compiled a report reflecting the total sales amount for various products.
- **Stored Procedures**:
  - **Monthly Gross Sales Report**: Automated report generation for monthly sales.
  - **Country-wise Market Badge (Gold, Silver)**: Identified top-ranking countries by market performance.

### 2. Top Customers, Products, and Markets
- **Pre-Invoice Report**: Generated reports before invoices are issued for customer analysis.
- **Database Views**: Created various views for analyzing sales data, including:
  - **Gross Sales**
  - **Net Sales**
  - **Sales Post-Invoice**
  - **Sales Pre-Invoice**
- **Stored Procedures**:
  - **Top Markets and Customers**: Automated the identification of the best-performing markets and customers.
  - **Top Products**: Identified the most popular products based on sales data.
- **Window Function**:
  - Utilized window functions to calculate **Net Sales Global Market Share %**.

### 3. Supply Chain Analytics
- **Stored Procedure for Forecast Accuracy**: Evaluated the accuracy of sales forecasts compared to actual sales.
- **Triggers**:
  - Created triggers for `fact_forecast_monthly` and `fact_sales_monthly` tables to automate database updates when new data is inserted.

## Methodology
1. **Data Collection**: Gathered transaction and sales data from various sources, amounting to a 240 MB database file, and successfully imported it into MySQL for analysis.
2. **Report Generation**: Utilized SQL queries, views, and stored procedures to create detailed financial and customer reports.
3. **Automated Updates**: Implemented triggers for automated data handling in the supply chain section.


## Key Findings
- **Financial Insights**: Generated accurate Gross and Net Sales reports, identifying trends and product performance.
- **Top Customers and Markets**: Discovered the best-performing markets and customers, providing insights for business strategy.
- **Supply Chain Efficiency**: Automated updates in sales and forecast data improved forecasting and operational efficiency.

## Conclusion
This project successfully provided key insights into financial analytics, customer and product performance, and supply chain management. The automated processes and detailed reports generated significant value for business decision-making.
