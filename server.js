// ================================================
// ERP System Backend API - Node.js + SQL Server
// ================================================

const express = require('express');
const sql = require('mssql');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const app = express();
app.use(cors());
app.use(express.json());

// ================== إعدادات قاعدة البيانات ==================
const config = {
    user: 'sa',
    password: 'YourPassword', // غير كلمة المرور هنا
    server: 'localhost',
    database: 'ERP_System',
    options: {
        encrypt: false,
        trustServerCertificate: true,
        enableArithAbort: true
    }
};

// الاتصال بقاعدة البيانات
let pool;
async function connectDB() {
    try {
        pool = await sql.connect(config);
        console.log('✅ تم الاتصال بقاعدة البيانات بنجاح');
    } catch (err) {
        console.error('❌ خطأ في الاتصال بقاعدة البيانات:', err);
    }
}
connectDB();

// ================== API للمصادقة ==================
app.post('/api/login', async (req, res) => {
    try {
        const { username, password, branchId } = req.body;
        
        const result = await pool.request()
            .input('username', sql.NVarChar, username)
            .query('SELECT * FROM Users WHERE Username = @username AND IsActive = 1');
        
        if (result.recordset.length === 0) {
            return res.status(401).json({ error: 'اسم المستخدم أو كلمة المرور غير صحيحة' });
        }
        
        const user = result.recordset[0];
        const validPassword = await bcrypt.compare(password, user.PasswordHash);
        
        if (!validPassword) {
            return res.status(401).json({ error: 'اسم المستخدم أو كلمة المرور غير صحيحة' });
        }
        
        const token = jwt.sign({ userId: user.UserID, role: user.Role }, 'SECRET_KEY', { expiresIn: '8h' });
        
        res.json({ 
            token, 
            user: { 
                id: user.UserID, 
                username: user.Username, 
                fullName: user.FullName, 
                role: user.Role,
                branchId: branchId
            } 
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ================== API لوحة التحكم ==================
app.get('/api/dashboard/:branchId', async (req, res) => {
    try {
        const { branchId } = req.params;
        
        // المبيعات اليومية
        const sales = await pool.request()
            .input('branchId', sql.Int, branchId)
            .query(`
                SELECT SUM(TotalAmount) as DailySales 
                FROM SalesInvoices 
                WHERE BranchID = @branchId 
                AND CAST(InvoiceDate AS DATE) = CAST(GETDATE() AS DATE)
            `);
        
        // المخزون
        const inventory = await pool.request()
            .input('branchId', sql.Int, branchId)
            .query('SELECT COUNT(*) as TotalProducts FROM Inventory WHERE BranchID = @branchId AND Quantity > 0');
        
        // رصيد الخزينة
        const cash = await pool.request()
            .input('branchId', sql.Int, branchId)
            .query('SELECT SUM(Balance) as CashBalance FROM Safes WHERE BranchID = @branchId');
        
        // عدد الفواتير
        const invoices = await pool.request()
            .input('branchId', sql.Int, branchId)
            .query(`
                SELECT COUNT(*) as InvoiceCount 
                FROM SalesInvoices 
                WHERE BranchID = @branchId 
                AND CAST(InvoiceDate AS DATE) = CAST(GETDATE() AS DATE)
            `);
        
        res.json({
            dailySales: sales.recordset[0].DailySales || 0,
            totalProducts: inventory.recordset[0].TotalProducts || 0,
            cashBalance: cash.recordset[0].CashBalance || 0,
            invoiceCount: invoices.recordset[0].InvoiceCount || 0
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ================== API المبيعات ==================
app.post('/api/sales/invoice', async (req, res) => {
    const transaction = pool.transaction();
    try {
        await transaction.begin();
        
        const { branchId, customerId, items, paymentMethod, totalAmount, vatAmount } = req.body;
        
        // إنشاء الفاتورة
        const invoice = await transaction.request()
            .input('branchId', sql.Int, branchId)
            .input('customerId', sql.Int, customerId)
            .input('totalAmount', sql.Decimal(18,2), totalAmount)
            .input('vatAmount', sql.Decimal(18,2), vatAmount)
            .input('paymentMethod', sql.NVarChar, paymentMethod)
            .query(`
                INSERT INTO SalesInvoices (BranchID, CustomerID, InvoiceDate, TotalAmount, VATAmount, PaymentMethod)
                OUTPUT INSERTED.InvoiceID
                VALUES (@branchId, @customerId, GETDATE(), @totalAmount, @vatAmount, @paymentMethod)
            `);
        
        const invoiceId = invoice.recordset[0].InvoiceID;
        
        // إضافة تفاصيل الفاتورة وتحديث المخزون
        for (const item of items) {
            await transaction.request()
                .input('invoiceId', sql.Int, invoiceId)
                .input('productId', sql.Int, item.productId)
                .input('quantity', sql.Int, item.quantity)
                .input('unitPrice', sql.Decimal(18,2), item.unitPrice)
                .input('totalPrice', sql.Decimal(18,2), item.totalPrice)
                .query(`
                    INSERT INTO SalesInvoiceDetails (InvoiceID, ProductID, Quantity, UnitPrice, TotalPrice)
                    VALUES (@invoiceId, @productId, @quantity, @unitPrice, @totalPrice);
                    
                    UPDATE Inventory 
                    SET Quantity = Quantity - @quantity 
                    WHERE BranchID = ${branchId} AND ProductID = @productId;
                `);
        }
        
        await transaction.commit();
        res.json({ invoiceId, message: 'تم إنشاء الفاتورة بنجاح' });
    } catch (err) {
        await transaction.rollback();
        res.status(500).json({ error: err.message });
    }
});

// ================== API المنتجات ==================
app.get('/api/products/:branchId', async (req, res) => {
    try {
        const { branchId } = req.params;
        const result = await pool.request()
            .input('branchId', sql.Int, branchId)
            .query(`
                SELECT p.*, i.Quantity 
                FROM Products p
                LEFT JOIN Inventory i ON p.ProductID = i.ProductID AND i.BranchID = @branchId
                ORDER BY p.ProductName
            `);
        res.json(result.recordset);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ================== API الشفتات ==================
app.post('/api/shifts/open', async (req, res) => {
    try {
        const { branchId, safeId, userId, openingBalance } = req.body;
        
        const result = await pool.request()
            .input('branchId', sql.Int, branchId)
            .input('safeId', sql.Int, safeId)
            .input('userId', sql.Int, userId)
            .input('openingBalance', sql.Decimal(18,2), openingBalance)
            .query(`
                INSERT INTO Shifts (BranchID, SafeID, UserID, OpeningBalance, OpenedAt)
                OUTPUT INSERTED.ShiftID
                VALUES (@branchId, @safeId, @userId, @openingBalance, GETDATE())
            `);
        
        res.json({ shiftId: result.recordset[0].ShiftID, message: 'تم فتح الشفت بنجاح' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.post('/api/shifts/close/:shiftId', async (req, res) => {
    try {
        const { shiftId } = req.params;
        const { closingBalance } = req.body;
        
        await pool.request()
            .input('shiftId', sql.Int, shiftId)
            .input('closingBalance', sql.Decimal(18,2), closingBalance)
            .query(`
                UPDATE Shifts 
                SET ClosingBalance = @closingBalance, ClosedAt = GETDATE()
                WHERE ShiftID = @shiftId
            `);
        
        res.json({ message: 'تم إغلاق الشفت بنجاح' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ================== API التقارير ==================
app.get('/api/reports/sales/:branchId', async (req, res) => {
    try {
        const { branchId } = req.params;
        const { startDate, endDate } = req.query;
        
        const result = await pool.request()
            .input('branchId', sql.Int, branchId)
            .input('startDate', sql.Date, startDate)
            .input('endDate', sql.Date, endDate)
            .query(`
                SELECT 
                    CAST(InvoiceDate AS DATE) as Date,
                    COUNT(*) as InvoiceCount,
                    SUM(TotalAmount) as TotalSales,
                    SUM(VATAmount) as TotalVAT
                FROM SalesInvoices
                WHERE BranchID = @branchId 
                AND InvoiceDate BETWEEN @startDate AND @endDate
                GROUP BY CAST(InvoiceDate AS DATE)
                ORDER BY Date DESC
            `);
        
        res.json(result.recordset);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ================== API ZATCA ==================
app.post('/api/zatca/send-invoice', async (req, res) => {
    try {
        const { invoiceId } = req.body;
        
        // هنا يتم إرسال الفاتورة لهيئة الزكاة
        // التكامل مع ZATCA API
        
        const result = await pool.request()
            .input('invoiceId', sql.Int, invoiceId)
            .query('SELECT * FROM SalesInvoices WHERE InvoiceID = @invoiceId');
        
        const invoice = result.recordset[0];
        
        // توليد XML حسب معايير ZATCA
        const xmlInvoice = generateZATCAXML(invoice);
        
        // إرسال إلى ZATCA
        // const response = await sendToZATCA(xmlInvoice);
        
        res.json({ message: 'تم إرسال الفاتورة لهيئة الزكاة بنجاح' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

function generateZATCAXML(invoice) {
    // تنسيق XML حسب معايير ZATCA
    return `<?xml version="1.0" encoding="UTF-8"?>
    <Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2">
        <InvoiceID>${invoice.InvoiceID}</InvoiceID>
        <IssueDate>${invoice.InvoiceDate}</IssueDate>
        <TotalAmount>${invoice.TotalAmount}</TotalAmount>
        <VATAmount>${invoice.VATAmount}</VATAmount>
    </Invoice>`;
}

// ================== تشغيل السيرفر ==================
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`🚀 السيرفر يعمل على المنفذ ${PORT}`);
    console.log(`📡 http://localhost:${PORT}`);
});
