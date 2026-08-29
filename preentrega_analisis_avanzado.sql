WITH ventas_mensuales AS (
   SELECT DATE_TRUNC ('month', v.fecha) AS mes_venta,
           c.nombre AS categoria,
           SUM (v.cantidad * p.precio) AS monto
    FROM ventas v
    JOIN productos p ON v.producto_id = p.id
    JOIN categorias c ON p.categoria_id = c.id
    GROUP BY
         DATE_TRUNC ('month', v.fecha),
         c.nombre),
metricas_ventana AS (
    SELECT *,
    RANK()  OVER (
            PARTITION BY mes_venta         
            ORDER BY monto DESC) AS ranking,
    SUM(monto) OVER(
               PARTITION BY categoria
               ORDER BY mes_venta) AS acumulado
    FROM ventas_mensuales)

SELECT
    mes_venta,
    categoria,
    monto,
    ranking,
    acumulado,
    CASE
    WHEN monto >= AVG(monto) OVER (
        PARTITION BY categoria)
    THEN 'Exitoso'
    ELSE 'Bajo el promedio'
    END AS comparativa
FROM metricas_ventana
    
;
    
    
