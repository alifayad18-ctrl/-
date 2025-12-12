-- ========================================

-- Visual Basic.NET + SQL Server
-- تشمل جميع الجداول المطلوبة
-- ========================================

CREATE DATABASE ERP_System;
GO

USE ERP_System;
GO

-- ========================================
-- 1️⃣ جدول الفروع (المعلز، الربوة، الروضة)
-- ========================================
CREATE TABLE Branches (
    BranchID INT PRIMARY KEY IDENTITY(1,1),
    BranchCode NVARCHAR(10) UNIQUE NOT NULL,
    BranchName NVARCHAR(100) NOT NULL,
    Location NVARCHAR(200),
    Phone NVARCHAR(20),
    Manager NVARCHAR(100),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE()
);

INSERT INTO Branches VALUES 
('BR001', N'فرع المعلز', N'الرياض - المعلز', '0112223344', N'محمد أحمد', 1, GETDATE()),
('BR002', N'فرع الربوة', N'الرياض - الربوة', '0112223355', N'خالد علي', 1, GETDATE()),
('BR003', N'فرع الروضة', N'الرياض - الروضة', '0112223366', N'عبدالله سعيد', 1, GETDATE());
GO


-- ========================================
-- 2️⃣ جدول المستخدمين والصلاحيات
-- ========================================
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    UserName NVARCHAR(100) NOT NULL,
    Password NVARCHAR(255) NOT NULL,
    FullName NVARCHAR(100),
    Role NVARCHAR(50), -- Admin, Manager, Cashier, etc.
    BranchID INT,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID)
);
GO

-- ========================================
-- 3️⃣ جدول الخزائن (Safe/Cash Registers)
-- ========================================
CREATE TABLE Safes (
    SafeID INT PRIMARY KEY IDENTITY(1,1),
    SafeName NVARCHAR(100) NOT NULL,
    BranchID INT NOT NULL,
    OpeningBalance DECIMAL(18,2) DEFAULT 0,
    CurrentBalance DECIMAL(18,2) DEFAULT 0,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID)
);
GO

-- ========================================
-- 4️⃣ جدول الشفتات (Shifts)
-- ========================================
CREATE TABLE Shifts (
    ShiftID INT PRIMARY KEY IDENTITY(1,1),
    BranchID INT NOT NULL,
    SafeID INT NOT NULL,
    UserID INT NOT NULL,
    ShiftNumber INT,
    OpeningTime DATETIME,
    ClosingTime DATETIME,
    OpeningBalance DECIMAL(18,2),
    ClosingBalance DECIMAL(18,2),
    ExpectedBalance DECIMAL(18,2),
    Difference DECIMAL(18,2),
    Notes NVARCHAR(500),
    Status NVARCHAR(20), -- Open, Closed
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (SafeID) REFERENCES Safes(SafeID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

-- ========================================
-- 5️⃣ جدول حركات الخزنة (Cash Transactions)
-- ========================================
CREATE TABLE CashTransactions (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    BranchID INT NOT NULL,
    SafeID INT NOT NULL,
    ShiftID INT,
    UserID INT NOT NULL,
    TransactionType NVARCHAR(50), -- In, Out, Transfer
    Amount DECIMAL(18,2) NOT NULL,
    Description NVARCHAR(500),
    TransactionDate DATETIME DEFAULT GETDATE(),
    ReferenceNumber NVARCHAR(50),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (SafeID) REFERENCES Safes(SafeID),
    FOREIGN KEY (ShiftID) REFERENCES Shifts(ShiftID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

-- ========================================
-- 6️⃣ جدول الحسابات البنكية (Bank Accounts)
-- ========================================
CREATE TABLE BankAccounts (
    AccountID INT PRIMARY KEY IDENTITY(1,1),
    BankName NVARCHAR(100) NOT NULL,
    AccountNumber NVARCHAR(50) UNIQUE NOT NULL,
    AccountName NVARCHAR(100),
    IBAN NVARCHAR(50),
    BranchID INT,
    Balance DECIMAL(18,2) DEFAULT 0,
    Currency NVARCHAR(10) DEFAULT 'SAR',
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID)
);
GO

-- ========================================
-- 7️⃣ جدول حركات البنوك (Bank Transactions)
-- ========================================
CREATE TABLE BankTransactions (
    BankTransactionID INT PRIMARY KEY IDENTITY(1,1),
    AccountID INT NOT NULL,
    TransactionType NVARCHAR(50), -- Deposit, Withdrawal, Transfer
    Amount DECIMAL(18,2) NOT NULL,
    Commission DECIMAL(18,2) DEFAULT 0,
    TransactionDate DATETIME DEFAULT GETDATE(),
    Description NVARCHAR(500),
    ReferenceNumber NVARCHAR(50),
    Status NVARCHAR(20), -- Pending, Completed, Cancelled
    FOREIGN KEY (AccountID) REFERENCES BankAccounts(AccountID)
);
GO

-- ========================================
-- 8️⃣ جدول العملاء (Customers)
-- ========================================
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    CustomerName NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(20),
    Email NVARCHAR(100),
    Address NVARCHAR(200),
    TaxNumber NVARCHAR(50),
    Balance DECIMAL(18,2) DEFAULT 0,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- ========================================
-- 9️⃣ جدول الموردين (Suppliers)
-- ========================================
CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY IDENTITY(1,1),
    SupplierName NVARCHAR(100) NOT NULL,
    ContactPerson NVARCHAR(100),
    Phone NVARCHAR(20),
    Email NVARCHAR(100),
    Address NVARCHAR(200),
    TaxNumber NVARCHAR(50),
    Balance DECIMAL(18,2) DEFAULT 0,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- ========================================
-- 🔟 جدول المنتجات (Products)
-- ========================================
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductCode NVARCHAR(50) UNIQUE NOT NULL,
    ProductName NVARCHAR(200) NOT NULL,
    Barcode NVARCHAR(50),
    Category NVARCHAR(100),
    Unit NVARCHAR(20), -- قطعة، كيلو، لتر
    PurchasePrice DECIMAL(18,2),
    SalePrice DECIMAL(18,2),
    MinStock INT DEFAULT 0,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- ========================================
-- 1️⃣1️⃣ جدول المخزون (Inventory)
-- ========================================
CREATE TABLE Inventory (
    InventoryID INT PRIMARY KEY IDENTITY(1,1),
    ProductID INT NOT NULL,
    BranchID INT NOT NULL,
    Quantity INT DEFAULT 0,
    LastUpdateDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID)
);
GO

-- ========================================
-- 1️⃣2️⃣ جدول فواتير المبيعات (Sales Invoices)
-- ========================================
CREATE TABLE SalesInvoices (
    InvoiceID INT PRIMARY KEY IDENTITY(1,1),
    InvoiceNumber NVARCHAR(50) UNIQUE NOT NULL,
    InvoiceDate DATETIME DEFAULT GETDATE(),
    BranchID INT NOT NULL,
    CustomerID INT,
    UserID INT NOT NULL,
    TotalAmount DECIMAL(18,2),
    DiscountAmount DECIMAL(18,2) DEFAULT 0,
    VATAmount DECIMAL(18,2) DEFAULT 0,
    NetAmount DECIMAL(18,2),
    PaymentMethod NVARCHAR(50), -- Cash, Card, Transfer
    Status NVARCHAR(20), -- Paid, Pending, Cancelled
    Notes NVARCHAR(500),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

-- ========================================
-- 1️⃣3️⃣ جدول تفاصيل فواتير المبيعات (Sales Invoice Details)
-- ========================================
CREATE TABLE SalesInvoiceDetails (
    DetailID INT PRIMARY KEY IDENTITY(1,1),
    InvoiceID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(18,2),
    TotalPrice DECIMAL(18,2),
    DiscountPercent DECIMAL(5,2) DEFAULT 0,
    DiscountAmount DECIMAL(18,2) DEFAULT 0,
    VATPercent DECIMAL(5,2) DEFAULT 15, -- 15% VAT in Saudi
    VATAmount DECIMAL(18,2),
    NetPrice DECIMAL(18,2),
    FOREIGN KEY (InvoiceID) REFERENCES SalesInvoices(InvoiceID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

-- ========================================
-- 1️⃣4️⃣ جدول فواتير المشتريات (Purchase Invoices)
-- ========================================
CREATE TABLE PurchaseInvoices (
    PurchaseID INT PRIMARY KEY IDENTITY(1,1),
    PurchaseNumber NVARCHAR(50) UNIQUE NOT NULL,
    PurchaseDate DATETIME DEFAULT GETDATE(),
    BranchID INT NOT NULL,
    SupplierID INT NOT NULL,
    UserID INT NOT NULL,
    TotalAmount DECIMAL(18,2),
    DiscountAmount DECIMAL(18,2) DEFAULT 0,
    VATAmount DECIMAL(18,2) DEFAULT 0,
    NetAmount DECIMAL(18,2),
    PaymentMethod NVARCHAR(50),
    Status NVARCHAR(20),
    Notes NVARCHAR(500),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

-- ========================================
-- 1️⃣5️⃣ جدول تفاصيل فواتير المشتريات (Purchase Invoice Details)
-- ========================================
CREATE TABLE PurchaseInvoiceDetails (
    DetailID INT PRIMARY KEY IDENTITY(1,1),
    PurchaseID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(18,2),
    TotalPrice DECIMAL(18,2),
    DiscountAmount DECIMAL(18,2) DEFAULT 0,
    VATAmount DECIMAL(18,2),
    NetPrice DECIMAL(18,2),
    FOREIGN KEY (PurchaseID) REFERENCES PurchaseInvoices(PurchaseID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

-- ========================================
-- 1️⃣6️⃣ جدول ضريبة القيمة المضافة (VAT Records)
-- ========================================
CREATE TABLE VATRecords (
    VATID INT PRIMARY KEY IDENTITY(1,1),
    Period NVARCHAR(20), -- 2025-Q1, 2025-Q2
    TotalSales DECIMAL(18,2),
    TotalPurchases DECIMAL(18,2),
    OutputVAT DECIMAL(18,2), -- ضريبة المخرجات
    InputVAT DECIMAL(18,2), -- ضريبة المدخلات
    NetVAT DECIMAL(18,2), -- الضريبة المستحقة
    Status NVARCHAR(20), -- Pending, Submitted, Paid
    SubmissionDate DATETIME,
    PaymentDate DATETIME,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- ========================================
-- 1️⃣7️⃣ جدول الزكاة (Zakat Records)
-- ========================================
CREATE TABLE ZakatRecords (
    ZakatID INT PRIMARY KEY IDENTITY(1,1),
    HijriYear NVARCHAR(10), -- 1446H
    TotalAssets DECIMAL(18,2),
    TotalLiabilities DECIMAL(18,2),
    ZakatBase DECIMAL(18,2),
    ZakatAmount DECIMAL(18,2), -- 2.5% of base
    Status NVARCHAR(20),
    PaymentDate DATETIME,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- ========================================
-- 1️⃣8️⃣ جدول سجل النشاط (Activity Log)
-- ========================================
CREATE TABLE ActivityLog (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT NOT NULL,
    Action NVARCHAR(200),
    TableName NVARCHAR(100),
    RecordID INT,
    OldValue NVARCHAR(MAX),
    NewValue NVARCHAR(MAX),
    ActionDate DATETIME DEFAULT GETDATE(),
    IPAddress NVARCHAR(50),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

-- ========================================
-- ✅ عرض تقرير ملخص للمبيعات (Sales Summary View)
-- ========================================
CREATE VIEW vw_SalesSummary AS
SELECT 
    b.BranchName,
    COUNT(si.InvoiceID) as TotalInvoices,
    SUM(si.NetAmount) as TotalSales,
    SUM(si.VATAmount) as TotalVAT,
    CONVERT(DATE, si.InvoiceDate) as SaleDate
FROM SalesInvoices si
INNER JOIN Branches b ON si.BranchID = b.BranchID
WHERE si.Status = 'Paid'
GROUP BY b.BranchName, CONVERT(DATE, si.InvoiceDate);
GO

-- ========================================
-- ✅ عرض الرصيد الحالي للمخزون (Current Inventory View)
-- ========================================
CREATE VIEW vw_CurrentInventory AS
SELECT 
    p.ProductCode,
    p.ProductName,
    p.Category,
    b.BranchName,
    i.Quantity,
    p.SalePrice,
    (i.Quantity * p.SalePrice) as TotalValue,
    CASE WHEN i.Quantity <= p.MinStock THEN 'تحذير: مخزون منخفض' ELSE 'طبيعي' END as StockStatus
FROM Inventory i
INNER JOIN Products p ON i.ProductID = p.ProductID
INNER JOIN Branches b ON i.BranchID = b.BranchID;
GO

-- ========================================
-- ✅ عرض حركة الخزائن (Safe Movements View)
-- ========================================
CREATE VIEW vw_SafeMovements AS
SELECT 
    b.BranchName,
    s.SafeName,
    u.FullName as UserName,
    ct.TransactionType,
    ct.Amount,
    ct.Description,
    ct.TransactionDate
FROM CashTransactions ct
INNER JOIN Branches b ON ct.BranchID = b.BranchID
INNER JOIN Safes s ON ct.SafeID = s.SafeID
INNER JOIN Users u ON ct.UserID = u.UserID;
GO

-- ========================================
-- 📦 بيانات أساسية للخزائن (Sample Data for Safes)
-- ========================================
INSERT INTO Safes (SafeName, BranchID, OpeningBalance, CurrentBalance) VALUES
(N'خزينة المعلز الرئيسية', 1, 10000.00, 10000.00),
(N'خزينة الربوة الرئيسية', 2, 8000.00, 8000.00),
(N'خزينة الروضة الرئيسية', 3, 12000.00, 12000.00);
GO

-- ========================================
-- 📦 بيانات أساسية للمستخدمين (Sample Data for Users)
-- ========================================
INSERT INTO Users (UserName, Password, FullName, Role, BranchID) VALUES
('admin', '123456', N'مدير النظام', 'Admin', NULL),
('manager1', '123456', N'محمد أحمد', 'Manager', 1),
('manager2', '123456', N'خالد علي', 'Manager', 2),
('manager3', '123456', N'عبدالله سعيد', 'Manager', 3),
('cashier1', '123456', N'كاشير المعلز', 'Cashier', 1),
('cashier2', '123456', N'كاشير الربوة', 'Cashier', 2),
('cashier3', '123456', N'كاشير الروضة', 'Cashier', 3);
GO

-- ========================================
-- 🎉 اكتمال قاعدة البيانات 🎉
-- ========================================
-- ✅ تم إنشاء 18 جدول كامل
-- ✅ تم إنشاء 3 عروض (Views) للتقارير
-- ✅ تم إضافة بيانات أساسية للفروع، الخزائن والمستخدمين
-- 
-- 📊 الجداول الرئيسية:
-- 1. Branches - الفروع (المعلز، الربوة، الروضة)
-- 2. Users - المستخدمين والصلاحيات
-- 3. Safes - الخزائن
-- 4. Shifts - الشفتات
-- 5. CashTransactions - حركات الخزنة
-- 6. BankAccounts - الحسابات البنكية
-- 7. BankTransactions - حركات البنوك
-- 8. Customers - العملاء
-- 9. Suppliers - الموردين
-- 10. Products - المنتجات
-- 11. Inventory - المخزون
-- 12. SalesInvoices - فواتير المبيعات
-- 13. SalesInvoiceDetails - تفاصيل الفواتير
-- 14. PurchaseInvoices - فواتير المشتريات
-- 15. PurchaseInvoiceDetails - تفاصيل المشتريات
-- 16. VATRecords - ضريبة القيمة المضافة
-- 17. ZakatRecords - الزكاة
-- 18. ActivityLog - سجل النشاط
--
-- 🔒 ملاحظة أمنية: يجب تغيير كلمات المرور الافتراضية بعد التنفيذ
-- 📝 تم التطوير بواسطة: alifayad18-ctrl
-- 📅 التاريخ: December 12, 2025
-- ========================================
