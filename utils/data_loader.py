# utils/data_loader.py
import pandas as pd
import streamlit as st

@st.cache_data(show_spinner="Cargando archivos...")
def load_multiple_excels(uploaded_files):
    dfs = []
    for file in uploaded_files:
        ext = file.name.split(".")[-1].lower()
        if ext == "xlsb":
            df = pd.read_excel(file, engine="pyxlsb")
        elif ext == "xls":
            # Requiere paquete 'xlrd'
            df = pd.read_excel(file, engine="xlrd")
        else:
            # Para xlsx/xlsm usará openpyxl automáticamente (ya en requirements)
            df = pd.read_excel(file)
        dfs.append(df)
    return pd.concat(dfs, ignore_index=True)
