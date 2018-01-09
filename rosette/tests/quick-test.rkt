#lang rosette 

(require "../cosette.rkt" "../sql.rkt" "../evaluator.rkt" "../syntax.rkt" 
         "../table.rkt" "../denotation.rkt" "../equal.rkt" "../util.rkt") 

(provide ros-instance)

(current-bitwidth #f)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-symbolic div_ (~> integer? integer? integer?))

(define months-info (table-info "months" (list "mid" "month")))
 
(define weekdays-info (table-info "weekdays" (list "did" "day_of_week")))
 
(define carriers-info (table-info "carriers" (list "cid" "name")))
 
(define flights-info (table-info "flights" (list "fid" "year" "month_id" "day_of_month" "day_of_week_id" "carrier_id" "flight_num" "origin_city" "origin_state" "dest_city" "dest_state" "departure_delay" "taxi_out" "arrival_delay" "canceled" "actual_time" "distance" "capacity" "price")))
 
(define-symbolic* str_boston_ma_ integer?) 
(define-symbolic* str_seattle_wa_ integer?) 
(define-symbolic* str_july_ integer?) 

(define (q1 tables) 
  (SELECT (VALS "c.name" "f1.flight_num" "f1.origin_city" "f1.dest_city" "f1.actual_time" "f2.flight_num" "f2.origin_city" "f2.dest_city" "f2.actual_time" (VAL-BINOP "f1.actual_time" + "f2.actual_time")) 
  FROM (JOIN (NAMED (RENAME (list-ref tables 3) "f1")) (JOIN (NAMED (RENAME (list-ref tables 3) "f2")) (JOIN (NAMED (RENAME (list-ref tables 0) "m")) (NAMED (RENAME (list-ref tables 2) "c"))))) 
  WHERE (AND (AND (AND (AND (AND (AND (AND (AND (AND (AND (AND (AND (BINOP "f1.dest_city" = "f2.origin_city") (BINOP "f1.origin_city" = str_seattle_wa_)) (BINOP "f2.dest_city" = str_boston_ma_)) (BINOP "f1.month_id" = "f2.month_id")) (BINOP "f1.month_id" = "m.mid")) (BINOP "m.month" = str_july_)) (BINOP "f1.day_of_month" = "f2.day_of_month")) (BINOP "f1.day_of_month" = 15)) (BINOP "f1.year" = "f2.year")) (BINOP "f1.year" = 2015)) (BINOP "f1.carrier_id" = "f2.carrier_id")) (BINOP "f1.carrier_id" = "c.cid")) (BINOP (VAL-BINOP "f1.actual_time" + "f2.actual_time") < 420))))

(define (q2 tables) 
  (SELECT (VALS "c.name" "f1.flight_num" "f1.origin_city" "f1.dest_city" "f2.flight_num" "f2.origin_city" "f2.dest_city" (VAL-BINOP "f1.actual_time" + "f2.actual_time")) 
  FROM (JOIN (NAMED (RENAME (list-ref tables 3) "f1")) (JOIN (NAMED (RENAME (list-ref tables 3) "f2")) (NAMED (RENAME (list-ref tables 2) "c")))) 
  WHERE (AND (AND (AND (AND (AND (AND (AND (AND (AND (AND (AND (BINOP "f1.carrier_id" = "c.cid") (BINOP "f1.year" = 2015)) (BINOP "f1.month_id" = 7)) (BINOP "f1.day_of_month" = 7)) (BINOP "f2.year" = 2015)) (BINOP "f2.month_id" = 7)) (BINOP "f2.day_of_month" = 7)) (BINOP "f1.origin_city" = str_seattle_wa_)) (BINOP "f2.origin_city" = "f1.dest_city")) (BINOP "f2.dest_city" = str_boston_ma_)) (BINOP "f1.carrier_id" = "f2.carrier_id")) (BINOP (VAL-BINOP "f1.actual_time" + "f2.actual_time") < 4200))))


(define ros-instance (list q1 q2 (list months-info weekdays-info carriers-info flights-info))) 
;;;;;;; test function

(define (test-now instance row-num)
    (let* ([table-info-list (list-ref instance 2)]
           [table-size-list (make-list (length table-info-list) row-num)]
           [tables (map (lambda (i) (gen-sym-table-from-info (list-ref table-info-list i)
                                                             (list-ref table-size-list i)))
                        (build-list (length table-info-list) values))]
           [q1 ((list-ref instance 0) tables)]
           [q2 ((list-ref instance 1) tables)])
      (println "=======================")
      (verify (same q1 q2))
      (println "0000000000000000000000")
      (cosette-solve q1 q2 tables)))

(test-now ros-instance 1)

(exit)

(define t1
  (Table "flights" (list "fid" "year" "month_id" "day_of_month" "day_of_week_id" "carrier_id" "flight_num" "origin_city" "origin_state" "dest_city" "dest_state" "departure_delay" "taxi_out" "arrival_delay" "canceled" "actual_time" "distance" "capacity" "price")
         (list (cons (list 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18) 1)
               (cons (list 1 3 5 3 46 5 6 71 8 9 10 11 12 13 14 15 16 17 11) 1))))

;(define t2
;  (Table "emp" 
;         (list "empno" "ename" "job" "mgr" "hiredate" "comm" "sal" "deptno" "slacker")
;         (list (cons (list 0 0 0 0 0 0 0 0 0) 2))))

(define qt1 (q1 (list t1)))
(define qt2 (q2 (list t1)))

(define r1 (denote-and-run qt1))
(define r2 (denote-and-run qt2))

(println r1)
(println r2)

;(bag-equal (Table-content r1) 
;           (Table-content r2))

