# E-Commerce Data Warehouse

A comprehensive data warehouse solution built with SQL Server, implementing a **medallion architecture** (Bronze → Silver → Gold layers) for e-commerce analytics. This project integrates data from multiple source systems (CRM and ERP) and transforms it into a star schema for business intelligence and reporting.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Project Structure](#project-structure)
- [Data Model](#data-model)
- [ETL Process](#etl-process)
- [Usage](#usage)

## 🎯 Overview

This data warehouse implements a **three-layer medallion architecture**:

- **Bronze Layer**: Raw data ingestion from source systems (CRM and ERP)
- **Silver Layer**: Cleaned and validated data with business logic applied
- **Gold Layer**: Business-ready dimensional model (Star Schema) for analytics

### Key Objectives

- Integrate data from heterogeneous sources (CRM and ERP systems)
- Implement data quality rules and transformations
- Provide a star schema optimized for analytical queries
- Enable business intelligence and reporting capabilities

## 🏗️ Architecture

The data warehouse follows a **medallion architecture** pattern:

```
┌─────────────────────────────────────────────────────────┐
│                    DATA SOURCES                          │
│  ┌─────────────────┐         ┌─────────────────┐       │
│  │  CRM System     │         │   ERP System    │       │
│  │  - Customers    │         │   - Demographics│       │
│  │  - Products     │         │   - Locations   │       │
│  │  - Sales        │         │   - Categories  │       │
│  └─────────────────┘         └─────────────────┘       │
└───────────────────┬────────────────┬─────────────────────┘
                    │                │
                    ▼                ▼
┌─────────────────────────────────────────────────────────┐
│                  BRONZE LAYER (Raw)                      │
│  Full load via BULK INSERT from CSV files              │
│  - bronze.crm_cust_info                                 │
│  - bronze.crm_prd_info                                  │
│  - bronze.crm_sales_details                             │
│  - bronze.erp_cust_az12                                 │
│  - bronze.erp_loc_a101                                  │
│  - bronze.erp_px_cat_g1v2                               │
└───────────────────────────┬─────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│               SILVER LAYER (Cleansed)                    │
│  Data quality rules, transformations, deduplication     │
│  - silver.crm_cust_info                                 │
│  - silver.crm_prd_info                                  │
│  - silver.crm_sales_details                             │
│  - silver.erp_cust_az12                                 │
│  - silver.erp_loc_a101                                  │
│  - silver.erp_px_cat_g1v2                               │
└───────────────────────────┬─────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│              GOLD LAYER (Star Schema)                    │
│  Dimensional model for analytics                        │
│  - gold.dim_customers  (Dimension)                      │
│  - gold.dim_products   (Dimension)                      │
│  - gold.fact_sales     (Fact Table)                     │
└─────────────────────────────────────────────────────────┘
```

## ✨ Features

- **Medallion Architecture**: Bronze → Silver → Gold layers for progressive data refinement
- **Multi-Source Integration**: Combines CRM and ERP data sources
- **Data Quality**: Comprehensive data cleansing and validation rules
- **Star Schema**: Optimized dimensional model for analytical queries
- **Automated ETL**: Stored procedures for automated data pipeline execution
- **Deduplication**: Handles duplicate records using ROW_NUMBER()
- **Data Type Conversions**: Transforms integer dates to proper DATE types
- **Business Logic**: Applies business rules and standardizations
- **Audit Tracking**: Timestamps for data lineage (dwh_create_date)

## 📦 Prerequisites

- **SQL Server** (2016 or later)
  - Express, Standard, or Enterprise Edition
- **SQL Server Management Studio (SSMS)** (version 18.0 or later)
- **Windows OS** (for BULK INSERT file access)
- **Git** (for cloning the repository)

### System Requirements

- Minimum 4GB RAM (8GB recommended)
- 5GB available disk space
- File system access for CSV data sources

## 🚀 Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/Amin-16/ecommerce-dwh.git
cd ecommerce-dwh
```

### Step 2: Update File Paths

Before running the scripts, update the file paths in `scripts/bronze/proc_load_bronze.sql` to match your local directory:

```sql
-- Change this path:
FROM 'C:\Users\MOHAMED\Desktop\college\ecommerce-dwh\datasets\source_crm\cust_info.csv'

-- To your local path:
FROM 'C:\YOUR_PATH\ecommerce-dwh\datasets\source_crm\cust_info.csv'
```

### Step 3: Execute Scripts in Order

Open SQL Server Management Studio and run the following scripts **in sequence**:

```sql
-- 1. Initialize Database and Schemas
-- Execute: scripts/init_db.sql
-- Creates: DataWarehouse database with bronze, silver, gold schemas

-- 2. Create Bronze Layer Tables
-- Execute: scripts/bronze/ddl_bronze.sql
-- Creates: All bronze layer tables

-- 3. Create Silver Layer Tables
-- Execute: scripts/silver/ddl_silver.sql
-- Creates: All silver layer tables

-- 4. Create Gold Layer Views
-- Execute: scripts/gold/ddl_gold.sql
-- Creates: Dimensional views (dim_customers, dim_products, fact_sales)

-- 5. Create Bronze Loading Procedure
-- Execute: scripts/bronze/proc_load_bronze.sql
-- Creates: bronze.load_bronze stored procedure

-- 6. Create Silver Loading Procedure
-- Execute: scripts/silver/proc_load_silver.sql
-- Creates: silver.load_silver stored procedure
```

### Step 4: Load Data

```sql
-- Run the ETL pipeline
USE DataWarehouse;
GO

-- Load Bronze Layer (from CSV files)
EXEC bronze.load_bronze;
GO

-- Load Silver Layer (cleanse and transform)
EXEC silver.load_silver;
GO

-- Query Gold Layer (analytics-ready views)
SELECT * FROM gold.dim_customers;
SELECT * FROM gold.dim_products;
SELECT * FROM gold.fact_sales;
```

## 📁 Project Structure

```
ecommerce-dwh/
│
├── datasets/
│   ├── source_crm/              # CRM system data
│   │   ├── cust_info.csv        # Customer information
│   │   ├── prd_info.csv         # Product information
│   │   └── sales_details.csv    # Sales transactions
│   │
│   └── source_erp/              # ERP system data
│       ├── CUST_AZ12.csv        # Customer demographics
│       ├── loc_a101.csv         # Location/country data
│       └── px_cat_g1v2.csv      # Product categories
│
├── scripts/
│   ├── bronze/                  # Bronze layer scripts
│   │   ├── ddl_bronze.sql       # Table definitions
│   │   └── proc_load_bronze.sql # ETL procedure
│   │
│   ├── silver/                  # Silver layer scripts
│   │   ├── ddl_silver.sql       # Table definitions
│   │   └── proc_load_silver.sql # ETL procedure
│   │
│   ├── gold/                    # Gold layer scripts
│   │   └── ddl_gold.sql         # View definitions
│   │
│   └── init_db.sql              # Database and schema creation
│
└── README.md
```

## 📊 Data Model

### Bronze Layer (Raw Data)

**CRM Tables:**
- `bronze.crm_cust_info` - Customer master data
- `bronze.crm_prd_info` - Product catalog
- `bronze.crm_sales_details` - Sales transactions

**ERP Tables:**
- `bronze.erp_cust_az12` - Customer birth dates and gender
- `bronze.erp_loc_a101` - Customer country information
- `bronze.erp_px_cat_g1v2` - Product categories and subcategories

### Silver Layer (Cleansed Data)

Same table structure as Bronze, but with:
- Data quality rules applied
- Standardized values (e.g., 'M' → 'Male', 'S' → 'Single')
- Date type conversions (INT → DATE)
- Deduplication logic
- NULL handling and default values
- Audit timestamps (`dwh_create_date`)

### Gold Layer (Star Schema)

**Dimension Tables:**

**`gold.dim_customers`** - Customer dimension
- `customer_key` (Surrogate key)
- `customer_id`, `customer_number`
- `first_name`, `last_name`
- `country`, `marital_status`, `gender`
- `birthdate`, `create_date`
- **Source**: Integrates CRM + ERP customer data

**`gold.dim_products`** - Product dimension
- `product_key` (Surrogate key)
- `product_id`, `product_number`, `product_name`
- `category_id`, `category`, `subcategory`
- `cost`, `product_line`, `start_date`
- **Source**: Integrates CRM products + ERP categories
- **Note**: Only active products (prd_end_dt IS NULL)

**Fact Table:**

**`gold.fact_sales`** - Sales transactions
- `order_number`
- `product_key` (FK to dim_products)
- `customer_key` (FK to dim_customers)
- `order_date`, `shipping_date`, `due_date`
- `sales_amount`, `quantity`, `price`

### Star Schema Diagram

```
     ┌─────────────────┐
     │ dim_customers   │
     │─────────────────│
     │ customer_key PK │
     │ customer_id     │
     │ first_name      │
     │ country         │
     │ gender          │
     └────────┬────────┘
              │
              │
     ┌────────▼────────┐
     │   fact_sales    │
     │─────────────────│
     │ order_number    │
     │ customer_key FK │◄────┐
     │ product_key FK  │     │
     │ order_date      │     │
     │ sales_amount    │     │
     │ quantity        │     │
     └────────┬────────┘     │
              │              │
     ┌────────▼────────┐     │
     │  dim_products   │     │
     │─────────────────│     │
     │ product_key PK  │─────┘
     │ product_id      │
     │ product_name    │
     │ category        │
     │ product_line    │
     └─────────────────┘
```

## 🔄 ETL Process

### Bronze Layer ETL (`bronze.load_bronze`)

**Purpose**: Ingest raw data from CSV files into staging tables

**Process**:
1. Truncate existing bronze tables
2. BULK INSERT from CSV files (source_crm and source_erp)
3. No transformations - data loaded as-is
4. Print execution time and status messages

**Execution**:
```sql
EXEC bronze.load_bronze;
```

### Silver Layer ETL (`silver.load_silver`)

**Purpose**: Cleanse, validate, and transform data

**Key Transformations**:

**Customer Data (`crm_cust_info`)**:
- Deduplicate using ROW_NUMBER() by cst_id
- Standardize marital status: 'S' → 'Single', 'M' → 'Married'
- Standardize gender: 'M' → 'Male', 'F' → 'Female'
- TRIM whitespace from names

**Product Data (`crm_prd_info`)**:
- Extract category_id from product_key
- Calculate end_date using LEAD() window function
- Standardize product lines: 'M' → 'Mountain', 'R' → 'Road', etc.
- Handle NULL costs (set to 0)

**Sales Data (`crm_sales_details`)**:
- Convert integer dates (YYYYMMDD) to DATE type
- Validate and recalculate sales_amount = quantity × price
- Handle negative prices (convert to positive)
- Handle NULL prices (calculate from sales/quantity)

**ERP Customer Data (`erp_cust_az12`)**:
- Remove 'NASA' prefix from customer IDs
- Validate birthdates (must be < current date)
- Standardize gender codes

**ERP Location Data (`erp_loc_a101`)**:
- Remove hyphens from customer IDs
- Standardize country codes: 'DE' → 'Germany', 'US'/'USA' → 'United States'

**Execution**:
```sql
EXEC silver.load_silver;
```

### Gold Layer (Views)

**Purpose**: Create analytics-ready dimensional model

The Gold layer uses **views** instead of tables, which means:
- Data is always fresh (no need to refresh)
- Queries pull directly from Silver layer
- Joins are performed at query time

**Dimension Building**:
- `dim_customers`: Joins CRM customer info with ERP demographics and location
- `dim_products`: Joins CRM products with ERP category data, filters to active products only
- `fact_sales`: Joins sales details with dimension surrogate keys

**Execution**:
```sql
-- Views are created once via ddl_gold.sql
-- Query them directly:
SELECT * FROM gold.dim_customers;
SELECT * FROM gold.dim_products;
SELECT * FROM gold.fact_sales;
```

## 💻 Usage

### Running the Complete ETL Pipeline

```sql
USE DataWarehouse;
GO

-- Step 1: Load raw data from CSV files
EXEC bronze.load_bronze;
GO

-- Step 2: Cleanse and transform data
EXEC silver.load_silver;
GO

-- Step 3: Query the dimensional model
SELECT 
    c.first_name,
    c.last_name,
    p.product_name,
    f.sales_amount,
    f.quantity
FROM gold.fact_sales f
INNER JOIN gold.dim_customers c ON f.customer_key = c.customer_key
INNER JOIN gold.dim_products p ON f.product_key = p.product_key;
```

### Sample Analytics Queries

```sql
-- Total sales by product category
SELECT 
    p.category,
    COUNT(DISTINCT f.order_number) as order_count,
    SUM(f.sales_amount) as total_sales,
    SUM(f.quantity) as total_quantity
FROM gold.fact_sales f
INNER JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY total_sales DESC;

-- Sales by customer country
SELECT 
    c.country,
    COUNT(DISTINCT c.customer_key) as customer_count,
    SUM(f.sales_amount) as total_sales
FROM gold.fact_sales f
INNER JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY total_sales DESC;

-- Top 10 customers by revenue
SELECT TOP 10
    c.first_name,
    c.last_name,
    c.country,
    SUM(f.sales_amount) as total_revenue,
    COUNT(DISTINCT f.order_number) as order_count
FROM gold.fact_sales f
INNER JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name, c.country
ORDER BY total_revenue DESC;

-- Monthly sales trend
SELECT 
    YEAR(f.order_date) as year,
    MONTH(f.order_date) as month,
    SUM(f.sales_amount) as monthly_sales,
    COUNT(DISTINCT f.order_number) as order_count
FROM gold.fact_sales f
WHERE f.order_date IS NOT NULL
GROUP BY YEAR(f.order_date), MONTH(f.order_date)
ORDER BY year, month;

-- Product performance by product line
SELECT 
    p.product_line,
    COUNT(DISTINCT p.product_key) as product_count,
    SUM(f.sales_amount) as total_sales,
    AVG(f.price) as avg_price
FROM gold.fact_sales f
INNER JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.product_line
ORDER BY total_sales DESC;
```

## 🔧 Customization

### Adding New Data Sources

1. Add CSV files to appropriate folder (`datasets/source_crm/` or `datasets/source_erp/`)
2. Create table definition in `ddl_bronze.sql`
3. Add BULK INSERT statement to `proc_load_bronze.sql`
4. Create corresponding silver table in `ddl_silver.sql`
5. Add transformation logic to `proc_load_silver.sql`
6. Update gold views if needed in `ddl_gold.sql`

### Scheduling ETL Jobs

Use SQL Server Agent to schedule the ETL procedures:

```sql
-- Create a job to run daily at 2 AM
USE msdb;
GO

EXEC sp_add_job 
    @job_name = N'DWH_Daily_Load';

EXEC sp_add_jobstep
    @job_name = N'DWH_Daily_Load',
    @step_name = N'Load Bronze',
    @command = N'EXEC bronze.load_bronze';

EXEC sp_add_jobstep
    @job_name = N'DWH_Daily_Load',
    @step_name = N'Load Silver',
    @command = N'EXEC silver.load_silver';

EXEC sp_add_schedule
    @schedule_name = N'Daily_2AM',
    @freq_type = 4,  -- Daily
    @active_start_time = 020000;  -- 2:00 AM
```


## 🙏 Acknowledgments

- Medallion architecture pattern (Bronze-Silver-Gold)
- SQL Server ETL best practices
- Data warehousing dimensional modeling principles
- Special thanks to **[DataWithBaraa](https://www.youtube.com/@DataWithBaraa)** YouTube channel for the inspiration and guidance
