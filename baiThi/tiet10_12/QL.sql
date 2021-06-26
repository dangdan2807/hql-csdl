Use master
go

use AdventureWorks2008R2
go

-- 1.b. kiểm tra sau phi phần quyền
select * FROM Purchasing.PurchaseOrderDetail
GO

-- 1.c. nhân viên QL xem lại kết quả NV1 và NV2 đã làm
SELECT * 
from Purchasing.PurchaseOrderDetail
WHERE PurchaseOrderDetailID = 651

SELECT * 
from Purchasing.PurchaseOrderDetail
WHERE PurchaseOrderDetailID = 195

-- 1d.Ai có thể xem dữ liệu bảng Purchasing.Vendor? Giải thích. Viết lệnh kiểm tra quyền trên
-- cửa sổ query của user tương ứng

SELECT * 
FROM Purchasing.ProductVendor

-- 1.e. kiểm tra quyền truy cập QL
select * FROM Purchasing.PurchaseOrderDetail
GO