Use master
go

use AdventureWorks2008R2
go

-- 1.b. kiểm tra sau phi phần quyền
select * FROM Purchasing.PurchaseOrderDetail
GO

-- 1.c. Nhân viên NV1 sửa ModifiedDate của đơn hàng có PurchaseOrderDetailID= 651 thành getdate()
update Purchasing.PurchaseOrderDetail
set ModifiedDate = GETDATE()
where PurchaseOrderDetailID = 651

-- 1d.Ai có thể xem dữ liệu bảng Purchasing.Vendor? Giải thích. Viết lệnh kiểm tra quyền trên
-- cửa sổ query của user tương ứng

SELECT * 
FROM Purchasing.ProductVendor

-- 1.e. kiểm tra quyền truy cập NV1
select * FROM Purchasing.PurchaseOrderDetail
GO
