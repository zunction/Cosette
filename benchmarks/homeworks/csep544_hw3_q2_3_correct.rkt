#lang rosette 
 
(require "../cosette.rkt" "../sql.rkt" "../evaluator.rkt" "../syntax.rkt") 
 
(provide ros-instance)
 
(current-bitwidth #f)
 
(define-symbolic div_ (~> integer? integer? integer?))
 
(define months-info (table-info "months" (list "mid" "month")))
 
(define weekdays-info (table-info "weekdays" (list "did" "day_of_week")))
 
(define carriers-info (table-info "carriers" (list "cid" "name")))
 
(define flights-info (table-info "flights" (list "fid" "year" "month_id" "day_of_month" "day_of_week_id" "carrier_id" "flight_num" "origin_city" "origin_state" "dest_city" "dest_state" "departure_delay" "taxi_out" "arrival_delay" "canceled" "actual_time" "distance" "capacity" "price")))
 

(define (q1 tables) 
  (SELECT (VALS "x.origin_city") 
 FROM (NAMED (RENAME (list-ref tables 3) "x")) 
 WHERE (TRUE) GROUP-BY (list "x.origin_city") 
 HAVING (BINOP (VAL-UNOP aggr-max (val-column-ref "x.actual_time")) < 180)))

(define (q2 tables) 
  (SELECT-DISTINCT (VALS "f1.origin_city") 
  FROM (JOIN (NAMED (RENAME (list-ref tables 3) "f1")) (AS (SELECT (VALS "f2.origin_city" (VAL-UNOP aggr-max (val-column-ref "f2.actual_time"))) 
 FROM (NAMED (RENAME (list-ref tables 3) "f2")) 
 WHERE (TRUE) GROUP-BY (list "f2.origin_city") 
 HAVING (TRUE)) ["mx" (list "origin_city" "max_time")])) 
  WHERE (AND (BINOP "f1.origin_city" = "mx.origin_city") (BINOP "mx.max_time" < 180))))


(define ros-instance (list q1 q2 (list months-info weekdays-info carriers-info flights-info))) 