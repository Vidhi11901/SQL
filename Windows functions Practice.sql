use orders;

-- 1.) Adding row numbers to each product at a product class code level

Select 
       Product_class_code,
       Row_number() over(partition by product_class_code) as Row_num,
       product_id,
       product_desc
from product;

-- 2.) Ranking the products in each product class in the desc order of price

Select 
      product_class_code,
      product_id,
      product_desc,
      rank() over (partition by product_class_code order by product_price desc) as Price_rank,
      product_price
from product;

-- 3.) Finding out the instances where customers have ordered the same or more quantity than what they purchased in their previous order
     
Select customer_id, order_id,
       sum(PRODUCT_QUANTITY) as Quantity,
       Lag(sum(PRODUCT_QUANTITY)) over (partition by customer_id order by order_id asc) as Previous_quantity,
       Case when sum(PRODUCT_QUANTITY) >= Lag(sum(PRODUCT_QUANTITY)) over (partition by customer_id order by order_id asc) then 1 else 0 end as FLAG
from 
    order_header inner join order_items
    using(order_id)
group by 1,2;  

   