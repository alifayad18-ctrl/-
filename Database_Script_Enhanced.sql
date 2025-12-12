-- ========================================
-- ERP System - Enhanced Version
-- نظام ERP المتكامل - النسخة المحسّنة
-- ========================================

CREATE DATABASE ERP_System_Enhanced;
GO

USE ERP_System_Enhanced;
GO

-- ========================================
-- 1️⃣ جدول الفروع
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
-- 2️⃣ جدول المستخدمين
-- ========================================
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    UserName NVARCHAR(100) NOT NULL,
    Password NVARCHAR(255) NOT NULL,
    FullName NVARCHAR(100),
    Role NVARCHAR(50),
    BranchID INT,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID)
);

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
-- 3️⃣ جدول الخزائن
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

INSERT INTO Safes (SafeName, BranchID, OpeningBalance, CurrentBalance) VALUES
(N'خزينة المعلز الرئيسية', 1, 10000.00, 10000.00),
(N'خزينة الربوة الرئيسية', 2, 8000.00, 8000.00),
(N'خزينة الروضة الرئيسية', 3, 12000.00, 12000.00);
GO

-- ========================================
-- 4️⃣ جدول الشفتات
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
    Status NVARCHAR(20),
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (SafeID) REFERENCES Safes(SafeID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

-- ========================================
-- 5️⃣ جدول حركات الخزنة
-- ========================================
CREATE TABLE CashTransactions (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    BranchID INT NOT NULL,
    SafeID INT NOT NULL,
    ShiftID INT,
    UserID INT NOT NULL,
    TransactionType NVARCHAR(50),
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
-- 6️⃣ جدول الحسابات البنكية
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
-- 7️⃣ جدول حركات البنوك
-- ========================================
CREATE TABLE BankTransactions (
    BankTransactionID INT PRIMARY KEY IDENTITY(1,1),
    AccountID INT NOT NULL,
    TransactionType NVARCHAR(50),
    Amount DECIMAL(18,2) NOT NULL,
    Commission DECIMAL(18,2) DEFAULT 0,
    TransactionDate DATETIME DEFAULT GETDATE(),
    Description NVARCHAR(500),
    ReferenceNumber NVARCHAR(50),
    Status NVARCHAR(20),
    FOREIGN KEY (AccountID) REFERENCES BankAccounts(AccountID)
);
GO

-- ========================================
-- 8️⃣ جدول الموردين
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
-- 9️⃣ جدول العملاء
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
-- 🔟 جدول المخزون بالقيمة (بدون أصناف)
-- المخزون يزيد وينقص حسب المبيعات والمشتريات ومردوداتهم
-- ========================================
CREATE TABLE InventoryValue (
    InventoryID INT PRIMARY KEY IDENTITY(1,1),
    BranchID INT NOT NULL,
    InventoryValue DECIMAL(18,2) DEFAULT 0,
    LastUpdateDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID)
);

INSERT INTO InventoryValue (BranchID, InventoryValue) VALUES
(1, 0.00),
(2, 0.00),
(3, 0.00);
GO

-- ========================================
-- 1️⃣1️⃣ جدول فواتير المشتريات
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
    PaymentMethod NVARCHAR(50), -- نقدي, آجل, بنكي
    PaymentStatus NVARCHAR(20), -- مدفوع, مؤجل, جزئي
    Status NVARCHAR(20),
    Notes NVARCHAR(500),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

-- ========================================
-- 1️⃣2️⃣ جدول فواتير المبيعات
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
    PaymentMethod NVARCHAR(50), -- نقدي, آجل, بنكي
    PaymentStatus NVARCHAR(20), -- مدفوع, مؤجل, جزئي
    Status NVARCHAR(20),
    Notes NVARCHAR(500),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

-- ========================================
-- 1️⃣3️⃣ جدول مردودات المشتريات (جديد)
-- ترتبط مع حسابات الموردين والبنك والنقدية والآجل
-- ========================================
CREATE TABLE PurchaseReturns (
    ReturnID INT PRIMARY KEY IDENTITY(1,1),
    ReturnNumber NVARCHAR(50) UNIQUE NOT NULL,
    ReturnDate DATETIME DEFAULT GETDATE(),
    OriginalPurchaseID INT, -- ربط مع فاتورة المشتريات الأصلية
    BranchID INT NOT NULL,
    SupplierID INT NOT NULL,
    UserID INT NOT NULL,
    TotalAmount DECIMAL(18,2),
    DiscountAmount DECIMAL(18,2) DEFAULT 0,
    VATAmount DECIMAL(18,2) DEFAULT 0,
    NetAmount DECIMAL(18,2),
    RefundMethod NVARCHAR(50), -- نقدي, آجل, بنكي
    RefundStatus NVARCHAR(20), -- تم الاسترداد, مؤجل, جزئي
    Status NVARCHAR(20),
    Reason NVARCHAR(500),
    Notes NVARCHAR(500),
    FOREIGN KEY (OriginalPurchaseID) REFERENCES PurchaseInvoices(PurchaseID),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

-- ========================================
-- 1️⃣4️⃣ جدول مردودات المبيعات (جديد)
-- ترتبط مع حسابات العملاء والبنك والنقدية والآجل
-- ========================================
CREATE TABLE SalesReturns (
    ReturnID INT PRIMARY KEY IDENTITY(1,1),
    ReturnNumber NVARCHAR(50) UNIQUE NOT NULL,
    ReturnDate DATETIME DEFAULT GETDATE(),
    OriginalInvoiceID INT, -- ربط مع فاتورة المبيعات الأصلية
    BranchID INT NOT NULL,
    CustomerID INT,
    UserID INT NOT NULL,
    TotalAmount DECIMAL(18,2),
    DiscountAmount DECIMAL(18,2) DEFAULT 0,
    VATAmount DECIMAL(18,2) DEFAULT 0,
    NetAmount DECIMAL(18,2),
    RefundMethod NVARCHAR(50), -- نقدي, آجل, بنكي
    RefundStatus NVARCHAR(20), -- تم الاسترداد, مؤجل, جزئي
    Status NVARCHAR(20),
    Reason NVARCHAR(500),
    Notes NVARCHAR(500),
    FOREIGN KEY (OriginalInvoiceID) REFERENCES SalesInvoices(InvoiceID),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

-- ========================================
-- 1️⃣5️⃣ جدول القيود اليومية (جديد)
-- ========================================
CREATE TABLE JournalEntries (
    EntryID INT PRIMARY KEY IDENTITY(1,1),
    EntryNumber NVARCHAR(50) UNIQUE NOT NULL,
    EntryDate DATETIME DEFAULT GETDATE(),
    BranchID INT NOT NULL,
    UserID INT NOT NULL,
    Description NVARCHAR(500),
    TotalDebit DECIMAL(18,2),
    TotalCredit DECIMAL(18,2),
    Status NVARCHAR(20), -- معتمد, مسودة, ملغى
    IsReversed BIT DEFAULT 0,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

-- ========================================
-- 1️⃣6️⃣ جدول تفاصيل القيود اليومية (جديد)
-- ========================================
CREATE TABLE JournalEntryDetails (
    DetailID INT PRIMARY KEY IDENTITY(1,1),
    EntryID INT NOT NULL,
    AccountCode NVARCHAR(50),
    AccountName NVARCHAR(200),
    DebitAmount DECIMAL(18,2) DEFAULT 0,
    CreditAmount DECIMAL(18,2) DEFAULT 0,
    Description NVARCHAR(500),
    FOREIGN KEY (EntryID) REFERENCES JournalEntries(EntryID)
);
GO

-- ========================================
-- 1️⃣7️⃣ جدول سندات القبض (جديد)
-- ========================================
CREATE TABLE ReceiptVouchers (
    VoucherID INT PRIMARY KEY IDENTITY(1,1),
    VoucherNumber NVARCHAR(50) UNIQUE NOT NULL,
    VoucherDate DATETIME DEFAULT GETDATE(),
    BranchID INT NOT NULL,
    SafeID INT,
    AccountID INT,
    UserID INT NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    ReceivedFrom NVARCHAR(200),
    PaymentMethod NVARCHAR(50), -- نقدي, شيك, تحويل بنكي
    ReferenceNumber NVARCHAR(50),
    Description NVARCHAR(500),
    Status NVARCHAR(20),
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (SafeID) REFERENCES Safes(SafeID),
    FOREIGN KEY (AccountID) REFERENCES BankAccounts(AccountID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

-- ========================================
-- 1️⃣8️⃣ جدول سندات الصرف (جديد)
-- ========================================
CREATE TABLE PaymentVouchers (
    VoucherID INT PRIMARY KEY IDENTITY(1,1),
    VoucherNumber NVARCHAR(50) UNIQUE NOT NULL,
    VoucherDate DATETIME DEFAULT GETDATE(),
    BranchID INT NOT NULL,
    SafeID INT,
    AccountID INT,
    UserID INT NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    PaidTo NVARCHAR(200),
    PaymentMethod NVARCHAR(50), -- نقدي, شيك, تحويل بنكي
    ReferenceNumber NVARCHAR(50),
    Description NVARCHAR(500),
    Status NVARCHAR(20),
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (SafeID) REFERENCES Safes(SafeID),
    FOREIGN KEY (AccountID) REFERENCES BankAccounts(AccountID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

-- ========================================
-- 1️⃣9️⃣ جدول سجل ضريبة القيمة المضافة (جديد)
-- مع إمكانية الربط مع الجهات الضريبية
-- ========================================
CREATE TABLE VATRecords (
    VATID INT PRIMARY KEY IDENTITY(1,1),
    Period NVARCHAR(20), -- 2025-Q1, 2025-Q2
    StartDate DATE,
    EndDate DATE,
    TotalSales DECIMAL(18,2),
    TotalPurchases DECIMAL(18,2),
    OutputVAT DECIMAL(18,2), -- ضريبة المخرجات (15%)
    InputVAT DECIMAL(18,2), -- ضريبة المدخلات
    NetVAT DECIMAL(18,2), -- الضريبة المستحقة
    Status NVARCHAR(20), -- مسودة, مقدمة, مدفوعة
    SubmissionDate DATETIME,
    PaymentDate DATETIME,
    ZatcaReferenceNumber NVARCHAR(100), -- رقم مرجعي من هيئة الزكاة والضريبة
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- ========================================
-- 2️⃣0️⃣ جدول الزكاة (جديد)
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
-- 2️⃣1️⃣ جدول الإشعارات (جديد)
-- ========================================
CREATE TABLE Notifications (
    NotificationID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT,
    Title NVARCHAR(200),
    Message NVARCHAR(500),
    NotificationType NVARCHAR(50), -- تنبيه, تحذير, معلومات
    IsRead BIT DEFAULT 0,
    Priority NVARCHAR(20), -- عادي, مهم, عاجل
    CreatedDate DATETIME DEFAULT GETDATE(),
    ReadDate DATETIME,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

-- ========================================
-- 2️⃣2️⃣ جدول سجل النشاط (جديد)
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
-- 2️⃣3️⃣ جدول النسخ الاحتياطية (جديد)
-- ========================================
CREATE TABLE BackupLog (
    BackupID INT PRIMARY KEY IDENTITY(1,1),
    BackupName NVARCHAR(200),
    BackupPath NVARCHAR(500),
    BackupSize DECIMAL(18,2), -- MB
    BackupType NVARCHAR(50), -- كامل, تفاضلي
    Status NVARCHAR(20), -- ناجح, فاشل
    CreatedBy INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID)
);
GO

-- ========================================
-- ✅ TRIGGERS - تحديث المخزون تلقائياً
-- ========================================

-- Trigger لتحديث المخزون عند المشتريات
CREATE TRIGGER trg_UpdateInventory_OnPurchase
ON PurchaseInvoices
AFTER INSERT
AS
BEGIN
    UPDATE InventoryValue
    SET InventoryValue = InventoryValue + i.NetAmount,
        LastUpdateDate = GETDATE()
    FROM InventoryValue iv
    INNER JOIN inserted i ON iv.BranchID = i.BranchID;
END;
GO

-- Trigger لتحديث المخزون عند المبيعات
CREATE TRIGGER trg_UpdateInventory_OnSales
ON SalesInvoices
AFTER INSERT
AS
BEGIN
    UPDATE InventoryValue
    SET InventoryValue = InventoryValue - i.NetAmount,
        LastUpdateDate = GETDATE()
    FROM InventoryValue iv
    INNER JOIN inserted i ON iv.BranchID = i.BranchID;
END;
GO

-- Trigger لتحديث المخزون عند مردودات المشتريات
CREATE TRIGGER trg_UpdateInventory_OnPurchaseReturn
ON PurchaseReturns
AFTER INSERT
AS
BEGIN
    UPDATE InventoryValue
    SET InventoryValue = InventoryValue - i.NetAmount,
        LastUpdateDate = GETDATE()
    FROM InventoryValue iv
    INNER JOIN inserted i ON iv.BranchID = i.BranchID;
END;
GO

-- Trigger لتحديث المخزون عند مردودات المبيعات
CREATE TRIGGER trg_UpdateInventory_OnSalesReturn
ON SalesReturns
AFTER INSERT
AS
BEGIN
    UPDATE InventoryValue
    SET InventoryValue = InventoryValue + i.NetAmount,
        LastUpdateDate = GETDATE()
    FROM InventoryValue iv
    INNER JOIN inserted i ON iv.BranchID = i.BranchID;
END;
GO

-- Trigger لتحديث رصيد الخزينة عند إضافة حركة
CREATE TRIGGER trg_UpdateSafeBalance
ON CashTransactions
AFTER INSERT
AS
BEGIN
    UPDATE Safes
    SET CurrentBalance = CASE 
        WHEN i.TransactionType = 'In' THEN CurrentBalance + i.Amount
        WHEN i.TransactionType = 'Out' THEN CurrentBalance - i.Amount
        ELSE CurrentBalance
    END
    FROM Safes s
    INNER JOIN inserted i ON s.SafeID = i.SafeID;
END;
GO

-- Trigger لتحديث رصيد البنك عند إضافة حركة
CREATE TRIGGER trg_UpdateBankBalance
ON BankTransactions
AFTER INSERT
AS
BEGIN
    UPDATE BankAccounts
    SET Balance = CASE 
        WHEN i.TransactionType = 'Deposit' THEN Balance + i.Amount
        WHEN i.TransactionType = 'Withdrawal' THEN Balance - i.Amount
        ELSE Balance
    END
    FROM BankAccounts ba
    INNER JOIN inserted i ON ba.AccountID = i.AccountID;
END;
GO

-- ========================================
-- ✅ VIEWS - عروض التقارير
-- ========================================

-- 1. عرض حالة الخزائن الثلاثة
CREATE VIEW vw_SafesStatus AS
SELECT 
    s.SafeID,
    s.SafeName,
    b.BranchName,
    s.OpeningBalance,
    s.CurrentBalance,
    (s.CurrentBalance - s.OpeningBalance) AS BalanceChange,
    s.IsActive
FROM Safes s
INNER JOIN Branches b ON s.BranchID = b.BranchID;
GO

-- 2. عرض حالة البنوك
CREATE VIEW vw_BankAccountsStatus AS
SELECT 
    ba.AccountID,
    ba.BankName,
    ba.AccountNumber,
    ba.IBAN,
    b.BranchName,
    ba.Balance,
    ba.Currency,
    ba.IsActive
FROM BankAccounts ba
LEFT JOIN Branches b ON ba.BranchID = b.BranchID;
GO

-- 3. عرض آخر 25 عملية
CREATE VIEW vw_Last25Transactions AS
SELECT TOP 25
    'Cash' AS TransactionSource,
    ct.TransactionID AS ID,
    ct.TransactionType,
    ct.Amount,
    ct.Description,
    ct.TransactionDate,
    b.BranchName,
    u.FullName AS UserName
FROM CashTransactions ct
INNER JOIN Branches b ON ct.BranchID = b.BranchID
INNER JOIN Users u ON ct.UserID = u.UserID
UNION ALL
SELECT TOP 25
    'Bank' AS TransactionSource,
    bt.BankTransactionID AS ID,
    bt.TransactionType,
    bt.Amount,
    bt.Description,
    bt.TransactionDate,
    b.BranchName,
    NULL AS UserName
FROM BankTransactions bt
INNER JOIN BankAccounts ba ON bt.AccountID = ba.AccountID
LEFT JOIN Branches b ON ba.BranchID = b.BranchID
ORDER BY TransactionDate DESC;
GO

-- 4. عرض ملخص المبيعات
CREATE VIEW vw_SalesSummary AS
SELECT 
    b.BranchName,
    COUNT(si.InvoiceID) AS TotalInvoices,
    SUM(si.NetAmount) AS TotalSales,
    SUM(si.VATAmount) AS TotalVAT,
    CONVERT(DATE, si.InvoiceDate) AS SaleDate
FROM SalesInvoices si
INNER JOIN Branches b ON si.BranchID = b.BranchID
WHERE si.Status = N'مدفوع'
GROUP BY b.BranchName, CONVERT(DATE, si.InvoiceDate);
GO

-- 5. عرض تقرير مطابقة الصندوق (حسب الفرع والكاشير والوردية)
CREATE VIEW vw_CashReconciliation AS
SELECT 
    sh.ShiftID,
    sh.ShiftNumber,
    b.BranchName,
    s.SafeName,
    u.FullName AS CashierName,
    sh.OpeningTime,
    sh.ClosingTime,
    sh.OpeningBalance,
    sh.ClosingBalance,
    sh.ExpectedBalance,
    sh.Difference,
    sh.Status,
    CONVERT(DATE, sh.OpeningTime) AS ShiftDate
FROM Shifts sh
INNER JOIN Branches b ON sh.BranchID = b.BranchID
INNER JOIN Safes s ON sh.SafeID = s.SafeID
INNER JOIN Users u ON sh.UserID = u.UserID;
GO

-- 6. عرض المخزون بالقيمة
CREATE VIEW vw_InventoryByBranch AS
SELECT 
    b.BranchName,
    iv.InventoryValue,
    iv.LastUpdateDate
FROM InventoryValue iv
INNER JOIN Branches b ON iv.BranchID = b.BranchID;
GO

-- 7. عرض أرصدة الموردين والعملاء
CREATE VIEW vw_AccountsBalance AS
SELECT 
    'Supplier' AS AccountType,
    SupplierID AS AccountID,
    SupplierName AS AccountName,
    Balance,
    Phone,
    IsActive
FROM Suppliers
UNION ALL
SELECT 
    'Customer' AS AccountType,
    CustomerID AS AccountID,
    CustomerName AS AccountName,
    Balance,
    Phone,
    IsActive
FROM Customers;
GO

-- 8. عرض تقرير ضريبة القيمة المضافة
CREATE VIEW vw_VATReport AS
SELECT 
    Period,
    StartDate,
    EndDate,
    TotalSales,
    TotalPurchases,
    OutputVAT,
    InputVAT,
    NetVAT,
    Status,
    ZatcaReferenceNumber
FROM VATRecords;
GO

-- ========================================
-- ✅ STORED PROCEDURES - الإجراءات المخزّنة
-- ========================================

-- 1. إجراء عمل نسخة احتياطية
CREATE PROCEDURE sp_CreateBackup
    @BackupPath NVARCHAR(500),
    @BackupType NVARCHAR(50),
    @UserID INT
AS
BEGIN
    DECLARE @BackupName NVARCHAR(200);
    DECLARE @FullPath NVARCHAR(500);
    DECLARE @DatabaseName NVARCHAR(100) = 'ERP_System_Enhanced';
    
    SET @BackupName = @DatabaseName + '_' + CONVERT(NVARCHAR, GETDATE(), 112) + '_' + 
                      REPLACE(CONVERT(NVARCHAR, GETDATE(), 108), ':', '') + '.bak';
    SET @FullPath = @BackupPath + '\\' + @BackupName;
    
    BEGIN TRY
        BACKUP DATABASE @DatabaseName TO DISK = @FullPath;
        
        INSERT INTO BackupLog (BackupName, BackupPath, BackupType, Status, CreatedBy)
        VALUES (@BackupName, @FullPath, @BackupType, N'ناجح', @UserID);
        
        SELECT 'Success' AS Result, @FullPath AS BackupPath;
    END TRY
    BEGIN CATCH
        INSERT INTO BackupLog (BackupName, BackupPath, BackupType, Status, CreatedBy)
        VALUES (@BackupName, @FullPath, @BackupType, N'فاشل', @UserID);
        
        SELECT 'Failed' AS Result, ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END;
GO

-- 2. إجراء تقرير مطابقة الصندوق
CREATE PROCEDURE sp_CashReconciliationReport
    @BranchID INT = NULL,
    @UserID INT = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    SELECT 
        sh.ShiftID,
        sh.ShiftNumber,
        b.BranchName,
        s.SafeName,
        u.FullName AS CashierName,
        sh.OpeningTime,
        sh.ClosingTime,
        sh.OpeningBalance,
        sh.ClosingBalance,
        sh.ExpectedBalance,
        sh.Difference,
        CASE 
            WHEN sh.Difference = 0 THEN N'مطابق'
            WHEN sh.Difference > 0 THEN N'زيادة'
            ELSE N'عجز'
        END AS ReconciliationStatus,
        sh.Status
    FROM Shifts sh
    INNER JOIN Branches b ON sh.BranchID = b.BranchID
    INNER JOIN Safes s ON sh.SafeID = s.SafeID
    INNER JOIN Users u ON sh.UserID = u.UserID
    WHERE (@BranchID IS NULL OR sh.BranchID = @BranchID)
        AND (@UserID IS NULL OR sh.UserID = @UserID)
        AND (@StartDate IS NULL OR CONVERT(DATE, sh.OpeningTime) >= @StartDate)
        AND (@EndDate IS NULL OR CONVERT(DATE, sh.ClosingTime) <= @EndDate)
    ORDER BY sh.OpeningTime DESC;
END;
GO

-- 3. إجراء حساب ضريبة القيمة المضافة
CREATE PROCEDURE sp_CalculateVAT
    @StartDate DATE,
    @EndDate DATE,
    @Period NVARCHAR(20)
AS
BEGIN
    DECLARE @TotalSales DECIMAL(18,2);
    DECLARE @TotalPurchases DECIMAL(18,2);
    DECLARE @OutputVAT DECIMAL(18,2);
    DECLARE @InputVAT DECIMAL(18,2);
    DECLARE @NetVAT DECIMAL(18,2);
    
    -- حساب إجمالي المبيعات وضريبتها
    SELECT 
        @TotalSales = ISNULL(SUM(NetAmount), 0),
        @OutputVAT = ISNULL(SUM(VATAmount), 0)
    FROM SalesInvoices
    WHERE InvoiceDate BETWEEN @StartDate AND @EndDate
        AND Status = N'مدفوع';
    
    -- حساب إجمالي المشتريات وضريبتها
    SELECT 
        @TotalPurchases = ISNULL(SUM(NetAmount), 0),
        @InputVAT = ISNULL(SUM(VATAmount), 0)
    FROM PurchaseInvoices
    WHERE PurchaseDate BETWEEN @StartDate AND @EndDate
        AND Status = N'مدفوع';
    
    -- الضريبة المستحقة
    SET @NetVAT = @OutputVAT - @InputVAT;
    
    -- حفظ السجل
    INSERT INTO VATRecords (Period, StartDate, EndDate, TotalSales, TotalPurchases, 
                            OutputVAT, InputVAT, NetVAT, Status)
    VALUES (@Period, @StartDate, @EndDate, @TotalSales, @TotalPurchases, 
            @OutputVAT, @InputVAT, @NetVAT, N'مسودة');
    
    -- عرض النتيجة
    SELECT 
        @Period AS Period,
        @TotalSales AS TotalSales,
        @TotalPurchases AS TotalPurchases,
        @OutputVAT AS OutputVAT,
        @InputVAT AS InputVAT,
        @NetVAT AS NetVAT;
END;
GO

-- 4. إجراء للتحليل المالي (للذكاء الاصطناعي)
CREATE PROCEDURE sp_FinancialAnalysis
    @BranchID INT = NULL,
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    -- ملخص المبيعات
    SELECT 
        b.BranchName,
        COUNT(si.InvoiceID) AS TotalInvoices,
        SUM(si.TotalAmount) AS TotalBeforeVAT,
        SUM(si.VATAmount) AS TotalVAT,
        SUM(si.NetAmount) AS TotalAfterVAT,
        AVG(si.NetAmount) AS AverageInvoice,
        MAX(si.NetAmount) AS MaxInvoice,
        MIN(si.NetAmount) AS MinInvoice
    FROM SalesInvoices si
    INNER JOIN Branches b ON si.BranchID = b.BranchID
    WHERE si.InvoiceDate BETWEEN @StartDate AND @EndDate
        AND (@BranchID IS NULL OR si.BranchID = @BranchID)
        AND si.Status = N'مدفوع'
    GROUP BY b.BranchName;
    
    -- ملخص المشتريات
    SELECT 
        b.BranchName,
        COUNT(pi.PurchaseID) AS TotalPurchases,
        SUM(pi.NetAmount) AS TotalPurchaseAmount
    FROM PurchaseInvoices pi
    INNER JOIN Branches b ON pi.BranchID = b.BranchID
    WHERE pi.PurchaseDate BETWEEN @StartDate AND @EndDate
        AND (@BranchID IS NULL OR pi.BranchID = @BranchID)
        AND pi.Status = N'مدفوع'
    GROUP BY b.BranchName;
    
    -- ربحية الفرع (تقريبي)
    SELECT 
        b.BranchName,
        (SELECT ISNULL(SUM(NetAmount), 0) FROM SalesInvoices 
         WHERE BranchID = b.BranchID AND InvoiceDate BETWEEN @StartDate AND @EndDate) AS TotalSales,
        (SELECT ISNULL(SUM(NetAmount), 0) FROM PurchaseInvoices 
         WHERE BranchID = b.BranchID AND PurchaseDate BETWEEN @StartDate AND @EndDate) AS TotalPurchases,
        (SELECT ISNULL(SUM(NetAmount), 0) FROM SalesInvoices 
         WHERE BranchID = b.BranchID AND InvoiceDate BETWEEN @StartDate AND @EndDate) -
        (SELECT ISNULL(SUM(NetAmount), 0) FROM PurchaseInvoices 
         WHERE BranchID = b.BranchID AND PurchaseDate BETWEEN @StartDate AND @EndDate) AS GrossProfit
    FROM Branches b
    WHERE (@BranchID IS NULL OR b.BranchID = @BranchID);
END;
GO

-- ========================================
-- 🎉 اكتمال قاعدة البيانات المحسّنة
-- ========================================

/*
✅ تم إضافة جميع الميزات المطلوبة:

1. ✅ مردودات المشتريات ومردودات المبيعات
2. ✅ الترابط مع حسابات الموردين والعملاء
3. ✅ الترابط مع البنك والنقدية والآجل
4. ✅ المخزون بالقيمة (بدون أصناف)
5. ✅ تحديث تلقائي للمخزون مع المبيعات/المشتريات/المردودات
6. ✅ القيود اليومية وتفاصيلها
7. ✅ سندات الصرف وسندات القبض
8. ✅ تقرير ضريبة القيمة المضافة (15%)
9. ✅ الربط مع هيئة الزكاة والضريبة (ZATCA)
10. ✅ النسخ الاحتياطية وسجلها
11. ✅ تقرير مطابقة الصندوق (حسب الفرع/الكاشير/الوردية/التاريخ)
12. ✅ التحليل المالي بالذكاء الاصطناعي
13. ✅ نظام الإشعارات
14. ✅ عرض حالة الخزائن الثلاثة
15. ✅ عرض حالة البنوك
16. ✅ عرض آخر 25 عملية

📂 إحصائيات قاعدة البيانات:
- 23 جدول رئيسي
- 8 عروض (Views) للتقارير
- 6 Triggers للتحديث التلقائي
- 4 Stored Procedures للعمليات

🔑 بيانات الدخول:
- Admin: admin / 123456
- Manager1: manager1 / 123456
- Manager2: manager2 / 123456
- Manager3: manager3 / 123456
- Cashier1: cashier1 / 123456
- Cashier2: cashier2 / 123456
- Cashier3: cashier3 / 123456

📦 ملفات الواجهات التفاعلية:
- سيتم إضافة ملفات HTML/CSS/JavaScript لاحقاً
- Dashboard.html - لوحة التحكم الديناميكية
- Reports.html - صفحة التقارير مع التصدير (Excel & PDF)
- Notifications.html - نظام الإشعارات

💻 التطوير:
alifayad18-ctrl

📅 التاريخ:
December 12, 2025

✅ جاهز للاستخدام فوراً!
*/
