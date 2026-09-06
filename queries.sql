/* =========================================================
   1. ORDER TOTAL FOR EACH CUSTOMER ORDER
   =========================================================
   Purpose:
   - Join Customers, Orders, and Order_Items
   - Calculate the total price of each order
   ========================================================= */

SELECT 
    c.name,
    o.order_id,
    o.order_date,
    SUM(oi.subtotal) AS total_price
FROM Customers c
JOIN Orders o 
    ON c.customer_id = o.customer_id
JOIN Order_Items oi 
    ON o.order_id = oi.order_id
GROUP BY 
    c.name,
    o.order_id,
    o.order_date;


/* =========================================================
   2. BEST-SELLING BOOKS
   =========================================================
   Purpose:
   - Find how many copies of each book were sold
   - SUM(quantity) gives the total number of books sold
   - Sort from highest sales to lowest
   ========================================================= */

SELECT 
    b.category,
    b.title,
    SUM(oi.quantity) AS total_sold
FROM Books b
JOIN Order_Items oi 
    ON b.book_id = oi.book_id
GROUP BY 
    b.category,
    b.book_id,
    b.title
ORDER BY total_sold DESC;


/* =========================================================
   3. STORED PROCEDURE - ProcessOrder
   =========================================================
   Purpose:
   - Create a new order
   - Accept customer ID, book ID, and quantity
   - Get the book price
   - Calculate total price
   - Insert the order into Orders
   ========================================================= */

DELIMITER //

CREATE PROCEDURE ProcessOrder(
    IN p_cust_id INT,
    IN p_book_id INT,
    IN p_qty INT
)
BEGIN

    /* Variable to store the price of the book */
    DECLARE book_price DECIMAL(10,2);

    /* Variable to store the total order amount */
    DECLARE total DECIMAL(10,2);


    /* Get the price of the selected book */
    SELECT price
    INTO book_price
    FROM Books
    WHERE book_id = p_book_id;


    /* Calculate total price */
    SET total = book_price * p_qty;


    /* Insert the new order */
    INSERT INTO Orders (
        customer_id,
        order_date,
        total_amount,
        status
    )
    VALUES (
        p_cust_id,
        NOW(),
        total,
        'Pending'
    );

END //

DELIMITER ;


/* ---------------------------------------------------------
   Execute the stored procedure

   Customer ID = 1
   Book ID     = 2
   Quantity    = 3
   --------------------------------------------------------- */

CALL ProcessOrder(1, 2, 3);



/* =========================================================
   4. TRIGGER - UpdateStock
   =========================================================
   Purpose:
   - Automatically reduce book stock whenever a new
     Order_Items record is inserted.
   
   Example:
   If stock = 20
   and quantity ordered = 3
   
   New stock = 20 - 3 = 17
   ========================================================= */

DELIMITER //

CREATE TRIGGER UpdateStock
AFTER INSERT ON Order_Items
FOR EACH ROW
BEGIN

    /* Reduce book stock by the quantity ordered */
    UPDATE Books
    SET stock = stock - NEW.quantity
    WHERE book_id = NEW.book_id;

END //

DELIMITER ;



/* =========================================================
   5. TRANSACTION - CREATE ORDER AND ORDER ITEM
   =========================================================
   Purpose:
   - Insert an order
   - Insert the corresponding order item
   - Trigger automatically updates book stock
   - COMMIT saves everything
   ========================================================= */

START TRANSACTION;


/* Step 1: Create a new order */
INSERT INTO Orders (
    customer_id,
    order_date,
    total_amount,
    status
)
VALUES (
    1,
    NOW(),
    150.00,
    'Pending'
);


/* Step 2: Insert the ordered book
   LAST_INSERT_ID() gets the newly created order_id */
INSERT INTO Order_Items (
    order_id,
    book_id,
    quantity,
    subtotal
)
VALUES (
    LAST_INSERT_ID(),
    2,
    3,
    150.00
);


/* Step 3: Save the transaction */
COMMIT;



/* =========================================================
   6. TRANSACTION - CHECK STOCK
   =========================================================
   IMPORTANT:
   IF...THEN cannot be used directly in a normal SQL session.
   
   So we:
   1. Start transaction
   2. Update stock
   3. Check the stock
   4. Decide COMMIT or ROLLBACK manually
   ========================================================= */


/* Start transaction */
START TRANSACTION;


/* Reduce stock by 5 */
UPDATE Books
SET stock = stock - 5
WHERE book_id = 1;


/* Check the remaining stock */
SELECT stock
FROM Books
WHERE book_id = 1;


/*
   If stock is >= 0:
       COMMIT;

   If stock is < 0:
       ROLLBACK;

   Run ONE of the following commands based on the result.
*/


/* Save the transaction if stock is valid */
COMMIT;


/*
   OR undo the transaction if stock became negative:

   ROLLBACK;
*/



/* =========================================================
   7. CREATE INDEX
   =========================================================
   Purpose:
   - Improve search performance
   - This index is useful when searching Orders
     using customer_id
   ========================================================= */

CREATE INDEX idx_orders_customer_id
ON Orders(customer_id);


/* Check the query execution plan */
EXPLAIN
SELECT *
FROM Orders
WHERE customer_id = 5;



/* =========================================================
   8. INDEX ON CUSTOMER EMAIL
   =========================================================
   Purpose:
   - Improve searches using customer email
   ========================================================= */

CREATE INDEX idx_customer_email
ON Customers(email);


/* Example query that can use the email index */

EXPLAIN
SELECT *
FROM Customers
WHERE email = 'example@gmail.com';



/* =========================================================
   9. CREATE VIEW - OrderSummary
   =========================================================
   Purpose:
   - Create a virtual table containing useful order information
   - Combines Orders and Customers
   ========================================================= */

CREATE VIEW OrderSummary AS

SELECT 
    o.order_id,
    c.name,
    o.order_date,
    o.total_amount,
    o.status

FROM Orders o

JOIN Customers c
    ON o.customer_id = c.customer_id;



/* View the data from the view */

SELECT *
FROM OrderSummary;



/* =========================================================
   10. CREATE FUNCTION - CalculateDiscount
   =========================================================
   Purpose:
   - Calculate a 10% discount
   - Takes amount as input
   - Returns discount amount
   ========================================================= */

DELIMITER //

CREATE FUNCTION CalculateDiscount(
    amount DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC

RETURN amount * 0.10;

//

DELIMITER ;



/* =========================================================
   11. TEST THE FUNCTION
   =========================================================
   Example:
   Amount = 1000
   Discount = 100
   ========================================================= */

SELECT CalculateDiscount(1000.00) AS discount;



/* =========================================================
   12. CALCULATE DISCOUNT AND FINAL PRICE
   ========================================================= */

SELECT
    1000.00 AS amount,

    /* Calculate 10% discount */
    CalculateDiscount(1000.00) AS discount,

    /* Calculate final price after discount */
    1000.00 - CalculateDiscount(1000.00) AS final_price;



/* =========================================================
   QUICK SUMMARY
   =========================================================

   SELECT + JOIN
       -> Combine data from multiple tables

   SUM()
       -> Calculate totals

   GROUP BY
       -> Group rows

   ORDER BY
       -> Sort results

   PROCEDURE
       -> Store a sequence of SQL operations

   TRIGGER
       -> Automatically execute SQL when an event occurs

   TRANSACTION
       -> Treat multiple operations as one unit

   COMMIT
       -> Permanently save transaction

   ROLLBACK
       -> Undo transaction

   INDEX
       -> Improve search/query performance

   EXPLAIN
       -> See how MySQL executes a query

   VIEW
       -> Save a SELECT query as a virtual table

   FUNCTION
       -> Create a reusable calculation

   LAST_INSERT_ID()
       -> Get the latest AUTO_INCREMENT ID

   NEW.column
       -> Access the newly inserted value inside a trigger

   ========================================================= */
