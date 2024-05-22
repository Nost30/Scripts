CREATE TABLE metacritic_games (
    game VARCHAR(100) NOT NULL,
    platform VARCHAR(50) NOT NULL,
    developer VARCHAR(100),
    genre VARCHAR(50),
    number_players VARCHAR(50),
    rating VARCHAR(50),
    release_date DATE NOT NULL,
    positive_critics SMALLINT NOT NULL,
    neutral_critics SMALLINT NOT NULL,
    negative_critics SMALLINT NOT NULL,
    positive_users SMALLINT NOT NULL,
    neutral_users SMALLINT NOT NULL,
    negative_users SMALLINT NOT NULL,
    metascore SMALLINT NOT NULL,
    user_score SMALLINT NOT NULL
);

COPY metacritic_games FROM 'C:\Users\Agustin\Desktop\metacritic_games.csv' WITH (FORMAT csv, HEADER true);

CREATE TABLE Plataforma (
    Id SERIAL PRIMARY KEY,
    NombrePlataforma VARCHAR(50) NOT NULL UNIQUE,
    IdUsuarioCrea INT,
    FechaCrea TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IdUsuarioModifica INT,
    FechaModifica TIMESTAMP,
    Estatus BOOLEAN DEFAULT TRUE
);

CREATE TABLE Genero (
    Id SERIAL PRIMARY KEY,
    Genero VARCHAR(50) UNIQUE,
    IdUsuarioCrea INT,
    FechaCrea TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IdUsuarioModifica INT,
    FechaModifica TIMESTAMP,
    Estatus BOOLEAN DEFAULT TRUE
);

CREATE TABLE Desarrolladora (
    Id SERIAL PRIMARY KEY,
    Desarrolladora VARCHAR(100),
    IdUsuarioCrea INT,
    FechaCrea TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IdUsuarioModifica INT,
    FechaModifica TIMESTAMP,
    Estatus BOOLEAN DEFAULT TRUE
);

CREATE TABLE Juego (
    Id SERIAL PRIMARY KEY,
    NombreJuego VARCHAR(100),
    IdGenero INT,
    IdDesarrolladora INT,
    IdPlataforma INT,
    FechaLanzamiento DATE,
    NumeroJugadores VARCHAR(50),
    Metascore SMALLINT,
    PuntajeUsuario SMALLINT,
    IdUsuarioCrea INT,
    FechaCrea TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IdUsuarioModifica INT,
    FechaModifica TIMESTAMP,
    Estatus BOOLEAN DEFAULT TRUE
);

CREATE TABLE Review (
    Id SERIAL PRIMARY KEY,
    IdJuego INT,
    Clasificacion VARCHAR(50),
    ReviewsPositivas SMALLINT,
    ReviewNeutras SMALLINT,
    ReviewNegativas SMALLINT,
    IdUsuarioCrea INT,
    FechaCrea TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IdUsuarioModifica INT,
    FechaModifica TIMESTAMP,
    Estatus BOOLEAN DEFAULT TRUE
);

ALTER TABLE Juego
ADD CONSTRAINT FK_JuegoGenero
FOREIGN KEY (IdGenero)
REFERENCES Genero(Id);

ALTER TABLE Juego
ADD CONSTRAINT FK_JuegoPlataforma
FOREIGN KEY (IdPlataforma)
REFERENCES Plataforma(Id);

ALTER TABLE Juego
ADD CONSTRAINT FK_JuegoDesarrolladora
FOREIGN KEY (IdDesarrolladora)
REFERENCES Desarrolladora(Id);

ALTER TABLE Review
ADD CONSTRAINT FK_ReviewsJuego
FOREIGN KEY (IdJuego)
REFERENCES Juego(Id);


CREATE TABLE Usuario (
    Id SERIAL PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    username VARCHAR(50) NOT NULL,
    Password VARCHAR(50) NOT NULL,
    Estatus BOOLEAN DEFAULT TRUE
);

ALTER TABLE Plataforma
ADD CONSTRAINT FK_PlataformaUsuarioCrea
FOREIGN KEY (IdUsuarioCrea)
REFERENCES Usuario(Id);

ALTER TABLE Plataforma
ADD CONSTRAINT FK_PlataformaUsuarioModifica
FOREIGN KEY (IdUsuarioModifica)
REFERENCES Usuario(Id);

ALTER TABLE Genero
ADD CONSTRAINT FK_GenerosUsuarioCrea
FOREIGN KEY (IdUsuarioCrea)
REFERENCES Usuario(Id);

ALTER TABLE Genero
ADD CONSTRAINT FK_GenerosUsuarioModifica
FOREIGN KEY (IdUsuarioModifica)
REFERENCES Usuario(Id);

ALTER TABLE Desarrolladora
ADD CONSTRAINT FK_DesarrolladorasUsuarioCrea
FOREIGN KEY (IdUsuarioCrea)
REFERENCES Usuario(Id);

ALTER TABLE Desarrolladora
ADD CONSTRAINT FK_DesarrolladorasUsuarioModifica
FOREIGN KEY (IdUsuarioModifica)
REFERENCES Usuario(Id);

ALTER TABLE Juego
ADD CONSTRAINT FK_JuegoUsuarioCrea
FOREIGN KEY (IdUsuarioCrea)
REFERENCES Usuario(Id);

ALTER TABLE Juego
ADD CONSTRAINT FK_JuegoUsuarioModifica
FOREIGN KEY (IdUsuarioModifica)
REFERENCES Usuario(Id);

ALTER TABLE Review
ADD CONSTRAINT FK_ReviewUsuarioCrea
FOREIGN KEY (IdUsuarioCrea)
REFERENCES Usuario(Id);

ALTER TABLE Review
ADD CONSTRAINT FK_ReviewUsuarioModifica
FOREIGN KEY (IdUsuarioModifica)
REFERENCES Usuario(Id);

-- Crear índices
CREATE INDEX IX_Usuario ON Usuario(Id);
CREATE INDEX IX_Plataforma ON Plataforma(Id);
CREATE INDEX IX_Genero ON Genero(Id);
CREATE INDEX IX_Desarrolladora ON Desarrolladora(Id);
CREATE INDEX IX_Juego ON Juego(Id);
CREATE INDEX IX_Review ON Review(Id);

-- Poblar tablas

-- INSERTAR DATOS A LA TABLA USUARIO
INSERT INTO Usuario(Nombre, username, Password, Estatus)
VALUES ('Admin', 'admin', 'c27ef4184b1ca67f8586e37271ea2c401b7171f8', TRUE);

-- INSERTAR DATOS A LA TABLA PLATAFORMA
INSERT INTO Plataforma(NombrePlataforma, IdUsuarioCrea)
SELECT DISTINCT platform, 1 FROM metacritic_games;

-- INSERTAR DATOS A LA TABLA GENERO
INSERT INTO Genero(Genero, IdUsuarioCrea)
SELECT DISTINCT genre, 1 FROM metacritic_games;

-- INSERTAR DATOS A LA TABLA DESARROLLADORA
INSERT INTO Desarrolladora(Desarrolladora, IdUsuarioCrea)
SELECT DISTINCT developer, 1 FROM metacritic_games;

-- INSERTAR DATOS A LA TABLA JUEGO
INSERT INTO Juego(NombreJuego, IdGenero, IdDesarrolladora, IdPlataforma, FechaLanzamiento, NumeroJugadores, Metascore, PuntajeUsuario, IdUsuarioCrea)
SELECT DISTINCT mg.game, g.Id, d.Id, p.Id, mg.release_date, mg.number_players, mg.metascore, mg.user_score, 1
FROM metacritic_games mg
INNER JOIN Desarrolladora d ON d.Desarrolladora = mg.developer
INNER JOIN Plataforma p ON p.NombrePlataforma = mg.platform
INNER JOIN Genero g ON g.Genero = mg.genre;

-- INSERTAR DATOS A LA TABLA REVIEW
INSERT INTO Review(IdJuego, Clasificacion, ReviewsPositivas, ReviewNeutras, ReviewNegativas, IdUsuarioCrea)
SELECT DISTINCT j.Id, mg.rating, mg.positive_users, mg.neutral_users, mg.negative_users, 1
FROM metacritic_games mg
INNER JOIN Juego j ON j.NombreJuego = mg.game;

-- Verificar los datos insertados en las tablas
SELECT * FROM Juego;
SELECT * FROM Review;


-- CREAR VISTA

CREATE OR REPLACE VIEW VW_JuegoReview AS
SELECT 
    J.Id AS IdJuego,
    J.NombreJuego,
    G.Genero,
    P.NombrePlataforma AS Plataforma,
    D.Desarrolladora,
    J.Metascore,
    J.NumeroJugadores
FROM 
    Juego J
JOIN 
    Genero G ON J.IdGenero = G.Id
LEFT JOIN 
    Plataforma P ON J.IdPlataforma = P.Id
LEFT JOIN 
    Desarrolladora D ON J.IdDesarrolladora = D.Id;


-- Borrar vista DROP VIEW VW_JuegoReview;

-- AGREGAR NUEVO JUEGO
CREATE OR REPLACE FUNCTION SP_AgregarJuego(
    p_NombreJuego VARCHAR(100),
    p_IdGenero INT,
    p_IdDesarrolladora INT,
    p_IdPlataforma INT,
    p_FechaLanzamiento DATE,
    p_NumeroJugadores VARCHAR(50),
    p_Metascore SMALLINT,
    p_PuntajeUsuario SMALLINT,
    p_IdUsuarioCrea INT
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO Juego (NombreJuego, IdGenero, IdDesarrolladora, IdPlataforma, FechaLanzamiento, NumeroJugadores, Metascore, PuntajeUsuario, IdUsuarioCrea)
    VALUES (p_NombreJuego, p_IdGenero, p_IdDesarrolladora, p_IdPlataforma, p_FechaLanzamiento, p_NumeroJugadores, p_Metascore, p_PuntajeUsuario, p_IdUsuarioCrea);
END;
$$ LANGUAGE plpgsql;


--ACTUALIZAR JUEGO
CREATE OR REPLACE FUNCTION SP_ActualizarJuego(
    p_IdJuego INT,
    p_NombreJuego VARCHAR(100),
    p_IdGenero INT,
    p_IdDesarrolladora INT,
    p_IdPlataforma INT,
    p_FechaLanzamiento DATE,
    p_NumeroJugadores VARCHAR(50),
    p_Metascore SMALLINT,
    p_PuntajeUsuario SMALLINT,
    p_IdUsuarioModifica INT
)
RETURNS VOID AS $$
BEGIN
    UPDATE Juego
    SET NombreJuego = p_NombreJuego,
        IdGenero = p_IdGenero,
        IdDesarrolladora = p_IdDesarrolladora,
        IdPlataforma = p_IdPlataforma,
        FechaLanzamiento = p_FechaLanzamiento,
        NumeroJugadores = p_NumeroJugadores,
        Metascore = p_Metascore,
        PuntajeUsuario = p_PuntajeUsuario,
        IdUsuarioModifica = p_IdUsuarioModifica,
        FechaModifica = CURRENT_DATE
    WHERE Id = p_IdJuego;
END;
$$ LANGUAGE plpgsql;

--ELIMINAR JUEGO
CREATE OR REPLACE FUNCTION SP_EliminarJuego(
    p_IdJuego INT
)
RETURNS VOID AS $$
DECLARE
    table_name TEXT;
BEGIN
    -- Desactivar las restricciones de clave externa temporalmente
    FOR table_name IN SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' LOOP
        EXECUTE 'ALTER TABLE ' || table_name || ' DISABLE TRIGGER ALL';
    END LOOP;

    -- Eliminar el juego de la tabla Review
    DELETE FROM Review WHERE IdJuego = p_IdJuego;

    -- Eliminar el juego de la tabla Juego
    DELETE FROM Juego WHERE Id = p_IdJuego;

    -- Activar las restricciones de clave externa nuevamente
    FOR table_name IN SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' LOOP
        EXECUTE 'ALTER TABLE ' || table_name || ' ENABLE TRIGGER ALL';
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- AGREGAR GENERO
CREATE OR REPLACE PROCEDURE SP_AgregarGenero (
    IN p_Genero VARCHAR(50),
    IN p_IdUsuarioCrea INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Genero (Genero, IdUsuarioCrea)
    VALUES (p_Genero, p_IdUsuarioCrea);
END;
$$;

-- AGREGAR PLATAFORMA
CREATE OR REPLACE PROCEDURE SP_AgregarPlataforma (
    IN p_NombrePlataforma VARCHAR(50),
    IN p_IdUsuarioCrea INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Plataforma (NombrePlataforma, IdUsuarioCrea)
    VALUES (p_NombrePlataforma, p_IdUsuarioCrea);
END;
$$;

-- AGREGAR DESARROLLADORA
CREATE OR REPLACE PROCEDURE SP_AgregarDesarrolladora (
    IN p_Desarrolladora VARCHAR(100),
    IN p_IdUsuarioCrea INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Desarrolladora (Desarrolladora, IdUsuarioCrea)
    VALUES (p_Desarrolladora, p_IdUsuarioCrea);
END;
$$;