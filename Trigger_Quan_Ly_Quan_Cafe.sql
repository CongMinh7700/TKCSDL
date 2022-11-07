Use Quan_Ly_Quan_Cafe_Phuc_Long
Go
---I.Nội Thủ Tục(Stored Procedure)
----1.Hiển Thị Danh Sách Đồ Uống Theo Loại---
--------------------------------------------------
Create Proc DS_Theo_Loai
AS
Begin
 Select Loai_ThucUong.Ten_Loai Loai ,Thuc_Uong.Ten_ThucUong ThucUong,Thuc_Uong.Gia Gia
 From Loai_ThucUong,Thuc_Uong
 Where Thuc_Uong.ID_Loai = Loai_ThucUong.ID_Loai
End
---Test
Exec DS_Theo_Loai 
---2.Lấy Thông Tin Tài Khoản Theo Tên Đăng Nhap---
Drop Proc Get_Account

Create Proc  Get_Account
@Ten_DN nvarchar(20)
AS 
Begin
 Select * From DangNhap Where Ten_DN=@Ten_DN
End
---Test
Exec Get_Account  @Ten_DN=N'Admin'

-------------------------------------------------------------
---II.Trigger---------------------
----1.Cập nhật Chi Tiết Hóa Đơn -----
Drop Trigger Bill_TG

Create Trigger Bill_TG 
On Chi_Tiet_Bill After Update,Insert
As 
Begin 
  Declare @ID_Bill nvarchar(20)
  Declare @ID_Ban int
  Declare @Count INT =1
  Select @ID_Bill=ID_Bill from inserted 
  Select @ID_Ban =b.ID_Ban From Bill AS b Where ID_Bill=@ID_Bill
  Select @Count =count(*) from Chi_Tiet_Bill Where ID_Bill=@ID_Bill--And a.ID_Ban=b.ID_Ban
 IF(@Count > 0) 
 Begin 
  Print @ID_Bill
  Print @ID_Ban
  Print @Count
  Update Ban SET Thong_tin=N'Có Người' Where ID_Ban=@ID_Ban
 End
Else 
 Begin 
  Print @ID_Bill
  Print @ID_Ban
  Print @Count
  Update Ban SET Thong_tin=N'Trống' Where ID_Ban=@ID_Ban
 End
End

 ---2.Đảm Bảo Giá Thức Uống >0---
Create Trigger Gia_Lon_Hon_0
On Thuc_Uong For Insert,Update
AS
Begin
 Declare @Gia int
 Select @Gia=Gia From inserted
If(@Gia<=0)
 Begin
  Print N'Giá của thức uống phải lớn hơn 0'
  Rollback Tran
 End
End
 ---3.Khi mua hàng phải mua ít nhất 1 sản phẩm---
 Drop trigger Mua_SP
Create Trigger Mua_SP
On Chi_Tiet_Bill for Insert, Update
AS
Begin
 Declare @ID_Bill nvarchar(20)
 Declare @So_Luong int
 Select @ID_Bill=ID_Bill,@So_Luong=So_Luong from Inserted
 IF(@So_Luong<1)
 Begin
  Print N'Mua ít nhất một sản phẩm'
  Rollback Tran
 End
End
---Test
 Insert Into Chi_Tiet_Bill Values(N'B01',N'T102',2,140000)--70
 ---4.Ngày bán hàng lớn hơn ngày nhân viên vào làm---
 Drop Trigger  NgayBH_Lon_Hon_NgayLam

Create trigger NgayBH_Lon_Hon_NgayLam
On Bill After Insert
AS  
Begin
If(Exists (Select *from Inserted i Join Nhan_Vien nv on i.ID_NV=nv.ID_NV 
              Where i.DateCheckOut <nv.NgayLam))
  Begin
	Rollback Tran
	Print N'Ngày hóa đơn phải lớn hơn ngày vào làm'
  End
End
---Test
Insert Into Bill Values(N'B12',N'NV01',N'KH10',23,'20221015','2022-10-15',20000,20,15000);
---5.Tự Động Thành Tiền Trong Chi Tiết Hóa Đơn---
Drop Trigger Thanh_Tien

Create Trigger Thanh_Tien
On Chi_Tiet_Bill
	For Insert 
	AS
Begin
	Update Chi_Tiet_Bill
	Set ThanhTien=Gia*So_Luong+(Select Sum(ThanhTien)From Inserted AS i Where i.ID_Bill=Chi_Tiet_Bill.ID_Bill)
	Where Chi_Tiet_Bill.ID_Bill in(Select ID_Bill	From inserted)
End
---Test
	Insert Into Chi_Tiet_Bill Values(N'B01',N'T704',1,27000,0)--27
	Select * From Chi_Tiet_Bill Where ID_Bill=N'B01'
----6.Tự Thiết lập giới tính nhân viên thành chữ---
Drop Trigger GT_Nhan_Vien

Create Trigger GT_Nhan_Vien
On Nhan_Vien 
For Insert ,Update
AS
 Begin
   Declare @Ten_NV nvarchar(100)
   Declare @Gioi_Tinh nvarchar(20)
   Select @Ten_NV=Ten_NV From inserted
   Select @Gioi_Tinh=Gioi_Tinh   From inserted

 If(@Gioi_Tinh=N'1')
Begin
  Update Nhan_Vien
  SET Gioi_Tinh=N'Nam' Where Ten_NV=@Ten_NV
  End
 Else If(@Gioi_Tinh=N'0')
Begin 
  Update Nhan_Vien
  Set Gioi_Tinh=N'Nu' Where Ten_NV=@Ten_NV
End
End
---Test
  Select * from Nhan_Vien
---7.Tự Động Tính Tổng Tiền Trong Hóa Đơn----
 Drop Trigger Them_Bill
 Create Trigger Them_Bill
On Chi_Tiet_Bill 
After Insert
AS
Begin
  Declare @So_Luong int
  Declare @Gia int
  Declare @Thanh_Tien int 
  Select @So_Luong=So_Luong,@Gia=Gia 
  from inserted  Where ID_Bill=inserted.ID_Bill
  Set @Thanh_Tien=@So_Luong*@Gia
  Update Bill 
  Set Tong_Tien=(Tong_Tien+@Thanh_Tien)-(Diem_TL*1000)
  from Bill Join inserted On Bill.ID_Bill=inserted.ID_Bill 
End

 ---8.Tự Động Thành Tiền Trong Chi Tiết Lương Nhân Viên---
 Drop Trigger Chi_Tiet_Luong

 Create Trigger Chi_Tiet_Luong 
 On Chi_Tiet_Luong_Nhan_Vien
 After Insert,Update
 AS
Begin
  Declare @ID_Ca nvarchar(20)
  Select @ID_Ca=c.ID_Ca
  From inserted join Chi_Tiet_Luong_Nhan_Vien AS c On c.ID_Ca=inserted.ID_Ca 
If(@ID_Ca=N'C04')
 Begin
  Update Chi_Tiet_Luong_Nhan_Vien
  Set Thanh_Tien=Tong_Ca_Lam*200000
  Where ID_Ca=@ID_Ca
 End
Else
  Begin
   Update Chi_Tiet_Luong_Nhan_Vien
   Set Thanh_Tien=Tong_Ca_Lam*100000
   Where ID_Ca=@ID_Ca
  End
End
---Test

Delete From Chi_Tiet_Luong_Nhan_Vien 

Select * From Chi_Tiet_Luong_Nhan_Vien 
---9.Xóa Chi Tiết Hóa Đơn---
Drop Trigger Xoa_Chi_Tiet_Bill

Create Trigger Xoa_Chi_Tiet_Bill
On Chi_Tiet_Bill
After Delete
AS
Begin
   Declare @ID_Bill nvarchar(20)
   Select @ID_Bill=ID_Bill From deleted Where ID_Bill=deleted.ID_Bill
   Delete From Chi_Tiet_Bill  
   Where ID_Bill=@ID_Bill
End
---Test
Delete Bill  Where ID_Bill=N'B04'
Select * From Chi_Tiet_Bill
Select * From Bill