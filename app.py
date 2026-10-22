
import streamlit as st
import pandas as pd
import mysql.connector

st.set_page_config(
    page_title="Global Seismic Trends",
    layout="wide"
)

st.title("Global Seismic Trends")
st.write("Earthquake Data Analysis and Visualization")

# 1. Load original dataset for BEFORE cleaning metrics
try:
    original = pd.read_csv("earthquakes_final.csv")
except FileNotFoundError:
    st.error("earthquakes_final.csv was not found.")
    st.stop()

# 2. MySQL connection
st.sidebar.header("MySQL Connection")

password = st.sidebar.text_input(
    "MySQL Password",
    type="password"
)

if not password:
    st.info("Enter your MySQL password in the sidebar.")
    st.stop()

try:
    conn = mysql.connector.connect(
        host="localhost",
        user="root",
        password=password,
        database="global_seismic_trends"
    )

    try:
        df = pd.read_sql_query(
            "SELECT * FROM earthquakes",
            conn
        )
    finally:
        conn.close()

except mysql.connector.Error as e:
    st.error(f"MySQL connection failed: {e}")
    st.stop()

# 3. BEFORE cleaning metrics
st.subheader("Data Cleaning - Before")

before_rows = len(original)
before_cols = len(original.columns)
before_missing = int(original.isnull().sum().sum())
before_duplicates = int(original.duplicated().sum())

c1, c2, c3, c4 = st.columns(4)
c1.metric("Rows", before_rows)
c2.metric("Columns", before_cols)
c3.metric("Missing Values", before_missing)
c4.metric("Duplicate Rows", before_duplicates)

st.write("Missing values by column")
missing_cols = original.isnull().sum()

st.dataframe(
    missing_cols[missing_cols > 0].rename("Missing Count")
)

# 4. AFTER cleaning metrics - MySQL data
st.subheader("Data Cleaning - After (MySQL)")

after_rows = len(df)
after_cols = len(df.columns)
after_missing = int(df.isnull().sum().sum())
after_duplicates = int(df.duplicated().sum())

c1, c2, c3, c4 = st.columns(4)
c1.metric("Rows", after_rows)
c2.metric("Columns", after_cols)
c3.metric("Missing Values", after_missing)
c4.metric("Duplicate Rows", after_duplicates)

if after_missing == 0 and after_duplicates == 0:
    st.success("Cleaning verification passed.")
else:
    st.warning(
        "Please review the remaining data quality issues."
    )

st.write("Columns removed:", before_cols - after_cols)
st.write("Rows removed:", before_rows - after_rows)

# 5. Earthquake summary
st.subheader("Earthquake Summary")

if "mag" in df.columns:
    df["mag"] = pd.to_numeric(
        df["mag"], errors="coerce"
    )
    valid_mag = df["mag"].dropna()

    if not valid_mag.empty:
        c1, c2, c3 = st.columns(3)

        c1.metric("Total Records", len(df))
        c2.metric(
            "Average Magnitude",
            round(valid_mag.mean(), 2)
        )
        c3.metric(
            "Maximum Magnitude",
            round(valid_mag.max(), 2)
        )

        # Magnitude frequency chart
        st.subheader("Earthquake Magnitude Analysis")

        mag_counts = (
            valid_mag.round(1)
            .value_counts()
            .sort_index()
        )

        st.bar_chart(mag_counts)

        # Highest magnitude earthquake
        max_idx = valid_mag.idxmax()
        max_row = df.loc[max_idx]

        st.subheader("Highest Magnitude Earthquake")
        st.write("Magnitude:", round(float(max_row["mag"]), 2))

        if "place" in df.columns:
            st.write("Location:", max_row["place"])

        if "depth" in df.columns:
            st.write("Depth (km):", max_row["depth"])








# 6. Earthquake depth distribution

import matplotlib.pyplot as plt

if "depth" in df.columns:
    depth = pd.to_numeric(
        df["depth"], errors="coerce"
    ).dropna()

    # Keep valid depths between 0 and 100 km
    depth = depth[(depth >= 0) & (depth <= 100)]

    st.write("Valid depth records:", len(depth))

    if not depth.empty:
        st.write(
            "Depth range:",
            depth.min(),
            "to",
            depth.max()
        )

        st.subheader("Earthquake Depth Distribution")

        # Create 20 bins, each 5 km wide
        depth_bins = pd.cut(
            depth,
            bins=list(range(0, 101, 5)),
            right=True,
            labels=False,
            include_lowest=True
        )

        depth_counts = (
            depth_bins.value_counts()
            .reindex(range(20), fill_value=0)
            .sort_index()
        )

       

        labels = [
            f"{i * 5}–{(i + 1) * 5}"
            for i in range(20)
        ]

        fig, ax = plt.subplots(figsize=(12, 7))

        ax.barh(
            labels,
            depth_counts.to_numpy()
        )

        ax.invert_yaxis()
        ax.set_xlabel("Earthquake Count")
        ax.set_ylabel("Depth Range (km)")
        ax.set_title("Earthquake Depth Distribution")

        plt.tight_layout()
        st.pyplot(fig)
        plt.close(fig)

        st.caption(
            "Earthquake depths are grouped into "
            "20 numerically ordered ranges (km), "
            "from 0 to 100 km."
        )
