/*
========================================
   EXTERNAL INTEGRATION MODULE
   وحدة التكامل مع الأنظمة الخارجية
========================================

Description:
Integration with external systems:
- Payment Gateways (STC Pay, Apple Pay, Mada, Visa)
- WhatsApp Business API
- SMS Gateways (Unifonic, Twilio)
- Email Services (SendGrid, SMTP)
- Shipping Companies APIs
- E-commerce Platforms (Salla, Zid)
- Social Media APIs
- Third-party APIs
- Webhooks & Callbacks
- API Authentication & Security

Developer: alifayad18-ctrl
Date: December 12, 2025
========================================
*/

USE ERPSystem;
GO

-- =============================================
-- SECTION 1: API CONFIGURATION TABLES
-- =============================================

-- جدول إعدادات الربط مع الأنظمة الخارجية
CREATE TABLE APIConfigurations (
    ConfigID INT PRIMARY KEY IDENTITY(1,1),
    ServiceName NVARCHAR(100) NOT NULL, -- STC Pay, WhatsApp, SMS, Email, etc.
    ServiceType NVARCHAR(50) NOT NULL, -- Payment, Messaging, Shipping, etc.
    APIKey NVARCHAR(500),
    APISecret NVARCHAR(500),
    BaseURL NVARCHAR(500),
    AuthType NVARCHAR(50), -- Bearer, Basic, OAuth, API Key
    IsActive BIT DEFAULT 1,
    IsSandbox BIT DEFAULT 0,
    RateLimitPerMinute INT DEFAULT 60,
    TimeoutSeconds INT DEFAULT 30,
    RetryAttempts INT DEFAULT 3,
    ConfigData NVARCHAR(MAX), -- JSON for additional config
    CreatedBy INT NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedBy INT,
    ModifiedDate DATETIME,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (ModifiedBy) REFERENCES Users(UserID)
);

-- جدول سجل الطلبات لل APIs
CREATE TABLE APIRequestLog (
    LogID BIGINT PRIMARY KEY IDENTITY(1,1),
    ConfigID INT NOT NULL,
    RequestType NVARCHAR(50) NOT NULL, -- GET, POST, PUT, DELETE
    EndpointURL NVARCHAR(1000) NOT NULL,
    RequestHeaders NVARCHAR(MAX),
    RequestBody NVARCHAR(MAX),
    ResponseStatus INT, -- HTTP Status Code
    ResponseBody NVARCHAR(MAX),
    ResponseTime INT, -- Milliseconds
    IsSuccess BIT DEFAULT 0,
    ErrorMessage NVARCHAR(MAX),
    RequestDate DATETIME DEFAULT GETDATE(),
    UserID INT,
    IPAddress NVARCHAR(50),
    FOREIGN KEY (ConfigID) REFERENCES APIConfigurations(ConfigID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE INDEX IDX_APILog_Date ON APIRequestLog(RequestDate DESC);
CREATE INDEX IDX_APILog_Status ON APIRequestLog(IsSuccess, RequestDate);

-- =============================================
-- SECTION 2: PAYMENT GATEWAY INTEGRATION
-- =============================================

-- جدول بوابات الدفع
CREATE TABLE PaymentGateways (
    GatewayID INT PRIMARY KEY IDENTITY(1,1),
    GatewayName NVARCHAR(100) NOT NULL, -- STC Pay, Mada, Visa, Apple Pay
    GatewayType NVARCHAR(50), -- Wallet, Card, Bank
    MerchantID NVARCHAR(200),
    MerchantKey NVARCHAR(500),
    APIConfigID INT,
    CommissionRate DECIMAL(5,2) DEFAULT 0, -- %
    FixedFee DECIMAL(10,2) DEFAULT 0,
    Currency NVARCHAR(10) DEFAULT 'SAR',
    IsActive BIT DEFAULT 1,
    SupportedCountries NVARCHAR(MAX), -- JSON array
    ConfigData NVARCHAR(MAX), -- JSON for gateway-specific config
    FOREIGN KEY (APIConfigID) REFERENCES APIConfigurations(ConfigID)
);

-- جدول معاملات الدفع الإلكتروني
CREATE TABLE OnlinePayments (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    SaleID INT,
    GatewayID INT NOT NULL,
    TransactionID NVARCHAR(200) UNIQUE, -- From gateway
    Amount DECIMAL(18,2) NOT NULL,
    CommissionAmount DECIMAL(18,2) DEFAULT 0,
    NetAmount DECIMAL(18,2),
    Currency NVARCHAR(10) DEFAULT 'SAR',
    Status NVARCHAR(50) DEFAULT 'Pending', -- Pending, Success, Failed, Refunded
    PaymentMethod NVARCHAR(50), -- Card, Wallet, Bank Transfer
    CardLast4 NVARCHAR(4),
    CardBrand NVARCHAR(50), -- Visa, Mastercard, Mada
    CustomerPhone NVARCHAR(20),
    CustomerEmail NVARCHAR(150),
    PaymentDate DATETIME DEFAULT GETDATE(),
    CallbackData NVARCHAR(MAX), -- JSON response from gateway
    RefundDate DATETIME,
    RefundReason NVARCHAR(500),
    CreatedBy INT NOT NULL,
    FOREIGN KEY (SaleID) REFERENCES Sales(SaleID),
    FOREIGN KEY (GatewayID) REFERENCES PaymentGateways(GatewayID),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID)
);

CREATE INDEX IDX_OnlinePayments_Status ON OnlinePayments(Status, PaymentDate);

-- =============================================
-- SECTION 3: MESSAGING INTEGRATION
-- =============================================

-- جدول رسائل WhatsApp
CREATE TABLE WhatsAppMessages (
    MessageID BIGINT PRIMARY KEY IDENTITY(1,1),
    RecipientPhone NVARCHAR(20) NOT NULL,
    MessageType NVARCHAR(50), -- Text, Image, Document, Template
    MessageContent NVARCHAR(MAX),
    TemplateName NVARCHAR(100),
    TemplateParams NVARCHAR(MAX), -- JSON
    MediaURL NVARCHAR(500),
    Status NVARCHAR(50) DEFAULT 'Pending', -- Pending, Sent, Delivered, Read, Failed
    WhatsAppID NVARCHAR(200), -- Message ID from WhatsApp
    SentDate DATETIME,
    DeliveredDate DATETIME,
    ReadDate DATETIME,
    FailureReason NVARCHAR(500),
    RelatedEntity NVARCHAR(50), -- Sale, Invoice, Order, etc.
    RelatedEntityID INT,
    CreatedBy INT NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID)
);

-- جدول رسائل SMS
CREATE TABLE SMSMessages (
    SMSID BIGINT PRIMARY KEY IDENTITY(1,1),
    RecipientPhone NVARCHAR(20) NOT NULL,
    SenderName NVARCHAR(50), -- Sender ID
    MessageContent NVARCHAR(1000) NOT NULL,
    Status NVARCHAR(50) DEFAULT 'Pending',
    MessageID NVARCHAR(200), -- From SMS provider
    Cost DECIMAL(10,4),
    PartsCount INT DEFAULT 1,
    SentDate DATETIME,
    DeliveredDate DATETIME,
    FailureReason NVARCHAR(500),
    RelatedEntity NVARCHAR(50),
    RelatedEntityID INT,
    CreatedBy INT NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID)
);

-- جدول رسائل البريد الإلكتروني
CREATE TABLE EmailMessages (
    EmailID BIGINT PRIMARY KEY IDENTITY(1,1),
    RecipientEmail NVARCHAR(200) NOT NULL,
    RecipientName NVARCHAR(200),
    Subject NVARCHAR(500) NOT NULL,
    Body NVARCHAR(MAX) NOT NULL,
    IsHTML BIT DEFAULT 1,
    Attachments NVARCHAR(MAX), -- JSON array of file paths
    Status NVARCHAR(50) DEFAULT 'Pending',
    MessageID NVARCHAR(200),
    SentDate DATETIME,
    OpenedDate DATETIME,
    ClickedDate DATETIME,
    FailureReason NVARCHAR(500),
    RelatedEntity NVARCHAR(50),
    RelatedEntityID INT,
    CreatedBy INT NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID)
);

GO
