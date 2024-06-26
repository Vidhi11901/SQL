Use orders;

-- Let us explore some tables of the database and then begin with the queries for the project.

Select * from address Limit 5;
Select * from carton Limit 5;
Select * from online_customer Limit 5;
Select * from order_header Limit 5;
Select * from order_items Limit 5;
Select * from product Limit 5;
Select * from product_class Limit 5;
Select * from shipper Limit 5;

-- 1. WRITE A QUERY TO DISPLAY CUSTOMER FULL NAME WITH THEIR TITLE (MR/MS), BOTH FIRST NAME AND LAST NAME ARE IN 
-- UPPER CASE WITH CUSTOMER EMAIL ID, CUSTOMER CREATIONDATE AND DISPLAY CUSTOMER’S CATEGORY AFTER APPLYING BELOW 
-- CATEGORIZATION RULES:
	-- i.IF CUSTOMER CREATION DATE YEAR <2005 THEN CATEGORY A
    -- ii.IF CUSTOMER CREATION DATE YEAR >=2005 AND <2011 THEN CATEGORY B
    -- iii.IF CUSTOMER CREATION DATE YEAR>= 2011 THEN CATEGORY C
    
    -- HINT: USE CASE STATEMENT, NO PERMANENT CHANGE IN TABLE REQUIRED. [NOTE: TABLES TO BE USED -ONLINE_CUSTOMER TABLE]


Select CT.customer_id,
       concat(CT.TITLE,' ',CT.FULL_NAME) as CUSTOMER_FULL_NAME,
       CT.CUSTOMER_EMAIL,
       CT.CUSTOMER_CREATION_DATE,
       CT.CUSTOMERS_CATEGORY
from
(Select customer_id,
	   case
       when CUSTOMER_GENDER = 'F' then 'MS'
       when CUSTOMER_GENDER = 'M' then 'MR'
       else ' ' 
       end as TITLE,
       concat(upper(CUSTOMER_FNAME),' ',upper(CUSTOMER_LNAME)) as FULL_NAME,
       CUSTOMER_EMAIL,
       CUSTOMER_CREATION_DATE,
       case 
           when year(CUSTOMER_CREATION_DATE)<2005 then 'CATEGORY A'
           when year(CUSTOMER_CREATION_DATE)>=2005 and year(CUSTOMER_CREATION_DATE)<2011 then 'CATEGORY B'
           when year(CUSTOMER_CREATION_DATE)>=2011 then 'CATEGORY C'
           else 'CATEGORY'
           end as CUSTOMERS_CATEGORY
from online_customer) CT
order by CUSTOMER_ID asc;  	 

-- 2. WRITE A QUERY TO DISPLAY THE FOLLOWING INFORMATION FOR THE PRODUCTS, WHICH HAVE NOT BEEN SOLD:  PRODUCT_ID, 
-- PRODUCT_DESC, PRODUCT_QUANTITY_AVAIL, PRODUCT_PRICE,INVENTORY VALUES(PRODUCT_QUANTITY_AVAIL*PRODUCT_PRICE), 
-- NEW_PRICE AFTER APPLYING DISCOUNT  AS PER BELOW CRITERIA. SORT THE OUTPUT WITH RESPECT TO DECREASING VALUE OF 
-- INVENTORY_VALUE.
	-- i.IF PRODUCT PRICE > 20,000 THEN APPLY 20% DISCOUNT
    -- ii.IF PRODUCT PRICE > 10,000 THEN APPLY 15% DISCOUNT
    -- iii.IF PRODUCT PRICE =< 10,000 THEN APPLY 10% DISCOUNT
    
    -- HINT: USE CASE STATEMENT, NO PERMANENT CHANGE IN TABLE REQUIRED. [NOTE: TABLES TO BE USED -PRODUCT, ORDER_ITEMS TABLE]

Select PRODUCT_ID,
       PRODUCT_DESC,
       PRODUCT_QUANTITY_AVAIL,
       PRODUCT_PRICE,
       PRODUCT_QUANTITY_AVAIL*PRODUCT_PRICE as INVENTORY_VALUES,
       Case
           when PRODUCT_PRICE > 20000 then PRODUCT_PRICE*1.20
           when PRODUCT_PRICE > 10000 then PRODUCT_PRICE*1.15
           when PRODUCT_PRICE <= 10000 then PRODUCT_PRICE*1.10
           else PRODUCT_PRICE
           end as NEW_PRICE
from 
product
where 
     PRODUCT_ID not in      
                      (Select PRODUCT_ID
                       from order_items)
order by PRODUCT_QUANTITY_AVAIL*PRODUCT_PRICE desc;	

-- 3. WRITE A QUERY TO DISPLAY PRODUCT_CLASS_CODE, PRODUCT_CLASS_DESCRIPTION, COUNT OF PRODUCT TYPE IN EACH 
-- PRODUCT CLASS, INVENTORY VALUE (P.PRODUCT_QUANTITY_AVAIL*P.PRODUCT_PRICE). INFORMATION SHOULD BE DISPLAYED
--  FOR ONLY THOSE PRODUCT_CLASS_CODE WHICH HAVE MORE THAN 1,00,000 INVENTORY VALUE. SORT THE OUTPUT WITH RESPECT 
-- TO DECREASING VALUE OF INVENTORY_VALUE.
	-- [NOTE: TABLES TO BE USED -PRODUCT, PRODUCT_CLASS]

Select PC.PRODUCT_CLASS_CODE,
       PC.PRODUCT_CLASS_DESC as Product_Type,
       Count(PC.PRODUCT_CLASS_DESC) as Count_of_Product,
       sum(P.PRODUCT_QUANTITY_AVAIL*P.PRODUCT_PRICE) as INVENTORY_VALUE
from  product_class PC 
inner join product P 
on PC.PRODUCT_CLASS_CODE=P.PRODUCT_CLASS_CODE 
group by PC.PRODUCT_CLASS_CODE, PC.PRODUCT_CLASS_DESC
having INVENTORY_VALUE > 100000 
order by INVENTORY_VALUE desc;   

-- 4. WRITE A QUERY TO DISPLAY CUSTOMER_ID, FULL NAME, CUSTOMER_EMAIL, CUSTOMER_PHONE 
-- AND COUNTRY OF CUSTOMERS WHO HAVE CANCELLED ALL THE ORDERS PLACED BY THEM
-- (USE SUB-QUERY)
	-- [NOTE: TABLES TO BE USED - ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
       
Select OC.CUSTOMER_ID, 
       concat(OC.CUSTOMER_FNAME,' ',OC.CUSTOMER_LNAME) as FULL_NAME, 
       OC.CUSTOMER_EMAIL, 
       OC.CUSTOMER_PHONE,
       A.COUNTRY
from online_customer OC left join address A using(ADDRESS_ID)
where customer_id in (
select customer_id
from order_header
where ORDER_STATUS = 'Cancelled');

	-- 5. WRITE A QUERY TO DISPLAY SHIPPER NAME, CITY TO WHICH IT IS CATERING, NUMBER OF CUSTOMER 
	-- CATERED BY THE SHIPPER IN THE CITY AND NUMBER OF CONSIGNMENTS DELIVERED TO THAT CITY FOR 
	-- SHIPPER DHL(9 ROWS)
		-- [NOTE: TABLES TO BE USED -SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
    

       
Select S.SHIPPER_NAME,
       A.CITY,
       Count(OC.Customer_ID) as Number_of_customers,
       Count(OH.ORDER_ID) as Number_of_consignments
from 
shipper S join order_header OH using(SHIPPER_ID)
join online_customer OC using(CUSTOMER_ID)
join address A using(ADDRESS_ID)
where S.SHIPPER_NAME = 'DHL'
group by S.SHIPPER_NAME, A.CITY;  

-- 6. WRITE A QUERY TO DISPLAY CUSTOMER ID, CUSTOMER FULL NAME, TOTAL QUANTITY AND TOTAL VALUE 
-- (QUANTITY*PRICE) SHIPPED WHERE MODE OF PAYMENT IS CASH AND CUSTOMER LAST NAME STARTS WITH 'G'
	-- [NOTE: TABLES TO BE USED -ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]
    
Select OC.CUSTOMER_ID,
       concat(OC.CUSTOMER_FNAME,' ',OC.CUSTOMER_LNAME) as FULL_NAME,
       Sum(OT.PRODUCT_QUANTITY) as TOTAL_QUANTITY,
       Sum(OT.PRODUCT_QUANTITY*P.PRODUCT_PRICE) as TOTAL_VALUE
from online_customer OC join order_header O using(CUSTOMER_ID)
join order_items OT using(ORDER_ID)  
join product P using(PRODUCT_ID)
where O.PAYMENT_MODE = 'Cash' and OC.CUSTOMER_LNAME like 'G%' and O.ORDER_STATUS = 'Shipped'
group by 1,2;

-- 7. WRITE A QUERY TO DISPLAY ORDER_ID AND VOLUME OF BIGGEST ORDER (IN TERMS OF VOLUME) THAT CAN 
-- FIT IN CARTON ID 10  
	-- [NOTE: TABLES TO BE USED -CARTON, ORDER_ITEMS, PRODUCT] 
           
Select OT.ORDER_ID,
       sum(P.LEN*P.WIDTH*P.HEIGHT*OT.PRODUCT_QUANTITY) as Total_Product_Volume
from order_items OT join product P using(PRODUCT_ID)
group by 1
having sum(P.LEN*P.WIDTH*P.HEIGHT*OT.PRODUCT_QUANTITY) <= 
                            (select (C.LEN*C.WIDTH*C.HEIGHT) as CARTON_VOLUME
                             from carton C
                             where CARTON_ID=10)
order by Total_Product_Volume desc
limit 1;             

-- 8. WRITE A QUERY TO DISPLAY PRODUCT_ID, PRODUCT_DESC, PRODUCT_QUANTITY_AVAIL, QUANTITY SOLD, AND SHOW 
-- INVENTORY STATUS OF PRODUCTS AS BELOW AS PER BELOW CONDITION:
	-- A.FOR ELECTRONICS AND COMPUTER CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY',
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 10% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY', 
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 50% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME 
        -- INVENTORY', 
        -- iv.IF INVENTORY QUANTITY IS MORE OR EQUAL TO 50% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
	-- B.FOR MOBILES AND WATCHES CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY', 
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 20% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY',  
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 60% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME
        -- INVENTORY', 
        -- iv.IF INVENTORY QUANTITY IS MORE OR EQUAL TO 60% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
	-- C.REST OF THE CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY', 
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 30% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY',  
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 70% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME
        -- INVENTORY', 
        -- iv. IF INVENTORY QUANTITY IS MORE OR EQUAL TO 70% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
        
			-- [NOTE: TABLES TO BE USED -PRODUCT, PRODUCT_CLASS, ORDER_ITEMS] (USE SUB-QUERY)

Select P.PRODUCT_ID, 
	   P.PRODUCT_DESC, 
       P.PRODUCT_QUANTITY_AVAIL as Inventory_Quantity, 
       Sum(OT.PRODUCT_QUANTITY) as QUANTITY_SOLD,
       case 
           when Sum(OT.PRODUCT_QUANTITY) is Null then 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY'
           when P.PRODUCT_QUANTITY_AVAIL< (0.1*Sum(OT.PRODUCT_QUANTITY)) then 'LOW INVENTORY, NEED TO ADD INVENTORY'
           when P.PRODUCT_QUANTITY_AVAIL< (0.5*Sum(OT.PRODUCT_QUANTITY)) and P.PRODUCT_QUANTITY_AVAIL>= (0.1*Sum(OT.PRODUCT_QUANTITY)) then 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY'
           when P.PRODUCT_QUANTITY_AVAIL>= (0.5*Sum(OT.PRODUCT_QUANTITY)) then 'SUFFICIENT INVENTORY'
           else ' '
           end as INVENTORY_STATUS
from product P left join order_items OT using(PRODUCT_ID)
where P.PRODUCT_CLASS_CODE in (select PRODUCT_CLASS_CODE
                              from product_class
								where PRODUCT_CLASS_DESC in ('Electronics','Computer'))
group by 1,2,3
order by 4 desc;


 Select P.PRODUCT_ID, 
	   P.PRODUCT_DESC, 
       P.PRODUCT_QUANTITY_AVAIL as Inventory_Quantity, 
       Sum(OT.PRODUCT_QUANTITY) as QUANTITY_SOLD,
       case 
           when Sum(OT.PRODUCT_QUANTITY) is Null then 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY'
           when P.PRODUCT_QUANTITY_AVAIL< (0.2*Sum(OT.PRODUCT_QUANTITY)) then 'LOW INVENTORY, NEED TO ADD INVENTORY'
           when P.PRODUCT_QUANTITY_AVAIL< (0.6*Sum(OT.PRODUCT_QUANTITY)) and P.PRODUCT_QUANTITY_AVAIL>= (0.2*Sum(OT.PRODUCT_QUANTITY)) then 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY'
           when P.PRODUCT_QUANTITY_AVAIL>= (0.6*Sum(OT.PRODUCT_QUANTITY)) then 'SUFFICIENT INVENTORY'
           else ' '
           end as INVENTORY_STATUS
from product P left join order_items OT using(PRODUCT_ID)
where P.PRODUCT_CLASS_CODE in 
                              (select PRODUCT_CLASS_CODE
							   from product_class
							   where PRODUCT_CLASS_DESC in ('Mobiles','Watches'))
group by 1,2,3
order by 4 desc;

Select P.PRODUCT_ID, 
	   P.PRODUCT_DESC, 
       P.PRODUCT_QUANTITY_AVAIL as Inventory_Quantity, 
       Sum(OT.PRODUCT_QUANTITY) as QUANTITY_SOLD,
       case 
           when Sum(OT.PRODUCT_QUANTITY) is Null then 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY'
           when P.PRODUCT_QUANTITY_AVAIL< (0.3*Sum(OT.PRODUCT_QUANTITY)) then 'LOW INVENTORY, NEED TO ADD INVENTORY'
           when P.PRODUCT_QUANTITY_AVAIL< (0.7*Sum(OT.PRODUCT_QUANTITY)) and P.PRODUCT_QUANTITY_AVAIL>= (0.3*Sum(OT.PRODUCT_QUANTITY)) then 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY'
           when P.PRODUCT_QUANTITY_AVAIL>= (0.7*Sum(OT.PRODUCT_QUANTITY)) then 'SUFFICIENT INVENTORY'
           else ' '
           end as INVENTORY_STATUS
from product P left join order_items OT using(PRODUCT_ID)
where P.PRODUCT_CLASS_CODE in 
                              (select PRODUCT_CLASS_CODE
							   from product_class
							   where PRODUCT_CLASS_DESC not in ('Electronics','Computer','Mobiles','Watches'))
group by 1,2,3
order by 4 desc;

-- 9. WRITE A QUERY TO DISPLAY PRODUCT_ID, PRODUCT_DESC AND TOTAL QUANTITY OF PRODUCTS WHICH ARE SOLD TOGETHER 
-- WITH PRODUCT ID 201 AND ARE NOT SHIPPED TO CITY BANGALORE AND NEW DELHI. DISPLAY THE OUTPUT IN DESCENDING 
-- ORDER WITH RESPECT TO TOT_QTY.(USE SUB-QUERY)
	-- [NOTE: TABLES TO BE USED -ORDER_ITEMS,PRODUCT,ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]

select P.product_id, 
       P.product_desc,
       sum(OT.product_quantity) as Total_Quantity
from product P join order_items OT using(PRODUCT_ID)
join        
(select OH.order_id
from order_header OH join online_customer OC using(CUSTOMER_ID)
join address A using(ADDRESS_ID) 
where order_id in (
                   select order_id
				from order_header OH join order_items OT using(order_id)
                 where product_id = 201)
and A.city not in ('Bangalore','New Delhi')) as SQ on OT.order_id=SQ.order_id
group by 1,2
order by 3 desc;	

-- 10. WRITE A QUERY TO DISPLAY THE ORDER_ID,CUSTOMER_ID AND CUSTOMER FULLNAME AND TOTAL QUANTITY OF PRODUCTS 
-- SHIPPED FOR ORDER IDS WHICH ARE EVENAND SHIPPED TO ADDRESS WHERE PINCODE IS NOT STARTING WITH "5" 
	-- [NOTE: TABLES TO BE USED - ONLINE_CUSTOMER,ORDER_HEADER, ORDER_ITEMS, ADDRESS]						   

select OH.order_id,
	   OC.customer_id,
	   concat(OC.CUSTOMER_FNAME,' ',OC.CUSTOMER_LNAME) as FULL_NAME,
       sum(OT.PRODUCT_QUANTITY) as Total_Quantity
from  order_header OH join online_customer OC using(customer_id)
join order_items OT using(order_id)
join address A using(address_id)
where OH.order_id % 2 =0 and A.Pincode in (select pincode 
from address 
where PINCODE not in (select pincode
from address 
where PINCODE like '5%'))	
group by 1,2,3;   