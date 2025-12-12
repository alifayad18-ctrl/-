-- =============================================
-- Management Module - نظام الإدارة المتقدم
-- =============================================
-- Version: 1.0
-- Description: إدارة شاملة مع تقارير تحليلية وذكاء اصطناعي
-- =============================================

USE ERPSystem;
GO

-- =============================================
-- 1. جدول الأهداف والخطط الاستراتيجية
-- =============================================
CREATE TABLE StrategicGoals (
    GoalID INT PRIMARY KEY IDENTITY(1,1),
    GoalName NVARCHAR(200) NOT NULL,
    GoalDescription NVARCHAR(MAX),
    GoalType NVARCHAR(50), -- مالي، تشغيلي، نمو، خدمة عملاء
    TargetValue DECIMAL(18,2),
    CurrentValue DECIMAL(18,2) DEFAULT 0,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    ResponsibleUserID INT,
    BranchID INT,
    Status NVARCHAR(50) DEFAULT 'نشط', -- نشط، مكتمل، ملغي، متأخر
    Priority NVARCHAR(20), -- عالية، متوسطة، منخفضة
    CompletionPercentage DECIMAL(5,2) DEFAULT 0,
    Notes NVARCHAR(MAX),
    CreatedBy INT NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedBy INT,
    ModifiedDate DATETIME,
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (ResponsibleUserID) REFERENCES Users(UserID),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID)
);
GO

-- =============================================
-- 2. جدول مؤشرات الأداء الرئيسية (KPIs)
-- =============================================
CREATE TABLE KPIDefinitions (
    KPIID INT PRIMARY KEY IDENTITY(1,1),
    KPIName NVARCHAR(200) NOT NULL,
    KPIDescription NVARCHAR(MAX),
    Category NVARCHAR(100), -- مالي، عملياتي، مبيعات، مخزون
    MeasurementUnit NVARCHAR(50), -- نسبة مئوية، مبلغ، عدد
    TargetValue DECIMAL(18,2),
    MinAcceptableValue DECIMAL(18,2),
    MaxValue DECIMAL(18,2),
    CalculationFormula NVARCHAR(MAX),
    BranchID INT,
    IsActive BIT DEFAULT 1,
    CreatedBy INT NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID)
);
GO

-- =============================================
-- 3. جدول قياسات مؤشرات الأداء
-- =============================================
CREATE TABLE KPIMeasurements (
    MeasurementID INT PRIMARY KEY IDENTITY(1,1),
    KPIID INT NOT NULL,
    MeasurementDate DATE NOT NULL,
    ActualValue DECIMAL(18,2) NOT NULL,
    TargetValue DECIMAL(18,2),
    Variance DECIMAL(18,2),
    VariancePercentage DECIMAL(5,2),
    BranchID INT,
    Period NVARCHAR(50), -- يومي، أسبوعي، شهري، ربع سنوي، سنوي
    Status NVARCHAR(50), -- فوق الهدف، ضمن الهدف، تحت الهدف
    Notes NVARCHAR(MAX),
    CreatedBy INT NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (KPIID) REFERENCES KPIDefinitions(KPIID),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID)
);
GO

-- =============================================
-- 4. جدول التنبيهات الذكية
-- =============================================
CREATE TABLE SmartAlerts (
    AlertID INT PRIMARY KEY IDENTITY(1,1),
    AlertType NVARCHAR(100) NOT NULL, -- مالي، مخزون، مبيعات، أداء، أمان
    AlertLevel NVARCHAR(50), -- حرج، تحذير، معلومات
    AlertTitle NVARCHAR(200) NOT NULL,
    AlertMessage NVARCHAR(MAX) NOT NULL,
    AlertDate DATETIME DEFAULT GETDATE(),
    RelatedEntityType NVARCHAR(100), -- فاتورة، موظف، مورد، منتج
    RelatedEntityID INT,
    BranchID INT,
    AssignedToUserID INT,
    IsRead BIT DEFAULT 0,
    IsActionTaken BIT DEFAULT 0,
    ActionDate DATETIME,
    ActionNotes NVARCHAR(MAX),
    Priority INT DEFAULT 3, -- 1-5
    ExpiryDate DATETIME,
    CreatedBy INT NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (AssignedToUserID) REFERENCES Users(UserID),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID)
);
GO

-- =============================================
-- 5. جدول المهام والمتابعة
-- =============================================
CREATE TABLE Tasks (
    TaskID INT PRIMARY KEY IDENTITY(1,1),
    TaskName NVARCHAR(200) NOT NULL,
    TaskDescription NVARCHAR(MAX),
    TaskType NVARCHAR(100), -- مالية، إدارية، فنية، متابعة
    AssignedToUserID INT NOT NULL,
    AssignedByUserID INT NOT NULL,
    BranchID INT,
    Priority NVARCHAR(20), -- عاجلة، عالية، متوسطة، منخفضة
    Status NVARCHAR(50) DEFAULT 'جديدة', -- جديدة، قيد التنفيذ، مكتملة، ملغاة، معلقة
    StartDate DATE,
    DueDate DATE,
    CompletionDate DATETIME,
    CompletionPercentage INT DEFAULT 0,
    EstimatedHours DECIMAL(10,2),
    ActualHours DECIMAL(10,2),
    RelatedEntityType NVARCHAR(100),
    RelatedEntityID INT,
    Notes NVARCHAR(MAX),
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME,
    FOREIGN KEY (AssignedToUserID) REFERENCES Users(UserID),
    FOREIGN KEY (AssignedByUserID) REFERENCES Users(UserID),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID)
);
GO

-- =============================================
-- 6. جدول تعليقات المهام
-- =============================================
CREATE TABLE TaskComments (
    CommentID INT PRIMARY KEY IDENTITY(1,1),
    TaskID INT NOT NULL,
    CommentText NVARCHAR(MAX) NOT NULL,
    CommentedBy INT NOT NULL,
    CommentDate DATETIME DEFAULT GETDATE(),
    IsInternal BIT DEFAULT 1,
    FOREIGN KEY (TaskID) REFERENCES Tasks(TaskID),
    FOREIGN KEY (CommentedBy) REFERENCES Users(UserID)
);
GO

-- =============================================
-- 7. جدول الاجتماعات
-- =============================================
CREATE TABLE Meetings (
    MeetingID INT PRIMARY KEY IDENTITY(1,1),
    MeetingTitle NVARCHAR(200) NOT NULL,
    MeetingDescription NVARCHAR(MAX),
    MeetingType NVARCHAR(100), -- إدارة، فريق، عملاء، موردين
    MeetingDate DATETIME NOT NULL,
    Duration INT, -- بالدقائق
    Location NVARCHAR(200),
    BranchID INT,
    OrganizerUserID INT NOT NULL,
    Status NVARCHAR(50) DEFAULT 'مجدول', -- مجدول، مكتمل، ملغي، مؤجل
    Agenda NVARCHAR(MAX),
    Minutes NVARCHAR(MAX), -- محضر الاجتماع
    Decisions NVARCHAR(MAX),
    IsRecurring BIT DEFAULT 0,
    RecurrencePattern NVARCHAR(100),
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME,
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (OrganizerUserID) REFERENCES Users(UserID)
);
GO

-- =============================================
-- 8. جدول حضور الاجتماعات
-- =============================================
CREATE TABLE MeetingAttendees (
    AttendeeID INT PRIMARY KEY IDENTITY(1,1),
    MeetingID INT NOT NULL,
    UserID INT NOT NULL,
    AttendanceStatus NVARCHAR(50) DEFAULT 'مدعو', -- مدعو، حاضر، غائب، معتذر
    ResponseDate DATETIME,
    Notes NVARCHAR(MAX),
    FOREIGN KEY (MeetingID) REFERENCES Meetings(MeetingID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

-- =============================================
-- 9. جدول تحليلات الذكاء الاصطناعي
-- =============================================
CREATE TABLE AIAnalytics (
    AnalyticsID INT PRIMARY KEY IDENTITY(1,1),
    AnalysisType NVARCHAR(100) NOT NULL, -- توقعات مبيعات، تحليل ربحية، تحسين مخزون
    AnalysisDate DATETIME DEFAULT GETDATE(),
    InputData NVARCHAR(MAX), -- JSON data
    OutputResults NVARCHAR(MAX), -- JSON results
    Confidence DECIMAL(5,2), -- نسبة الثقة في التحليل
    BranchID INT,
    Period NVARCHAR(50),
    Insights NVARCHAR(MAX), -- الرؤى والتوصيات
    Recommendations NVARCHAR(MAX),
    ModelVersion NVARCHAR(50),
    ProcessingTime INT, -- بالميلي ثانية
    CreatedBy INT NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID)
);
GO

-- =============================================
-- 10. جدول التوقعات المالية
-- =============================================
CREATE TABLE FinancialForecasts (
    ForecastID INT PRIMARY KEY IDENTITY(1,1),
    ForecastType NVARCHAR(100) NOT NULL, -- مبيعات، مصروفات، إيرادات، تدفقات نقدية
    ForecastPeriod NVARCHAR(50), -- شهري، ربع سنوي، سنوي
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    BranchID INT,
    ForecastedAmount DECIMAL(18,2) NOT NULL,
    ActualAmount DECIMAL(18,2),
    Variance DECIMAL(18,2),
    VariancePercentage DECIMAL(5,2),
    ConfidenceLevel DECIMAL(5,2), -- نسبة الثقة
    BasedOnAI BIT DEFAULT 0,
    Methodology NVARCHAR(200), -- الطريقة المستخدمة في التوقع
    Assumptions NVARCHAR(MAX),
    Notes NVARCHAR(MAX),
    CreatedBy INT NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedBy INT,
    ModifiedDate DATETIME,
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID)
);
GO

-- =============================================
-- 11. جدول السيناريوهات والمحاكاة
-- =============================================
CREATE TABLE Scenarios (
    ScenarioID INT PRIMARY KEY IDENTITY(1,1),
    ScenarioName NVARCHAR(200) NOT NULL,
    ScenarioDescription NVARCHAR(MAX),
    ScenarioType NVARCHAR(100), -- متفائل، واقعي، متشائم، مخصص
    BranchID INT,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    Parameters NVARCHAR(MAX), -- JSON للمعاملات
    ExpectedRevenue DECIMAL(18,2),
    ExpectedCosts DECIMAL(18,2),
    ExpectedProfit DECIMAL(18,2),
    ProbabilityPercentage DECIMAL(5,2),
    Impact NVARCHAR(MAX), -- التأثيرات المتوقعة
    RiskLevel NVARCHAR(50), -- منخفض، متوسط، عالي
    IsActive BIT DEFAULT 1,
    CreatedBy INT NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID)
);
GO

-- =============================================
-- 12. جدول تقييم المخاطر
-- =============================================
CREATE TABLE RiskAssessments (
    RiskID INT PRIMARY KEY IDENTITY(1,1),
    RiskName NVARCHAR(200) NOT NULL,
    RiskDescription NVARCHAR(MAX),
    RiskCategory NVARCHAR(100), -- مالي، تشغيلي، قانوني، سمعة، استراتيجي
    RiskLevel NVARCHAR(50), -- حرج، عالي، متوسط، منخفض
    Probability DECIMAL(5,2), -- احتمالية الحدوث %
    Impact DECIMAL(5,2), -- حجم التأثير
    RiskScore DECIMAL(5,2), -- Probability * Impact
    BranchID INT,
    IdentifiedDate DATE DEFAULT CAST(GETDATE() AS DATE),
    Owner INT, -- مسؤول عن إدارة المخاطر
    MitigationStrategy NVARCHAR(MAX),
    MitigationCost DECIMAL(18,2),
    Status NVARCHAR(50) DEFAULT 'نشط', -- نشط، مخفف، مغلق، تحقق
    ReviewDate DATE,
    Notes NVARCHAR(MAX),
    CreatedBy INT NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedBy INT,
    ModifiedDate DATETIME,
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (Owner) REFERENCES Users(UserID),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID)
);
GO

-- =============================================
-- 13. جدول المشاريع
-- =============================================
CREATE TABLE Projects (
    ProjectID INT PRIMARY KEY IDENTITY(1,1),
    ProjectName NVARCHAR(200) NOT NULL,
    ProjectDescription NVARCHAR(MAX),
    ProjectType NVARCHAR(100), -- داخلي، خارجي، تطوير
    BranchID INT,
    ProjectManagerID INT NOT NULL,
    StartDate DATE NOT NULL,
    PlannedEndDate DATE NOT NULL,
    ActualEndDate DATE,
    Budget DECIMAL(18,2),
    ActualCost DECIMAL(18,2) DEFAULT 0,
    Status NVARCHAR(50) DEFAULT 'مخطط', -- مخطط، قيد التنفيذ، معلق، مكتمل، ملغي
    CompletionPercentage DECIMAL(5,2) DEFAULT 0,
    Priority NVARCHAR(50), -- عالية، متوسطة، منخفضة
    Deliverables NVARCHAR(MAX),
    Milestones NVARCHAR(MAX), -- JSON
    Risks NVARCHAR(MAX),
    Notes NVARCHAR(MAX),
    CreatedBy INT NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedBy INT,
    ModifiedDate DATETIME,
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (ProjectManagerID) REFERENCES Users(UserID),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID)
);
GO

-- =============================================
-- 14. جدول أعضاء فريق المشروع
-- =============================================
CREATE TABLE ProjectTeam (
    ProjectTeamID INT PRIMARY KEY IDENTITY(1,1),
    ProjectID INT NOT NULL,
    UserID INT NOT NULL,
    Role NVARCHAR(100), -- مدير، عضو، مستشار، راعي
    AssignedDate DATE DEFAULT CAST(GETDATE() AS DATE),
    RemovedDate DATE,
    IsActive BIT DEFAULT 1,
    AllocatedHours DECIMAL(10,2),
    ActualHours DECIMAL(10,2) DEFAULT 0,
    Notes NVARCHAR(MAX),
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

-- =============================================
-- 15. جدول لوحة المعلومات Dashboard Widgets
-- =============================================
CREATE TABLE DashboardWidgets (
    WidgetID INT PRIMARY KEY IDENTITY(1,1),
    WidgetName NVARCHAR(200) NOT NULL,
    WidgetType NVARCHAR(100), -- Chart, KPI, Table, Alert, Calendar
    WidgetCategory NVARCHAR(100), -- مالي، مبيعات، مخزون، عمليات
    DataSource NVARCHAR(200), -- SQL View or Table name
    Configuration NVARCHAR(MAX), -- JSON config
    RefreshInterval INT, -- بالثواني
    IsActive BIT DEFAULT 1,
    DisplayOrder INT DEFAULT 0,
    RequiredPermission NVARCHAR(100),
    CreatedBy INT NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedBy INT,
    ModifiedDate DATETIME,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID)
);
GO

-- =============================================
-- 16. جدول تخصيص لوحة المعلومات للمستخدمين
-- =============================================
CREATE TABLE UserDashboards (
    UserDashboardID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT NOT NULL,
    WidgetID INT NOT NULL,
    Position NVARCHAR(50), -- Grid position: "row-col"
    Width INT DEFAULT 4, -- Grid columns (1-12)
    Height INT DEFAULT 4, -- Grid rows
    Settings NVARCHAR(MAX), -- JSON إعدادات خاصة للمستخدم
    IsVisible BIT DEFAULT 1,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (WidgetID) REFERENCES DashboardWidgets(WidgetID)
);
GO

-- =============================================
-- 17. جدول مراجعات الأداء
-- =============================================
CREATE TABLE PerformanceReviews (
    ReviewID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT NOT NULL,
    ReviewerID INT NOT NULL,
    ReviewPeriodStart DATE NOT NULL,
    ReviewPeriodEnd DATE NOT NULL,
    ReviewDate DATE NOT NULL,
    OverallRating DECIMAL(3,2), -- 1-5
    BranchID INT,
    ReviewType NVARCHAR(100), -- سنوي، نصف سنوي، ربع سنوي، تجريبي
    Strengths NVARCHAR(MAX),
    AreasForImprovement NVARCHAR(MAX),
    Goals NVARCHAR(MAX),
    TrainingNeeds NVARCHAR(MAX),
    Comments NVARCHAR(MAX),
    EmployeeComments NVARCHAR(MAX),
    Status NVARCHAR(50) DEFAULT 'مسودة', -- مسودة، قيد المراجعة، مكتملة
    ApprovedBy INT,
    ApprovedDate DATE,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME,
    FOREIGN KEY (EmployeeID) REFERENCES Users(UserID),
    FOREIGN KEY (ReviewerID) REFERENCES Users(UserID),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (ApprovedBy) REFERENCES Users(UserID)
);
GO

-- =============================================
-- 18. جدول معايير تقييم الأداء
-- =============================================
CREATE TABLE PerformanceCriteria (
    CriteriaID INT PRIMARY KEY IDENTITY(1,1),
    ReviewID INT NOT NULL,
    CriteriaName NVARCHAR(200) NOT NULL,
    CriteriaDescription NVARCHAR(MAX),
    Weight DECIMAL(5,2), -- الوزن النسبي %
    Rating DECIMAL(3,2), -- 1-5
    Comments NVARCHAR(MAX),
    FOREIGN KEY (ReviewID) REFERENCES PerformanceReviews(ReviewID)
);
GO

-- =============================================
-- VIEWS - إنشاء عروض تحليلية
-- =============================================

-- عرض ملخص مؤشرات الأداء
CREATE VIEW vw_KPISummary AS
SELECT 
    k.KPIID,
    k.KPIName,
    k.Category,
    k.MeasurementUnit,
    k.TargetValue,
    m.MeasurementDate,
    m.ActualValue,
    m.Variance,
    m.VariancePercentage,
    m.Status,
    b.BranchName,
    CASE 
        WHEN m.ActualValue >= k.TargetValue THEN 'محقق'
        WHEN m.ActualValue >= k.MinAcceptableValue THEN 'مقبول'
        ELSE 'غير مقبول'
    END AS PerformanceLevel
FROM KPIDefinitions k
LEFT JOIN KPIMeasurements m ON k.KPIID = m.KPIID
LEFT JOIN Branches b ON k.BranchID = b.BranchID
WHERE k.IsActive = 1;
GO

-- عرض ملخص المهام النشطة
CREATE VIEW vw_ActiveTasksSummary AS
SELECT 
    t.TaskID,
    t.TaskName,
    t.TaskType,
    t.Priority,
    t.Status,
    t.DueDate,
    t.CompletionPercentage,
    DATEDIFF(day, GETDATE(), t.DueDate) AS DaysUntilDue,
    CASE 
        WHEN t.DueDate < GETDATE() AND t.Status NOT IN ('مكتملة', 'ملغاة') THEN 'متأخرة'
        WHEN DATEDIFF(day, GETDATE(), t.DueDate) <= 3 AND t.Status NOT IN ('مكتملة', 'ملغاة') THEN 'عاجلة'
        ELSE 'عادية'
    END AS Urgency,
    assignee.FullName AS AssignedTo,
    assigner.FullName AS AssignedBy,
    b.BranchName
FROM Tasks t
INNER JOIN Users assignee ON t.AssignedToUserID = assignee.UserID
INNER JOIN Users assigner ON t.AssignedByUserID = assigner.UserID
LEFT JOIN Branches b ON t.BranchID = b.BranchID
WHERE t.Status NOT IN ('مكتملة', 'ملغاة');
GO

-- عرض ملخص التنبيهات النشطة
CREATE VIEW vw_ActiveAlerts AS
SELECT 
    a.AlertID,
    a.AlertType,
    a.AlertLevel,
    a.AlertTitle,
    a.AlertMessage,
    a.AlertDate,
    a.Priority,
    a.IsRead,
    a.IsActionTaken,
    u.FullName AS AssignedTo,
    b.BranchName,
    DATEDIFF(hour, a.AlertDate, GETDATE()) AS HoursSinceAlert
FROM SmartAlerts a
LEFT JOIN Users u ON a.AssignedToUserID = u.UserID
LEFT JOIN Branches b ON a.BranchID = b.BranchID
WHERE a.IsActionTaken = 0 
  AND (a.ExpiryDate IS NULL OR a.ExpiryDate > GETDATE());
GO

-- عرض ملخص المشاريع النشطة
CREATE VIEW vw_ActiveProjects AS
SELECT 
    p.ProjectID,
    p.ProjectName,
    p.ProjectType,
    p.Status,
    p.StartDate,
    p.PlannedEndDate,
    p.Budget,
    p.ActualCost,
    p.CompletionPercentage,
    (p.Budget - p.ActualCost) AS RemainingBudget,
    CASE 
        WHEN p.ActualCost > p.Budget THEN 'تجاوز الميزانية'
        WHEN (p.ActualCost / NULLIF(p.Budget, 0)) > 0.9 THEN 'قريب من الحد'
        ELSE 'ضمن الميزانية'
    END AS BudgetStatus,
    pm.FullName AS ProjectManager,
    b.BranchName,
    DATEDIFF(day, GETDATE(), p.PlannedEndDate) AS DaysRemaining
FROM Projects p
INNER JOIN Users pm ON p.ProjectManagerID = pm.UserID
LEFT JOIN Branches b ON p.BranchID = b.BranchID
WHERE p.Status IN ('قيد التنفيذ', 'مخطط');
GO

-- عرض تحليل المخاطر
CREATE VIEW vw_RiskAnalysis AS
SELECT 
    r.RiskID,
    r.RiskName,
    r.RiskCategory,
    r.RiskLevel,
    r.Probability,
    r.Impact,
    r.RiskScore,
    r.Status,
    r.MitigationStrategy,
    r.MitigationCost,
    owner.FullName AS RiskOwner,
    b.BranchName,
    CASE 
        WHEN r.RiskScore >= 75 THEN 'حرج'
        WHEN r.RiskScore >= 50 THEN 'عالي'
        WHEN r.RiskScore >= 25 THEN 'متوسط'
        ELSE 'منخفض'
    END AS RiskPriority
FROM RiskAssessments r
LEFT JOIN Users owner ON r.Owner = owner.UserID
LEFT JOIN Branches b ON r.BranchID = b.BranchID
WHERE r.Status = 'نشط';
GO

-- عرض ملخص الأهداف الاستراتيجية
CREATE VIEW vw_StrategicGoalsProgress AS
SELECT 
    g.GoalID,
    g.GoalName,
    g.GoalType,
    g.TargetValue,
    g.CurrentValue,
    g.CompletionPercentage,
    g.Status,
    g.Priority,
    g.StartDate,
    g.EndDate,
    DATEDIFF(day, g.StartDate, g.EndDate) AS TotalDays,
    DATEDIFF(day, g.StartDate, GETDATE()) AS DaysElapsed,
    DATEDIFF(day, GETDATE(), g.EndDate) AS DaysRemaining,
    CASE 
        WHEN g.CompletionPercentage >= 100 THEN 'مكتمل'
        WHEN g.CompletionPercentage >= 75 THEN 'على المسار'
        WHEN g.CompletionPercentage >= 50 THEN 'يحتاج متابعة'
        ELSE 'متأخر'
    END AS ProgressStatus,
    responsible.FullName AS ResponsiblePerson,
    b.BranchName
FROM StrategicGoals g
LEFT JOIN Users responsible ON g.ResponsibleUserID = responsible.UserID
LEFT JOIN Branches b ON g.BranchID = b.BranchID
WHERE g.Status = 'نشط';
GO

-- =============================================
-- STORED PROCEDURES - إجراءات مخزنة
-- =============================================

-- إجراء إضافة تنبيه ذكي
CREATE PROCEDURE sp_CreateSmartAlert
    @AlertType NVARCHAR(100),
    @AlertLevel NVARCHAR(50),
    @AlertTitle NVARCHAR(200),
    @AlertMessage NVARCHAR(MAX),
    @RelatedEntityType NVARCHAR(100) = NULL,
    @RelatedEntityID INT = NULL,
    @BranchID INT = NULL,
    @AssignedToUserID INT = NULL,
    @Priority INT = 3,
    @ExpiryDate DATETIME = NULL,
    @CreatedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO SmartAlerts (
        AlertType, AlertLevel, AlertTitle, AlertMessage,
        RelatedEntityType, RelatedEntityID, BranchID,
        AssignedToUserID, Priority, ExpiryDate, CreatedBy
    )
    VALUES (
        @AlertType, @AlertLevel, @AlertTitle, @AlertMessage,
        @RelatedEntityType, @RelatedEntityID, @BranchID,
        @AssignedToUserID, @Priority, @ExpiryDate, @CreatedBy
    );
    
    SELECT SCOPE_IDENTITY() AS AlertID;
END;
GO

-- إجراء تسجيل KPI
CREATE PROCEDURE sp_RecordKPIMeasurement
    @KPIID INT,
    @MeasurementDate DATE,
    @ActualValue DECIMAL(18,2),
    @BranchID INT = NULL,
    @Period NVARCHAR(50) = NULL,
    @Notes NVARCHAR(MAX) = NULL,
    @CreatedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @TargetValue DECIMAL(18,2);
    DECLARE @Variance DECIMAL(18,2);
    DECLARE @VariancePercentage DECIMAL(5,2);
    DECLARE @Status NVARCHAR(50);
    
    -- جلب القيمة المستهدفة
    SELECT @TargetValue = TargetValue
    FROM KPIDefinitions
    WHERE KPIID = @KPIID;
    
    -- حساب الانحراف
    SET @Variance = @ActualValue - @TargetValue;
    SET @VariancePercentage = CASE 
        WHEN @TargetValue = 0 THEN 0
        ELSE (@Variance / @TargetValue) * 100
    END;
    
    -- تحديد الحالة
    SET @Status = CASE 
        WHEN @ActualValue >= @TargetValue THEN N'فوق الهدف'
        WHEN @ActualValue >= (@TargetValue * 0.9) THEN N'ضمن الهدف'
        ELSE N'تحت الهدف'
    END;
    
    INSERT INTO KPIMeasurements (
        KPIID, MeasurementDate, ActualValue, TargetValue,
        Variance, VariancePercentage, BranchID, Period, Status, Notes, CreatedBy
    )
    VALUES (
        @KPIID, @MeasurementDate, @ActualValue, @TargetValue,
        @Variance, @VariancePercentage, @BranchID, @Period, @Status, @Notes, @CreatedBy
    );
    
    SELECT SCOPE_IDENTITY() AS MeasurementID;
END;
GO

-- إجراء تحديث تقدم الهدف
CREATE PROCEDURE sp_UpdateGoalProgress
    @GoalID INT,
    @CurrentValue DECIMAL(18,2),
    @ModifiedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @TargetValue DECIMAL(18,2);
    DECLARE @CompletionPercentage DECIMAL(5,2);
    DECLARE @Status NVARCHAR(50);
    
    SELECT @TargetValue = TargetValue
    FROM StrategicGoals
    WHERE GoalID = @GoalID;
    
    SET @CompletionPercentage = CASE 
        WHEN @TargetValue = 0 THEN 0
        ELSE (@CurrentValue / @TargetValue) * 100
    END;
    
    IF @CompletionPercentage > 100 SET @CompletionPercentage = 100;
    
    SET @Status = CASE 
        WHEN @CompletionPercentage >= 100 THEN N'مكتمل'
        WHEN @CompletionPercentage >= 75 THEN N'نشط'
        WHEN @CompletionPercentage >= 50 THEN N'نشط'
        ELSE N'متأخر'
    END;
    
    UPDATE StrategicGoals
    SET CurrentValue = @CurrentValue,
        CompletionPercentage = @CompletionPercentage,
        Status = @Status,
        ModifiedBy = @ModifiedBy,
        ModifiedDate = GETDATE()
    WHERE GoalID = @GoalID;
    
    -- إنشاء تنبيه إذا اكتمل الهدف
    IF @CompletionPercentage >= 100
    BEGIN
        INSERT INTO SmartAlerts (
            AlertType, AlertLevel, AlertTitle, AlertMessage,
            RelatedEntityType, RelatedEntityID, Priority, CreatedBy
        )
        SELECT 
            N'إنجاز', N'معلومات',
            N'تم إكمال هدف استراتيجي',
            N'تم إكمال الهدف: ' + GoalName,
            N'هدف', @GoalID, 1, @ModifiedBy
        FROM StrategicGoals
        WHERE GoalID = @GoalID;
    END;
END;
GO

-- إجراء تحديث حالة المهمة
CREATE PROCEDURE sp_UpdateTaskStatus
    @TaskID INT,
    @Status NVARCHAR(50),
    @CompletionPercentage INT = NULL,
    @ActualHours DECIMAL(10,2) = NULL,
    @Notes NVARCHAR(MAX) = NULL,
    @ModifiedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CompletionDate DATETIME = NULL;
    
    IF @Status IN (N'مكتملة')
    BEGIN
        SET @CompletionDate = GETDATE();
        IF @CompletionPercentage IS NULL SET @CompletionPercentage = 100;
    END;
    
    UPDATE Tasks
    SET Status = @Status,
        CompletionPercentage = ISNULL(@CompletionPercentage, CompletionPercentage),
        ActualHours = ISNULL(@ActualHours, ActualHours),
        CompletionDate = @CompletionDate,
        ModifiedDate = GETDATE()
    WHERE TaskID = @TaskID;
    
    -- إضافة تعليق إذا كان هناك ملاحظات
    IF @Notes IS NOT NULL
    BEGIN
        INSERT INTO TaskComments (TaskID, CommentText, CommentedBy)
        VALUES (@TaskID, @Notes, @ModifiedBy);
    END;
    
    -- إنشاء تنبيه للمسند إليه
    IF @Status = N'مكتملة'
    BEGIN
        INSERT INTO SmartAlerts (
            AlertType, AlertLevel, AlertTitle, AlertMessage,
            RelatedEntityType, RelatedEntityID, AssignedToUserID, Priority, CreatedBy
        )
        SELECT 
            N'مهمة', N'معلومات',
            N'تم إكمال مهمة',
            N'تم إكمال المهمة: ' + TaskName,
            N'مهمة', @TaskID, AssignedByUserID, 1, @ModifiedBy
        FROM Tasks
        WHERE TaskID = @TaskID;
    END;
END;
GO

-- =============================================
-- INDEXES - فهرسة لتحسين الأداء
-- =============================================

CREATE INDEX IDX_KPIMeasurements_Date ON KPIMeasurements(MeasurementDate);
CREATE INDEX IDX_KPIMeasurements_Branch ON KPIMeasurements(BranchID);
CREATE INDEX IDX_Tasks_Status ON Tasks(Status);
CREATE INDEX IDX_Tasks_DueDate ON Tasks(DueDate);
CREATE INDEX IDX_Tasks_Assigned ON Tasks(AssignedToUserID);
CREATE INDEX IDX_SmartAlerts_Level ON SmartAlerts(AlertLevel, IsActionTaken);
CREATE INDEX IDX_SmartAlerts_Date ON SmartAlerts(AlertDate);
CREATE INDEX IDX_Projects_Status ON Projects(Status);
CREATE INDEX IDX_StrategicGoals_Status ON StrategicGoals(Status);
CREATE INDEX IDX_RiskAssessments_Level ON RiskAssessments(RiskLevel, Status);
CREATE INDEX IDX_PerformanceReviews_Employee ON PerformanceReviews(EmployeeID, ReviewDate);
GO

-- =============================================
-- تعليق نهائي
-- =============================================
PRINT N'تم إنشاء Management Module بنجاح!';
PRINT N'يتضمن النظام:';
PRINT N'- 18 جدول إداري متكامل';
PRINT N'- 6 عروض تحليلية';
PRINT N'- 4 إجراءات مخزنة';
PRINT N'- 11 فهرس لتحسين الأداء';
PRINT N'';
PRINT N'المزايا الرئيسية:';
PRINT N'✓ إدارة الأهداف الاستراتيجية';
PRINT N'✓ مؤشرات الأداء الرئيسية (KPIs)';
PRINT N'✓ نظام تنبيهات ذكي متقدم';
PRINT N'✓ إدارة المهام والمشاريع';
PRINT N'✓ تقييم وإدارة المخاطر';
PRINT N'✓ اجتماعات ومحاضر';
PRINT N'✓ تحليلات ذكاء اصطناعي';
PRINT N'✓ توقعات مالية وسيناريوهات';
PRINT N'✓ لوحة معلومات تفاعلية';
PRINT N'✓ مراجعات أداء الموظفين';
PRINT N'';
PRINT N'تم إكمال Management Module - جاهز للاستخدام ✓';
GO
