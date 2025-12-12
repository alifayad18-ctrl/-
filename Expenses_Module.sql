-- ========================================
-- 💸 Expenses Module - نظام المصروفات المتقدم
-- مع جميع فئات المصروفات التشغيلية
-- ========================================

USE ERP_System_Enhanced;
GO

-- ========================================
-- 1️⃣ جدول فئات المصروفات
-- ========================================
CREATE TABLE ExpenseCategories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryCode NVARCHAR(20) UNIQUE NOT NULL,
    CategoryName NVARCHAR(100) NOT NULL,
    CategoryNameAr NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE()
);

-- إدخال جميع فئات المصروفات
INSERT INTO ExpenseCategories (CategoryCode, CategoryName, CategoryNameAr, Description) VALUES
('RENT', 'Rent', N'إيجار', N'إيجار المحلات والفروع'),
('SALARY', 'Salaries', N'رواتب', N'رواتب الموظفين والعاملين'),
('ELEC', 'Electricity', N'كهرباء', N'فواتير الكهرباء'),
('WATER', 'Water', N'مياه', N'فواتير المياه'),
('FUEL-CAR', 'Car Fuel', N'بنزين سيارة', N'وقود للسيارات'),
('FUEL-BIKE', 'Motorcycle Fuel', N'بنزين دباب', N'وقود للدراجات النارية'),
('INSUR', 'Insurance', N'تأمينات', N'تأمينات الموظفين والسيارات'),
('ALLOW', 'Allowances', N'بدلات', N'بدلات الموظفين'),
('MEALS', 'Employee Meals', N'وجبات للعاملين', N'وجبات الطعام للموظفين'),
('PARTS', 'Spare Parts', N'قطع غيار', N'قطع غيار وصيانة'),
('PAPER', 'Paper & Stationery', N'ورق وقرطاسية', N'ورق ومستلزمات مكتبية'),
('BAGS', 'Bags & Packaging', N'أكياس وتغليف', N'أكياس ومواد التغليف'),
('DRINK-WATER', 'Drinking Water', N'مياه شرب للعاملين', N'مياه شرب معبأة للموظفين'),
('VAT-EXP', 'VAT Expense', N'مصروف ضريبة القيمة المضافة', N'مصروفات ضريبة القيمة المضافة'),
('IQAMA', 'Residence Permit', N'مصروفات إقامات العاملين', N'تجديد إقامات وتأشيرات العمل'),
('VISA', 'Visas', N'تأشيرات', N'تأشيرات ورسوم الجوازات'),
('MAINT', 'Maintenance', N'صيانة', N'صيانة وإصلاحات'),
('CLEAN', 'Cleaning', N'نظافة', N'مواد تنظيف وخدمات نظافة'),
('TELECOM', 'Telecommunications', N'اتصالات', N'هواتف وإنترنت'),
('TRANS', 'Transportation', N'نقليات', N'مصروفات نقل وتوصيل'),
('ADV', 'Advertising', N'دعاية وتسويق', N'مصروفات دعاية وتسويق'),
('LEGAL', 'Legal & Accounting', N'قانونية ومحاسبية', N'رسوم قانونية ومحاسبية'),
('BANK-FEE', 'Bank Fees', N'رسوم بنكية', N'رسوم وعمولات بنكية'),
('MISC', 'Miscellaneous', N'مصروفات متنوعة', N'مصروفات متنوعة أخرى');
GO

-- ========================================
-- 2️⃣ جدول المصروفات التفصيلي
-- ========================================
CREATE TABLE Expenses (
    ExpenseID INT PRIMARY KEY IDENTITY(1,1),
    ExpenseNumber NVARCHAR(50) UNIQUE NOT NULL,
    ExpenseDate DATETIME DEFAULT GETDATE(),
    BranchID INT NOT NULL,
    CategoryID INT NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    VATAmount DECIMAL(18,2) DEFAULT 0,
    TotalAmount DECIMAL(18,2),
    PaymentMethod NVARCHAR(50), -- نقدي, شيك, تحويل بنكي
    PaidTo NVARCHAR(200), -- مدفوع لـ
    InvoiceNumber NVARCHAR(50), -- رقم فاتورة المورد
    Description NVARCHAR(500),
    Notes NVARCHAR(500),
    ApprovedBy INT, -- المعتمد من قبل
    Status NVARCHAR(20), -- مسودة, معتمدة, مدفوعة, ملغاة
    CreatedBy INT NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (CategoryID) REFERENCES ExpenseCategories(CategoryID),
    FOREIGN KEY (ApprovedBy) REFERENCES Users(UserID),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID)
);
GO

-- ========================================
-- 3️⃣ جدول موافقات المصروفات
-- ========================================
CREATE TABLE ExpenseApprovals (
    ApprovalID INT PRIMARY KEY IDENTITY(1,1),
    ExpenseID INT NOT NULL,
    ApproverID INT NOT NULL,
    ApprovalLevel INT, -- 1 = مدير الفرع, 2 = مدير عام, 3 = إدارة عليا
    ApprovalStatus NVARCHAR(20), -- موافق, مرفوض, قيد المراجعة
    ApprovalDate DATETIME DEFAULT GETDATE(),
    Comments NVARCHAR(500),
    FOREIGN KEY (ExpenseID) REFERENCES Expenses(ExpenseID),
    FOREIGN KEY (ApproverID) REFERENCES Users(UserID)
);
GO

-- ========================================
-- 4️⃣ جدول المستندات المرفقة
-- ========================================
CREATE TABLE ExpenseAttachments (
    AttachmentID INT PRIMARY KEY IDENTITY(1,1),
    ExpenseID INT NOT NULL,
    FileName NVARCHAR(200),
    FilePath NVARCHAR(500),
    FileSize DECIMAL(18,2), -- KB
    FileType NVARCHAR(50), -- PDF, JPG, PNG, etc.
    UploadedBy INT NOT NULL,
    UploadedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ExpenseID) REFERENCES Expenses(ExpenseID),
    FOREIGN KEY (UploadedBy) REFERENCES Users(UserID)
);
GO

-- ========================================
-- 5️⃣ Trigger لتحديث رصيد الخزينة عند دفع مصروف
-- ========================================
CREATE TRIGGER trg_UpdateSafeBalance_OnExpense
ON Expenses
AFTER INSERT, UPDATE
AS
BEGIN
    -- إذا كان الدفع نقدي ومدفوع
    IF EXISTS (SELECT 1 FROM inserted WHERE PaymentMethod = N'نقدي' AND Status = N'مدفوعة')
    BEGIN
        -- تسجيل حركة في جدول حركات الخزنة
        INSERT INTO CashTransactions (BranchID, SafeID, UserID, TransactionType, Amount, Description, ReferenceNumber)
        SELECT 
            i.BranchID,
            (SELECT TOP 1 SafeID FROM Safes WHERE BranchID = i.BranchID AND IsActive = 1),
            i.CreatedBy,
            'Out',
            i.TotalAmount,
            N'مصروف - ' + ec.CategoryNameAr,
            i.ExpenseNumber
        FROM inserted i
        INNER JOIN ExpenseCategories ec ON i.CategoryID = ec.CategoryID
        WHERE i.PaymentMethod = N'نقدي' AND i.Status = N'مدفوعة';
    END
END;
GO

-- ========================================
-- 6️⃣ Views - عروض تقارير المصروفات
-- ========================================

-- عرض ملخص المصروفات حسب الفئة
CREATE VIEW vw_ExpensesByCategory AS
SELECT 
    ec.CategoryCode,
    ec.CategoryNameAr AS CategoryName,
    b.BranchName,
    COUNT(e.ExpenseID) AS TotalExpenses,
    SUM(e.Amount) AS TotalAmountBeforeVAT,
    SUM(e.VATAmount) AS TotalVAT,
    SUM(e.TotalAmount) AS TotalAmountAfterVAT,
    YEAR(e.ExpenseDate) AS Year,
    MONTH(e.ExpenseDate) AS Month
FROM Expenses e
INNER JOIN ExpenseCategories ec ON e.CategoryID = ec.CategoryID
INNER JOIN Branches b ON e.BranchID = b.BranchID
WHERE e.Status = N'مدفوعة'
GROUP BY ec.CategoryCode, ec.CategoryNameAr, b.BranchName, YEAR(e.ExpenseDate), MONTH(e.ExpenseDate);
GO

-- عرض ملخص المصروفات حسب الفرع
CREATE VIEW vw_ExpensesByBranch AS
SELECT 
    b.BranchName,
    COUNT(e.ExpenseID) AS TotalExpenses,
    SUM(e.TotalAmount) AS TotalAmount,
    CONVERT(DATE, e.ExpenseDate) AS ExpenseDate
FROM Expenses e
INNER JOIN Branches b ON e.BranchID = b.BranchID
WHERE e.Status = N'مدفوعة'
GROUP BY b.BranchName, CONVERT(DATE, e.ExpenseDate);
GO

-- عرض تفصيلي للمصروفات
CREATE VIEW vw_ExpensesDetailed AS
SELECT 
    e.ExpenseNumber,
    e.ExpenseDate,
    b.BranchName,
    ec.CategoryNameAr AS CategoryName,
    e.Amount,
    e.VATAmount,
    e.TotalAmount,
    e.PaymentMethod,
    e.PaidTo,
    e.InvoiceNumber,
    e.Description,
    e.Status,
    u.FullName AS CreatedBy,
    approver.FullName AS ApprovedBy
FROM Expenses e
INNER JOIN ExpenseCategories ec ON e.CategoryID = ec.CategoryID
INNER JOIN Branches b ON e.BranchID = b.BranchID
INNER JOIN Users u ON e.CreatedBy = u.UserID
LEFT JOIN Users approver ON e.ApprovedBy = approver.UserID;
GO

-- عرض المصروفات المعلقة (بحاجة موافقة)
CREATE VIEW vw_PendingExpenses AS
SELECT 
    e.ExpenseNumber,
    e.ExpenseDate,
    b.BranchName,
    ec.CategoryNameAr AS CategoryName,
    e.TotalAmount,
    e.Status,
    u.FullName AS CreatedBy
FROM Expenses e
INNER JOIN ExpenseCategories ec ON e.CategoryID = ec.CategoryID
INNER JOIN Branches b ON e.BranchID = b.BranchID
INNER JOIN Users u ON e.CreatedBy = u.UserID
WHERE e.Status IN (N'مسودة', N'معتمدة');
GO

-- ========================================
-- 7️⃣ Stored Procedures - إجراءات المصروفات
-- ========================================

-- إجراء تقرير المصروفات الشامل
CREATE PROCEDURE sp_ExpensesReport
    @BranchID INT = NULL,
    @CategoryCode NVARCHAR(20) = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    SELECT 
        e.ExpenseNumber,
        e.ExpenseDate,
        b.BranchName,
        ec.CategoryCode,
        ec.CategoryNameAr AS CategoryName,
        e.Amount,
        e.VATAmount,
        e.TotalAmount,
        e.PaymentMethod,
        e.PaidTo,
        e.Description,
        e.Status,
        u.FullName AS CreatedBy
    FROM Expenses e
    INNER JOIN ExpenseCategories ec ON e.CategoryID = ec.CategoryID
    INNER JOIN Branches b ON e.BranchID = b.BranchID
    INNER JOIN Users u ON e.CreatedBy = u.UserID
    WHERE (@BranchID IS NULL OR e.BranchID = @BranchID)
        AND (@CategoryCode IS NULL OR ec.CategoryCode = @CategoryCode)
        AND (@StartDate IS NULL OR CONVERT(DATE, e.ExpenseDate) >= @StartDate)
        AND (@EndDate IS NULL OR CONVERT(DATE, e.ExpenseDate) <= @EndDate)
        AND e.Status = N'مدفوعة'
    ORDER BY e.ExpenseDate DESC;
END;
GO

-- إجراء تلخيص المصروفات حسب الفئة
CREATE PROCEDURE sp_ExpensesSummaryByCategory
    @Year INT,
    @Month INT = NULL
AS
BEGIN
    SELECT 
        ec.CategoryCode,
        ec.CategoryNameAr AS CategoryName,
        COUNT(e.ExpenseID) AS TotalCount,
        SUM(e.TotalAmount) AS TotalAmount,
        AVG(e.TotalAmount) AS AverageAmount,
        MAX(e.TotalAmount) AS MaxAmount,
        MIN(e.TotalAmount) AS MinAmount
    FROM Expenses e
    INNER JOIN ExpenseCategories ec ON e.CategoryID = ec.CategoryID
    WHERE YEAR(e.ExpenseDate) = @Year
        AND (@Month IS NULL OR MONTH(e.ExpenseDate) = @Month)
        AND e.Status = N'مدفوعة'
    GROUP BY ec.CategoryCode, ec.CategoryNameAr
    ORDER BY TotalAmount DESC;
END;
GO

-- ========================================
-- 8️⃣ بيانات تجريبية - أمثلة للمصروفات
-- ========================================

-- مثال 1: إيجار فرع المعلز
INSERT INTO Expenses (ExpenseNumber, BranchID, CategoryID, Amount, VATAmount, TotalAmount, PaymentMethod, PaidTo, Description, Status, CreatedBy)
VALUES (
    'EXP-2025-001',
    1, -- فرع المعلز
    (SELECT CategoryID FROM ExpenseCategories WHERE CategoryCode = 'RENT'),
    50000.00,
    0.00,
    50000.00,
    N'تحويل بنكي',
    N'المالك - عبدالله الأحمد',
    N'إيجار شهر ديسمبر 2025',
    N'مدفوعة',
    2 -- مدير الفرع
);

-- مثال 2: رواتب الموظفين
INSERT INTO Expenses (ExpenseNumber, BranchID, CategoryID, Amount, VATAmount, TotalAmount, PaymentMethod, PaidTo, Description, Status, CreatedBy)
VALUES (
    'EXP-2025-002',
    1,
    (SELECT CategoryID FROM ExpenseCategories WHERE CategoryCode = 'SALARY'),
    25000.00,
    0.00,
    25000.00,
    N'تحويل بنكي',
    N'رواتب الموظفين',
    N'رواتب شهر ديسمبر 2025',
    N'مدفوعة',
    2
);

-- مثال 3: فاتورة كهرباء
INSERT INTO Expenses (ExpenseNumber, BranchID, CategoryID, Amount, VATAmount, TotalAmount, PaymentMethod, PaidTo, InvoiceNumber, Description, Status, CreatedBy)
VALUES (
    'EXP-2025-003',
    1,
    (SELECT CategoryID FROM ExpenseCategories WHERE CategoryCode = 'ELEC'),
    2000.00,
    300.00,
    2300.00,
    N'نقدي',
    N'شركة الكهرباء',
    'ELEC-12-2025',
    N'فاتورة الكهرباء ديسمبر',
    N'مدفوعة',
    5 -- كاشير
);

-- مثال 4: بنزين سيارة
INSERT INTO Expenses (ExpenseNumber, BranchID, CategoryID, Amount, VATAmount, TotalAmount, PaymentMethod, PaidTo, Description, Status, CreatedBy)
VALUES (
    'EXP-2025-004',
    1,
    (SELECT CategoryID FROM ExpenseCategories WHERE CategoryCode = 'FUEL-CAR'),
    500.00,
    75.00,
    575.00,
    N'نقدي',
    N'محطة وقود',
    N'بنزين سيارة التوصيل',
    N'مدفوعة',
    5
);

-- مثال 5: وجبات للعاملين
INSERT INTO Expenses (ExpenseNumber, BranchID, CategoryID, Amount, VATAmount, TotalAmount, PaymentMethod, PaidTo, Description, Status, CreatedBy)
VALUES (
    'EXP-2025-005',
    1,
    (SELECT CategoryID FROM ExpenseCategories WHERE CategoryCode = 'MEALS'),
    300.00,
    0.00,
    300.00,
    N'نقدي',
    N'مطعم الفرحة',
    N'وجبات الغداء للموظفين',
    N'مدفوعة',
    5
);
GO

-- ========================================
-- ✅ اكتمال نظام المصروفات
-- ========================================

/*
💸 ما تم إضافته:

1. ✅ جدول ExpenseCategories - 24 فئة للمصروفات
2. ✅ جدول Expenses - المصروفات التفصيلية
3. ✅ جدول ExpenseApprovals - نظام موافقات
4. ✅ جدول ExpenseAttachments - رفع المستندات
5. ✅ Trigger لتحديث الخزينة تلقائياً
6. ✅ 4 Views للتقارير
7. ✅ 2 Stored Procedures
8. ✅ 5 أمثلة تجريبية

📊 فئات المصروفات المتوفرة:
✅ إيجار
✅ رواتب
✅ كهرباء
✅ مياه
✅ بنزين سيارة
✅ بنزين دباب
✅ تأمينات
✅ بدلات
✅ وجبات للعاملين
✅ قطع غيار
✅ ورق وقرطاسية
✅ أكياس وتغليف
✅ مياه شرب للعاملين
✅ مصروف ضريبة القيمة المضافة
✅ مصروفات إقامات العاملين
✅ تأشيرات
✅ صيانة
✅ نظافة
✅ اتصالات
✅ نقليات
✅ دعاية وتسويق
✅ قانونية ومحاسبية
✅ رسوم بنكية
✅ مصروفات متنوعة

📝 كيفية الاستخدام:

-- مثال 1: تسجيل مصروف
INSERT INTO Expenses VALUES (
    'EXP-2025-XXX', GETDATE(), 1, 
    (SELECT CategoryID FROM ExpenseCategories WHERE CategoryCode = 'RENT'),
    50000, 0, 50000, N'تحويل بنكي', N'المالك',
    NULL, N'إيجار شهري', NULL, NULL, N'مدفوعة', 2, GETDATE()
);

-- مثال 2: عرض المصروفات حسب الفئة
SELECT * FROM vw_ExpensesByCategory
WHERE Year = 2025 AND Month = 12;

-- مثال 3: تقرير المصروفات
EXEC sp_ExpensesReport 
    @BranchID = 1,
    @CategoryCode = 'RENT',
    @StartDate = '2025-01-01',
    @EndDate = '2025-12-31';

-- مثال 4: تلخيص شهري
EXEC sp_ExpensesSummaryByCategory @Year = 2025, @Month = 12;

💻 التطوير: alifayad18-ctrl
📅 التاريخ: December 12, 2025

✅ جاهز للاستخدام!
*/
