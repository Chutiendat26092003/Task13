CREATE DATABASE Lab12_CityGroup
GO

USE Lab12_CityGroup
GO

CREATE TABLE Employee
(
    EmployeeID INT PRIMARY KEY,
	Name varchar(100),
	Tel char(11),
	Email varchar(30)
)
GO

CREATE TABLE Project
(
    ProjectID INT PRIMARY KEY,
	ProjectName varchar(30),
	StartDate DATETIME,
	EndDate DATETIME,
	PeriodP INT,
	Cost MONEY
)
GO

CREATE TABLE Group12
( 
    GroupID INT PRIMARY KEY,
	GroupName varchar(30),
	LeaderID INT FOREIGN KEY REFERENCES dbo.Employee(EmployeeID),
    ProjectID INT FOREIGN KEY REFERENCES dbo.Project(ProjectID)
)
GO

CREATE TABLE GroupDetail
(
    GroupID INT FOREIGN KEY REFERENCES dbo.Group12(GroupID),
	EmployeeID INT FOREIGN KEY REFERENCES dbo.Employee(EmployeeID),
    Status CHAR(20) 
)
GO


--2
INSERT INTO dbo.Employee VALUES ( 1,  'Jack A', '0922222222', 'jacka@gamil.com'),
                                ( 2,  'Jack B', '0922223333', 'jackb@gamil.com'),
								( 3,  'Jack C', '0922225555', 'jackc@gamil.com'),
								( 4,  'Jack D', '0922226666', 'jackd@gamil.com'),
								( 5,  'Jack E', '0922224442', 'jacke@gamil.com'),
								( 6,  'Jack F', '0922224567', 'jackf@gamil.com'),
								( 7,  'Jack G', '0922223456', 'jackg@gamil.com'),
								( 8,  'Jack H', '0922227777', 'jackh@gamil.com'),
								( 9,  'Jack I', '0922299999', 'jacki@gamil.com'),
								( 10,  'Jack K', '0333332222', 'jackK@gamil.com')

INSERT INTO dbo.Project VALUES ( 555, 'Du An 1', '2022-1-19','2022-3-19', 3, 1000000 ),
                               ( 556, 'Du An 2', '2022-1-19','2022-7-11', 6, 2200000 )

INSERT INTO dbo.Group12 VALUES ( 1000, 'ABCDE', 4, 556 ),
                               ( 1001, 'FGHIK', 8, 555 )
                               

INSERT INTO dbo.GroupDetail VALUES ( 1000, 1, '0'),
                                   ( 1000, 2, '1'),
								   ( 1000, 3, '1'),
								   ( 1000, 4, '1'),
								   ( 1000, 5, '2'),
								   ( 1001, 6, '1'),
								   ( 1001, 7, '2'),
								   ( 1001, 8, '1'),
								   ( 1001, 9, '1'),
								   ( 1001, 10, '0')



SELECT * FROM Employee
SELECT * FROM Project
SELECT * FROM Group12
SELECT * FROM GroupDetail

--3
--Hiển thị thông tin của tất cả nhân viên
SELECT * FROM Employee

--Liệt kê danh sách nhân viên đang làm dự án “Du An 1”
SELECT Employee.EmployeeID, Name, Tel, Email, ProjectName FROM dbo.Employee
INNER JOIN dbo.GroupDetail ON GroupDetail.EmployeeID = Employee.EmployeeID
INNER JOIN dbo.Group12 ON Group12.GroupID = GroupDetail.GroupID
INNER JOIN dbo.Project ON Project.ProjectID = Group12.ProjectID
WHERE ProjectName LIKE 'Du An 1'

-- Thống kê số lượng nhân viên đang làm việc tại mỗi nhóm
SELECT GroupID, COUNT(EmployeeID) AS SoluongNV
FROM dbo.GroupDetail
GROUP BY GroupID

-- Liệt kê thông tin cá nhân của các trưởng nhóm
SELECT EmployeeID, Name, Tel, Email
FROM  dbo.Employee
WHERE EmployeeID IN
(SELECT LeaderID FROM dbo.Group12)

-- Liệt kê thông tin về nhóm và nhân viên đang làm các dự án có ngày bắt đầu làm trước ngày 12/10/2010
SELECT Employee.EmployeeID, Name, Tel, Email, ProjectName FROM dbo.Employee
INNER JOIN dbo.GroupDetail ON GroupDetail.EmployeeID = Employee.EmployeeID
INNER JOIN dbo.Group12 ON Group12.GroupID = GroupDetail.GroupID
INNER JOIN dbo.Project ON Project.ProjectID = Group12.ProjectID
WHERE StartDate < '2010-10-12'

-- Liệt kê tất cả nhân viên dự kiến sẽ được phân vào các nhóm làm việc
SELECT * FROM dbo.Employee
WHERE EmployeeID IN
(SELECT EmployeeID FROM dbo.GroupDetail )

-- Liệt kê tất cả thông tin về nhân viên, nhóm làm việc, dự án của những dự án đã hoàn thành
SELECT * FROM dbo.Employee
INNER JOIN dbo.GroupDetail ON GroupDetail.EmployeeID = Employee.EmployeeID
INNER JOIN dbo.Group12 ON Group12.GroupID = GroupDetail.GroupID
INNER JOIN dbo.Project ON Project.ProjectID = Group12.ProjectID
WHERE EndDate < GETDATE()

--4
-- Ngày hoàn thành dự án phải sau ngày bắt đầu dự án
ALTER TABLE dbo.Project
     ADD CONSTRAINT CK_Date CHECK(EndDate > StartDate)

-- Trường tên nhân viên không được null
ALTER TABLE dbo.Employee
     ALTER COLUMN Name varchar(100) NOT NULL

-- Trường trạng thái làm việc chỉ nhận một trong 3 giá trị: inprogress, pending, done
ALTER TABLE dbo.GroupDetail
     ADD CONSTRAINT CK_Sta CHECK(Status = '0' OR Status = '1' OR Status = '2')

--Trường giá trị dự án phải lớn hơn 1000
ALTER TABLE dbo.Project
     ADD CONSTRAINT CK_Cost CHECK(Cost > 1000)

-- Trưởng nhóm làm việc phải là nhân viên

-- Trường điện thoại của nhân viên chỉ được nhập số và phải bắt đầu bằng số 0 
ALTER TABLE dbo.Employee 
     ADD CHECK(ISNUMERIC(Tel) = 1 AND  LEFT(Tel, 1)= '0')

-- 5
-- Tăng giá thêm 10% của các dự án có tổng giá trị nhỏ hơn 2000 
CREATE PROCEDURE TangGiaThem
   @Cost float = 0.1
AS 
BEGIN 
   IF (dbo.Project.Cost > 2000)
   SELECT * FROM dbo.Project
   WHERE Cost =  @Cost*Cost 
END 

-- Hiển thị thông tin về dự án sắp được thực hiện
CREATE PROCEDURE DASapTH
    @date datetime 
AS 
SELECT * FROM dbo.Project
WHERE StartDate > @date 

EXECUTE DASapTH '2022-1-13'

-- Hiển thị tất cả các thông tin liên quan về các dự án đã hoàn thành
CREATE PROCEDURE DADaHT
    @date datetime 
AS 
SELECT * FROM dbo.Project
WHERE EndDate < @date 

EXECUTE DADaHT '2022-1-13'

--6
-- Tạo chỉ mục duy nhất tên là IX_Group trên 2 trường GroupID và EmployeeID của bảng GroupDetail
CREATE UNIQUE INDEX IX_Group ON GroupDetail(GroupID, EmployeeID)

-- Tạo chỉ mục tên là IX_Project trên trường ProjectName của bảng Project gồm các trường StartDate và EndDate
CREATE INDEX IX_Project ON Project(ProjectName)

--7
-- Liệt kê thông tin về nhân viên, nhóm làm việc có dự án đang thực hiện
CREATE VIEW ThongTin 
AS 
SELECT Employee.EmployeeID, Name, Tel, Email, ProjectName, GroupName FROM dbo.Employee
INNER JOIN dbo.GroupDetail ON GroupDetail.EmployeeID = Employee.EmployeeID
INNER JOIN dbo.Group12 ON Group12.GroupID = GroupDetail.GroupID
INNER JOIN dbo.Project ON Project.ProjectID = Group12.ProjectID
WHERE StartDate < GETDATE() AND EndDate > GETDATE()

-- Tạo khung nhìn chứa các dữ liệu sau: tên Nhân viên, tên Nhóm, tên Dự án và trạng thái làm việc của Nhân viên.
CREATE VIEW ThongTin 
AS 
SELECT Name, ProjectName, GroupName, Status FROM dbo.Employee
INNER JOIN dbo.GroupDetail ON GroupDetail.EmployeeID = Employee.EmployeeID
INNER JOIN dbo.Group12 ON Group12.GroupID = GroupDetail.GroupID
INNER JOIN dbo.Project ON Project.ProjectID = Group12.ProjectID

--8
-- Khi trường EndDate được cập nhật thì tự động tính toán tổng thời gian hoàn thành dự án và cập nhật vào trường Period


--Đảm bảo rằng khi xóa một Group thì tất cả những bản ghi có liên quan trong bảng GroupDetail cũng sẽ bị xóa theo.
CREATE TRIGGER DeleteGroup
ON Group12
INSTEAD OF DELETE 
AS 
      BEGIN 
	      DELETE FROM dbo.GroupDetail WHERE GroupID IN (SELECT GroupID FROM deleted)
	  END 
GO

-- Không cho phép chèn 2 nhóm có cùng tên vào trong bảng Group.
CREATE TRIGGER InsertGroup 
ON Group12
FOR INSERT
AS 
    BEGIN 
      IF EXISTS(SELECT * FROM inserted WHERE Inserted.GroupName != Group12.GroupName)  -- kiểm tra 
	  BEGIN 
	      PRINT 'Ten nhom bi trung'
		  ROLLBACK TRANSACTION -- hoàn trả dữ liệu --> qua trở lại ban đầu 
	  END 
	END 
GO