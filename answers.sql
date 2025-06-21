--  ANSWER TO QUESTION 1

-- Query To Create  Original Table for ProductDetails
CREATE TABLE ProductDetail (
    OrderID INT,
    CustomerName VARCHAR(50),
    Products VARCHAR(255)
);

 -- Insert example data
INSERT INTO ProductDetail (OrderID, CustomerName, Products) VALUES
(101, 'John Doe', 'Laptop, Mouse'),
(102, 'Jane Smith', 'Tablet, Keyboard, Mouse'),
(103, 'Emily Clark', 'Phone');


-- Query To Create  New First Normal Form Table for ProductDetails
CREATE TABLE ProductDetail_1NF (
    OrderID INT,
    CustomerName VARCHAR(50),
    Product VARCHAR(50)
);

-- Query For Splitting Products
DELIMITER //

CREATE PROCEDURE SplitProducts()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE oID INT;
    DECLARE cName VARCHAR(50);
    DECLARE prodList TEXT;
    DECLARE singleProduct VARCHAR(50);

    -- Cursor to loop through the original table
    DECLARE cur CURSOR FOR 
        SELECT OrderID, CustomerName, Products FROM ProductDetail;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO oID, cName, prodList;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Loop to split the product list by comma
        WHILE LOCATE(',', prodList) > 0 DO
            SET singleProduct = TRIM(SUBSTRING_INDEX(prodList, ',', 1));
            INSERT INTO ProductDetail_1NF (OrderID, CustomerName, Product)
            VALUES (oID, cName, singleProduct);
            SET prodList = SUBSTRING(prodList FROM LOCATE(',', prodList) + 1);
        END WHILE;

        -- Insert the last or only product
        SET singleProduct = TRIM(prodList);
        INSERT INTO ProductDetail_1NF (OrderID, CustomerName, Product)
        VALUES (oID, cName, singleProduct);

    END LOOP;

    CLOSE cur;
END //

DELIMITER ;

-- Query For Execution
CALL SplitProducts();

-- Query To Display Result
SELECT * FROM ProductDetail_1NF;



-- ANSWER TO QUESTION 2

CREATE TABLE Customers (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(50)
);

-- Insert data
INSERT INTO Customers (OrderID, CustomerName) VALUES
(101, 'John Doe'),
(102, 'Jane Smith'),
(103, 'Emily Clark');

CREATE TABLE OrderDetails (
    OrderID INT,
    Product VARCHAR(50),
    Quantity INT,
    PRIMARY KEY (OrderID, Product),
    FOREIGN KEY (OrderID) REFERENCES Customers(OrderID)
);

-- Insert data
INSERT INTO OrderDetails (OrderID, Product, Quantity) VALUES
(101, 'Laptop', 2),
(101, 'Mouse', 1),
(102, 'Tablet', 3),
(102, 'Keyboard', 1),
(102, 'Mouse', 2),
(103, 'Phone', 1);

-- CustomerName depends only on OrderID in the Customers table.Product and Quantity depend on the composite key in OrderDetails table.
-- Thus, the partial dependency is removed — the table is now in 2NF.
