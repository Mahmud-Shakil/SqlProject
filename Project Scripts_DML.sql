--- Answer to question no 3 
use SaleDB
go

delete from CustomerInfo where CustomerID = 102
go 

--Answer to question no 4
use SaleDB
go 
Update CustomerAddress set  RoadNoandName='990, Park Av' , City = 'Denver' where AddressID = 2
update Invoices set UnitPrice = 24000 where CustomerID = 102
go 

-- Answer to question no 5
use SaleDB
go 

/*Drop table supplier*/  

--- Answer to question no 6 
use SaleDB
go 

alter table Supplier 
drop column SupplierName 
go 

--Answer to question no 7
use SaleDB 
go 

select s.SupplierName, p.ProductName, i.UnitPrice, Quantity
from Product  as p join Supplier as S
on P.Supplierid = S.SupplierID  join Invoices as I 
on p.ProductID = i.ProductID
where p.SupplierID in 
(select  SupplierID= 201  from Supplier where SupplierName = 'Microsoft' )

go 

--- Answer to question no 8

use SaleDB
go 

select  count (S.Supplierid) as TotaSupplier  , s.SupplierName , s.SupplierPhoneNo, p.ProductName
from Product  as p join Supplier as S
on P.Supplierid = S.SupplierID  join Invoices as I 
on p.ProductID = i.ProductID
group by S.SupplierName, s.SupplierPhoneNo, p.ProductName
having s.SupplierName = 'sony'
order by s.SupplierPhoneNo desc

go 

--Answer to question no 14
use SaleDB
go 
select * from Supplier
go 

begin try 
begin tran 
insert into Supplier values (304, 'Play Station 5')
insert into Supplier values (305, 'Xbox One S')
commit tran 
end try 
begin catch 
rollback tran 
end catch 

go 

-- Answer to question no 17

with ProductWiseCustomerCount (Productid, TotalCustomer)
as 

(select ProductID, Count(CustomerID) as [Total Customer] 
from Invoices
group by ProductID 

)
select p.ProductID, p.ProductName, p.SupplierID , TotalCustomer from Product as P join ProductWiseCustomerCount as CTE
on p.ProductID =CTE.Productid

go 


-- Answer to question no 18
--simplecase
select ProductID, ProductName, 
Case productname 
when 'Xbox one' then 'Gaming PC'
Else 'Console'
end as [Types]
from Product

--- Searchcase 
select ProductID, ProductName, 
Case 
when ProductName = 'Xbox one' then 'Gaming PC'
Else 'Console'
end as [Types]
from Product


go 

-- Answer to question no 20 

select Ci.CustomerID, ci.CustomerFName+ ' '+ ci.CustomerLName as Customers,
Ntile (2) over ( order by ci.customerid) as Tile2 , 
Ntile (3) over ( order by ci.customerid) as Tile3, 
Ntile (4) over ( order by ci.customerid) as Tile4
from invoices as i join Customerinfo  as CI  on 
i.customerid = ci.customerid ; 



--Answer to question no 21

use SaleDB
go 

 merge targetproduct as TP 
 using Product as P 
 on tp.productid = p.productid
 when matched then 
 update set tp.productname =p.productname
 when not matched by target then 
 insert (productid, productname) values (p.productid, p.productname)
 when not matched by source then 
 delete;
go 


