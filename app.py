
import streamlit as st
import pandas as pd

st.title("Global Seismic Trends")
st.write("Earthquake Data Analysis and Visualization")

# Load original dataset
df = pd.read_csv("earthquakes_final.csv")

# 1. Check data before cleaning
missing_before = int(df.isnull().sum().sum())
duplicates_before = int(df.duplicated().sum())
rows_before = len(df)
columns_before = len(df.columns)

st.subheader("Data Cleaning")

st.write("Rows Before Cleaning:", rows_before)
st.write("Columns Before Cleaning:", columns_before)
st.write("Missing Values Before Cleaning:", missing_before)
st.write("Duplicate Rows Before Cleaning:", duplicates_before)

# 2. Remove columns where every value is missing
empty_columns = df.columns[df.isnull().all()].tolist()
df = df.drop(columns=empty_columns)

st.write("Completely Empty Columns Removed:", empty_columns)

# 3. Fill missing numerical values using median
numeric_columns = ["nst", "dmin", "gap", "rms"]

for col in numeric_columns:
    if col in df.columns and df[col].isnull().any():
        median_value = df[col].median()
        df[col] = df[col].fillna(median_value)

# 4. Remove duplicate rows
df = df.drop_duplicates()

# 5. Convert date columns
df["time"] = pd.to_datetime(df["time"], errors="coerce", utc=True)
df["updated"] = pd.to_datetime(df["updated"], errors="coerce", utc=True)

# 6. Check data after cleaning
missing_after = int(df.isnull().sum().sum())
duplicates_after = int(df.duplicated().sum())

st.write("Missing Values After Cleaning:", missing_after)
st.write("Duplicate Rows After Cleaning:", duplicates_after)
st.write("Rows After Cleaning:", len(df))
st.write("Columns After Cleaning:", len(df.columns))

# 7. Summary
st.subheader("Earthquake Summary")

col1, col2, col3 = st.columns(3)

col1.metric("Total Records", len(df))
col2.metric("Average Magnitude", round(df["mag"].mean(), 2))
col3.metric("Maximum Magnitude", round(df["mag"].max(), 2))

# 8. Earthquake data table
st.subheader("Earthquake Data")
st.dataframe(df, use_container_width=True)

# 9. Magnitude analysis
st.subheader("Earthquake Magnitude Analysis")
st.bar_chart(df["mag"].value_counts().sort_index())

# 10. Highest magnitude earthquake
st.subheader("Highest Magnitude Earthquake")

max_row = df.loc[df["mag"].idxmax()]

st.write("Magnitude:", max_row["mag"])
st.write("Location:", max_row["place"])
st.write("Depth:", max_row["depth"])

# 11. Depth analysis
st.subheader("Earthquake Depth Analysis")
st.line_chart(df["depth"])
