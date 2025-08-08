-- Base de datos
CREATE DATABASE IF NOT EXISTS sistema_formularios;
USE sistema_formularios;

-- Tabla de usuarios que responden formularios
CREATE TABLE usuario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    cargo VARCHAR(100),
    dependencia VARCHAR(100)
);

-- Tabla de formularios (puedes ajustar los títulos si lo deseas)
CREATE TABLE formulario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

-- Tabla de asignación usuario-formulario
CREATE TABLE asignacion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_formulario INT NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id),
    FOREIGN KEY (id_formulario) REFERENCES formulario(id),
    UNIQUE KEY idx_asignacion_usuario_formulario (id_usuario, id_formulario)
);

-- Tabla de factores (descripción fija para los 10 factores)
CREATE TABLE factor (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT NOT NULL
);

-- Tabla de respuestas de los usuarios a los factores
CREATE TABLE respuesta (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_formulario INT NOT NULL,
    fecha_respuesta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id),
    FOREIGN KEY (id_formulario) REFERENCES formulario(id),
    UNIQUE (id_usuario, id_formulario)
);

-- Índice para facilitar consultas por formulario
CREATE INDEX idx_respuesta_formulario
    ON respuesta (id_formulario);

-- Detalle de las respuestas por factor (valor de 1 a 10, sin repetir por respuesta)
CREATE TABLE respuesta_detalle (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_respuesta INT NOT NULL,
    id_factor INT NOT NULL,
    valor_usuario INT NOT NULL CHECK (valor_usuario BETWEEN 1 AND 10),
    FOREIGN KEY (id_respuesta) REFERENCES respuesta(id) ON DELETE CASCADE,
    FOREIGN KEY (id_factor) REFERENCES factor(id),
    UNIQUE (id_respuesta, valor_usuario),  -- impide duplicar valores
    UNIQUE (id_respuesta, id_factor)       -- impide duplicar factores
);

-- Índice para acelerar consultas por respuesta y factor
CREATE INDEX idx_respuesta_detalle_respuesta_factor
    ON respuesta_detalle (id_respuesta, id_factor);

-- Tabla de ponderación del administrador sobre cada respuesta
CREATE TABLE ponderacion_admin (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_respuesta INT NOT NULL,
    id_factor INT NOT NULL,
    peso_admin FLOAT NOT NULL,  -- Puedes usar INT si prefieres solo enteros
    FOREIGN KEY (id_respuesta) REFERENCES respuesta(id) ON DELETE CASCADE,
    FOREIGN KEY (id_factor) REFERENCES factor(id),
    UNIQUE (id_respuesta, id_factor)
);

-- Índice para búsquedas por respuesta en ponderaciones
CREATE INDEX idx_ponderacion_admin_respuesta
    ON ponderacion_admin (id_respuesta);

-- Insertar los 54 formularios
INSERT INTO formulario (nombre)
SELECT CONCAT('Formulario ', LPAD(n, 2, '0'))
FROM (SELECT @row := @row + 1 AS n FROM (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
      UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8
      UNION ALL SELECT 9) t1, (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
      UNION ALL SELECT 4 UNION ALL SELECT 5) t2, (SELECT @row := 0) t0) AS numeros
WHERE n <= 54;

-- Insertar los 10 factores (nombres y descripciones ejemplo)
INSERT INTO factor (nombre, descripcion) VALUES
('Factor 1', 'Descripción del factor 1'),
('Factor 2', 'Descripción del factor 2'),
('Factor 3', 'Descripción del factor 3'),
('Factor 4', 'Descripción del factor 4'),
('Factor 5', 'Descripción del factor 5'),
('Factor 6', 'Descripción del factor 6'),
('Factor 7', 'Descripción del factor 7'),
('Factor 8', 'Descripción del factor 8'),
('Factor 9', 'Descripción del factor 9'),
('Factor 10', 'Descripción del factor 10');


INSERT INTO usuario (id, nombre, apellidos, cargo, dependencia) VALUES
(1, 'Nombre1', 'Apellidos1', 'Cargo1', 'Dependencia1'),
(2, 'Nombre2', 'Apellidos2', 'Cargo2', 'Dependencia2'),
(3, 'Nombre3', 'Apellidos3', 'Cargo3', 'Dependencia3'),
(4, 'Nombre4', 'Apellidos4', 'Cargo4', 'Dependencia4'),
(5, 'Nombre5', 'Apellidos5', 'Cargo5', 'Dependencia5'),
(6, 'Nombre6', 'Apellidos6', 'Cargo6', 'Dependencia6'),
(7, 'Nombre7', 'Apellidos7', 'Cargo7', 'Dependencia7'),
(8, 'Nombre8', 'Apellidos8', 'Cargo8', 'Dependencia8'),
(9, 'Nombre9', 'Apellidos9', 'Cargo9', 'Dependencia9'),
(10, 'Nombre10', 'Apellidos10', 'Cargo10', 'Dependencia10'),
(11, 'Nombre11', 'Apellidos11', 'Cargo11', 'Dependencia11'),
(12, 'Nombre12', 'Apellidos12', 'Cargo12', 'Dependencia12'),
(13, 'Nombre13', 'Apellidos13', 'Cargo13', 'Dependencia13'),
(14, 'Nombre14', 'Apellidos14', 'Cargo14', 'Dependencia14'),
(15, 'Nombre15', 'Apellidos15', 'Cargo15', 'Dependencia15'),
(16, 'Nombre16', 'Apellidos16', 'Cargo16', 'Dependencia16'),
(17, 'Nombre17', 'Apellidos17', 'Cargo17', 'Dependencia17'),
(18, 'Nombre18', 'Apellidos18', 'Cargo18', 'Dependencia18'),
(19, 'Nombre19', 'Apellidos19', 'Cargo19', 'Dependencia19'),
(20, 'Nombre20', 'Apellidos20', 'Cargo20', 'Dependencia20'),
(21, 'Nombre21', 'Apellidos21', 'Cargo21', 'Dependencia21'),
(22, 'Nombre22', 'Apellidos22', 'Cargo22', 'Dependencia22'),
(23, 'Nombre23', 'Apellidos23', 'Cargo23', 'Dependencia23'),
(24, 'Nombre24', 'Apellidos24', 'Cargo24', 'Dependencia24'),
(25, 'Nombre25', 'Apellidos25', 'Cargo25', 'Dependencia25'),
(26, 'Nombre26', 'Apellidos26', 'Cargo26', 'Dependencia26'),
(27, 'Nombre27', 'Apellidos27', 'Cargo27', 'Dependencia27'),
(28, 'Nombre28', 'Apellidos28', 'Cargo28', 'Dependencia28'),
(29, 'Nombre29', 'Apellidos29', 'Cargo29', 'Dependencia29'),
(30, 'Nombre30', 'Apellidos30', 'Cargo30', 'Dependencia30'),
(31, 'Nombre31', 'Apellidos31', 'Cargo31', 'Dependencia31'),
(32, 'Nombre32', 'Apellidos32', 'Cargo32', 'Dependencia32'),
(33, 'Nombre33', 'Apellidos33', 'Cargo33', 'Dependencia33'),
(34, 'Nombre34', 'Apellidos34', 'Cargo34', 'Dependencia34'),
(35, 'Nombre35', 'Apellidos35', 'Cargo35', 'Dependencia35'),
(36, 'Nombre36', 'Apellidos36', 'Cargo36', 'Dependencia36'),
(37, 'Nombre37', 'Apellidos37', 'Cargo37', 'Dependencia37'),
(38, 'Nombre38', 'Apellidos38', 'Cargo38', 'Dependencia38'),
(39, 'Nombre39', 'Apellidos39', 'Cargo39', 'Dependencia39'),
(40, 'Nombre40', 'Apellidos40', 'Cargo40', 'Dependencia40'),
(41, 'Nombre41', 'Apellidos41', 'Cargo41', 'Dependencia41'),
(42, 'Nombre42', 'Apellidos42', 'Cargo42', 'Dependencia42'),
(43, 'Nombre43', 'Apellidos43', 'Cargo43', 'Dependencia43'),
(44, 'Nombre44', 'Apellidos44', 'Cargo44', 'Dependencia44'),
(45, 'Nombre45', 'Apellidos45', 'Cargo45', 'Dependencia45'),
(46, 'Nombre46', 'Apellidos46', 'Cargo46', 'Dependencia46'),
(47, 'Nombre47', 'Apellidos47', 'Cargo47', 'Dependencia47'),
(48, 'Nombre48', 'Apellidos48', 'Cargo48', 'Dependencia48'),
(49, 'Nombre49', 'Apellidos49', 'Cargo49', 'Dependencia49'),
(50, 'Nombre50', 'Apellidos50', 'Cargo50', 'Dependencia50'),
(51, 'Nombre51', 'Apellidos51', 'Cargo51', 'Dependencia51'),
(52, 'Nombre52', 'Apellidos52', 'Cargo52', 'Dependencia52'),
(53, 'Nombre53', 'Apellidos53', 'Cargo53', 'Dependencia53'),
(54, 'Nombre54', 'Apellidos54', 'Cargo54', 'Dependencia54'),
(55, 'Nombre55', 'Apellidos55', 'Cargo55', 'Dependencia55'),
(56, 'Nombre56', 'Apellidos56', 'Cargo56', 'Dependencia56'),
(57, 'Nombre57', 'Apellidos57', 'Cargo57', 'Dependencia57'),
(58, 'Nombre58', 'Apellidos58', 'Cargo58', 'Dependencia58'),
(59, 'Nombre59', 'Apellidos59', 'Cargo59', 'Dependencia59'),
(60, 'Nombre60', 'Apellidos60', 'Cargo60', 'Dependencia60');

INSERT INTO asignacion (id_usuario, id_formulario) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 13),
(14, 14),
(15, 15),
(16, 16),
(17, 17),
(18, 18),
(19, 19),
(20, 20),
(21, 21),
(22, 22),
(23, 23),
(24, 24),
(25, 25),
(26, 26),
(27, 27),
(28, 28),
(29, 29),
(30, 30),
(31, 31),
(32, 32),
(33, 33),
(34, 34),
(35, 35),
(36, 36),
(37, 37),
(38, 38),
(39, 39),
(40, 40),
(41, 41),
(42, 42),
(43, 43),
(44, 44),
(45, 45),
(46, 46),
(47, 47),
(48, 48),
(49, 49),
(50, 50),
(51, 51),
(52, 52),
(53, 53),
(54, 54);
