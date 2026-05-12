-- ============================================================
--  BASE DE DATOS: Restaurante Italiano
--  Descripción : Gestión completa de mesas, pedidos, menú,
--                empleados, inventario y proveedores.
--  Motor        : MySQL 8+ / MariaDB 10.5+
-- ============================================================

CREATE DATABASE IF NOT EXISTS bdrestaurante
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE bdrestaurante;

-- ------------------------------------------------------------
-- 1. ROLES  (catálogo de puestos de trabajo)
-- ------------------------------------------------------------
CREATE TABLE roles (
  id_rol      INT           NOT NULL AUTO_INCREMENT,
  nombre      VARCHAR(60)   NOT NULL,
  descripcion TEXT,
  PRIMARY KEY (id_rol),
  UNIQUE KEY uq_rol_nombre (nombre)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 2. EMPLEADOS
-- ------------------------------------------------------------
CREATE TABLE empleados (
  id_empleado    INT           NOT NULL AUTO_INCREMENT,
  id_rol         INT           NOT NULL,
  nombre         VARCHAR(80)   NOT NULL,
  apellido       VARCHAR(80)   NOT NULL,
  telefono       VARCHAR(20),
  email          VARCHAR(120)  UNIQUE,
  fecha_contrato DATE          NOT NULL,
  salario        DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (id_empleado),
  CONSTRAINT fk_emp_rol
    FOREIGN KEY (id_rol) REFERENCES roles (id_rol)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 3. CLIENTES
-- ------------------------------------------------------------
CREATE TABLE clientes (
  id_cliente     INT          NOT NULL AUTO_INCREMENT,
  nombre         VARCHAR(80)  NOT NULL,
  apellido       VARCHAR(80)  NOT NULL,
  telefono       VARCHAR(20),
  email          VARCHAR(120) UNIQUE,
  fecha_registro DATE         NOT NULL DEFAULT (CURRENT_DATE),
  PRIMARY KEY (id_cliente)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 4. MESAS
-- ------------------------------------------------------------
CREATE TABLE mesas (
  id_mesa      INT         NOT NULL AUTO_INCREMENT,
  numero_mesa  INT         NOT NULL,
  capacidad    INT         NOT NULL DEFAULT 4,
  ubicacion    VARCHAR(60) COMMENT 'Ej: terraza, interior, bar',
  estado       ENUM('libre','ocupada','reservada','mantenimiento')
               NOT NULL DEFAULT 'libre',
  PRIMARY KEY (id_mesa),
  UNIQUE KEY uq_numero_mesa (numero_mesa)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 5. RESERVACIONES
-- ------------------------------------------------------------
CREATE TABLE reservaciones (
  id_reservacion INT          NOT NULL AUTO_INCREMENT,
  id_cliente     INT          NOT NULL,
  id_mesa        INT          NOT NULL,
  fecha_hora     DATETIME     NOT NULL,
  num_personas   INT          NOT NULL DEFAULT 1,
  estado         ENUM('pendiente','confirmada','cancelada','completada')
                 NOT NULL DEFAULT 'pendiente',
  notas          TEXT,
  PRIMARY KEY (id_reservacion),
  CONSTRAINT fk_res_cliente
    FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_res_mesa
    FOREIGN KEY (id_mesa) REFERENCES mesas (id_mesa)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 6. CATEGORIAS  (Antipasti, Primi, Secondi, Dolci, Bevande…)
-- ------------------------------------------------------------
CREATE TABLE categorias (
  id_categoria  INT         NOT NULL AUTO_INCREMENT,
  nombre        VARCHAR(80) NOT NULL,
  descripcion   TEXT,
  orden_display INT         NOT NULL DEFAULT 0
                COMMENT 'Orden de aparición en el menú',
  PRIMARY KEY (id_categoria),
  UNIQUE KEY uq_cat_nombre (nombre)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 7. PLATILLOS  (menú)
-- ------------------------------------------------------------
CREATE TABLE platillos (
  id_platillo  INT            NOT NULL AUTO_INCREMENT,
  id_categoria INT            NOT NULL,
  nombre       VARCHAR(120)   NOT NULL,
  descripcion  TEXT,
  precio       DECIMAL(10,2)  NOT NULL,
  disponible   TINYINT(1)     NOT NULL DEFAULT 1,
  imagen_url   VARCHAR(255),
  PRIMARY KEY (id_platillo),
  CONSTRAINT fk_plat_cat
    FOREIGN KEY (id_categoria) REFERENCES categorias (id_categoria)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 8. INGREDIENTES  (inventario)
-- ------------------------------------------------------------
CREATE TABLE ingredientes (
  id_ingrediente INT            NOT NULL AUTO_INCREMENT,
  nombre         VARCHAR(120)   NOT NULL,
  unidad_medida  VARCHAR(20)    NOT NULL COMMENT 'kg, lt, unidad, etc.',
  stock_actual   DECIMAL(10,3)  NOT NULL DEFAULT 0,
  stock_minimo   DECIMAL(10,3)  NOT NULL DEFAULT 0
                 COMMENT 'Alerta de reabastecimiento',
  costo_unidad   DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
  PRIMARY KEY (id_ingrediente),
  UNIQUE KEY uq_ing_nombre (nombre)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 9. RECETAS  (qué ingredientes lleva cada platillo)
-- ------------------------------------------------------------
CREATE TABLE recetas (
  id_receta          INT           NOT NULL AUTO_INCREMENT,
  id_platillo        INT           NOT NULL,
  id_ingrediente     INT           NOT NULL,
  cantidad_requerida DECIMAL(10,3) NOT NULL,
  PRIMARY KEY (id_receta),
  UNIQUE KEY uq_receta (id_platillo, id_ingrediente),
  CONSTRAINT fk_rec_plat
    FOREIGN KEY (id_platillo) REFERENCES platillos (id_platillo)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_rec_ing
    FOREIGN KEY (id_ingrediente) REFERENCES ingredientes (id_ingrediente)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 10. PEDIDOS
-- ------------------------------------------------------------
CREATE TABLE pedidos (
  id_pedido   INT           NOT NULL AUTO_INCREMENT,
  id_mesa     INT           NOT NULL,
  id_empleado INT           NOT NULL,
  fecha_hora  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  tipo        ENUM('local','domicilio','recoger')
              NOT NULL DEFAULT 'local',
  estado      ENUM('abierto','en_cocina','listo','entregado','cancelado')
              NOT NULL DEFAULT 'abierto',
  total       DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (id_pedido),
  CONSTRAINT fk_ped_mesa
    FOREIGN KEY (id_mesa) REFERENCES mesas (id_mesa)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_ped_emp
    FOREIGN KEY (id_empleado) REFERENCES empleados (id_empleado)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 11. DETALLE_PEDIDO  (líneas de cada pedido)
-- ------------------------------------------------------------
CREATE TABLE detalle_pedido (
  id_detalle     INT           NOT NULL AUTO_INCREMENT,
  id_pedido      INT           NOT NULL,
  id_platillo    INT           NOT NULL,
  cantidad       INT           NOT NULL DEFAULT 1,
  precio_unitario DECIMAL(10,2) NOT NULL,
  instrucciones  TEXT          COMMENT 'Modificaciones del cliente',
  PRIMARY KEY (id_detalle),
  CONSTRAINT fk_det_ped
    FOREIGN KEY (id_pedido) REFERENCES pedidos (id_pedido)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_det_plat
    FOREIGN KEY (id_platillo) REFERENCES platillos (id_platillo)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 12. PAGOS
-- ------------------------------------------------------------
CREATE TABLE pagos (
  id_pago     INT           NOT NULL AUTO_INCREMENT,
  id_pedido   INT           NOT NULL,
  monto       DECIMAL(10,2) NOT NULL,
  metodo_pago ENUM('efectivo','tarjeta_debito','tarjeta_credito',
                   'transferencia','otro')
              NOT NULL DEFAULT 'efectivo',
  fecha_hora  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  estado      ENUM('pendiente','completado','reembolsado')
              NOT NULL DEFAULT 'completado',
  PRIMARY KEY (id_pago),
  CONSTRAINT fk_pago_ped
    FOREIGN KEY (id_pedido) REFERENCES pedidos (id_pedido)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 13. PROVEEDORES
-- ------------------------------------------------------------
CREATE TABLE proveedores (
  id_proveedor INT          NOT NULL AUTO_INCREMENT,
  nombre       VARCHAR(120) NOT NULL,
  contacto     VARCHAR(120) COMMENT 'Nombre del representante',
  telefono     VARCHAR(20),
  email        VARCHAR(120),
  PRIMARY KEY (id_proveedor)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 14. COMPRAS  (órdenes de compra de ingredientes)
-- ------------------------------------------------------------
CREATE TABLE compras (
  id_compra    INT           NOT NULL AUTO_INCREMENT,
  id_proveedor INT           NOT NULL,
  id_empleado  INT           NOT NULL,
  fecha        DATE          NOT NULL DEFAULT (CURRENT_DATE),
  total        DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  estado       ENUM('pendiente','recibida','cancelada')
               NOT NULL DEFAULT 'pendiente',
  PRIMARY KEY (id_compra),
  CONSTRAINT fk_com_prov
    FOREIGN KEY (id_proveedor) REFERENCES proveedores (id_proveedor)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_com_emp
    FOREIGN KEY (id_empleado) REFERENCES empleados (id_empleado)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 15. DETALLE_COMPRA  (líneas de cada orden de compra)
-- ------------------------------------------------------------
CREATE TABLE detalle_compra (
  id_detalle_compra INT           NOT NULL AUTO_INCREMENT,
  id_compra         INT           NOT NULL,
  id_ingrediente    INT           NOT NULL,
  cantidad          DECIMAL(10,3) NOT NULL,
  precio_unitario   DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (id_detalle_compra),
  CONSTRAINT fk_dc_compra
    FOREIGN KEY (id_compra) REFERENCES compras (id_compra)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_dc_ing
    FOREIGN KEY (id_ingrediente) REFERENCES ingredientes (id_ingrediente)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;


-- ============================================================
--  DATOS DE EJEMPLO
-- ============================================================

-- Roles
INSERT INTO roles (nombre, descripcion) VALUES
  ('Gerente',    'Supervisión general del restaurante'),
  ('Mesero',     'Atención a mesas y toma de pedidos'),
  ('Chef',       'Preparación de platillos'),
  ('Barista',    'Preparación de bebidas y café'),
  ('Cajero',     'Manejo de cobros y caja'),
  ('Repartidor', 'Entregas a domicilio');

-- Empleados
INSERT INTO empleados (id_rol, nombre, apellido, telefono, email, fecha_contrato, salario) VALUES
  (1, 'Marco',    'Rossi',    '6561110001', 'marco.rossi@trattoria.mx',    '2020-01-15', 25000.00),
  (2, 'Sofía',    'Martínez', '6561110002', 'sofia.mtz@trattoria.mx',      '2021-03-10', 12000.00),
  (3, 'Giovanni', 'Bianchi',  '6561110003', 'gio.bianchi@trattoria.mx',    '2020-06-01', 20000.00),
  (4, 'Lucía',    'Torres',   '6561110004', 'lucia.torres@trattoria.mx',   '2022-09-01', 13000.00),
  (5, 'Pedro',    'Lara',     '6561110005', 'pedro.lara@trattoria.mx',     '2023-01-20', 11000.00);

-- Clientes
INSERT INTO clientes (nombre, apellido, telefono, email, fecha_registro) VALUES
  ('Ana',   'García',  '6562220001', 'ana.garcia@mail.com',  '2024-01-10'),
  ('Carlos','Medina',  '6562220002', 'carlos.m@mail.com',    '2024-02-14'),
  ('Elena', 'Fuentes', '6562220003', 'elena.f@mail.com',     '2024-03-05');

-- Mesas
INSERT INTO mesas (numero_mesa, capacidad, ubicacion, estado) VALUES
  (1, 2, 'Interior',  'libre'),
  (2, 4, 'Interior',  'libre'),
  (3, 6, 'Terraza',   'libre'),
  (4, 4, 'Terraza',   'libre'),
  (5, 8, 'Privado',   'libre'),
  (6, 2, 'Bar',       'libre');

-- Categorías del menú
INSERT INTO categorias (nombre, descripcion, orden_display) VALUES
  ('Antipasti',  'Entradas y aperitivos italianos',   1),
  ('Primi',      'Pastas, risottos y sopas',          2),
  ('Secondi',    'Carnes, pescados y proteínas',      3),
  ('Contorni',   'Guarniciones y ensaladas',          4),
  ('Dolci',      'Postres',                           5),
  ('Bevande',    'Bebidas, vinos y cócteles',         6);

-- Platillos
INSERT INTO platillos (id_categoria, nombre, descripcion, precio, disponible) VALUES
  (1, 'Bruschetta al Pomodoro', 'Pan tostado con tomate fresco, albahaca y aceite de oliva', 95.00,  1),
  (1, 'Carpaccio di Manzo',     'Láminas de res con rúcula, parmesano y alcaparras',         180.00, 1),
  (2, 'Spaghetti Carbonara',    'Pasta con huevo, guanciale, pecorino y pimienta negra',     165.00, 1),
  (2, 'Penne all\'Arrabbiata',  'Pasta con salsa picante de tomate y ajo',                   145.00, 1),
  (2, 'Risotto ai Funghi',      'Arroz cremoso con hongos porcini y parmesano',              185.00, 1),
  (3, 'Pollo alla Parmigiana',  'Milanesa de pollo con salsa pomodoro y mozzarella',         210.00, 1),
  (3, 'Salmone al Limone',      'Filete de salmón al horno con mantequilla y limón',         255.00, 1),
  (5, 'Tiramisù',               'Clásico postre italiano con café, mascarpone y cacao',      95.00,  1),
  (5, 'Panna Cotta',            'Crema italiana con coulis de frutos rojos',                  85.00,  1),
  (6, 'Acqua Minerale',         'Agua mineral 500 ml',                                        35.00,  1),
  (6, 'Vino Tinto Casa',        'Copa de vino tinto de la casa',                              80.00,  1),
  (6, 'Caffè Espresso',         'Espresso doble italiano',                                    55.00,  1);

-- Ingredientes
INSERT INTO ingredientes (nombre, unidad_medida, stock_actual, stock_minimo, costo_unidad) VALUES
  ('Spaghetti',           'kg',     15.00,  5.00,  28.00),
  ('Huevo',               'unidad', 60.00, 12.00,   4.50),
  ('Guanciale',           'kg',      4.50,  1.00, 180.00),
  ('Queso Pecorino',      'kg',      3.00,  0.50, 220.00),
  ('Tomate Salsero',      'kg',     20.00,  5.00,  18.00),
  ('Ajo',                 'kg',      2.00,  0.50,  25.00),
  ('Aceite de Oliva EV',  'lt',      8.00,  2.00,  95.00),
  ('Albahaca Fresca',     'kg',      0.50,  0.10,  60.00),
  ('Pan Baguette',        'unidad', 10.00,  4.00,  22.00),
  ('Arroz Arborio',       'kg',      8.00,  2.00,  55.00),
  ('Hongos Porcini',      'kg',      2.00,  0.50, 350.00),
  ('Queso Parmesano',     'kg',      5.00,  1.00, 280.00),
  ('Pechuga de Pollo',    'kg',     10.00,  3.00,  75.00),
  ('Mozzarella',          'kg',      4.00,  1.00, 160.00),
  ('Filete de Salmón',    'kg',      5.00,  1.50, 320.00),
  ('Queso Mascarpone',    'kg',      2.00,  0.50, 190.00),
  ('Café Espresso',       'kg',      3.00,  0.50, 280.00),
  ('Crema para Batir',    'lt',      4.00,  1.00,  65.00);

-- Recetas (ejemplos principales)
INSERT INTO recetas (id_platillo, id_ingrediente, cantidad_requerida) VALUES
  -- Spaghetti Carbonara (id 3)
  (3,  1, 0.150), -- spaghetti
  (3,  2, 2.000), -- huevo
  (3,  3, 0.080), -- guanciale
  (3,  4, 0.040), -- pecorino
  -- Bruschetta (id 1)
  (1,  9, 2.000), -- pan
  (1,  5, 0.100), -- tomate
  (1,  8, 0.020), -- albahaca
  (1,  7, 0.020), -- aceite oliva
  -- Risotto ai Funghi (id 5)
  (5, 10, 0.120), -- arroz arborio
  (5, 11, 0.060), -- porcini
  (5, 12, 0.030), -- parmesano
  -- Tiramisù (id 8)
  (8, 16, 0.100), -- mascarpone
  (8, 17, 0.015), -- café
  (8,  2, 2.000); -- huevo

-- Proveedores
INSERT INTO proveedores (nombre, contacto, telefono, email) VALUES
  ('Distribuidora La Pasta SA', 'Roberto Ferri',  '6563330001', 'ventas@lapasta.mx'),
  ('Carnes Select Juárez',      'María López',    '6563330002', 'mlopez@carnesse.mx'),
  ('Fresh Market Produce',      'Daniel Ortega',  '6563330003', 'dorte@freshmarket.mx');

-- Reservación de ejemplo
INSERT INTO reservaciones (id_cliente, id_mesa, fecha_hora, num_personas, estado, notas) VALUES
  (1, 3, '2026-05-15 20:00:00', 4, 'confirmada', 'Cumpleaños, solicitan pastel sorpresa'),
  (2, 2, '2026-05-16 13:30:00', 2, 'pendiente',  NULL);

-- Pedido de ejemplo
INSERT INTO pedidos (id_mesa, id_empleado, fecha_hora, tipo, estado, total) VALUES
  (2, 2, NOW(), 'local', 'abierto', 0.00);

INSERT INTO detalle_pedido (id_pedido, id_platillo, cantidad, precio_unitario, instrucciones) VALUES
  (1, 3, 2, 165.00, NULL),
  (1, 1, 1,  95.00, 'Sin ajo'),
  (1,12, 2,  55.00, NULL);

UPDATE pedidos SET total = (
  SELECT SUM(cantidad * precio_unitario) FROM detalle_pedido WHERE id_pedido = 1
) WHERE id_pedido = 1;

INSERT INTO pagos (id_pedido, monto, metodo_pago, estado) VALUES
  (1, 480.00, 'tarjeta_credito', 'completado');


-- ============================================================
--  VISTAS ÚTILES
-- ============================================================

-- Platillos disponibles con categoría
CREATE OR REPLACE VIEW v_menu AS
SELECT p.id_platillo, c.nombre AS categoria, p.nombre AS platillo,
       p.descripcion, p.precio
FROM platillos p
JOIN categorias c ON c.id_categoria = p.id_categoria
WHERE p.disponible = 1
ORDER BY c.orden_display, p.nombre;

-- Inventario con alerta de stock bajo
CREATE OR REPLACE VIEW v_stock_bajo AS
SELECT id_ingrediente, nombre, unidad_medida,
       stock_actual, stock_minimo,
       (stock_minimo - stock_actual) AS faltante
FROM ingredientes
WHERE stock_actual < stock_minimo;

-- Ventas del día por platillo
CREATE OR REPLACE VIEW v_ventas_hoy AS
SELECT pl.nombre AS platillo,
       SUM(dp.cantidad) AS unidades_vendidas,
       SUM(dp.cantidad * dp.precio_unitario) AS total_vendido
FROM detalle_pedido dp
JOIN platillos pl ON pl.id_platillo = dp.id_platillo
JOIN pedidos pe   ON pe.id_pedido   = dp.id_pedido
WHERE DATE(pe.fecha_hora) = CURRENT_DATE
  AND pe.estado NOT IN ('cancelado')
GROUP BY pl.id_platillo, pl.nombre
ORDER BY total_vendido DESC;

-- ============================================================
--  FIN DEL SCRIPT
-- ============================================================
