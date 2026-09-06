CREATE DATABASE Bookstore;
USE Bookstore;

CREATE TABLE Books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL,
    category VARCHAR(100),
    published_date DATE
);

CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL,
    status ENUM('Pending', 'Completed', 'Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE
);

CREATE TABLE Order_Items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    book_id INT,
    quantity INT NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE
);

CREATE TABLE Admins (
    admin_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('Manager', 'Staff') DEFAULT 'Staff'
);


-- Insert data into Books
INSERT INTO Books (title, author, price, stock, category, published_date) VALUES
('The Great Gatsby', 'F. Scott Fitzgerald', 10.99, 50, 'Fiction', '1925-04-10'),
('1984', 'George Orwell', 8.99, 40, 'Dystopian', '1949-06-08'),
('To Kill a Mockingbird', 'Harper Lee', 12.50, 30, 'Classic', '1960-07-11'),
('The Catcher in the Rye', 'J.D. Salinger', 9.99, 20, 'Novel', '1951-07-16'),
('Moby Dick', 'Herman Melville', 15.75, 25, 'Adventure', '1851-10-18');


-- Insert data into Customers
INSERT INTO Customers (name, email, phone, address) VALUES
('Alice Johnson', 'alice@example.com', '1234567890', '123 Main St, NY'),
('Bob Smith', 'bob@example.com', '0987654321', '456 Elm St, CA'),
('Charlie Brown', 'charlie@example.com', '1122334455', '789 Pine St, TX'),
('David Wilson', 'david@example.com', '2233445566', '101 Oak St, FL'),
('Eve Adams', 'eve@example.com', '3344556677', '202 Birch St, WA');


-- Insert data into Orders
INSERT INTO Orders (customer_id, total_amount, status) VALUES
(1, 29.98, 'Completed'),
(2, 15.75, 'Pending'),
(3, 25.49, 'Cancelled'),
(4, 40.00, 'Completed'),
(5, 19.99, 'Pending');


-- Insert data into Order_Items
INSERT INTO Order_Items (order_id, book_id, quantity, subtotal) VALUES
(1, 1, 2, 21.98),
(1, 2, 1, 8.00),
(2, 3, 1, 12.50),
(3, 4, 1, 9.99),
(4, 5, 2, 31.50);


-- Insert data into Admins
INSERT INTO Admins (username, password_hash, role) VALUES
('admin1', 'hashedpassword1', 'Manager'),
('staff1', 'hashedpassword2', 'Staff'),
('admin2', 'hashedpassword3', 'Manager'),
('staff2', 'hashedpassword4', 'Staff'),
('staff3', 'hashedpassword5', 'Staff');
 
SELECT*FROM Books;
SELECT*FROM Customers;
SELECT*FROM Orders;
SELECT*FROM Order_Items;
SELECT*FROM Admins;