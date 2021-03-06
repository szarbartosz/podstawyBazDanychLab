﻿--Wypisać wszystkich czytelnikow którzy nigdy nie wypożyczyli książki: dane adresowe i podział czy ta osoba jest dzieckiem (joiny, in, exists)
use library
select m.member_no, m.firstname, m.lastname, a.street, a.city, a.state, a.zip, 'adult' as 'adult/kid'
from member as m
inner join adult as a on m.member_no = a.member_no
left outer join loan as l on m.member_no = l.member_no
left outer join loanhist as lh on m.member_no = lh.member_no
where l.out_date is null and lh.out_date is null
union
select m.member_no, m.firstname, m.lastname, a.street, a.city, a.state, a.zip, 'child' as 'adult/kid'
from member as m
inner join juvenile as j on m.member_no = j.member_no
inner join adult as a on j.adult_member_no = a.member_no
left outer join loan as l on m.member_no = l.member_no
left outer join loanhist as lh on m.member_no = lh.member_no
where l.out_date is null and lh.out_date is null
order by 1

select m.member_no, m.firstname, m.lastname, (select a.street from adult as a where m.member_no = a.member_no),
											 (select a.city from adult as a where m.member_no = a.member_no), 
											 (select a.state from adult as a where m.member_no = a.member_no),
											 (select a.zip from adult as a where m.member_no = a.member_no),
											 'adult' as 'adult/kid' 
from member as m		
where m.member_no in (select member_no 
						from adult as a
						where a.member_no not in (select member_no from loan) and a.member_no not in (select member_no from loanhist)
					)
union
select m.member_no, m.firstname, m.lastname, (select a.street from adult as a where a.member_no = (select adult_member_no from juvenile as j where j.member_no = m.member_no)),
											 (select a.city from adult as a where a.member_no = (select adult_member_no from juvenile as j where j.member_no = m.member_no)), 
											 (select a.state from adult as a where a.member_no = (select adult_member_no from juvenile as j where j.member_no = m.member_no)),
											 (select a.zip from adult as a where a.member_no = (select adult_member_no from juvenile as j where j.member_no = m.member_no)),
											 'child' as 'adult/kid' 
from member as m		
where m.member_no in (select member_no 
						from juvenile as j
						where j.member_no not in (select member_no from loan) and j.member_no not in (select member_no from loanhist)
					)

--Wypisać wszystkich czytelnikow którzy nigdy nie wypożyczyli książki: dane adresowe i podział czy ta osoba jest dzieckiem + liczba dzieci
use library
select m.firstname, m.lastname, a.street, a.city, a.state, a.zip, 'adult' as 'child/adult',
		(select count(*) from juvenile as j where j.adult_member_no = m.member_no) as 'no of children'
from member as m
inner join adult as a on m.member_no = a.member_no
left outer join loan as l on m.member_no = l.member_no
left outer join loanhist as lh on m.member_no = lh.member_no
where l.member_no is null and lh.member_no is null
union
select m.firstname, m.lastname, a.street, a.city, a.state, a.zip, 'child' as 'child/adult', 0 as 'no of children'
from member as m
inner join juvenile as j on m.member_no = j.member_no
inner join adult as a on j.adult_member_no = a.member_no
left outer join loan as l on m.member_no = l.member_no
left outer join loanhist as lh on m.member_no = lh.member_no
where l.member_no is null and lh.member_no is null

--Podział na company, year month i suma freight
use northwind
select s.companyname, month(o.shippeddate) as 'month', year(o.shippeddate) as 'year', sum(o.freight) as 'freight value'
from shippers as s
inner join orders as o on s.shipperid = o.shipvia
group by s.shipperid, s.companyname, month(o.shippeddate),  year(o.shippeddate)
order by 1, 3, 2

--Podział na company, year month i suma freight -> to samo, zamiast sippeddate - orderdate
use northwind
select s.companyname, month(o.orderdate) as 'month', year(o.orderdate) as 'year', sum(o.freight) as 'freight value'
from shippers as s
inner join orders as o on s.shipperid = o.shipvia
group by s.shipperid, s.companyname, month(o.orderdate),  year(o.orderdate)
order by 1, 3, 2

--Najczęściej wybierana kategoria dla każdego klienta
select c.companyname, (select top 1 ca.categoryname
						from orders as o
						inner join [order details] as od on o.orderid = od.orderid
						inner join products as p on od.productid = p.productid
						inner join categories as ca on p.categoryid = ca.categoryid
						where c.customerid = o.customerid
						group by ca.categoryname
						order by count(*) desc) as 'category'
from customers as c

--Najczęściej wybierana kategoria w 1997 dla każdego klienta
use northwind
select c.companyname, (select top 1 ca.categoryname
						from orders as o
						inner join [order details] as od on o.orderid = od.orderid
						inner join products as p on od.productid = p.productid
					    inner join categories as ca on p.categoryid = ca.categoryid
						where o.customerid = c.customerid and year(o.shippeddate) = 1997
						group by ca.categoryname
						order by count(*) desc) as 'category'
from customers as c

--Dla każdego czytelnika imię nazwisko, suma książek wypożyczonych przez tą osobę
use library
select m.member_no, m.firstname, m.lastname, count(l.isbn) as 'borrowed books', 'adult' as 'child/adult'
from member as m
inner join adult as a on m.member_no = a.member_no
left outer join loan as l on m.member_no = l.member_no
group by m.member_no, m.firstname, m.lastname
union
select m.member_no, m.firstname, m.lastname, count(l.isbn) as 'borrowed books', 'child' as 'child/adult'
from member as m
inner join juvenile as j on m.member_no = j.member_no
left outer join loan as l on m.member_no = l.member_no
group by m.member_no, m.firstname, m.lastname
order by 1	

--Dla każdego czytelnika imię nazwisko, suma książek wypożyczonych przez tą osobę i jej dzieci w grudniu 2001
--osoba żyjąca w Arizonie ma mieć więcej niż 2 dzieci a osoba żyjąca w Californi ma mieć więcej niż 3 dzieci
use library
select m.member_no, m.firstname, m.lastname, a.state, (select count(*)
														from loanhist as lh
														where lh.member_no = m.member_no
														and year(lh.in_date) = 2001
														and month(lh.in_date) =  12) + (select count(*)
																						from loanhist as lh
																						inner join juvenile as j on lh.member_no = j.member_no
																						where j.adult_member_no = m.member_no
																						and year(lh.in_date) = 2001
																						and month(lh.in_date) =  12) as 'sum of borrowed books by the person and their child', 'adult'
from member as m
inner join adult as a on m.member_no = a.member_no
except
(select m.member_no, m.firstname, m.lastname, a.state, (select count(*)
														from loanhist as lh
														where lh.member_no = m.member_no
														and year(lh.in_date) = 2001
														and month(lh.in_date) =  12) + (select count(*)
																						from loanhist as lh
																						inner join juvenile as j on lh.member_no = j.member_no
																						where j.adult_member_no = m.member_no
																						and year(lh.in_date) = 2001
																						and month(lh.in_date) =  12) as 'sum of borrowed books by the person and their child', 'adult'
from member as m
inner join adult as a on m.member_no = a.member_no
where (select count(*) from juvenile as j where j.adult_member_no = m.member_no) <= 2 and a.state like 'az'
union
select m.member_no, m.firstname, m.lastname, a.state, (select count(*)
														from loanhist as lh
														where lh.member_no = m.member_no
														and year(lh.in_date) = 2001
														and month(lh.in_date) =  12) + (select count(*)
																						from loanhist as lh
																						inner join juvenile as j on lh.member_no = j.member_no
																						where j.adult_member_no = m.member_no
																						and year(lh.in_date) = 2001
																						and month(lh.in_date) =  12) as 'sum of borrowed books by the person and their child', 'adult'
from member as m
inner join adult as a on m.member_no = a.member_no
where (select count(*) from juvenile as j where j.adult_member_no = m.member_no) <= 3 and a.state like 'ca'
)

--Dla każdego czytelnika z arizony i californii: imię nazwisko, suma książek wypożyczonych przez tą osobę i jej dzieci w grudniu 2001
--osoba żyjąca w Arizonie ma mieć więcej niż 2 dzieci a osoba żyjąca w Californi ma mieć więcej niż 3 dzieci
use library
select m.member_no, m.firstname, m.lastname, a.state, (select count(*)
														from loanhist as lh
														where lh.member_no = m.member_no
														and year(lh.in_date) = 2001
														and month(lh.in_date) =  12) + (select count(*)
																						from loanhist as lh
																						inner join juvenile as j on lh.member_no = j.member_no
																						where j.adult_member_no = m.member_no
																						and year(lh.in_date) = 2001
																						and month(lh.in_date) =  12) as 'sum of borrowed books by the person and their child', 'adult'
from member as m
inner join adult as a on m.member_no = a.member_no
where (select count(*) from juvenile as j where j.adult_member_no = m.member_no) > 2 and a.state like 'az'
union
select m.member_no, m.firstname, m.lastname, a.state, (select count(*)
														from loanhist as lh
														where lh.member_no = m.member_no
														and year(lh.in_date) = 2001
														and month(lh.in_date) =  12) + (select count(*)
																						from loanhist as lh
																						inner join juvenile as j on lh.member_no = j.member_no
																						where j.adult_member_no = m.member_no
																						and year(lh.in_date) = 2001
																						and month(lh.in_date) =  12) as 'sum of borrowed books by the person and their child', 'adult'
from member as m
inner join adult as a on m.member_no = a.member_no
where (select count(*) from juvenile as j where j.adult_member_no = m.member_no) > 3 and a.state like 'ca'
order by 1

--Wypisz wszystkich członków biblioteki z adresami i info czy jest dzieckiem czy nie i ilosc wypozyczeń w poszczegolnych latach i miesiacach
use library
select m.member_no, m.firstname, m.lastname, a.street, a.city, a.state, a.zip, 'adult' as 'adult/child', 
		month(lh.in_date) as 'month', year(lh.in_date) as 'year', count(lh.in_date) as 'no of books borrowed'
from member as m
inner join adult as a on m.member_no = a.member_no
left outer join loanhist as lh on m.member_no = lh.member_no
group by m.member_no, m.firstname, m.lastname, a.street, a.city, a.state, a.zip, month(lh.in_date), year(lh.in_date)
union
select m.member_no, m.firstname, m.lastname, a.street, a.city, a.state, a.zip, 'child' as 'adult/child', 
		month(lh.in_date) as 'month', year(lh.in_date) as 'year', count(lh.in_date) as 'no of books borrowed'
from member as m
inner join juvenile as j on m.member_no = j.member_no
inner join adult as a on j.adult_member_no = a.member_no
left outer join loanhist as lh on m.member_no = lh.member_no
group by m.member_no, m.firstname, m.lastname, a.street, a.city, a.state, a.zip, month(lh.in_date), year(lh.in_date)
order by 1, 10, 9

--Zamówienia z Freight większym niż AVG danego roku
use northwind
select o.orderid, o.freight, year(o.orderdate) as 'year', (select avg(freight) from orders where year(o.orderdate) = year(orderdate)) as 'avg freight'
from orders as o
where o.freight > (select avg(freight) from orders where year(o.orderdate) = year(orderdate))

--Klienci którzy nie zamówli nigdy nic z kategorii 'Seafood' w trzech wersjach
use northwind
select cu.customerid, cu.companyname
from customers as c
inner join orders as o on c.customerid = o.customerid
inner join [order details] as od on o.orderid = od.orderid
inner join products as p on od.productid = p.productid
inner join categories as ca on p.categoryid = ca.categoryid and ca.categoryname like 'seafood'
right outer join customers as cu on c.customerid = cu.customerid
where c.customerid is null

select customerid, companyname
from customers
except
select customerid, companyname
from customers
where customerid in (select customerid
						from orders
						where orderid in (select orderid
											from [order details]
											where productid in	(select productid 
																	from products
																	where categoryid in (select categoryid
																							from categories
																							where categoryname like 'seafood')
																)
										 )
						)

select c.customerid, c.companyname
from customers as c
where not exists (select *
					from orders as o
					where c.customerid = o.customerid and exists 
								(select * 
								from [order details] as od
								where o.orderid = od.orderid and exists
											(select *
											from products as p
											where od.productid = p.productid and exists
														(select *
														from categories as ca
														where p.categoryid = ca.categoryid and ca.categoryname like 'seafood')
											)
								)
					)

--Wyświetl ile każdy z przewoźników miał dostać wynagrodzenia w poszczególnych latach i miesiącach
select s.companyname, month(o.orderdate) as 'month', year(o.orderdate) as 'year', sum(o.freight) as 'total freight'
from orders as o
inner join shippers as s on o.shipvia = s.shipperid
group by s.companyname, month(o.orderdate), year(o.orderdate)

select (select s.companyname from shippers as s where s.shipperid = o.shipvia), month(o.orderdate) as 'month', 
		year(o.orderdate) as 'year', sum(o.freight) as 'total freight'
from orders as o
group by o.shipvia, month(o.orderdate), year(o.orderdate)

