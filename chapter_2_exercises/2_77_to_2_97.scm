; 2.77
; ========================================================================
(define put 2d-put!)
(define (get x-key y-key)
  (let ((1d-table (2d-get-alist-x x-key)))
    (let ((type-f (assoc y-key 1d-table)))
      (if type-f (cdr type-f) false))))

(define (attach-tag type-tag contents)
  (cons type-tag contents))
(define (type-tag datum)
  (if (pair? datum)
      (car datum)
      (error "Bad tagged datum -- TYPE-TAG" datum)))
(define (contents datum)
  (if (pair? datum)
      (cdr datum)
      (error "Bad tagged datum -- CONTENTS" datum)))

(define (add x y) (apply-generic 'add x y))
(define (sub x y) (apply-generic 'sub x y))
(define (mul x y) (apply-generic 'mul x y))
(define (div x y) (apply-generic 'div x y))

(define (install-scheme-number-package)
  (define (tag x)
    (attach-tag 'scheme-number x))
  (put 'add 'scheme-number
       (lambda (x y) (tag (+ x y))))
  (put 'sub 'scheme-number
       (lambda (x y) (tag (- x y))))
  (put 'mul 'scheme-number
       (lambda (x y) (tag (* x y))))
  (put 'div 'scheme-number
       (lambda (x y) (tag (/ x y))))
  (put 'make 'scheme-number
       (lambda (x) (tag x)))
  'done)

(define (make-scheme-number n)
  ((get 'make 'scheme-number) n))


(define (install-rational-package)
  ;; internal procedures
  (define (numer x) (car x))
  (define (denom x) (cdr x))
  (define (make-rat n d)
    (let ((g (gcd n d)))
      (cons (/ n g) (/ d g))))
  (define (add-rat x y)
    (make-rat (+ (* (numer x) (denom y))
                 (* (numer y) (denom x)))
              (* (denom x) (denom y))))
  (define (sub-rat x y)
    (make-rat (- (* (numer x) (denom y))
                 (* (numer y) (denom x)))
              (* (denom x) (denom y))))
  (define (mul-rat x y)
    (make-rat (* (numer x) (numer y))
              (* (denom x) (denom y))))
  (define (div-rat x y)
    (make-rat (* (numer x) (denom y))
              (* (denom x) (numer y))))
  ;; interface to rest of the system
  (define (tag x) (attach-tag 'rational x))
  (put 'add 'rational
       (lambda (x y) (tag (add-rat x y))))
  (put 'sub 'rational
       (lambda (x y) (tag (sub-rat x y))))
  (put 'mul 'rational
       (lambda (x y) (tag (mul-rat x y))))
  (put 'div 'rational
       (lambda (x y) (tag (div-rat x y))))

  (put 'make 'rational
       (lambda (n d) (tag (make-rat n d))))
  'done)

(define (make-rational n d)
  ((get 'make 'rational) n d))

(define (install-rectangular-package)
  ;; internal procedures
  (define (real-part z) (car z))
  (define (imag-part z) (cdr z))
  (define (make-from-real-imag x y) (cons x y))
  (define (magnitude z)
    (sqrt (+ (square (real-part z))
             (square (imag-part z)))))
  (define (angle z)
    (atan (imag-part z) (real-part z)))
  (define (make-from-mag-ang r a)
    (cons (* r (cos a)) (* r (sin a))))
  ;; interface to the rest of the system
  (define (tag x) (attach-tag 'rectangular x))
  (put 'real-part 'rectangular real-part)
  (put 'imag-part 'rectangular imag-part)
  (put 'magnitude 'rectangular magnitude)
  (put 'angle 'rectangular angle)
  (put 'make-from-real-imag 'rectangular
       (lambda (x y) (tag (make-from-real-imag x y))))
  (put 'make-from-mag-ang 'rectangular
       (lambda (r a) (tag (make-from-mag-ang r a))))
  'done)

(define (install-polar-package)
  ;; internal procedures
  (define (magnitude z) (car z))
  (define (angle z) (cdr z))
  (define (make-from-mag-ang r a) (cons r a))
  (define (real-part z)
    (* (magnitude z) (cos (angle z))))
  (define (imag-part z)
    (* (magnitude z) (sin (angle z))))
  (define (make-from-real-imag x y)
    (cons (sqrt (+ (square x) (square y)))
          (atan y x)))
  ;; interface to the rest of the system
  (define (tag x) (attach-tag 'polar x))
  (put 'real-part 'polar real-part)
  (put 'imag-part 'polar imag-part)
  (put 'magnitude 'polar magnitude)
  (put 'angle 'polar angle)
  (put 'make-from-real-imag 'polar
       (lambda (x y) (tag (make-from-real-imag x y))))
  (put 'make-from-mag-ang 'polar
       (lambda (r a) (tag (make-from-mag-ang r a))))
  'done)

(define (install-complex-package)
  ;; imported procedures from rectangular and polar packages
  (define (make-from-real-imag x y)
    ((get 'make-from-real-imag 'rectangular) x y))
  (define (make-from-mag-ang r a)
    ((get 'make-from-mag-ang 'polar) r a))
  ;; internal procedures
  (define (add-complex z1 z2)
    (make-from-real-imag (+ (real-part z1) (real-part z2))
                         (+ (imag-part z1) (imag-part z2))))
  (define (sub-complex z1 z2)
    (make-from-real-imag (- (real-part z1) (real-part z2))
                         (- (imag-part z1) (imag-part z2))))
  (define (mul-complex z1 z2)
    (make-from-mag-ang (* (magnitude z1) (magnitude z2))
                       (+ (angle z1) (angle z2))))
  (define (div-complex z1 z2)
    (make-from-mag-ang (/ (magnitude z1) (magnitude z2))
                       (- (angle z1) (angle z2))))
  ;; interface to rest of the system
  (define (tag z) (attach-tag 'complex z))
  (put 'add 'complex
       (lambda (z1 z2) (tag (add-complex z1 z2))))
  (put 'sub 'complex
       (lambda (z1 z2) (tag (sub-complex z1 z2))))
  (put 'mul 'complex
       (lambda (z1 z2) (tag (mul-complex z1 z2))))
  (put 'div 'complex
       (lambda (z1 z2) (tag (div-complex z1 z2))))
  (put 'make-from-real-imag 'complex
       (lambda (x y) (tag (make-from-real-imag x y))))
  (put 'make-from-mag-ang 'complex
       (lambda (r a) (tag (make-from-mag-ang r a))))
  (put 'real-part 'complex real-part)
  (put 'imag-part 'complex imag-part)
  (put 'magnitude 'complex magnitude)
  (put 'angle 'complex angle)
  'done)

(define (make-complex-from-real-imag x y)
  ((get 'make-from-real-imag 'complex) x y))
(define (make-complex-from-mag-ang r a)
  ((get 'make-from-mag-ang 'complex) r a))

(install-scheme-number-package)
(install-rational-package)
(install-rectangular-package)
(install-polar-package)
(install-complex-package)

(define (apply-generic op . args)
  (let ((type-tag (type-tag (car args))))
    (let ((proc (get op type-tag)))
      (if proc
          (apply proc (map contents args))
          (error
            "No method for these types -- APPLY-GENERIC"
            (list op type-tag))))))


;; 1 ]=> (add (make-complex-from-real-imag 3 6) (make-complex-from-real-imag 2 8))
;; Value 185: (complex rectangular 5 . 14)
;; 1 ]=> (add (make-rational 3 8) (make-rational 1 4))
;; Value 186: (rational 5 . 8)
;; 1 ]=> (div (make-scheme-number 8) (make-scheme-number 3))
;; Value 187: (scheme-number . 8/3)


;; 1 ]=> (magnitude (make-complex-from-real-imag 3 4))
;; Value: 5
;; (magnitude) works by calling (apply-generic) and dispatching on type.
;; When (apply-generic) is first called it looks up the (magnitude) proc
;; for our type 'complex and finds our definition that points back to the
;; global (magnitude)

;;   (put 'magnitude 'complex magnitude)

;; then invokes it on this line

;;   (apply proc (map contents args))

;; which, when applied to our complex number, yields

;;   (apply magnitude (rectangular 3 . 4))

;; (magnitude) then gets invoked on our 'rectangular and (apply-generic)
;; correctly routes it to the definition in the rectangular package.

;; So (apply-generic) is invoked twice, first dispatching to (magnitude)
;; and second dispatching to 'rectangular::(magnitude)

; 2.78
; ========================================================================
(define (attach-tag type-tag contents)
  (if (integer? contents)
      contents
      (cons type-tag contents)))
(define (type-tag datum)
  (cond ((pair? datum) (car datum))
	((number? datum) 'scheme-number)
	(else (error "Bad tagged datum -- TYPE-TAG" datum))))
(define (contents datum)
  (cond ((pair? datum) (cdr datum))
	((number? datum) datum)
	(else (error "Bad tagged datum -- CONTENTS" datum))))

;; 1 ]=> (make-scheme-number 8)
;; Value: 8
;; 1 ]=> (type-tag (make-scheme-number 8))
;; Value: scheme-number
;; 1 ]=> (contents (make-scheme-number 8))
;; Value: 8
;; 1 ]=> (add (make-scheme-number 8) (make-scheme-number 7))
;; Value: 15

; 2.79
; ========================================================================
(define (equ? x y) (apply-generic 'equ? x y))

(define (install-scheme-number-package)
  (define (tag x)
    (attach-tag 'scheme-number x))
  (put 'add 'scheme-number
       (lambda (x y) (tag (+ x y))))
  (put 'sub 'scheme-number
       (lambda (x y) (tag (- x y))))
  (put 'mul 'scheme-number
       (lambda (x y) (tag (* x y))))
  (put 'div 'scheme-number
       (lambda (x y) (tag (/ x y))))
  (put 'make 'scheme-number
       (lambda (x) (tag x)))

;;BEGIN NEW CODE
  (put 'equ? 'scheme-number
       (lambda (x y) (= x y)))
;;END NEW CODE
  'done)

(define (install-rational-package)
  ;; internal procedures
  (define (numer x) (car x))
  (define (denom x) (cdr x))
  (define (make-rat n d)
    (let ((g (gcd n d)))
      (cons (/ n g) (/ d g))))
  (define (add-rat x y)
    (make-rat (+ (* (numer x) (denom y))
                 (* (numer y) (denom x)))
              (* (denom x) (denom y))))
  (define (sub-rat x y)
    (make-rat (- (* (numer x) (denom y))
                 (* (numer y) (denom x)))
              (* (denom x) (denom y))))
  (define (mul-rat x y)
    (make-rat (* (numer x) (numer y))
              (* (denom x) (denom y))))
  (define (div-rat x y)
    (make-rat (* (numer x) (denom y))
              (* (denom x) (numer y))))
  ;; interface to rest of the system
  (define (tag x) (attach-tag 'rational x))
  (put 'add 'rational
       (lambda (x y) (tag (add-rat x y))))
  (put 'sub 'rational
       (lambda (x y) (tag (sub-rat x y))))
  (put 'mul 'rational
       (lambda (x y) (tag (mul-rat x y))))
  (put 'div 'rational
       (lambda (x y) (tag (div-rat x y))))

  (put 'make 'rational
       (lambda (n d) (tag (make-rat n d))))

;;BEGIN NEW CODE
  (define (equ?-rat x y)
    (and
     (= (numer x) (numer y))
     (= (denom x) (denom y))))
  (put 'equ? 'rational equ?-rat)
;;END NEW CODE
  'done)

(define (install-complex-package)
  ;; imported procedures from rectangular and polar packages
  (define (make-from-real-imag x y)
    ((get 'make-from-real-imag 'rectangular) x y))
  (define (make-from-mag-ang r a)
    ((get 'make-from-mag-ang 'polar) r a))
  ;; internal procedures
  (define (add-complex z1 z2)
    (make-from-real-imag (+ (real-part z1) (real-part z2))
                         (+ (imag-part z1) (imag-part z2))))
  (define (sub-complex z1 z2)
    (make-from-real-imag (- (real-part z1) (real-part z2))
                         (- (imag-part z1) (imag-part z2))))
  (define (mul-complex z1 z2)
    (make-from-mag-ang (* (magnitude z1) (magnitude z2))
                       (+ (angle z1) (angle z2))))
  (define (div-complex z1 z2)
    (make-from-mag-ang (/ (magnitude z1) (magnitude z2))
                       (- (angle z1) (angle z2))))
  ;; interface to rest of the system
  (define (tag z) (attach-tag 'complex z))
  (put 'add 'complex
       (lambda (z1 z2) (tag (add-complex z1 z2))))
  (put 'sub 'complex
       (lambda (z1 z2) (tag (sub-complex z1 z2))))
  (put 'mul 'complex
       (lambda (z1 z2) (tag (mul-complex z1 z2))))
  (put 'div 'complex
       (lambda (z1 z2) (tag (div-complex z1 z2))))
  (put 'make-from-real-imag 'complex
       (lambda (x y) (tag (make-from-real-imag x y))))
  (put 'make-from-mag-ang 'complex
       (lambda (r a) (tag (make-from-mag-ang r a))))
  (put 'real-part 'complex real-part)
  (put 'imag-part 'complex imag-part)
  (put 'magnitude 'complex magnitude)
  (put 'angle 'complex angle)
;;BEGIN NEW CODE
  (define (equ?-complex x y)
    (and
     (= (real-part x) (real-part y))
     (= (imag-part x) (imag-part y))))
  (put 'equ? 'complex equ?-complex)
;;END NEW CODE
  'done)


(install-scheme-number-package)
;; 1 ]=> (equ? (make-scheme-number 8) (make-scheme-number 8))
;; Value: #t
;; 1 ]=> (equ? (make-scheme-number 8) (make-scheme-number 7))
;; Value: #f

(install-rational-package)
;; 1 ]=> (equ? (make-rational 3 8) (make-rational 4 8))
;; Value: #f
;; 1 ]=> (equ? (make-rational 4 8) (make-rational 4 8))
;; Value: #t

(install-complex-package)
;; 1 ]=> (equ? (make-complex-from-real-imag 3 4) (make-complex-from-real-imag 3 8))
;; Value: #f
;; 1 ]=> (equ? (make-complex-from-real-imag 3 4) (make-complex-from-real-imag 3 4))
;; Value: #t
;; 1 ]=> (equ? (make-complex-from-mag-ang 3 20) (make-complex-from-mag-ang 3 30))
;; Value: #f
;; 1 ]=> (equ? (make-complex-from-mag-ang 3 20) (make-complex-from-mag-ang 3 20))
;; Value: #t

; 2.80
; ========================================================================
(define (=zero? x) (apply-generic '=zero? x))

(define (install-scheme-number-package)
  (define (tag x)
    (attach-tag 'scheme-number x))
  (put 'add 'scheme-number
       (lambda (x y) (tag (+ x y))))
  (put 'sub 'scheme-number
       (lambda (x y) (tag (- x y))))
  (put 'mul 'scheme-number
       (lambda (x y) (tag (* x y))))
  (put 'div 'scheme-number
       (lambda (x y) (tag (/ x y))))
  (put 'make 'scheme-number
       (lambda (x) (tag x)))
  (put 'equ? 'scheme-number
       (lambda (x y) (= x y)))
;;BEGIN NEW CODE
  (put '=zero? 'scheme-number
       (lambda (x) (= x 0)))
;;END NEW CODE
  'done)

(define (install-rational-package)
  ;; internal procedures
  (define (numer x) (car x))
  (define (denom x) (cdr x))
  (define (make-rat n d)
    (let ((g (gcd n d)))
      (cons (/ n g) (/ d g))))
  (define (add-rat x y)
    (make-rat (+ (* (numer x) (denom y))
                 (* (numer y) (denom x)))
              (* (denom x) (denom y))))
  (define (sub-rat x y)
    (make-rat (- (* (numer x) (denom y))
                 (* (numer y) (denom x)))
              (* (denom x) (denom y))))
  (define (mul-rat x y)
    (make-rat (* (numer x) (numer y))
              (* (denom x) (denom y))))
  (define (div-rat x y)
    (make-rat (* (numer x) (denom y))
              (* (denom x) (numer y))))
  ;; interface to rest of the system
  (define (tag x) (attach-tag 'rational x))
  (put 'add 'rational
       (lambda (x y) (tag (add-rat x y))))
  (put 'sub 'rational
       (lambda (x y) (tag (sub-rat x y))))
  (put 'mul 'rational
       (lambda (x y) (tag (mul-rat x y))))
  (put 'div 'rational
       (lambda (x y) (tag (div-rat x y))))

  (put 'make 'rational
       (lambda (n d) (tag (make-rat n d))))
  (define (equ?-rat x y)
    (and
     (= (numer x) (numer y))
     (= (denom x) (denom y))))
  (put 'equ? 'rational equ?-rat)
;;BEGIN NEW CODE
  (define (=zero?-rat x)
    (or (= (numer x) 0)
	(= (denom x) 0))) ;;Technically this is illegal!
			  ;;But our implementation allows it, so.
  (put '=zero? 'rational =zero?-rat)
;;END NEW CODE
  'done)

(define (install-complex-package)
  ;; imported procedures from rectangular and polar packages
  (define (make-from-real-imag x y)
    ((get 'make-from-real-imag 'rectangular) x y))
  (define (make-from-mag-ang r a)
    ((get 'make-from-mag-ang 'polar) r a))
  ;; internal procedures
  (define (add-complex z1 z2)
    (make-from-real-imag (+ (real-part z1) (real-part z2))
                         (+ (imag-part z1) (imag-part z2))))
  (define (sub-complex z1 z2)
    (make-from-real-imag (- (real-part z1) (real-part z2))
                         (- (imag-part z1) (imag-part z2))))
  (define (mul-complex z1 z2)
    (make-from-mag-ang (* (magnitude z1) (magnitude z2))
                       (+ (angle z1) (angle z2))))
  (define (div-complex z1 z2)
    (make-from-mag-ang (/ (magnitude z1) (magnitude z2))
                       (- (angle z1) (angle z2))))
  ;; interface to rest of the system
  (define (tag z) (attach-tag 'complex z))
  (put 'add 'complex
       (lambda (z1 z2) (tag (add-complex z1 z2))))
  (put 'sub 'complex
       (lambda (z1 z2) (tag (sub-complex z1 z2))))
  (put 'mul 'complex
       (lambda (z1 z2) (tag (mul-complex z1 z2))))
  (put 'div 'complex
       (lambda (z1 z2) (tag (div-complex z1 z2))))
  (put 'make-from-real-imag 'complex
       (lambda (x y) (tag (make-from-real-imag x y))))
  (put 'make-from-mag-ang 'complex
       (lambda (r a) (tag (make-from-mag-ang r a))))
  (put 'real-part 'complex real-part)
  (put 'imag-part 'complex imag-part)
  (put 'magnitude 'complex magnitude)
  (put 'angle 'complex angle)

  (define (equ?-complex x y)
    (and
     (= (real-part x) (real-part y))
     (= (imag-part x) (imag-part y))))
  (put 'equ? 'complex equ?-complex)
;;BEGIN NEW CODE
  (define (=zero?-complex x)
    (and
     (= (real-part x) 0)
     (= (imag-part x) 0)))
  (put '=zero? 'complex =zero?-complex)
;;END NEW CODE
  'done)



(install-scheme-number-package)
;; 1 ]=> (=zero? (make-scheme-number 8))
;; Value: #f
;; 1 ]=> (=zero? (make-scheme-number 0))
;; Value: #t

(install-rational-package)
;; 1 ]=> (=zero? (make-rational 3 8))
;; Value: #f
;; 1 ]=> (=zero? (make-rational 0 8))
;; Value: #t
;; 1 ]=> (=zero? (make-rational 8 0))
;; Value: #t

(install-complex-package)
;; 1 ]=> (=zero? (make-complex-from-real-imag 3 4))
;; Value: #f
;; 1 ]=> (=zero? (make-complex-from-real-imag 3 0))
;; Value: #f
;; 1 ]=> (=zero? (make-complex-from-real-imag 0 3))
;; Value: #f
;; 1 ]=> (=zero? (make-complex-from-real-imag 0 0))
;; Value: #t
;; 1 ]=> (=zero? (make-complex-from-mag-ang 3 4))
;; Value: #f
;; 1 ]=> (=zero? (make-complex-from-mag-ang 3 0))
;; Value: #f
;; 1 ]=> (=zero? (make-complex-from-mag-ang 0 3))
;; Value: #t
;; 1 ]=> (=zero? (make-complex-from-mag-ang 0 0))
;; Value: #t

; 2.81
; ========================================================================
(define put-coercion put)
(define get-coercion get)

(define (apply-generic op . args)
  (let ((type-tags (map type-tag args)))
    (let ((proc (get op type-tags)))
      (if proc
          (apply proc (map contents args))
          (if (= (length args) 2)
              (let ((type1 (car type-tags))
                    (type2 (cadr type-tags))
                    (a1 (car args))
                    (a2 (cadr args)))
                (let ((t1->t2 (get-coercion type1 type2))
                      (t2->t1 (get-coercion type2 type1)))
                  (cond (t1->t2
                         (apply-generic op (t1->t2 a1) a2))
                        (t2->t1
                         (apply-generic op a1 (t2->t1 a2)))
                        (else
                         (error "No method for these types"
                                (list op type-tags))))))
              (error "No method for these types"
                     (list op type-tags)))))))

(define (scheme-number->scheme-number n) n)
(define (complex->complex z) z)
(put-coercion 'scheme-number 'scheme-number
              scheme-number->scheme-number)
(put-coercion 'complex 'complex complex->complex)

;;a.
;; It will do infinite recursion!  It will find the conversion from
;; complex->complex and then try to
;;   (apply-generic op (t1->t2 a1) a2))
;; which will route back to (apply-generic) and fail to find an operation
;; defined for it.  Thus it will find the conversion and execute the same
;;   (apply-generic op (t1->t2 a1) a2))
;; line.

(define (exp x y) (apply-generic 'exp x y))

(define (install-scheme-number-package)
  (define (tag x)
    (attach-tag 'scheme-number x))
  (put 'add 'scheme-number
       (lambda (x y) (tag (+ x y))))
  (put 'sub 'scheme-number
       (lambda (x y) (tag (- x y))))
  (put 'mul 'scheme-number
       (lambda (x y) (tag (* x y))))
  (put 'div 'scheme-number
       (lambda (x y) (tag (/ x y))))
  (put 'make 'scheme-number
       (lambda (x) (tag x)))
  (put 'equ? 'scheme-number
       (lambda (x y) (= x y)))
  (put '=zero? 'scheme-number
       (lambda (x) (= x 0)))
;;BEGIN NEW CODE
  (put 'exp '(scheme-number scheme-number)
     (lambda (x y) (tag (expt x y)))) ; using primitive expt
;;END NEW CODE
  'done)

(install-scheme-number-package)
;; 1 ]=> (exp (make-complex-from-real-imag 3 4) (make-complex-from-real-imag 6 8))
;; . . . . . . . . . . . . . . . . .
;; I waited 30s or so and then cancelled this.

;;b.
;; Louis is WRONG.  The procedure would have worked fine as is  - if it
;; can't find a method for the types or a coercion from one type to another
;; it will signal "No method for these types".

;;c.
(define (apply-generic op . args)
  (let ((type-tags (map type-tag args)))
    (let ((proc (get op type-tags)))
      (if proc
          (apply proc (map contents args))
          (if (= (length args) 2)
              (let ((type1 (car type-tags))
                    (type2 (cadr type-tags))
                    (a1 (car args))
                    (a2 (cadr args)))
                (let ((t1->t2 (get-coercion type1 type2))
                      (t2->t1 (get-coercion type2 type1)))
		  ;;BEGIN NEW CODE
                  (cond ((equal? type1 type2) (error "No method for these types" (list op type-tags)))
		  ;;END NEW CODE
			(t1->t2
                         (apply-generic op (t1->t2 a1) a2))
                        (t2->t1
                         (apply-generic op a1 (t2->t1 a2)))
                        (else
                         (error "No method for these types"
                                (list op type-tags))))))
              (error "No method for these types"
                     (list op type-tags)))))))

;; 1 ]=> (exp (make-complex-from-real-imag 3 4) (make-complex-from-real-imag 6 8))
;; No method for these types (exp (complex complex))

; 2.82
; ========================================================================
(define (apply-generic op . args)
  (define (all-elements-equal? elements)
     (every (lambda (x) (equal? x (car elements))) elements))

  (define (can-convert-all-types? target-type types)
    ;; Really what I want to say is (every defined ...), but I can't.
    (every (lambda (x) (and x true))
	   (map (lambda (type) (get-coercion type target-type)) types)))

  (define (convert-all-types target-type args)
    (let ((type-tags (map type-tag args)))
      (if (can-convert-all-types? target-type type-tags)
	  (map (lambda (x) ((get-coercion (type-tag x) target-type) x)) args)
	  false)))

  (define (find-conversion types)
    (define (iter remaining)
      (cond ((null? remaining) false)
	    ((can-convert-all-types? (car remaining) types) (car remaining))
	    (else (iter (cdr remaining)))))

    (iter types))


  (let ((type-tags (map type-tag args)))
    (let ((proc (get op type-tags)))
      (cond ((and proc true) (apply proc (map contents args))) ;;we can run it as is
	    ((all-elements-equal? type-tags) (error "No method for these types" (list op type-tags))) ;; there is no method defined
	    ((find-conversion type-tags) (apply apply-generic op (convert-all-types (find-conversion type-tags) args))) ;; there is a conversion available
	    (else (error "No method for these types" (list op type-tags)))))))

;; (convert-all-types)
;; 1 ]=> (convert-all-types (make-scheme-number 8) (map (lambda (x) (make-scheme-number x)) '(1 2 8 3 4)))
;; Value 246: (1 2 8 3 4)
;; 1 ]=> (convert-all-types (make-scheme-number 8) (map (lambda (x) (make-complex-from-real-imag x (+ x 4))) '(1 2 8 3 4)))
;; Value: #f
;; 1 ]=>  (convert-all-types (make-complex-from-real-imag 8 10) (map (lambda (x) (make-scheme-number x)) '(1 2 8 3 4)))
;; Value 24: ((complex rectangular 1 . 0) (complex rectangular 2 . 0) (complex rectangular 8 . 0) (complex rectangular 3 . 0) (complex rectangular 4 . 0))
;; 1 ]=>  (convert-all-types (make-complex-from-real-imag 8 10) (append (map (lambda (x) (make-scheme-number x)) '(1 2 3)) (map (lambda (x) (make-complex-from-real-imag x (+ x 4))) '(1 2 3))))
;; Value 30: ((complex rectangular 1 . 0) (complex rectangular 2 . 0) (complex rectangular 3 . 0) (complex rectangular 1 . 5) (complex rectangular 2 . 6) (complex rectangular 3 . 7))

;; (find-conversion)
;; 1 ]=> (find-conversion '(complex scheme-number scheme-number complex))
;;Value: complex
;; 1 ]=> (find-conversion '(complex scheme-number rational))
;; Value: #f
;; 1 ]=> (find-conversion '(complex scheme-number rational complex))
;; Value: #f

(define (scheme-number->complex n)
  (make-complex-from-real-imag (contents n) 0))
(put-coercion 'scheme-number 'complex scheme-number->complex)

;; Well. . .success?  It converted everything properly, but we haven't
;; implemented variable-length arithmetic operators yet. Cool, SICP.
;; 1 ]=> (apply-generic 'add (make-scheme-number 8) (make-scheme-number 4) (make-complex-from-real-imag 8 10))
;; No method for these types (add (complex complex complex))

; 2.83
; ========================================================================
;;We need the old definition of attach-tag so we can create real numbers
(define (attach-tag type-tag contents)
  (cons type-tag contents))

(define (install-scheme-number-package)
  (define (tag x)
    (attach-tag 'scheme-number x))
  (put 'add '(scheme-number scheme-number)
       (lambda (x y) (tag (+ x y))))
  (put 'sub '(scheme-number scheme-number)
       (lambda (x y) (tag (- x y))))
  (put 'mul '(scheme-number scheme-number)
       (lambda (x y) (tag (* x y))))
  (put 'div '(scheme-number scheme-number)
       (lambda (x y) (tag (/ x y))))
  (put 'make '(scheme-number)
       (lambda (x) (tag x)))
  (put 'equ? '(scheme-number scheme-number)
       (lambda (x y) (= x y)))
  (put '=zero? '(scheme-number scheme-number)
       (lambda (x) (= x 0)))
  (put 'exp '(scheme-number scheme-number)
     (lambda (x y) (tag (expt x y))))
;;BEGIN NEW CODE
  (put 'raise '(scheme-number)
       (lambda (x) (make-rational x 1)))
;;END NEW CODE
  'done)

(define (install-rational-package)
  ;; internal procedures
  (define (numer x) (car x))
  (define (denom x) (cdr x))
  (define (make-rat n d)
    (let ((g (gcd n d)))
      (cons (/ n g) (/ d g))))
  (define (add-rat x y)
    (make-rat (+ (* (numer x) (denom y))
                 (* (numer y) (denom x)))
              (* (denom x) (denom y))))
  (define (sub-rat x y)
    (make-rat (- (* (numer x) (denom y))
                 (* (numer y) (denom x)))
              (* (denom x) (denom y))))
  (define (mul-rat x y)
    (make-rat (* (numer x) (numer y))
              (* (denom x) (denom y))))
  (define (div-rat x y)
    (make-rat (* (numer x) (denom y))
              (* (denom x) (numer y))))
  ;; interface to rest of the system
  (define (tag x) (attach-tag 'rational x))
  (put 'add '(rational rational)
       (lambda (x y) (tag (add-rat x y))))
  (put 'sub '(rational rational)
       (lambda (x y) (tag (sub-rat x y))))
  (put 'mul '(rational rational)
       (lambda (x y) (tag (mul-rat x y))))
  (put 'div '(rational rational)
       (lambda (x y) (tag (div-rat x y))))

  (put 'make '(rational)
       (lambda (n d) (tag (make-rat n d))))
  (define (equ?-rat x y)
    (and
     (= (numer x) (numer y))
     (= (denom x) (denom y))))
  (put 'equ? '(rational) equ?-rat)
  (define (=zero?-rat x)
    (or (= (numer x) 0)
	(= (denom x) 0)))
  (put '=zero? '(rational) =zero?-rat)
;;BEGIN NEW CODE
  (put 'raise '(rational)
       (lambda (x) (make-real (/
			       (* (numer x) 1.0)
			       (denom x)))))
;;END NEW CODE
  'done)

(define (install-real-package)
  (define (tag n) (attach-tag 'real n))
  (put 'make '(real)
       (lambda (z) (tag z)))
  (put 'raise '(real)
       (lambda (z) (make-complex-from-real-imag z 0)))
  'done)

(define (make-real n)
  ((get 'make '(real)) n))

(install-scheme-number-package)
(install-rational-package)
(install-real-package)
(install-complex-package)

(define (raise x) (apply-generic 'raise x))

;; 1 ]=> (raise (make-scheme-number 8))
;; Value 100: (rational 8 . 1)
;; 1 ]=> (raise (raise (make-scheme-number 8)))
;; Value 211: (real . 8)
;; 1 ]=> (raise (raise (raise (make-scheme-number 8))))
;; Value 212: (complex rectangular 8 . 0)

; 2.84
; ========================================================================
(define (<=> type1 type2)
  ((get '<=> (list type1)) type2))

(define _old-install-scheme-number-package_ install-scheme-number-package)
(define (install-scheme-number-package)
  (_old-install-scheme-number-package_)

  (define (cmp type)
    (if (equal? type 'scheme-number)
	0
	-1))

  (put '<=> '(scheme-number) cmp)
  'done)

(define _old-install-rational-number-package_ install-rational-package)
(define (install-rational-package)
  (_old-install-rational-number-package_)

  (define (cmp type)
    (cond ((equal? type 'scheme-number) 1)
	  ((equal? type 'rational) 0)
	  (else -1)))

  (put '<=> '(rational) cmp)
  'done)

(define _old-install-real-package_ install-real-package)
(define (install-real-package)
  (_old-install-real-package_)

  (define (cmp type)
    (cond ((equal? type 'complex) -1)
	  ((equal? type 'real) 0)
	  (else 1)))

  (put '<=> '(real) cmp)
  'done)

(define _old-install-complex-package_ install-complex-package)
(define (install-complex-package)
  (_old-install-complex-package_)

  (define (cmp type)
    (if (equal? type 'complex)
	0
	1))

  (put '<=> '(complex) cmp)
  'done)

(install-scheme-number-package)
(install-rational-package)
(install-real-package)
(install-complex-package)

;; 1 ]=> (<=> 'rational 'scheme-number)
;; Value: 1
;; 1 ]=> (<=> 'rational 'real)
;; Value: -1
;; 1 ]=> (<=> 'complex 'complex)
;; Value: 0
;; 1 ]=> (<=> 'real 'complex)
;; Value: -1

(define (apply-generic op . args)
  (define (all-types-equal? types)
     (every (lambda (x) (= (<=> x (car types)) 0)) types))

  (define (convert-all-types target-type args)
    (define (successive-raise x)
      (if (equal? (type-tag x) target-type)
	  x
	  (successive-raise (raise x))))

    (map successive-raise args))

  (define (find-max-type types)
    (define (iter remaining max-type)
      (cond ((null? remaining) max-type)
	    ((= (<=> (car remaining) max-type) 1) (iter (cdr remaining) (car remaining)))
	    (else (iter (cdr remaining) max-type))))

    (iter types (car types)))

  (let ((type-tags (map type-tag args)))
    (let ((proc (get op type-tags)))
      (cond ((and proc true) (apply proc (map contents args))) ;;we can run it as is
	    ((all-types-equal? type-tags) (error "No method for these types" (list op type-tags))) ;; there is no method defined
	    (else (apply apply-generic op (convert-all-types (find-max-type type-tags) args))))))) ;; raise all types


;; 1 ]=> (find-max-type '(scheme-number rational real))
;; Value: real
;; 1 ]=> (find-max-type '(rational complex real complex))
;; Value: complex

;; 1 ]=> (convert-all-types 'real (list (make-scheme-number 8) (make-rational 3 8) (make-real 2.3) (make-scheme-number 4)))
;; Value 75: ((real . 8.) (real . .375) (real . 2.3) (real . 4.))

;; 1 ]=> (apply-generic 'add (make-scheme-number 8) (make-scheme-number 4) (make-complex-from-real-imag 8 10))
;; No method for these types (add (complex complex complex))
;; 1 ]=> (apply-generic 'add (make-scheme-number 8) (make-rational 3 8))
;; Value 125: (rational 67 . 8)