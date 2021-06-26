--Bài tập về Single Transaction (bổ sung)
--Câu 1
-- Tạo một transaction giảm giá (Listprice) mặt hàng xe đạp có mã 780 trong bảng Product xuống 10%
-- nếu tổng trị giá tồn kho của mặt hàng này sau khi giảm giá KHONG thấp hơn 60% so với tổng trị giá tồn kho với đơn giá ban đầu.
(table Production.productInventory)
-- (ngược lại => không thì cancel giảm giá)

begin transaction
		lenh 1
		lenh 2
		if .... true 
			commit
		else  
			rollback
	
--Câu 2
--Tạo một transaction xuất bán một mặt hàng xe đạp nếu số lượng xuất bán không vượt quá số lượng tồn kho 
--của mặt hàng đó trong kho có mã LocationID = 7 









