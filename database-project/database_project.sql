/* ============================================================
   פרויקט: VideoGamesDB — תכנון ויצירת טבלאות
   נושא: משחקי וידאו 🎮
   קורס: SQL Server (T‑SQL)
   מחבר/ים: ...
   תאריך: ...
   מטרה:
   - ליצור בסיס נתונים עם 4–5 טבלאות, קשרים ואילוצים
   - לתעד בהחלטות התכנון ובשיקולים העסקיים
   ============================================================ */

-- ------------------------------------------------------------
-- [שלב 0] איפוס בסיס הנתונים (לצורכי פיתוח/תרגול בלבד!)
-- בודק אם DB קיים -> מעביר ל-SINGLE_USER -> מנתק חיבורים -> מוחק.
-- כך אפשר להריץ את הסקריפט מהתחלה בצורה נקייה.
-- הערה: לא להשתמש כך בסביבת פרודקשן.
-- ------------------------------------------------------------
IF DB_ID('VideoGamesDB') IS NOT NULL
BEGIN
    ALTER DATABASE VideoGamesDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE; -- ניתוק כל החיבורים הפעילים
    DROP DATABASE VideoGamesDB; -- מחיקת ה-DB הקיים
END;
GO

-- ------------------------------------------------------------
-- [שלב 1] יצירת בסיס נתונים חדש והחלפת קונטקסט
-- ------------------------------------------------------------
CREATE DATABASE VideoGamesDB; -- יצירת DB חדש
GO
USE VideoGamesDB;             -- עבודה מכאן והלאה בתוך ה-DB הזה
GO

/* ============================================================
   תכנון לוגי (ERD קצר):
   - Developers (מפתחים/סטודיו) — טבלת ייחוס
   - Genres (ז'אנרים) — טבלת ייחוס
   - Platforms (פלטפורמות) — טבלת ייחוס
   - Games (משחקים) — טבלה מרכזית: FK ל-Developers ו-Genres
   - GamePlatforms (קישור N–N) — משחק X פלטפורמה + תאריך יציאה ספציפי
   שיקולים:
   - מפתחות מלאכותיים INT IDENTITY לנוחות ויעילות
   - ייחודיות שמות בטבלאות ייחוס
   - מניעת כפילויות בשם המשחק אצל אותו מפתח (UQ על Title+DeveloperID)
   - CHECK להגבלת טווחים (שנה, ציון, מחיר)
   ============================================================ */

-- ------------------------------------------------------------
-- [שלב 2] טבלאות ייחוס
-- ------------------------------------------------------------

-- Developers: טבלת מפתחים/סטודיו
-- PK: מפתח מלאכותי. שם המפתח UQ לשמירת ייחודיות.
CREATE TABLE dbo.Developers (
    DeveloperID INT IDENTITY(1,1) CONSTRAINT PK_Developers PRIMARY KEY, -- מזהה ייחודי אוטומטי
    Name        NVARCHAR(200) NOT NULL CONSTRAINT UQ_Developers_Name UNIQUE, -- שם ייחודי למניעת כפילויות
    Country     NVARCHAR(100) NULL -- מדינת מוצא (רשות)
);

-- Genres: טבלת ז'אנרים
-- שמות ז'אנר ייחודיים כדי למנוע חזרות.
CREATE TABLE dbo.Genres (
    GenreID INT IDENTITY(1,1) CONSTRAINT PK_Genres PRIMARY KEY,
    Name    NVARCHAR(100) NOT NULL CONSTRAINT UQ_Genres_Name UNIQUE
);

-- Platforms: טבלת פלטפורמות (שם ייחודי + יצרן אופציונלי)
CREATE TABLE dbo.Platforms (
    PlatformID   INT IDENTITY(1,1) CONSTRAINT PK_Platforms PRIMARY KEY,
    Name         NVARCHAR(100) NOT NULL CONSTRAINT UQ_Platforms_Name UNIQUE, -- שם הפלטפורמה ייחודי
    Manufacturer NVARCHAR(100) NULL -- יצרן (למשל: Sony, Microsoft, Nintendo, PC=Various)
);

-- ------------------------------------------------------------
-- [שלב 3] טבלת משחקים (עובדות)
-- ------------------------------------------------------------
-- FK ל-Developers ו-Genres, אילוצי CHECK לטווחי ערכים, ו-UQ למניעת כפילות משחק אצל אותו מפתח.
CREATE TABLE dbo.Games (
    GameID       INT IDENTITY(1,1) CONSTRAINT PK_Games PRIMARY KEY, -- מזהה משחק
    Title        NVARCHAR(200) NOT NULL, -- שם המשחק
    ReleaseYear  SMALLINT NOT NULL
        CONSTRAINT CK_Games_ReleaseYear CHECK (ReleaseYear BETWEEN 1970 AND 2035), -- טווח סביר
    Metascore    TINYINT NULL
        CONSTRAINT CK_Games_Metascore CHECK (Metascore BETWEEN 0 AND 100), -- ציון 0–100
    Price        DECIMAL(6,2) NULL
        CONSTRAINT CK_Games_Price CHECK (Price >= 0), -- מחיר לא שלילי
    DeveloperID  INT NOT NULL, -- FK: חייב מפתח קיים בטבלת Developers
    GenreID      INT NOT NULL, -- FK: חייב ז'אנר קיים
    CONSTRAINT UQ_Games_Title_Developer UNIQUE (Title, DeveloperID), -- אי-כפילות של שם אצל אותו מפתח
    CONSTRAINT FK_Games_Developers FOREIGN KEY (DeveloperID)
        REFERENCES dbo.Developers(DeveloperID),
    CONSTRAINT FK_Games_Genres FOREIGN KEY (GenreID)
        REFERENCES dbo.Genres(GenreID)
    -- ללא ON DELETE CASCADE בכוונה: נמנע מחיקות שרשרת בשוגג; ננהל מחיקות ידנית/לוגית.
);

-- ------------------------------------------------------------
-- [שלב 4] טבלת צימוד משחק–פלטפורמה (יחס N–N)
-- ------------------------------------------------------------
-- מפתח משולב (GameID, PlatformID) מונע כפילויות של אותו משחק על אותה פלטפורמה.
-- ReleaseDate אופציונלי — לא תמיד יש לנו את התאריך המדויק לכל פלטפורמה.
CREATE TABLE dbo.GamePlatforms (
    GameID      INT NOT NULL,
    PlatformID  INT NOT NULL,
    ReleaseDate DATE NULL, -- תאריך יציאה ספציפי לפלטפורמה (אם ידוע)
    CONSTRAINT PK_GamePlatforms PRIMARY KEY (GameID, PlatformID),
    CONSTRAINT FK_GamePlatforms_Games FOREIGN KEY (GameID)
        REFERENCES dbo.Games(GameID),
    CONSTRAINT FK_GamePlatforms_Platforms FOREIGN KEY (PlatformID)
        REFERENCES dbo.Platforms(PlatformID)
);

/* ============================================================
   הערות תכנוניות נוספות:
   - שמות אילוצים (PK_/FK_/UQ_/CK_) ניתנים במפורש לניהול קל (ALTER/DROP).
   - טיפוסים:
     * NVARCHAR — תמיכה בעברית/שפות עם ניקוד/יוניקוד.
     * SMALLINT לשנת יציאה (חסכוני ומתאים לטווח), TINYINT לציון.
     * DECIMAL(6,2) למחירים (עד 9999.99).
   - נורמליזציה:
     * טבלאות ייחוס מוקדשות ל-Developers/Genres/Platforms.
     * קשר N–N עם מפתח מורכב.
   ============================================================ */

   USE VideoGamesDB;
GO

/* ============================================
   [שלב 2] הזנת נתונים לדוגמה (DML)
   סדר חשוב: טבלאות ייחוס -> טבלת Games -> טבלת צימוד GamePlatforms
   ============================================ */

------------------------------------------------------------
-- 1) Developers — לפחות 20 רשומות (שמות ייחודיים)
------------------------------------------------------------
INSERT INTO dbo.Developers (Name, Country) VALUES
(N'Nintendo', N'Japan'),
(N'FromSoftware', N'Japan'),
(N'CD Projekt', N'Poland'),
(N'Mojang Studios', N'Sweden'),
(N'Rockstar Games', N'USA'),
(N'Ubisoft', N'France'),
(N'Bethesda Game Studios', N'USA'),
(N'Square Enix', N'Japan'),
(N'Capcom', N'Japan'),
(N'Sega', N'Japan'),
(N'Naughty Dog', N'USA'),
(N'Insomniac Games', N'USA'),
(N'BioWare', N'Canada'),
(N'Blizzard Entertainment', N'USA'),
(N'Valve', N'USA'),
(N'NetherRealm Studios', N'USA'),
(N'343 Industries', N'USA'),
(N'Treyarch', N'USA'),
(N'Respawn Entertainment', N'USA'),
(N'Larian Studios', N'Belgium');

------------------------------------------------------------
-- 2) Genres — לפחות 20 רשומות (שמות ייחודיים)
------------------------------------------------------------
INSERT INTO dbo.Genres (Name) VALUES
(N'Action'),
(N'RPG'),
(N'Sandbox'),
(N'Adventure'),
(N'Shooter'),
(N'Strategy'),
(N'Simulation'),
(N'Sports'),
(N'Racing'),
(N'Puzzle'),
(N'Platformer'),
(N'Fighting'),
(N'Survival'),
(N'Horror'),
(N'Indie'),
(N'MMO'),
(N'Roguelike'),
(N'Metroidvania'),
(N'Stealth'),
(N'Open World');

------------------------------------------------------------
-- 3) Platforms — לפחות 20 רשומות (שמות ייחודיים)
------------------------------------------------------------
INSERT INTO dbo.Platforms (Name, Manufacturer) VALUES
(N'PC', N'Various'),
(N'PlayStation 4', N'Sony'),
(N'PlayStation 5', N'Sony'),
(N'Xbox One', N'Microsoft'),
(N'Xbox Series X|S', N'Microsoft'),
(N'Nintendo Switch', N'Nintendo'),
(N'Nintendo 3DS', N'Nintendo'),
(N'PlayStation 3', N'Sony'),
(N'Xbox 360', N'Microsoft'),
(N'Wii', N'Nintendo'),
(N'Wii U', N'Nintendo'),
(N'PlayStation Vita', N'Sony'),
(N'Mobile', N'Various'),
(N'macOS', N'Apple'),
(N'Linux', N'Various'),
(N'Steam Deck', N'Valve'),
(N'Stadia', N'Google'),
(N'PlayStation 2', N'Sony'),
(N'GameCube', N'Nintendo'),
(N'Dreamcast', N'Sega');

------------------------------------------------------------
-- 4) Games — לפחות 20 רשומות
-- שימוש בתתי-שאילתות לשיוך FK לפי שם (Developer, Genre)
------------------------------------------------------------
INSERT INTO dbo.Games (Title, ReleaseYear, Metascore, Price, DeveloperID, GenreID) VALUES
(N'The Legend of Zelda: Breath of the Wild', 2017, 97, 59.99,
 (SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Nintendo'),
 (SELECT GenreID     FROM dbo.Genres     WHERE Name=N'Open World')),
(N'Elden Ring', 2022, 96, 59.99,
 (SELECT DeveloperID FROM dbo.Developers WHERE Name=N'FromSoftware'),
 (SELECT GenreID     FROM dbo.Genres     WHERE Name=N'RPG')),
(N'The Witcher 3: Wild Hunt', 2015, 92, 39.99,
 (SELECT DeveloperID FROM dbo.Developers WHERE Name=N'CD Projekt'),
 (SELECT GenreID     FROM dbo.Genres     WHERE Name=N'RPG')),
(N'Minecraft', 2011, 93, 26.95,
 (SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Mojang Studios'),
 (SELECT GenreID     FROM dbo.Genres     WHERE Name=N'Sandbox')),
(N'Grand Theft Auto V', 2013, 97, 29.99,
 (SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Rockstar Games'),
 (SELECT GenreID     FROM dbo.Genres     WHERE Name=N'Open World')),
(N'Assassin''s Creed Odyssey', 2018, 86, 49.99,
 (SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Ubisoft'),
 (SELECT GenreID     FROM dbo.Genres     WHERE Name=N'Open World')),
(N'The Elder Scrolls V: Skyrim', 2011, 94, 39.99,
 (SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Bethesda Game Studios'),
 (SELECT GenreID     FROM dbo.Genres     WHERE Name=N'RPG')),
(N'Final Fantasy VII Remake', 2020, 87, 69.99,
 (SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Square Enix'),
 (SELECT GenreID     FROM dbo.Genres     WHERE Name=N'RPG')),
(N'Monster Hunter: World', 2018, 90, 29.99,
 (SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Capcom'),
 (SELECT GenreID     FROM dbo.Genres     WHERE Name=N'Action')),
(N'Sonic Mania', 2017, 86, 19.99,
 (SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Sega'),
 (SELECT GenreID     FROM dbo.Genres     WHERE Name=N'Platformer')),
(N'The Last of Us Part II', 2020, 93, 59.99,
 (SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Naughty Dog'),
 (SELECT GenreID     FROM dbo.Genres     WHERE Name=N'Adventure')),
(N'Marvel''s Spider-Man', 2018, 87, 49.99,
 (SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Insomniac Games'),
 (SELECT GenreID     FROM dbo.Genres     WHERE Name=N'Action')),
(N'Mass Effect 2', 2010, 94, 19.99,
 (SELECT DeveloperID FROM dbo.Developers WHERE Name=N'BioWare'),
 (SELECT GenreID     FROM dbo.Genres     WHERE Name=N'RPG')),
(N'Overwatch', 2016, 91, 39.99,
 (SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Blizzard Entertainment'),
 (SELECT GenreID     FROM dbo.Genres     WHERE Name=N'Shooter')),
(N'Half-Life: Alyx', 2020, 93, 59.99,
 (SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Valve'),
 (SELECT GenreID     FROM dbo.Genres     WHERE Name=N'Shooter')),
(N'Mortal Kombat 11', 2019, 88, 49.99,
 (SELECT DeveloperID FROM dbo.Developers WHERE Name=N'NetherRealm Studios'),
 (SELECT GenreID     FROM dbo.Genres     WHERE Name=N'Fighting')),
(N'Halo Infinite', 2021, 87, 59.99,
 (SELECT DeveloperID FROM dbo.Developers WHERE Name=N'343 Industries'),
 (SELECT GenreID     FROM dbo.Genres     WHERE Name=N'Shooter')),
(N'Call of Duty: Black Ops Cold War', 2020, 76, 59.99,
 (SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Treyarch'),
 (SELECT GenreID     FROM dbo.Genres     WHERE Name=N'Shooter')),
(N'Apex Legends', 2019, 88, 0.00,
 (SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Respawn Entertainment'),
 (SELECT GenreID     FROM dbo.Genres     WHERE Name=N'Shooter')),
(N'Baldur''s Gate 3', 2023, 96, 69.99,
 (SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Larian Studios'),
 (SELECT GenreID     FROM dbo.Genres     WHERE Name=N'RPG'));

------------------------------------------------------------
-- 5) GamePlatforms — לפחות 20 רשומות (צימוד N–N)
-- כאן נבחר "פלטפורמה עיקרית" אחת לכל משחק כדי לעמוד במינימום 20.
-- ניתן להרחיב בקלות ולהוסיף פלטפורמות נוספות לכל משחק.
------------------------------------------------------------
INSERT INTO dbo.GamePlatforms (GameID, PlatformID, ReleaseDate) VALUES
-- BOTW (Switch)
((SELECT GameID FROM dbo.Games WHERE Title=N'The Legend of Zelda: Breath of the Wild'
   AND DeveloperID=(SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Nintendo')),
 (SELECT PlatformID FROM dbo.Platforms WHERE Name=N'Nintendo Switch'),
 '2017-03-03'),

-- Elden Ring (PC)
((SELECT GameID FROM dbo.Games WHERE Title=N'Elden Ring'
   AND DeveloperID=(SELECT DeveloperID FROM dbo.Developers WHERE Name=N'FromSoftware')),
 (SELECT PlatformID FROM dbo.Platforms WHERE Name=N'PC'),
 '2022-02-25'),

-- Witcher 3 (PC)
((SELECT GameID FROM dbo.Games WHERE Title=N'The Witcher 3: Wild Hunt'
   AND DeveloperID=(SELECT DeveloperID FROM dbo.Developers WHERE Name=N'CD Projekt')),
 (SELECT PlatformID FROM dbo.Platforms WHERE Name=N'PC'),
 '2015-05-19'),

-- Minecraft (PC)
((SELECT GameID FROM dbo.Games WHERE Title=N'Minecraft'
   AND DeveloperID=(SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Mojang Studios')),
 (SELECT PlatformID FROM dbo.Platforms WHERE Name=N'PC'),
 '2011-11-18'),

-- GTA V (PS4)
((SELECT GameID FROM dbo.Games WHERE Title=N'Grand Theft Auto V'
   AND DeveloperID=(SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Rockstar Games')),
 (SELECT PlatformID FROM dbo.Platforms WHERE Name=N'PlayStation 4'),
 '2014-11-18'),

-- AC Odyssey (PS4)
((SELECT GameID FROM dbo.Games WHERE Title=N'Assassin''s Creed Odyssey'
   AND DeveloperID=(SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Ubisoft')),
 (SELECT PlatformID FROM dbo.Platforms WHERE Name=N'PlayStation 4'),
 '2018-10-05'),

-- Skyrim (PC)
((SELECT GameID FROM dbo.Games WHERE Title=N'The Elder Scrolls V: Skyrim'
   AND DeveloperID=(SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Bethesda Game Studios')),
 (SELECT PlatformID FROM dbo.Platforms WHERE Name=N'PC'),
 '2011-11-11'),

-- FF7 Remake (PS4)
((SELECT GameID FROM dbo.Games WHERE Title=N'Final Fantasy VII Remake'
   AND DeveloperID=(SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Square Enix')),
 (SELECT PlatformID FROM dbo.Platforms WHERE Name=N'PlayStation 4'),
 '2020-04-10'),

-- Monster Hunter: World (PS4)
((SELECT GameID FROM dbo.Games WHERE Title=N'Monster Hunter: World'
   AND DeveloperID=(SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Capcom')),
 (SELECT PlatformID FROM dbo.Platforms WHERE Name=N'PlayStation 4'),
 '2018-01-26'),

-- Sonic Mania (Switch)
((SELECT GameID FROM dbo.Games WHERE Title=N'Sonic Mania'
   AND DeveloperID=(SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Sega')),
 (SELECT PlatformID FROM dbo.Platforms WHERE Name=N'Nintendo Switch'),
 '2017-08-15'),

-- TLOU Part II (PS4)
((SELECT GameID FROM dbo.Games WHERE Title=N'The Last of Us Part II'
   AND DeveloperID=(SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Naughty Dog')),
 (SELECT PlatformID FROM dbo.Platforms WHERE Name=N'PlayStation 4'),
 '2020-06-19'),

-- Spider-Man (PS4)
((SELECT GameID FROM dbo.Games WHERE Title=N'Marvel''s Spider-Man'
   AND DeveloperID=(SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Insomniac Games')),
 (SELECT PlatformID FROM dbo.Platforms WHERE Name=N'PlayStation 4'),
 '2018-09-07'),

-- Mass Effect 2 (Xbox 360)
((SELECT GameID FROM dbo.Games WHERE Title=N'Mass Effect 2'
   AND DeveloperID=(SELECT DeveloperID FROM dbo.Developers WHERE Name=N'BioWare')),
 (SELECT PlatformID FROM dbo.Platforms WHERE Name=N'Xbox 360'),
 '2010-01-26'),

-- Overwatch (PC)
((SELECT GameID FROM dbo.Games WHERE Title=N'Overwatch'
   AND DeveloperID=(SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Blizzard Entertainment')),
 (SELECT PlatformID FROM dbo.Platforms WHERE Name=N'PC'),
 '2016-05-24'),

-- Half-Life: Alyx (PC)
((SELECT GameID FROM dbo.Games WHERE Title=N'Half-Life: Alyx'
   AND DeveloperID=(SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Valve')),
 (SELECT PlatformID FROM dbo.Platforms WHERE Name=N'PC'),
 '2020-03-23'),

-- Mortal Kombat 11 (PS4)
((SELECT GameID FROM dbo.Games WHERE Title=N'Mortal Kombat 11'
   AND DeveloperID=(SELECT DeveloperID FROM dbo.Developers WHERE Name=N'NetherRealm Studios')),
 (SELECT PlatformID FROM dbo.Platforms WHERE Name=N'PlayStation 4'),
 '2019-04-23'),

-- Halo Infinite (Xbox Series X|S)
((SELECT GameID FROM dbo.Games WHERE Title=N'Halo Infinite'
   AND DeveloperID=(SELECT DeveloperID FROM dbo.Developers WHERE Name=N'343 Industries')),
 (SELECT PlatformID FROM dbo.Platforms WHERE Name=N'Xbox Series X|S'),
 '2021-12-08'),

-- CoD: Black Ops Cold War (PS5)
((SELECT GameID FROM dbo.Games WHERE Title=N'Call of Duty: Black Ops Cold War'
   AND DeveloperID=(SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Treyarch')),
 (SELECT PlatformID FROM dbo.Platforms WHERE Name=N'PlayStation 5'),
 '2020-11-13'),

-- Apex Legends (PC)
((SELECT GameID FROM dbo.Games WHERE Title=N'Apex Legends'
   AND DeveloperID=(SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Respawn Entertainment')),
 (SELECT PlatformID FROM dbo.Platforms WHERE Name=N'PC'),
 '2019-02-04'),

-- Baldur's Gate 3 (PC)
((SELECT GameID FROM dbo.Games WHERE Title=N'Baldur''s Gate 3'
   AND DeveloperID=(SELECT DeveloperID FROM dbo.Developers WHERE Name=N'Larian Studios')),
 (SELECT PlatformID FROM dbo.Platforms WHERE Name=N'PC'),
 '2023-08-03');

 -- Comptages
SELECT 'Developers' AS T, COUNT(*) FROM dbo.Developers
UNION ALL SELECT 'Genres', COUNT(*) FROM dbo.Genres
UNION ALL SELECT 'Platforms', COUNT(*) FROM dbo.Platforms
UNION ALL SELECT 'Games', COUNT(*) FROM dbo.Games
UNION ALL SELECT 'GamePlatforms', COUNT(*) FROM dbo.GamePlatforms;


- בדיקת כפילויות (אמור להחזיר 0 שורות)
SELECT Name, COUNT(*) c FROM dbo.Developers GROUP BY Name HAVING COUNT(*) > 1;
SELECT Name, COUNT(*) c FROM dbo.Genres     GROUP BY Name HAVING COUNT(*) > 1;
SELECT Name, COUNT(*) c FROM dbo.Platforms  GROUP BY Name HAVING COUNT(*) > 1;

SELECT Title, DeveloperID, COUNT(*) c
FROM dbo.Games
GROUP BY Title, DeveloperID
HAVING COUNT(*) > 1;

-- בדיקת יתומים (Orphans) — אמור להחזיר 0 שורות
SELECT g.* FROM dbo.Games g
LEFT JOIN dbo.Developers d ON g.DeveloperID = d.DeveloperID
WHERE d.DeveloperID IS NULL;

SELECT g.* FROM dbo.Games g
LEFT JOIN dbo.Genres ge ON g.GenreID = ge.GenreID
WHERE ge.GenreID IS NULL;

SELECT gp.* FROM dbo.GamePlatforms gp
LEFT JOIN dbo.Games g ON gp.GameID = g.GameID
WHERE g.GameID IS NULL;

SELECT gp.* FROM dbo.GamePlatforms gp
LEFT JOIN dbo.Platforms p ON gp.PlatformID = p.PlatformID
WHERE p.PlatformID IS NULL;

-- רשימת משחקים עם מפתח וז'אנר (JOIN בסיסי)
SELECT g.GameID, g.Title, g.ReleaseYear, g.Metascore,
       d.Name  AS Developer, ge.Name AS Genre
FROM dbo.Games g
JOIN dbo.Developers d ON g.DeveloperID = d.DeveloperID
JOIN dbo.Genres ge    ON g.GenreID     = ge.GenreID
ORDER BY g.ReleaseYear, g.Title;

-- משחקים לפי פלטפורמות (JOIN N–N)
SELECT p.Name AS Platform, g.Title, gp.ReleaseDate
FROM dbo.GamePlatforms gp
JOIN dbo.Games g      ON gp.GameID = g.GameID
JOIN dbo.Platforms p  ON gp.PlatformID = p.PlatformID
ORDER BY p.Name, g.Title;

-- מספר משחקים לפי ז'אנר (GROUP BY)
SELECT ge.Name AS Genre, COUNT(*) AS NumGames
FROM dbo.Games g
JOIN dbo.Genres ge ON g.GenreID = ge.GenreID
GROUP BY ge.Name
ORDER BY NumGames DESC, ge.Name;

-- ממוצע Metascore לפי מפתח (רק מפתחים עם ≥ 2 משחקים)
SELECT d.Name AS Developer,
       COUNT(*) AS NumGames,
       AVG(CAST(g.Metascore AS INT)) AS AvgScore
FROM dbo.Games g
JOIN dbo.Developers d ON g.DeveloperID = d.DeveloperID
GROUP BY d.Name
HAVING COUNT(*) >= 2
ORDER BY AvgScore DESC;

-- Top 5 משחקים לפי Metascore
SELECT TOP (5) g.Title, d.Name AS Developer, g.Metascore
FROM dbo.Games g
JOIN dbo.Developers d ON g.DeveloperID = d.DeveloperID
ORDER BY g.Metascore DESC, g.Title;

-- פלטפורמות עם לפחות 3 משחקים (בסט הנתונים הנוכחי — יתכן פחות, כי קישרנו פלטפורמה אחת למשחק)
SELECT p.Name AS Platform, COUNT(*) AS NumGames
FROM dbo.GamePlatforms gp
JOIN dbo.Platforms p ON gp.PlatformID = p.PlatformID
GROUP BY p.Name
HAVING COUNT(*) >= 3
ORDER BY NumGames DESC, p.Name;

-- משחקים מעל הממוצע הכללי של Metascore (Subquery)
SELECT g.Title, d.Name AS Developer, g.Metascore
FROM dbo.Games g
JOIN dbo.Developers d ON g.DeveloperID = d.DeveloperID
WHERE g.Metascore > (SELECT AVG(CAST(Metascore AS INT)) FROM dbo.Games)
ORDER BY g.Metascore DESC;

-- ממוצע מחיר לפי ז'אנר
SELECT ge.Name AS Genre, AVG(g.Price) AS AvgPrice
FROM dbo.Games g
JOIN dbo.Genres ge ON g.GenreID = ge.GenreID
GROUP BY ge.Name
ORDER BY AvgPrice DESC;
