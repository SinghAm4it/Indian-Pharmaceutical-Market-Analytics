import pandas as pd
import numpy as np
import mysql.connector


# -----------------------------
# 1. Load CSV
# -----------------------------
df = pd.read_csv("C:/Users/cw/Downloads/Pharmaceutical/indian_pharmaceutical_products_cleaned.csv")


# Fix NaN issues
df = df.replace({np.nan: None})
df = df.replace("nan", None)
df = df.replace("NaN", None)
df = df.replace("", None)

print("Rows in CSV:", len(df))

# -----------------------------
# 2. MySQL Connection
# -----------------------------
conn = mysql.connector.connect(
    host="localhost",
    user="username",
    password="password",
    database="indian_pharmaceuticals"
)

cursor = conn.cursor()

# -----------------------------
# 3. Insert Query
# -----------------------------
insert_query = """
INSERT INTO pharma (
    product_id,
    brand_name,
    manufacturer,
    price_inr,
    is_discontinued,
    dosage_form,
    pack_size,
    pack_unit,
    num_active_ingredients,
    primary_ingredient,
    primary_strength,
    secondary_ingredient,
    secondary_strength,
    therapeutic_class,
    packaging_raw,
    combination_drug
)
VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
"""

# -----------------------------
# 4. Convert DataFrame → list of lists
# -----------------------------
data = df[
    [
        "product_id",
        "brand_name",
        "manufacturer",
        "price_inr",
        "is_discontinued",
        "dosage_form",
        "pack_size",
        "pack_unit",
        "num_active_ingredients",
        "primary_ingredient",
        "primary_strength",
        "secondary_ingredient",
        "secondary_strength",
        "therapeutic_class",
        "packaging_raw",
        "combination_drug"
    ]
].where(pd.notnull(df), None).values.tolist()

# Alternative approach:
# data = list(
#     df.where(pd.notnull(df), None)
#       .itertuples(index=False, name=None))


# -----------------------------
# 5. Bulk Insert
# -----------------------------
cursor.executemany(insert_query, data)
conn.commit()

print(f"Inserted {cursor.rowcount} rows successfully")

# -----------------------------
# 6. Close Connection
# -----------------------------
cursor.close()
conn.close()


