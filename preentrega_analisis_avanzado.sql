WITH ventas_mensuales AS (
   SELECT 
   --normaliza las fechas y agrupa por mes 
   DATE_TRUNC ('month', v.fecha) AS mes_venta,
           c.nombre AS categoria,
   --suma todas la ventas de mes y categoria
           SUM (v.cantidad * p.precio) AS monto
    FROM ventas v
   --para buscar datos de otros tablas que son necesarios 
    JOIN productos p ON v.producto_id = p.id
    JOIN categorias c ON p.categoria_id = c.id
    GROUP BY
         DATE_TRUNC ('month', v.fecha),
         c.nombre),
metricas_ventana AS (
    SELECT *,
    --posicion de la categoria dentro del mes
    RANK()  OVER (
            PARTITION BY mes_venta         
            ORDER BY monto DESC) AS ranking,
    -- cuanto lleva vendido la categoria 
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
    
    
