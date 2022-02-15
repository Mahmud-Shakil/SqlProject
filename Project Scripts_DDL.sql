

-- Answer to question no 1& 2
use master
go 

if DB_ID('SaleDB') is not null
Drop database SaleDB 
go 


Create Database SaleDB 
on 
(
	Name = 'SaleDB_Data_1', 
	Filename = 'D:\Shakil\Project\SaleDB_Data_1.mdf', 
	Size = 25 MB , 
	Maxsize = 100 MB, 
	Filegrowth = 5%


) log on 
(
	Name = 'SaleDB_log_1', 
	Filename = 'D:\Shakil\Project\SaleDB_log_1.ldf', 
	Size = 2 MB , 
	Maxsize = 25 MB, 
	Filegrowth = 1%

)

go 

use SaleDB
go 
Create table CustomerAddress 
(
	AddressID int primary key  not null, 
	RoadNoandName varchar (30), 
	City varchar (15)

)
insert into CustomerAddress values 
(1, '21 Cumpus RD' , 'Boston' ), (2, '890 Park Av', 'Denver' ), (3,'28 Rock Av', 'Denver')

go 


Create Table CustomerInfo
(
	CustomerID int primary key  not null, 
	CustomerFName Varchar (15), 
	CustomerLName varchar (15),
	AddressId int references Customeraddress(AddressId)
)

insert into CustomerInfo 
values (101, 'Roger' ,'Burks', 1), (102, 'Alan', 'Smith', 2),
		(103, 'Evan' ,'Wilson', 3)

Go 

use saleDB 
go 

create table Supplier 
(
	SupplierID int primary key Nonclustered not null, 
	SupplierName varchar (30), 
	SupplierPhoneNo varchar (10)

)

insert into Supplier values 
(201, 'Microsoft', '(800)13232'), (202, 'Sony', '(800)64644')

go 

Create Table Product 
(
	ProductID int primary key not null, 
	ProductName varchar (30),
	SupplierID int references Supplier(SupplierID)

)

insert into Product values 
(301, 'Xbox One', 201), (302, 'Play Station 4', 202 ), (303, 'PS Vita', 202)

go 

Create table Invoices 
(
	CustomerID int references Customerinfo(CustomerID),  
	ProductID int references Product(ProductID) ,
	Primary key (CustomerID, ProductID),
	UnitPrice decimal, 
	Quantity int

)

insert into Invoices Values 
(101, 301, 20000, 2), (102, 302, 2400, 3), (103, 301, 20000, 3 ), (103, 303, 16000, 2 ), (102, 301, 20000, 2)

go 

--Answer to question no 9 & 16 
use SaleDB
go 
create Proc SPInsert_Update_Delete_Output 
@Tasktype varchar (10), 
@Cid int, 
@Pid int, 
@Uprice decimal, 
@Quantity int,
@CustomerCount int output
as 
begin
if @Tasktype = 'Select'
begin 
select * from Invoices
end 

if @Tasktype = 'insert'

begin try 
begin tran 
insert into Invoices values (@cid, @pid, @Uprice, @Quantity) 
commit tran 
 
end try 
begin catch 

select ERROR_MESSAGE() as 'Error Message', 
Error_Number () as 'Error Number' 
Rollback  tran 
end catch 

if @Tasktype = 'Update'

begin

update Invoices 
set 
CustomerID = @Cid, ProductID = @Pid , UnitPrice = @Uprice, Quantity = @Quantity 
where CustomerID = @Cid
end 

if @Tasktype = 'Delete' 
begin try 
begin tran 
delete from Invoices where CustomerID = @Cid
commit tran 
end try 
begin catch
select ERROR_MESSAGE() as 'Error Message', 
Error_Number () as 'Error Number'
rollback tran 
end catch 
if @Tasktype = 'Count'
begin
select @CustomerCount = Count (Customerid) from Invoices
end 
end 



--Answer to question no 10
create clustered index ix_Supplier_Suppliername 
on Supplier(Suppliername)

--Justify
--Exec sp_helpindex Supplier 

go 

-- Answer to question no 11
use SaleDB
if object_ID ('FnlinewiseTotalAmount') is not null 
drop function FnlinewiseTotalAmount
go 
create function FnlinewiseTotalAmount (@Productid int) 
Returns money
Begin 
Declare @totalAmount int 
select @totalAmount = UnitPrice * Quantity  from Invoices where ProductID = @Productid
return @TotalAmount
End 
go 

-- Justify
use SaleDB
go 
--select dbo.FnlinewiseTotalAmount(303)


--- Answer to question no 12
if object_Id('Invoices_Customerinfo_Product_Supplier') is not null
Drop View Invoices_Customerinfo_Product_Supplier
use saleDB 
go 
create view Invoices_Customerinfo_Product_Supplier
as 
select CI.CustomerID, Ci.CustomerFName+ ' '+ Ci.CustomerLName as [Customer Name],
		p.ProductName , S.SupplierName, ca.RoadNoandName+ ','+ Ca.City as [Shipping Address] , UnitPrice, Quantity

from Invoices as I join CustomerInfo as CI
on i.CustomerID = ci.CustomerID join Product as P 
on i.ProductID = p.ProductID join Supplier as S 
on p.SupplierID = s.SupplierID join CustomerAddress as Ca 
on ci.AddressId = ca.AddressID

go 
-- Justify 
use SaleDB
go 
--select * from dbo.Invoices_Customerinfo_Product_Supplier 

-- Answer to question no 13 

use SaleDB 
go 
if OBJECT_ID('TrInvoice_Insert_Update_Delete') is not null 
drop trigger TrInvoice_Insert_Update_Delete
go 
create trigger TrInvoice_Insert_Update_Delete
on invoices
after insert , update, Delete
as 
begin 
declare 
@Cid int, 
@Pid int, 
@Uprice Decimal, 
@Quantity int 
select * from inserted
begin 
begin try 
begin tran
insert into Invoices values (@Cid, @pid, @Uprice, @Quantity)
update Invoices set Quantity = @Quantity where CustomerID = @Cid
delete from Invoices where ProductID =@Pid
commit tran 
end try 
begin catch 
begin tran 
select ERROR_MESSAGE() as 'Error_Message', 
ERROR_NUMBER() as 'Error Number', 
ERROR_LINE () as 'Error Line',
ERROR_SEVERITY() as 'Error SEVERITY',
Error_State() as 'Error State'
Rollback tran
end catch 
end
end 

go 



--Answer to question no 15
use SaleDB
go 
if OBJECT_ID('FnCustomerwiseProductInfo')is not null 
drop function FnCustomerwiseProductInfo
go 

create function FnCustomerwiseProductInfo ()
returns Table 

return(select c.CustomerFName + ' '+ c.CustomerLName as Customers, p.ProductID, p.ProductName 
		from Invoices as i join CustomerInfo as c on i.CustomerID = C.CustomerID join Product as P 
		on i.ProductID = p.ProductID)

go 

--Justify
use SaleDB
go 
--Select * from dbo.FnCustomerwiseProductInfo()




--- Answer to question no 19 

use SaleDB
if OBJECT_ID ('Tempdb#view') is not null
drop table #view
go 

create table #view(ID int , Suppliername varchar (30), phoneno varchar (10))
insert into #view values (203, 'AMD' , '(800)21232')
insert into #view values (204, 'NVDIA' , '(800)12125')

declare  @id int,@Sname varchar (30) , @phoneno varchar (10)

declare SuppliersCursor  cursor for 
select * from #view 
open SuppliersCursor 
fetch next from SuppliersCursor  into @id, @sname, @phoneno
while(@@FETCH_STATUS =0 )
begin
insert into Supplier values (@id,@Sname, @phoneno)
fetch next from SuppliersCursor  into @id,@Sname, @phoneno
end

Close SuppliersCursor 
deallocate suppliersCursor

--Justify 

--select * from #view


go 


-- Answer to question no 21
use SaleDB
go 

create table Targetproduct 
(
	Productid int primary key not null, 
	Productname varchar (30), 
); 

insert into Targetproduct 

 values (201, 'Joy Stick '), (202, 'Consule')

