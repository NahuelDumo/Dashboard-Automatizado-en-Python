import pandas as pd
from io import BytesIO
import plotly.graph_objects as go
import plotly.express as px

def export_to_excel(resumen_global_df, figuras=None):
    """
    Exporta:
    - Hoja 'Resumen Global' con los indicadores (incluye todos los KPIs)
    - Hoja 'Graficos' con capturas PNG de figuras Plotly (si se proveen)
    """
    output = BytesIO()
    with pd.ExcelWriter(output, engine="xlsxwriter") as writer:
        # Hoja de indicadores
        resumen_global_df.to_excel(writer, index=False, sheet_name="Resumen Global")

        # Hoja de gráficos (opcional)
        if figuras:
            workbook = writer.book
            ws = workbook.add_worksheet("Graficos")

            # Insertar imágenes, una por fila, grandes
            row, col = 1, 1  # usando base 0 -> esto es fila 2, col B para dejar margen
            row_step = 35     # separación de filas entre imágenes (más alto para gráficos grandes)

            for i, fig in enumerate(figuras, start=1):
                try:
                    # Exportar respetando el Figure original (tema, colores y tamaños)
                    fig_export = go.Figure(fig)
                    # Si no hay template explícito, usar uno colorido por defecto para evitar barras negras
                    if fig_export.layout.template is None:
                        fig_export.update_layout(template="plotly")
                    # Si no hay colorway, asignar una cualitativa por defecto
                    if not getattr(fig_export.layout, 'colorway', None):
                        fig_export.update_layout(colorway=px.colors.qualitative.Plotly)
                    # Usar dimensiones del layout si existen
                    export_width = getattr(fig_export.layout, 'width', None) or 1400
                    export_height = getattr(fig_export.layout, 'height', None) or 700
                    fig_export.update_layout(width=export_width, height=export_height)
                    img_bytes = fig_export.to_image(format="png", scale=3, engine="kaleido")
                    img_io = BytesIO(img_bytes)
                    ws.insert_image(row, col, f"grafico_{i}.png", {
                        'image_data': img_io,
                        'x_scale': 1.6,
                        'y_scale': 1.6
                    })
                    # Siguiente imagen en una nueva fila
                    row += row_step
                    col = 1
                except Exception as e:
                    # Si falla la exportación de una figura, continuamos con las demás
                    ws.write(row, col, f"Error exportando figura {i}: {e}")
                    row += row_step
                    col = 1
    output.seek(0)
    return output
