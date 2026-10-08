import streamlit as st
import pandas as pd

st.title("Global Seismic Trends")

df = pd.read_csv("earthquakes_cleaned.csv")

df = df.drop_duplicates()
df["time"] = pd.to_datetime(df["time"], errors="coerce")
df["updated"] = pd.to_datetime(df["updated"], errors="coerce")   

st.write("Total Missing Values:", df.isnull().sum().sum())
st.write("Total Duplicate Rows:", df.duplicated().sum())

st.write("### Earthquake Data")
st.dataframe(df)

st.write("### Summary")
st.write("Total Earthquake Records:", len(df))
st.write("Average Magnitude:", round(df["mag"].mean(), 2))
st.write("Maximum Magnitude:", df["mag"].max()) 


st.subheader("Charts / Analysis")

st.bar_chart(df["mag"])  


st.subheader("Earthquake Analysis")

st.write("### Highest Magnitude Earthquake")
max_row = df.loc[df["mag"].idxmax()]

st.write("Magnitude:", max_row["mag"])
st.write("Location:", max_row["place"])
st.write("Depth:", max_row["depth"]) 

st.subheader("Earthquake Magnitude Distribution")

st.bar_chart(df["mag"].value_counts().sort_index())

st.subheader("Earthquake Depth Analysis")

st.line_chart(df["depth"])  

