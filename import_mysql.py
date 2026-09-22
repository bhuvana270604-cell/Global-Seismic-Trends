import mysql.connector

conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="bhuvana2004",
    database="global_seismic_trends"
)

print("MySQL Connected Successfully!")

conn.close()