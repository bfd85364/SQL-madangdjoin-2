describe book;

describe customer;

describe imported_book;

describe orders;

describe promotion;

#orders 테이블과 별도로 책에 대한 promotion(행사)를 진행하여 이력을 남긴 것을 기록한 테이블
#promote_id를 기본키로 지니고 있고 custid를 외래키로 지님

# 문제 1. 김연아 고객이 주문한 도서의 판매가격을 검색해보자.
SELECT CUST.name, CUST.custid, ORD.bookid, ORD.saleprice FROM customer CUST INNER JOIN orders ORD ON CUST.custid = ORD.custid 
WHERE name LIKE '김연아';

# 문제 2. 도서를 주문한 고객들의 이름, 전화번호를 조회해보자. (도서 주문이력이 있는 고객들의 이름,전화번호 조회)
SELECT DISTINCT CUST.name, CUST.custid, ORD.bookid, CUST.phone FROM customer CUST INNER JOIN orders ORD ON CUST.custid = ORD.custid;
# 문제 3. 주문 도서들의 도서명과 도서가격, 판매가격, 주문일자을 조회해보자. (주문이력 있는 도서들의 세부정보 조회)
SELECT BK.bookid, BK.bookname, BK.price, ORD.saleprice, ORD.orderdate FROM book BK INNER JOIN orders ORD ON BK.bookid = ORD.bookid;

# 문제 4  김연아 고객이 주문한 도서이름을 검색해보자.
SELECT DISTINCT  CUST.name, BK.bookname FROM customer CUST JOIN orders ORD ON CUST.custid = ORD.custid
JOIN book BK ON ORD.bookid = BK.bookid;

# 문제 5  모든 고객 국가(주소)별 도서 주문량을 조회하시오 (도서를 구매하지 않은 고객들의 주소지 모두 포함)
SELECT SUBSTRING_INDEX(CUST.address, ' ', 1) AS ADDR, count(orderid) FROM customer CUST LEFT JOIN orders ORD   
ON CUST.custid = ORD.custid GROUP BY ADDR; 
# 참고용: ' '을 기준으로 문자열을 한 덩어리로 본다, ex)영국 멘체스터 -> 영국' '멘체스터  (' ',1) -> ' ' 앞에 1만큼 가져온다. 2일 경우 영국 멘체스터 

#LEFT JOIN의 결과: master table(왼쪽의 테이블 기준) 
SELECT * FROM customer CUST LEFT JOIN orders ORD ON CUST.custid = ORD.custid;   #ordeid 말고 custid도 써도 됨 


# 문제 6  주문이력이 있는 고객들의 주소지의 두번째가 "국"인 고객들의 고객명, 주소지, 주문 도서이름을 조회하시오 
SELECT a.name, a.address, c.bookname FROM customer a join orders b on a.custid = b.custid join book c on b.bookid where a.address like
"_국%";

# 문제 7. 모든 출판사별로 주문 도서의 판매가격의 합과 첫 구매일을 조회해보자 (주문되지 않은 도서의 출판사들을 모두 포함)
select a.publisher, sum(b.saleprice), min(b.orderdate) from book a left join orders b
on a.bookid = b.bookid group by a.publisher;

# 문제 8. 모든 고객들의 도서 주문 이력들을 조회해 보자. (도서를 구매하지 않은 고객들을 모두 포함)
select * from customer a left join orders b on a.custid = b.custid;

#문제 9. 도서를 주문한 고객이름, 도서이름, 도서가격, 판매가격을 조회하시오.
SELECT CUST.name, BK.bookname, BK.price, ORD.saleprice FROM customer CUST 
JOIN orders ORD ON CUST.custid = ORD.custid
JOIN book BK ON ORD.bookid = BK.bookid;

# 문제 10. 주문도서의 판매가가 도서가격보다 낮은 도서의 주문고객명, 도서명, 판매가, 가격을 조회하시오.
SELECT CUST.name, BK.bookname, BK.price, ORD.saleprice FROM customer CUST 
JOIN orders ORD ON CUST.custid = ORD.custid
JOIN book BK ON ORD.bookid = BK.bookid WHERE ORD.saleprice < BK.price;

# 문제 11. 판매된 적 없는 도서의 도서명, 도서가격, 출판사를 조회하시오.
SELECT * FROM book a left join orders b on  a.bookid = b.bookid WHERE b.orderid IS NULL;

# 여기까지만 중간고사 포함

#중간고사는 이론 + 실습(손코딩) -> 동영상 강의 다 나옴 

# -------------------------------------------
# promotion table 생성 쿼리 실행 필요 
# -------------------------------------------

# 문제 12. 모든 고객의 이름별 프로모션 횟수 및 프로모션 수락 횟수를 집계하시오.
# 모든 값을 참조하기 위헤서는 -> left join 
SELECT CUST.name, count(PRO.promote_id), sum(PRO.accept_yn) FROM customer CUST LEFT JOIN promotion PRO ON
CUST.custid = PRO.custid GROUP BY CUST.name  

# 문제 13. 모든 주문 고객에 대하여 고객별로 프로모션 진행 년월별 프로모션건수 집계하시오.
#GROUP BY 속성 2개 -> 고객별, 년월별 
#COUNT(DISTINCT promote_id) --> 중복된 주문이력을 제거하기 위해 ( "모든 주문 고객"의 년월별 고객별 기준이므로)
SELECT CUST.custid, EXTRACT(YEAR_MONTH FROM PRO.promote_date) AS YM, count(DISTINCT PRO.promote_id) 
FROM orders ORD LEFT JOIN promotion PRO ON ORD.custid = PRO.custid
LEFT JOIN customer CUST ON CUST.custid = PRO.custid 
GROUP BY CUST.custid, YM;

# 문제 14. 모든 주문 고객별 판매총액과 프로모션 수락건수를 조회하시오.
#custmoer 테이블과 orders 테이블, promotion테이블을 join해야함 alter
WITH order_summary AS(SELECT custid, sum(saleprice) AS price GROUP BY custid),
promote_summary AS(SELECT custid, SUM(accept_yn) AS yn FROM promotion GROUP BY custid)
SELECT * FROM customer CUST LEFT JOIN order_summary ORD ON CUST.custid = ORD.custid
LEFT JOIN promotion PRO on CUST.custid = PRO.custid
GROUP BY CUST.custid, EXTRACT(year_month FROM PRO.promote_date);
