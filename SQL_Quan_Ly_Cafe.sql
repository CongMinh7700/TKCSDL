Create Database Quan_Ly_Quan_Cafe_Phuc_Long
Go
Use Quan_Ly_Quan_Cafe_Phuc_Long
Go

---Bảng Ca Làm Việc---

Create Table Ca_Lam_Viec(
ID_Ca nvarchar(20) Primary Key,
Ten_Ca nvarchar(20),
Gio_Bat_Dau Time(0),
Gio_KetThuc Time(0),
So_Tien Int
);
Go

---------------------------------------------------------------
---Bảng Loại Thức Uống---

Create Table Loai_ThucUong(
ID_Loai nvarchar(20)  Primary Key,
Ten_Loai nvarchar(100),
);
Go

---------------------------------------------------------------
---Bảng Khu Vực---

Create Table Khu_Vuc(
ID_KV nvarchar(20) Primary Key,
Ten_KV nvarchar(50),
Trang_Thai nvarchar(20),
);

---------------------------------------------------------------
---Bảng Chức Vụ---

Create Table Chuc_Vu(
ID_CV nvarchar(20) Primary Key,
Ten_CV nvarchar(50),
);
Go

---------------------------------------------------------------
---Bảng Thức Uống---

Create Table Thuc_Uong(
ID_ThucUong nvarchar(20) Primary Key,
Ten_ThucUong nvarchar(100),
ID_Loai nvarchar(20),
Gia float,
Foreign Key (ID_Loai) References Loai_ThucUong(ID_Loai)
);
Go

--------------------------------------------------------------------
---Bảng Bàn---

Create Table Ban(
ID_Ban int  Primary Key,
ID_KV nvarchar(20),
Ban_So nvarchar(100),
Thong_tin nvarchar(50),
foreign key (ID_KV) references Khu_Vuc(ID_KV),
);
Go

---Bảng Nhân Viên---

Create Table Nhan_Vien(
ID_NV nvarchar(20) Primary Key,
Ten_NV nvarchar(100),
Dia_Chi nvarchar(100),
Gioi_Tinh nvarchar(20),
ID_CV nvarchar(20),
NgayLam Date,
CMND int,
SDT nvarchar(13),
Mat_Khau nvarchar(20),
foreign key (ID_CV) references Chuc_Vu(ID_CV),
);
Go

---Bảng Chi Tiết Lương Nhân Viên-----
Create Table Chi_Tiet_Luong_Nhan_Vien(
ID_Ca nvarchar(20) ,
ID_NV nvarchar(20) ,
Tong_Ca_Lam int,
Thanh_Tien int,
foreign key (ID_Ca) references Ca_Lam_Viec(ID_Ca),
foreign key (ID_NV) references Nhan_Vien(ID_NV),
);
Go
------------------------------------------------------
---Bảng Khách Hàng---

Create Table Khach_Hang(
ID_KH nvarchar(20) Primary Key,
Ten_KH nvarchar(100),
Dia_Chi nvarchar(100),
Gioi_Tinh bit,
SDT nvarchar(13),
Diem_Tich_Luy int,
);
Go

---------------------------------------------------------------
---Bảng Đăng Nhập---

Create Table DangNhap(
Ten_DN nvarchar (20) Primary Key,
Mat_Khau nvarchar(20),
ID_NV nvarchar(20),
Quyen nvarchar(30),
Foreign Key (ID_NV) References Nhan_Vien(ID_NV),
);
---------------------------------------------------------------
---Bảng Hóa Đơn---

Create Table Bill(
ID_Bill nvarchar(20)  Primary Key,
ID_NV nvarchar(20),
ID_KH nvarchar(20),
ID_Ban int ,
DateCheckIn Date,
DateCheckOut Date,
Giam_Gia int,
Diem_TL int,
Tong_Tien int ,
foreign key (ID_Ban) references Ban(ID_Ban),
foreign key (ID_NV) references Nhan_Vien(ID_NV),
foreign key (ID_KH) references Khach_Hang(ID_KH)
);
Go
---------------------------------------------------------------
---Bảng Chi Tiết Hóa Đơn---

Create Table Chi_Tiet_Bill(				
ID_Bill nvarchar(20),
ID_ThucUong nvarchar(20),
So_Luong int,
Gia int,
ThanhTien int,
foreign key (ID_Bill) references Bill(ID_Bill),
foreign key (ID_ThucUong) references Thuc_Uong(ID_ThucUong),
);
Go
---------------------------------------------------------------


