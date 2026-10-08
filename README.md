# Global Seismic Trends: Data-Driven Earthquake Insights

## Project Overview

This project analyzes earthquake data to understand patterns and trends in earthquake magnitude, depth, location, and occurrence over time.

The project uses Python, Pandas, NumPy, MySQL, data analysis, data visualization, and Streamlit to explore and present earthquake-related insights.

## Objectives

* Analyze earthquake data
* Understand earthquake magnitude and depth
* Identify the strongest earthquakes
* Analyze earthquake occurrences over time
* Study geographical patterns
* Visualize important earthquake trends
* Generate data-driven insights

## Technologies Used

* Python
* Pandas
* NumPy
* MySQL
* SQL
* Matplotlib
* Seaborn
* Streamlit

## Project Workflow

1. Collect the earthquake dataset
2. Load and inspect the data
3. Clean and preprocess the data
4. Check and handle missing values
5. Check and remove duplicate records
6. Convert date columns into the appropriate datetime format
7. Perform exploratory data analysis
8. Analyze earthquake magnitude and depth
9. Analyze geographical and time-based patterns
10. Create visualizations
11. Generate meaningful insights
12. Build the Streamlit application

## Data Cleaning

The earthquake dataset was checked for missing values and duplicate records.

The final cleaned dataset contains:

* **Rows:** 28
* **Columns:** 26
* **Missing Values:** 0
* **Duplicate Rows:** 0

The `time` and `updated` columns were converted into datetime format.

Additional analysis columns such as `year`, `month`, `month_name`, and `depth_category` were created to support the analysis.

## Analysis Performed

The project includes analysis of:

* Earthquake magnitude
* Earthquake depth
* Latitude and longitude
* Earthquake frequency
* Strongest earthquakes
* Earthquake occurrence by year and month
* Geographical distribution of earthquakes
* Earthquake magnitude distribution
* Earthquake depth patterns

## Key Insights

The analysis helps identify patterns in earthquake magnitude, depth, location, and occurrence over time.

The visualizations provide a clear understanding of seismic activity and help transform earthquake data into meaningful insights.

## Project Files

* `2.5_day.csv` – Source earthquake dataset used for the analysis.
* `earthquakes_cleaned.csv` – Cleaned dataset used by the application.
* `earthquakes_final.csv` – Original project dataset.
* `app.py` – Streamlit application for earthquake analysis and visualization.
* `import_mysql.py` – MySQL database connection script.
* `requirements.txt` – Required Python packages.

## Streamlit Application

A Streamlit application was developed to provide an interactive way to explore the earthquake data.

The application displays:

* Earthquake data
* Total earthquake records
* Average magnitude
* Maximum magnitude
* Highest magnitude earthquake
* Earthquake magnitude distribution
* Earthquake depth analysis
* Data cleaning validation including missing values and duplicate records

## Conclusion

This project demonstrates how Python, Pandas, SQL, MySQL, data visualization, and Streamlit can be used to clean, analyze, visualize, and present earthquake data.

The project provides data-driven insights into earthquake magnitude, depth, location, and occurrence patterns.
