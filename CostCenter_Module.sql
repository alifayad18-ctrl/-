-- ========================================
-- 🏭 Cost Center Module - نظام مراكز التكلفة
-- معاملة كل فرع كشركة مستقلة
-- ========================================

USE ERP_System_Enhanced;
GO

-- ========================================
-- 1️⃣ تحديث جدول الموردين - إضافة الفرع
-- ========================================
ALTER TABLE Suppliers
ADD BranchID INT NULL;
GO

ALTER TABLE Suppliers
ADD CONSTRAINT FK_Suppliers_Branch 
FOREIGN KEY (BranchID) REFERENCES Branches(BranchID);
GO

-- ========================================
-- 2️⃣ جدول حسابات الموردين حسب الفرع
-- نفس المورد لكن لكل فرع حساب مستقل
-- ========================================
CREATE TABLE SupplierBranchAccounts (
    AccountID INT PRIMARY KEY IDENTITY(1,1),
    SupplierID INT NOT NULL,
    BranchID INT NOT NULL,
    Balance DECIMAL(18,2) DEFAULT 0,
    LastTransactionDate DATETIME,
    Notes NVARCHAR(500),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    UNIQUE (SupplierID, BranchID) -- مورد واحد لكل فرع
);
GO

-- ========================================
-- 3️⃣ جدول حسابات العملاء حسب الفرع
-- ========================================
CREATE TABLE CustomerBranchAccounts (
    AccountID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL,
    BranchID INT NOT NULL,
    Balance DECIMAL(18,2) DEFAULT 0,
    LastTransactionDate DATETIME,
    Notes NVARCHAR(500),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    UNIQUE (CustomerID, BranchID)
);
GO

-- ========================================
-- 4️⃣ جدول تحويلات المخزون بالقيمة
-- تحويل مخزون من فرع إلى آخر
-- ========================================
CREATE TABLE InventoryTransfers (
    TransferID INT PRIMARY KEY IDENTITY(1,1),
    TransferNumber NVARCHAR(50) UNIQUE NOT NULL,
    TransferDate DATETIME DEFAULT GETDATE(),
    FromBranchID INT NOT NULL,
    ToBranchID INT NOT NULL,
    TransferValue DECIMAL(18,2) NOT NULL, -- قيمة المخزون المحول
    Description NVARCHAR(500),
    TransferReason NVARCHAR(200),
    ApprovedBy INT,
    Status NVARCHAR(20), -- مسودة, معتمدة, مرسلة, مستلمة
    SentDate DATETIME,
    ReceivedDate DATETIME,
    CreatedBy INT NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (FromBranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (ToBranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (ApprovedBy) REFERENCES Users(UserID),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID)
);
GO

-- ========================================
-- 5️⃣ Trigger - تحديث المخزون عند التحويل
-- ========================================
CREATE TRIGGER trg_UpdateInventory_OnTransfer
ON InventoryTransfers
AFTER INSERT, UPDATE
AS
BEGIN
    -- عندما يتم اعتماد التحويل وإرساله
    IF EXISTS (SELECT 1 FROM inserted WHERE Status = N'مرسلة')
    BEGIN
        -- نقص من الفرع المرسل
        UPDATE InventoryValue
        SET InventoryValue = InventoryValue - i.TransferValue,
            LastUpdateDate = GETDATE()
        FROM InventoryValue iv
        INNER JOIN inserted i ON iv.BranchID = i.FromBranchID
        WHERE i.Status = N'مرسلة';
    END
    
    -- عندما يتم استلام التحويل
    IF EXISTS (SELECT 1 FROM inserted WHERE Status = N'مستلمة')
    BEGIN
        -- زيادة للفرع المستقبل
        UPDATE InventoryValue
        SET InventoryValue = InventoryValue + i.TransferValue,
            LastUpdateDate = GETDATE()
        FROM InventoryValue iv
        INNER JOIN inserted i ON iv.BranchID = i.ToBranchID
        WHERE i.Status = N'مستلمة';
    END
END;
GO

-- ========================================
-- 6️⃣ Views - عروض تقارير مراكز التكلفة
-- ========================================

-- عرض ملخص كل فرع (مركز تكلفة)
CREATE VIEW vw_BranchCostCenter AS
SELECT 
    b.BranchID,
    b.BranchCode,
    b.BranchName,
    -- المخزون
    iv.InventoryValue AS InventoryValue,
    -- رصيد الخزينة
    (SELECT CurrentBalance FROM Safes WHERE BranchID = b.BranchID AND IsActive = 1) AS SafeBalance,
    -- رصيد البنك
    (SELECT SUM(Balance) FROM BankAccounts WHERE BranchID = b.BranchID AND IsActive = 1) AS BankBalance,
    -- إجمالي المبيعات
    (SELECT ISNULL(SUM(NetAmount), 0) FROM SalesInvoices WHERE BranchID = b.BranchID AND Status = N'مدفوع') AS TotalSales,
    -- إجمالي المشتريات
    (SELECT ISNULL(SUM(NetAmount), 0) FROM PurchaseInvoices WHERE BranchID = b.BranchID AND Status = N'مدفوع') AS TotalPurchases,
    -- إجمالي المصروفات
    (SELECT ISNULL(SUM(TotalAmount), 0) FROM Expenses WHERE BranchID = b.BranchID AND Status = N'مدفوعة') AS TotalExpenses
FROM Branches b
LEFT JOIN InventoryValue iv ON b.BranchID = iv.BranchID;
GO

-- عرض حسابات الموردين حسب الفرع
CREATE VIEW vw_SuppliersByBranch AS
SELECT 
    sba.AccountID,
    b.BranchName,
    s.SupplierName,
    s.Phone,
    sba.Balance,
    sba.LastTransactionDate,
    sba.IsActive
FROM SupplierBranchAccounts sba
INNER JOIN Branches b ON sba.BranchID = b.BranchID
INNER JOIN Suppliers s ON sba.SupplierID = s.SupplierID;
GO

-- عرض تحويلات المخزون
CREATE VIEW vw_InventoryTransfers AS
SELECT 
    it.TransferNumber,
    it.TransferDate,
    bf.BranchName AS FromBranch,
    bt.BranchName AS ToBranch,
    it.TransferValue,
    it.Description,
    it.Status,
    u.FullName AS CreatedBy
FROM InventoryTransfers it
INNER JOIN Branches bf ON it.FromBranchID = bf.BranchID
INNER JOIN Branches bt ON it.ToBranchID = bt.BranchID
INNER JOIN Users u ON it.CreatedBy = u.UserID;
GO

-- ========================================
-- 7️⃣ Stored Procedures
-- ========================================

-- إجراء تقرير مركز التكلفة
CREATE PROCEDURE sp_CostCenterReport
    @BranchID INT,
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SELECT 
        b.BranchName AS 'مركز التكلفة',
        -- المبيعات
        (SELECT ISNULL(SUM(NetAmount), 0) FROM SalesInvoices 
         WHERE BranchID = @BranchID 
         AND InvoiceDate BETWEEN @StartDate AND @EndDate
         AND Status = N'مدفوع') AS TotalSales,
        -- المشتريات
        (SELECT ISNULL(SUM(NetAmount), 0) FROM PurchaseInvoices 
         WHERE BranchID = @BranchID 
         AND PurchaseDate BETWEEN @StartDate AND @EndDate
         AND Status = N'مدفوع') AS TotalPurchases,
        -- المصروفات
        (SELECT ISNULL(SUM(TotalAmount), 0) FROM Expenses 
         WHERE BranchID = @BranchID 
         AND ExpenseDate BETWEEN @StartDate AND @EndDate
         AND Status = N'مدفوعة') AS TotalExpenses,
        -- الربح الإجمالي
        (SELECT ISNULL(SUM(NetAmount), 0) FROM SalesInvoices 
         WHERE BranchID = @BranchID 
         AND InvoiceDate BETWEEN @StartDate AND @EndDate) -
        (SELECT ISNULL(SUM(NetAmount), 0) FROM PurchaseInvoices 
         WHERE BranchID = @BranchID 
         AND PurchaseDate BETWEEN @StartDate AND @EndDate) -
        (SELECT ISNULL(SUM(TotalAmount), 0) FROM Expenses 
         WHERE BranchID = @BranchID 
         AND ExpenseDate BETWEEN @StartDate AND @EndDate) AS NetProfit,
        -- رصيد المخزون
        (SELECT InventoryValue FROM InventoryValue WHERE BranchID = @BranchID) AS CurrentInventory
    FROM Branches b
    WHERE b.BranchID = @BranchID;
END;
GO

-- ========================================
-- 8️⃣ أمثلة تطبيقية
-- ========================================

-- مثال 1: ربط مورد بفرع معين
-- نفس المورد لكن لكل فرع حساب مستقل
INSERT INTO SupplierBranchAccounts (SupplierID, BranchID, Balance) VALUES
(1, 1, 0), -- مورد 1 - فرع المعلز
(1, 2, 0), -- نفس المورد - فرع الربوة
(1, 3, 0), -- نفس المورد - فرع الروضة
(2, 1, 0),
(2, 2, 0),
(2, 3, 0);
GO

-- مثال 2: تحويل مخزون بالقيمة من فرع إلى آخر
INSERT INTO InventoryTransfers (
    TransferNumber, FromBranchID, ToBranchID, 
    TransferValue, Description, TransferReason,
    Status, CreatedBy
) VALUES (
    'TR-2025-001',
    1, -- من فرع المعلز
    2, -- إلى فرع الربوة
    5000.00, -- قيمة 5000 ريال
    N'تحويل مخزون بقيمة 5000 ريال',
    N'فرع الربوة بحاجة مخزون',
    N'مسودة', -- سيتم اعتماده لاحقاً
    2 -- مدير الفرع
);
GO

-- مثال 3: اعتماد وإرسال التحويل
UPDATE InventoryTransfers
SET Status = N'مرسلة', 
    SentDate = GETDATE(),
    ApprovedBy = 1 -- مدير النظام
WHERE TransferNumber = 'TR-2025-001';
-- هذا سينقص 5000 من مخزون فرع المعلز تلقائياً
GO

-- مثال 4: استلام التحويل
UPDATE InventoryTransfers
SET Status = N'مستلمة',
    ReceivedDate = GETDATE()
WHERE TransferNumber = 'TR-2025-001';
-- هذا سيزيد 5000 لمخزون فرع الربوة تلقائياً
GO

-- ========================================
-- ✅ ملخص النظام
-- ========================================

/*
🏭 نظام مراكز التكلفة:

✅ كل فرع يعامل كشركة مستقلة
✅ حسابات موردين مستقلة لكل فرع
✅ حسابات عملاء مستقلة لكل فرع
✅ مخزون بالقيمة لكل فرع
✅ تحويلات مخزون بين الفروع
✅ تحديث تلقائي للمخزون عند التحويل
✅ تقرير ربحية مستقل لكل فرع

📊 كيفية الاستخدام:

-- 1. عرض جميع مراكز التكلفة
SELECT * FROM vw_BranchCostCenter;

-- 2. عرض موردي فرع معين
SELECT * FROM vw_SuppliersByBranch
WHERE BranchName = N'فرع المعلز';

-- 3. عرض تحويلات المخزون
SELECT * FROM vw_InventoryTransfers;

-- 4. تقرير مركز تكلفة
EXEC sp_CostCenterReport 
    @BranchID = 1,
    @StartDate = '2025-01-01',
    @EndDate = '2025-12-31';

💻 التطوير: alifayad18-ctrl
📅 التاريخ: December 12, 2025

✅ جاهز للاستخدام!
*/
