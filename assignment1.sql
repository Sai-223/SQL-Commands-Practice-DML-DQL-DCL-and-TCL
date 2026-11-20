-- 1. CREATE TABLES
CREATE DATABASE library;
USE library;

CREATE TABLE Books (
    BookID INT PRIMARY KEY,
    Title VARCHAR(100),
    Author VARCHAR(100),
    Genre VARCHAR(50),
    Price DECIMAL(8,2),
    IsAvailable INT DEFAULT 1
);

CREATE TABLE Members (
    MemberID INT PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100)
);

CREATE TABLE Loans (
    LoanID INT PRIMARY KEY AUTO_INCREMENT,
    BookID INT,
    MemberID INT,
    LoanDate DATE,
    ReturnDate DATE,
    FOREIGN KEY (BookID) REFERENCES Books(BookID),
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID)
);

-- 2. DML
INSERT INTO Books VALUES (1, 'Dune', 'Frank Herbert', 'Sci-Fi', 12.99, 1);
INSERT INTO Books VALUES (2, 'Emma', 'Jane Austen', 'Romance', 8.50, 1);
INSERT INTO Books VALUES (3, 'Neuromancer', 'William Gibson', 'Sci-Fi', 11.25, 0);
INSERT INTO Books VALUES (4, 'Sapiens', 'Yuval Harari', 'History', 15.00, 0);
INSERT INTO Books VALUES (5, 'The Hobbit', 'J.R.R. Tolkien', 'Fantasy', 10.75, 0);
INSERT INTO Books VALUES (6, 'Clean Code', 'Robert Martin', 'Technology', 35.00, 1);

INSERT INTO Members VALUES (1, 'Asha Reddy', 'asha@example.com');
INSERT INTO Members VALUES (2, 'Ravi Kumar', 'ravi@example.com');
INSERT INTO Members VALUES (3, 'Meera Iyer', 'meera@example.com');
INSERT INTO Members VALUES (4, 'John Smith', 'john@example.com');
INSERT INTO Members VALUES (5, 'Priya Nair', 'priya@example.com');
INSERT INTO Members VALUES (6, 'Karan Shah', 'karan@example.com');

INSERT INTO Loans (BookID, MemberID, LoanDate, ReturnDate) VALUES (1, 1, '2026-10-01', '2026-10-10');
INSERT INTO Loans (BookID, MemberID, LoanDate, ReturnDate) VALUES (2, 1, '2026-10-15', '2026-10-28');
INSERT INTO Loans (BookID, MemberID, LoanDate, ReturnDate) VALUES (3, 1, '2026-11-01', NULL);
INSERT INTO Loans (BookID, MemberID, LoanDate, ReturnDate) VALUES (4, 2, '2026-10-20', NULL);
INSERT INTO Loans (BookID, MemberID, LoanDate, ReturnDate) VALUES (5, 3, '2026-11-15', NULL);
INSERT INTO Loans (BookID, MemberID, LoanDate, ReturnDate) VALUES (1, 4, '2026-10-12', '2026-10-20');
INSERT INTO Loans (BookID, MemberID, LoanDate, ReturnDate) VALUES (3, 5, '2026-09-01', '2026-09-12');

-- Update the price of one book
UPDATE Books SET Price = 14.50 WHERE BookID = 4;

-- Delete a member with no loans (Karan Shah)
DELETE FROM Members WHERE MemberID = 6;

-- 3. DQL
-- Books currently loaned out
SELECT Books.Title, Members.Name, Loans.LoanDate
FROM Loans
JOIN Books ON Loans.BookID = Books.BookID
JOIN Members ON Loans.MemberID = Members.MemberID
WHERE Loans.ReturnDate IS NULL;

-- Members who borrowed more than two books
SELECT Members.Name, COUNT(*) AS TotalLoans
FROM Members
JOIN Loans ON Members.MemberID = Loans.MemberID
GROUP BY Members.Name
HAVING COUNT(*) > 2;

-- Loans per genre
SELECT Books.Genre, COUNT(*) AS LoanCount
FROM Books
JOIN Loans ON Books.BookID = Loans.BookID
GROUP BY Books.Genre;

-- 4. TCL
-- Successful transaction (both statements succeed, so COMMIT)
START TRANSACTION;
INSERT INTO Loans (BookID, MemberID, LoanDate) VALUES (6, 2, CURDATE());
UPDATE Books SET IsAvailable = 0 WHERE BookID = 6;
COMMIT;

-- Rollback demo (second insert uses BookID 999, which does not exist, so it fails)
START TRANSACTION;
INSERT INTO Loans (BookID, MemberID, LoanDate) VALUES (2, 3, CURDATE());
INSERT INTO Loans (BookID, MemberID, LoanDate) VALUES (999, 3, CURDATE());  -- ERROR
ROLLBACK;  -- undoes the first insert too

-- Check: no new loan for book 2
SELECT * FROM Loans WHERE BookID = 2;

-- 5. DCL (run as admin / root)
CREATE USER 'library_app'@'localhost' IDENTIFIED BY 'password123';

GRANT SELECT ON library.Books TO 'library_app'@'localhost';
GRANT SELECT ON library.Members TO 'library_app'@'localhost';
GRANT INSERT, UPDATE ON library.Loans TO 'library_app'@'localhost';

REVOKE INSERT ON library.Loans FROM 'library_app'@'localhost';

-- 6. ADDITIONAL QUERIES
-- Books never borrowed
SELECT Title FROM Books
WHERE BookID NOT IN (SELECT BookID FROM Loans);

-- Members with overdue loans (14-day period)
SELECT Members.Name, DATEDIFF(CURDATE(), Loans.LoanDate) - 14 AS DaysOverdue
FROM Loans
JOIN Members ON Loans.MemberID = Members.MemberID
WHERE Loans.ReturnDate IS NULL
  AND DATEDIFF(CURDATE(), Loans.LoanDate) > 14;

