(use util.perl-splice)
(use srfi-1)
(use gauche.sequence)
      
(define-macro (aquote s)
  `(lambda (x) (aquote-aux ',s x)))
(define (aquote-aux s x)
 (cond
  ((pair? s)   (cons (aquote-aux (car s) x) (aquote-aux (cdr s) x)))
  ((eq? s 'it) x)
  (else s)))
(define fn lambda)
(define each for-each)
 
;Directed graph select
;pair := (vertex, graph)
;query := (vertex) -> (Maybe query) 
(define (dg-select query pair)
  (if (eq? query #t) pair
    (map (pa$ apply dg-select)
      (filter first (map (fn (it) `(,(query `(,it ,(second pair))) (,it ,(second pair)))) (adjacentary-list pair))))))

(define (adjacentary-list pair)
  (if (list? (first pair)) (filter list? (cdr (first pair))) ()))

(define (dg-query-test path)
  (or (null? path)
      (lambda (pair) (and (list? (first pair)) (eq? (car (first pair)) (car path)) (dg-query-test (cdr path))))))

(define (xgp-create) (vector '() #f))
(define (xgp-create-symbolic))

(define (xgp-reverse-graph context)
  (set! (vector-ref context 1) (not (vector-ref context 1))))

;utilty functions
(define (xgp-circular?))
(define (xgp-tree?))
(define (xgp-woods?))

; basic reference functions
(define (xgp-edges context node)
  (vector-ref node (if (vector-ref context 1) 1 0)))
(set! (setter xgp-edges) 
  (lambda (context node edges)
    (vector-set! node (if (vector-ref context 1) 1 0) edges)))

(define (xgp-reverse-edges context node)
  (vector-ref node (if (vector-ref context 1) 0 1)))
(set! (setter xgp-reverse-edges)
  (lambda (context node edges)
    (vector-set! node (if (vector-ref context 1) 0 1) edges)))

(define (xgp-subject context edge)
  (vector-ref edge (if (vector-ref context 1) 1 0)))
(set! (setter xgp-subject)
  (lambda (context edge subject)
    (vector-set! edge (if (vector-ref context 1) 1 0) subject)))

(define (xgp-object context edge)
  (vector-ref edge (if (vector-ref context 1) 0 1)))
(set! (setter xgp-object) 
  (lambda (context edge object)
    (vector-set! edge (if (vector-ref context 1) 0 1) object)))

(define (xgp-label context node-or-edge)
  (vector-ref node-or-edge 2))

(set! (setter xgp-label) 
  (lambda (context node-or-edge label)
    (vector-set! node-or-edge 2 label)))

; baseic manipulation functions
(define (xgp-create-edge context subject object :optional (pos 0) (label #f))
  (let1 edge (vector subject object label)
    (set! (xgp-edges context subject)        (splice! (xgp-edges context subject) pos 0 edge))
    (set! (xgp-reverse-edges context object) (splice! (xgp-reverse-edges context object) 0 0 edge))))
(define (xgp-remove-edge context edge)
  (let ((subject (xgp-subject context edge)) (object (xgp-object context edge)))
  (set! (xgp-edges context subject) (remove! (pa$ eq? edge) (xgp-edges context subject)))
  (set! (xgp-reverse-edges context object)  (remove! (pa$ eq? edge) (xgp-reverse-edges context object)))))
;(define (xgp-replace-edge old-edge new-edge))
(define (xgp-create-node context label)
  (let1 node (vector '() '() label)
   (set! (vector-ref context 0) (splice! (vector-ref context 0) 0 0 node))
   node))
(define (xgp-remove-node context node)
  (each (pa$ xgp-remove-edge context) (xgp-reverse-edges context node))
  (each (pa$ xgp-remove-edge context) (xgp-edges context node))
  (set! (vector-ref context 0) (remove! (pa$ eq? node) (vector-ref context 0))))
;(define (xgp-replace-node old-node new-node))

;utility functions
;(define xgp-like)
;(define xgp-next)
;(define xgp-prev)
(define (xgp-all context)
  (vector-ref context 0))
(define (xgp-nodes-by-label context label)
  (filter (fn (x) (eq? (xgp-label context x) label)) (xgp-all context)))
(define (xgp-parents context node)
  (map (fn (e) (xgp-subject context e)) (xgp-reverse-edges context node)))
(define (xgp-children context node)
  (map (fn (e) (xgp-object context e)) (xgp-edges context node)))
;(define xgp-ancestors)
;(define xgp-decendants)

(define (xgp-after! context after-what what-after)
  (let1 parents (map (pa$ xgp-subject context) (xgp-reverse-edges context after-what))
    (each (fn (p) (xgp-create-edge context p what-after (+ (find-index (fn (e) (eq? (xgp-object context e) after-what)) (xgp-edges context p)) 1))) parents)))
(define (xgp-before! context before-what what-before)
  (let1 parents (map (pa$ xgp-subject context) (xgp-reverse-edges context after-what))
    (each (fn (p) (xgp-create-edge context p what-after (index-of after-what))) parents)))
(define (xgp-prepend! context to-what what-to)
  (xgp-create-edge context to-what what-to 0))
(define (xgp-append! context to-what what-to)
  (xgp-create-edge context to-what what-to (length (xgp-edges context to-what))))

(define (xgp-replace!))
(define (xgp-swap!))
(define (xgp-remove!))
(define (xgp-clone))
(define (xgp-wrap! context nodes))
(define (xgp-unwrap!))
(define (xgp-wrap-inner!))
(define (xgp-unwrap-inner!))
(define (xgp-attr!))
(define (xgp-add-class!))
(define (xgp-remove-class!))
(define (xgp-toggle-class!))
(define (xgp-has-class?))

(define (xgp-offset))

(define (xgp-event))
(define (xgp-toggle-verb) context)

(define (xgp-select))
(define (xgp-attach))
(define (xgp-apply-template context node template))
