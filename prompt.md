actua como administrador de base de datos de proyecto de restaurante italiano, qué entidades se necesitan para su gestión, las entidades con sus atributos y tipo de forma de tabla para cada una de las entidades y generar un script aparte en sql para descargar con el nombre "bdrestaurante.sql" para las entidades con sus relaciones
<img width="1440" height="1104" alt="image" src="https://github.com/user-attachments/assets/342621ee-0390-434a-9094-8942a057ec4e" />
Aquí está el resumen completo del diseño:

15 entidades identificadas para la gestión del restaurante italiano:
#EntidadPropósito1rolesPuestos de trabajo (gerente, mesero, chef…)2empleadosPersonal del restaurante3clientesBase de clientes registrados4mesasMesas físicas con estado y capacidad5reservacionesReservas vinculadas a cliente y mesa6categoriasSecciones del menú (Antipasti, Primi, Dolci…)7platillosMenú completo con precios8ingredientesInventario con control de stock mínimo9recetasIngredientes que componen cada platillo10pedidosÓrdenes de mesa, domicilio o para llevar11detalle_pedidoLíneas de cada pedido12pagosCobros con método de pago13proveedoresContactos de abastecimiento14comprasÓrdenes de compra de ingredientes15detalle_compraLíneas de cada orden de compra
El script SQL incluye:

Creación de base de datos y todas las tablas con tipos de dato, PK, FK, índices y constraints
Datos de ejemplo reales (menú italiano auténtico, empleados, clientes, mesas, pedido completo)
3 vistas útiles: v_menu, v_stock_bajo y v_ventas_hoy
Compatible con MySQL 8+ y MariaDB 10.5+
