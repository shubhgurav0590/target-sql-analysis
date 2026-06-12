# Target Brazil E-Commerce — SQL Analysis

## Overview
SQL-based exploratory analysis of Target's Brazil e-commerce operations using Google BigQuery. The analysis covers customer geography, order trends, delivery performance, freight costs, and payment behaviour across 27 Brazilian states.

## Business Problem
- Which states drive the most orders and revenue?
- How has order volume and payment value grown year-on-year?
- Which states have the worst delivery times and highest freight costs?
- What payment methods do customers prefer?
- When do customers place orders during the day?

## Dataset
- **Source:** Target Brazil E-Commerce (via Scaler Academy)
- **Tables:** `customers`, `orders`, `order_items`, `payments`
- **Period:** September 2016 – October 2018
- **Tool:** Google BigQuery

## Analysis Sections

| Section | Topic |
|---------|-------|
| I | Initial Exploration — data types, time range, city/state counts |
| II | Evolution of Orders — state-wise trends, time-of-day analysis |
| III | Economic Impact — revenue, freight value by state, YoY growth |
| IV | Delivery Analysis — top/bottom 5 states by delivery time and freight |
| V | Payment Analysis — installments, payment types by month |

## Key Insights
- **SP dominates** — São Paulo has the highest order volume and total revenue across all months
- **136.98% YoY growth** in payment value from 2017 to 2018 (Jan–Aug comparison)
- **Afternoon is peak ordering time** — 38,135 orders placed between 1 PM and 6 PM
- **Remote northern states** (RR, AP, AM) have the highest delivery times and freight costs
- **Credit card is the #1 payment method** across all months; 52,546 orders paid in a single installment
- **SP, PR, MG** have the fastest delivery and lowest freight — well-developed logistics hubs
