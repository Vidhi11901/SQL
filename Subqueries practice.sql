-- 1.) Products which are priced at above average rates

Select product_id,
       product_desc,
       PRODUCT_PRICE
from 
      product 
where 
     PRODUCT_PRICE > (Select avg(PRODUCT_PRICE) from product);   

-- 2.) Finding all the orders from order_items where the product price is greater than 10000
 
 Select order_id
 from order_items
 where product_id in (
					   Select product_id
					   from product
                       where product_price>10000);

-- 3.) Alternate way to find products priced below or above average 

Select product_id,
       Case when product_price > (Select avg(PRODUCT_PRICE) from product) then "Above Average"
       Else "Below Average" End as Price_range
from product
order by product_id;       

-- 4.) Using CTE (Common Table Expression) to query the data with products having price > 10000

With Product_List as (
	Select product_id
    from product
    where product_price>10000)
    
Select *
from order_items
where product_id in (Select * from Product_List);    

