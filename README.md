# Superstore Sales Dashboard

## Overview
Interactive Power BI dashboard analyzing sales, profit, and discount 
trends across a retail Superstore dataset — built to identify 
underperforming regions, categories, and discount strategies hurting margin.

## Workflow
1. `data/` — raw Superstore dataset
2. `sql/` — queries used to clean and aggregate the raw data
3. `dashboard/` — final Power BI dashboard (.pbix)

## Tools Used
Power BI · DAX · Power Query · SQL

## Key Insights
- Generated $2M in total sales and $292K in profit across ~5K orders (≈14.6% overall margin)
- Technology led all categories at $0.84M in sales, narrowly ahead of Furniture ($0.75M) and Office Supplies ($0.73M)
- Chairs and Phones were the top-performing sub-categories by sales, while Copiers and Machines lagged furthest behind
- California and New York generated the highest profit by state, with Georgia and Indiana trailing
- March was the peak sales month in the observed period, following a dip in February
- Sub-categories with the steepest discounts (~30-40%) clustered toward the lowest profit points — discounting is visibly eating into margin

## Dashboard Preview
![Dashboard](screenshots/dashboard-overview.png)

## File
`dashboard/superstore-dashboard.pbix` — open in Power BI Desktop to explore
