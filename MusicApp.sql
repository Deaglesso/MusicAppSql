CREATE DATABASE MusicApp

USE MusicApp

CREATE TABLE Genders
(
	[ID] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(25),
	[Letter] VARCHAR(2)
)

CREATE TABLE Users
(
	[ID] INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(25) CHECK(LEN(Name)>=3),
	[Surname] NVARCHAR(25) CHECK(LEN(Surname)>=3),
	[Username] VARCHAR(25) CHECK(LEN(Username)>=3),
	[Password] VARCHAR(25) CHECK(LEN(Password)>=8),
	[Gender] INT FOREIGN KEY REFERENCES Genders(ID)
)

CREATE TABLE Artists
(
	[ID] INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(25) CHECK(LEN(Name)>=3),
	[Surname] NVARCHAR(25) CHECK(LEN(Surname)>=3),
	[Birthday] DATE,
	[Gender] INT FOREIGN KEY REFERENCES Genders(ID)
)

CREATE TABLE Categories
(
	[ID] INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(25) CHECK(LEN(Name)>=3)
)

CREATE TABLE Musics
(
	[ID] INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(25) CHECK(LEN(Name)>=3),
	[Duration] INT CHECK(Duration>0),
	[CatID] INT REFERENCES Categories(ID)

)


CREATE TABLE ArtistMusics
(
	[ArtistID] INT REFERENCES Artists(ID),
	[MusicID] INT REFERENCES Musics(ID)
)


CREATE TABLE Playlist
(
	[UserID] INT REFERENCES Users(ID),
	[MusicID] INT REFERENCES Musics(ID)
)

CREATE VIEW MusicInfo AS
SELECT Musics.Name,Musics.Duration,Categories.Name AS Genre,Artists.Name + ' ' + Artists.Surname AS [Artist Name] FROM Musics,Categories,Artists,ArtistMusics
WHERE Musics.CatID = Categories.ID AND Musics.ID = ArtistMusics.MusicID AND Artists.ID = ArtistMusics.ArtistID 

SELECT * FROM MusicInfo

CREATE PROCEDURE usp_CreateMusic @name VARCHAR(25), @duration INT, @catid INT,@artistid INT
AS
INSERT INTO Musics(Name,Duration,CatID) VALUES 
(
	@name,@duration,@catid
)
DECLARE @musicid INT
SET @musicid = (SELECT MAX(ID) FROM Musics)
INSERT INTO ArtistMusics(ArtistID,MusicID) VALUES
(
	@artistID, @musicid
)

EXEC usp_CreateMusic 'Paint the town red', 290, 2, 2

CREATE PROCEDURE usp_CreateUser @name NVARCHAR(25), @surname NVARCHAR(25), @username VARCHAR(25), @password VARCHAR(25), @gender INT
AS
BEGIN
    INSERT INTO Users (Name, Surname, Username, Password, Gender) 
    VALUES (@name, @surname, @username, @password, @gender)
END

EXEC usp_CreateUser 'Shems','Rehimzade','shems','shems123',2

CREATE PROCEDURE usp_CreateCategory @name NVARCHAR(25)
AS
BEGIN
    INSERT INTO Categories (Name) 
    VALUES (@name)
END

EXEC usp_CreateCategory 'Classic'



ALTER TABLE Musics ADD IsDeleted BIT DEFAULT 0

ALTER TRIGGER MusicDeleteTrigger 
ON Musics
INSTEAD OF DELETE
AS
BEGIN
DECLARE @id INT, @flag BIT
SET @id= (SELECT ID FROM deleted)
SET @flag = (SELECT IsDeleted FROM deleted)
DELETE FROM Playlist WHERE MusicID =@id;
IF(@flag = 0)
BEGIN
	UPDATE Musics SET IsDeleted = 1 WHERE ID = @id
END
ELSE
BEGIN
	DELETE FROM ArtistMusics WHERE MusicID = @id;
	DELETE FROM Musics WHERE ID=@id
END
END

DELETE FROM Musics WHERE ID = 3

DELETE FROM Musics WHERE ID = 3

DELETE FROM Musics WHERE ID = 4

CREATE FUNCTION dbo.GetArtistCountByUser (@UserID INT)
RETURNS INT
AS
BEGIN
    DECLARE @ArtistCount INT
    SET @ArtistCount = (
        SELECT COUNT(ArtistID)
        FROM (
            SELECT am.ArtistID
            FROM Playlist p
            JOIN ArtistMusics am ON p.MusicID = am.MusicID
            WHERE p.UserID = @UserID
            GROUP BY am.ArtistID
        ) AS T
    )

    RETURN @ArtistCount
END

SELECT dbo.GetArtistCountByUser(5) AS Result