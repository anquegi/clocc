;;; Regression Testing
;;;
;;; Copyright (C) 1999-2002 by Sam Steingold
;;; This is Free Software, covered by the GNU GPL (v2)
;;; See http://www.gnu.org/copyleft/gpl.html
;;;
;;; $Id: tests.lisp,v 2.30 2004/12/22 19:55:41 sds Exp $
;;; $Source: /cvsroot/clocc/clocc/src/cllib/tests.lisp,v $

(eval-when (load compile eval)
  (require :cllib-base (translate-logical-pathname "clocc:src;cllib;base"))
  ;; `mesg'
  (require :cllib-log (translate-logical-pathname "cllib:log"))
  ;; these files will be tested:
  (require :cllib-string (translate-logical-pathname "cllib:string"))
  (require :cllib-matrix (translate-logical-pathname "cllib:matrix"))
  (require :cllib-math (translate-logical-pathname "cllib:math"))
  (require :cllib-date (translate-logical-pathname "cllib:date"))
  (require :cllib-url (translate-logical-pathname "cllib:url"))
  (require :cllib-rpm (translate-logical-pathname "cllib:rpm"))
  (require :cllib-elisp (translate-logical-pathname "cllib:elisp"))
  (require :cllib-xml (translate-logical-pathname "cllib:xml"))
  (require :cllib-munkres (translate-logical-pathname "cllib:munkres"))
  (require :cllib-cvs (translate-logical-pathname "cllib:cvs")))

(in-package :cllib)

(export '(test-all))

(defparameter *network-dependent-tests* '(test-cvs))

(defun test-string (&key (out *standard-output*))
  (mesg :test out " ** ~s...~%" 'test-string)
  (let ((num-err 0))
    (flet ((ts (res seq from to &rest keys)
             (mesg :test out " * ~s ~s ~s~{ ~s~} -> ~s~%" seq from to keys res)
             (let ((r1 (apply #'substitute-subseq seq from to keys)))
               (unless (string= r1 res)
                 (incf num-err)
                 (warn " ### FAILED: ~s ~s ~s~{ ~s~}~% ->~10t~s~% /=~10t~s~%"
                       seq from to keys r1 res)))))
      (ts "ab123efghcda" "abcdefghcda" "cd" "123" :start 1 :end 6)
      (ts "ab123efgh123a" "abcdefghcda" "cd" "123" :start 1)
      (ts "ab123efghcda" "abcdefghcda" "cd" "123" :end 6)
      (ts "ab123efgh123a" "abcdefghcda" "cd" "123")
      (ts "abcdefghcda" "abcdefghcda" "cd" "123" :start 5 :end 6))
    (mesg :test out " ** ~s: ~:d error~:p~2%" 'test-string num-err)
    num-err))

(defun test-math (&key (out *standard-output*))
  (mesg :test out " ** ~s...~%" 'test-math)
  (let ((num-err 0))
    (labels ((perm= (li1 la1 li2 la2)
               (when (set-difference li1 li2 :test #'equalp)
                 (incf num-err)
                 (warn "permutation lists differ:
 ** ~s **~%~s~% ** ~s **~%~s~% ** difference **~%~s~%"
                       la1 li1 la2 li2
                       (set-difference li1 li2 :test #'equalp))))
             (perm-eq (li1 la1 li2 la2)
               (perm= li1 la1 li2 la2)
               (perm= li2 la2 li1 la1))
             (ts-perm (nn)
               (mesg :test out " * permutations of ~d element~:p~%" nn)
               (let* ((ve (make-vector-indexed nn))
                      (le (permutations-list ve :method :lex))
                      (sh (permutations-list ve :method :shuffle))
                      (sw (permutations-list ve :method :swap)))
                 (perm-eq le :lex sh :shuffle)
                 (perm-eq le :lex sw :swap))))
      (ts-perm 3)
      (ts-perm 4)
      (ts-perm 5))
    (mesg :test out " ** ~s: ~:d error~:p~2%" 'test-math num-err)
    num-err))

(defun test-date (&key (out *standard-output*))
  (mesg :test out " ** ~s...~%" 'test-date)
  (let ((num-err 0))
    (loop :repeat 10 :do
          (let* ((n0 (random 100000)) (dd (days2date n0)) (n1 (date2days dd)))
            (mesg :test out "~6:d --> ~a --> ~6:d~%" n0 dd n1)
            (unless (= n0 n1)
              (incf num-err)
              (warn " ### FAILED: ~6:d --> ~a --> ~6:d~2%" n0 dd n1))))
    (flet ((ts (nn st)
             (mesg :test out "~30s --> ~d --> ~a~%"
                   st nn (dttm->string nn :format :short))
             (unless (= nn (string->dttm st))
               (incf num-err)
               (warn " ### FAILED: ~s --> ~d, not ~d~2%"
                     st (string->dttm st) nn))))
      (ts 3221942400 "2002-02-06")
      (ts 3222004920 "2002-02-06T17:22")
      (ts 3222004978 "2002-02-06T17:22:58")
      (ts 3222004979 "2002-02-06T17:22:58.9")
      (ts 3222004978 "2002-02-06T12:22:58.12Z-0500")
      (ts 3222004978 "2002-02-06T22:22:58Z+0500")
      (ts 3222004978 "06 Feb 2002 18:22:58 +0100")
      (ts 3222004978 "06 Feb 2002 16:22:58 -0100")
      (ts 3126878578 "1999/02/01 17:22:58")
      (ts 3126896578 "Mon Feb  1 17:22:58 1999 EST")
      (ts 3126878578 "Feb  1 Mon 17:22:58 1999 GMT")
      (ts 3126878578 "Feb  1 Mon 17:22:58 1999")
      (ts 3126878578 "1999 Feb  1 Mon 17:22:58")
      (ts 3126896578 "1999-02-01 Mon 17:22:58 EST")
      (ts 3126878578 "1999-02-01 17:22:58")
      (ts 3126878578 "1999-02-01 17:22:58 GMT")
      (ts 3126878578 "1999 Feb  1 17:22:58")
      (ts 3126896578 "Feb  1 17:22:58 1999 EST"))
    (mesg :test out " ** ~s: ~:d error~:p~2%" 'test-date num-err)
    num-err))

(defun test-rpm (&key (out *standard-output*))
  (mesg :test out " ** ~s...~%" 'test-rpm)
  (let ((num-err 0))
    (flet ((av (v0 v1)
             (mesg :test out " ~a < ~a~%" v0 v1)
             (unless (version< v0 v1)
               (incf num-err)
               (warn " ### FAILED: ~a < ~a~2%" v0 v1))))
      (av "3.3.2" "3.3.11")
      (av "4.2b980516" "4.2")
      (av "3.3.2pl2" "3.3.3")
      (av "1.1b" "1.1.1")
      (av "3.0" "3.0.3"))
    (mesg :test out " ** ~s: ~:d error~:p~2%" 'test-rpm num-err)
    num-err))

(defun test-url (&key (out *standard-output*))
  (mesg :test out " ** ~s...~%" 'test-url)
  (let ((num-err 0))
    (flet ((ts (st url pr)
             (mesg :test out " * ~s~% - ~s~% - ~s~%" st url pr)
             (let ((uu (url st)))
               (unless (equalp uu url)
                 (incf num-err)
                 (warn " ### PARSING FAILED:~%~s~% ###~%~s~%" uu url))
               (unless (string= (princ-to-string uu) pr)
                 (incf num-err)
                 (warn " ### PRINTING FAILED:~%~5t~s -->~%~5t~s~% not~5t~s~2%"
                       st uu st)))))
      (ts "news://nntp.gnu.org/gnu.discuss"
          (make-url :prot :news :user "" :pass "" :host "nntp.gnu.org" :port 0
                    :path "/gnu.discuss")
          "news://nntp.gnu.org/gnu.discuss")
      (ts "news:gnu.discuss"
          (make-url :prot :news :user "" :pass "" :host "" :port 0
                    :path "gnu.discuss")
          "news:gnu.discuss")
      (ts "ftp://user#password@host.domain/path/to/file"
          (make-url :prot :ftp :user "user" :pass "password" :host
                    "host.domain" :port 0 :path "/path/to/file")
          "ftp://user#password@host.domain/path/to/file")
      (ts "mailto:sds@gnu.org"
          (make-url :prot :mailto :user "sds" :host "gnu.org")
          "mailto:sds@gnu.org")
      (ts "www.gnu.org/gpl.html"
          (make-url :prot :http :user "" :pass "" :host "www.gnu.org" :port 0
                    :path "/gpl.html")
          "http://www.gnu.org/gpl.html"))
    (mesg :test out " ** ~s: ~:d error~:p~2%" 'test-url num-err)
    num-err))

(defun test-elisp (&key (out *standard-output*))
  (mesg :test out " ** ~s...~%" 'test-elisp)
  (let ((*readtable* +elisp-readtable+) (num-err 0)
        (*package* (find-package "CLLIB")))
    (flet ((ts (str obj)
             (mesg :test out " * ~s --> ~s~%" str obj)
             (handler-case
                 (let ((o1 (read-from-string str)))
                   (unless (equalp o1 obj)
                     (warn " ### READING FAILED: ~s != ~s~%" o1 obj)
                     (incf num-err)))
               (error (err)
                 (warn " ### READ ERROR: ~a~%" err)
                 (incf num-err)))))
      (ts "[a ?\\C-a ?c #\\z]" #(a (:control #\a) #\c #\z))
      (ts "[?Z ?\\^M ?\\n]" #(#\Z (:control #\M) #\Newline)))
    (mesg :test out " ** ~s: ~:d error~:p~2%" 'test-elisp num-err)
    num-err))

(defun test-xml (&key (out *standard-output*))
  (let ((num-err 0))
    (flet ((ts (path num)
             (mesg :test out " => <~a> ~:d object~:p expected~%" path num)
             (handler-case
                 (let ((len (length (xml-read-from-file path :reset-ent nil))))
                   (if (= num len)
                       (mesg :test out " * correct length: ~:d~%" len)
                       (mesg :test out
                             " #~d# wrong length: ~:d (should be ~:d)~%"
                             (incf num-err) len num)))
               (error (err)
                 (warn " ### ERROR: ~a~%" err)
                 (incf num-err)))))
      (mesg :test out " ** ~s...~%" 'test-xml)
      (ts *xml-ent-file* 284)
      (ts (translate-logical-pathname "clocc:etc;cl-ent.xml") 1208))
    (mesg :test out " ** ~s: ~:d error~:p~2%" 'test-xml num-err)
    num-err))

(defun test-cvs (&key (out *standard-output*))
  (let ((num-err 0))
    (flet ((ts (path)
             (mesg :test out " * ~a~%" path)
             (handler-case (when (cvs-stat-log path) 1)
               (error (err)
                 (warn " ### ERROR: ~a~%" err)
                 (incf num-err)))))
      (mesg :test out " ** ~s...~%" 'test-cvs)
      (ts (namestring (translate-logical-pathname "clocc:"))))
    (mesg :test out " ** ~s: ~:d error~:p~2%" 'test-cvs num-err)
    num-err))

(defun test-matrix (&key (out *standard-output*) (num-test 10)
                    (dim 10) (max 10))
  (loop :repeat num-test :with det :with i1 = (make-array (list dim dim))
    :with error-count = 0 :for err = 0
    :for mx = (random-matrix dim dim max) :for m1 = (array-copy mx) :do
    (handler-case (setq det (matrix-inverse m1))
      (division-by-zero (c)
        (mesg :test out " ** degenerate matrix~%~S~%"
              (first (arithmetic-error-operands c)))))
    (mesg :test out " ** det = ~S~%" det)
    (matrix-multiply mx m1 i1)
    (dotimes (i dim)
      (dotimes (j dim)
        (let ((e (abs (- (if (= i j) 1 0) (aref i1 i j)))))
          (when (< err e)
            (setq err e)))))
    (if (> err 0.001)
        (warn " ###~:D### ERROR: ~F~%~S~%==>~%~S" (incf error-count) err mx m1)
        (mesg :test out "    err = ~S~%" err))
    :finally (return error-count)))

(defun test-munkres (&key (out *standard-output*))
  (let ((num-err 0)
        (assignment-list
         '((#2A((69 64 23 53 94 85 16 7 77)
                (12 6 22 43 73 17 15 39 91)
                (74 38 43 86 40 89 22 69 81)
                (33 83 10 34 30 20 94 100 58)
                (15 14 60 3 97 70 8 8 0)
                (53 23 23 32 26 32 37 3 13)
                (73 54 60 93 98 53 75 76 94)
                (44 51 26 73 14 66 71 73 79)
                (77 88 69 86 94 49 50 93 68)
                (19 43 7 5 22 42 29 55 62))
            141 #(7 1 6 2 0 8 NIL 4 5 3) #(4 1 3 9 7 8 2 0 5))
           (#2A((150 69 64 23 53 94 85 16 7 77)
                (150 12 6 22 43 73 17 15 39 91)
                (150 74 38 43 86 40 89 22 69 81)
                (150 33 83 10 34 30 20 94 100 58)
                (150 15 14 60 3 97 70 8 8 0)
                (150 53 23 23 32 26 32 37 3 13)
                (150 73 54 60 93 98 53 75 76 94)
                (150 44 51 26 73 14 66 71 73 79)
                (150 77 88 69 86 94 49 50 93 68)
                (150 19 43 7 5 22 42 29 55 62))
            291 #(8 2 7 3 1 9 0 5 6 4) #(6 4 1 3 9 7 8 2 0 5))
           (#2A((150 69 64 23 53 94 85 16 7 77 12)
                (150 12 6 22 43 73 17 15 39 91 32)
                (150 74 38 43 86 40 89 22 69 81 11)
                (150 33 83 10 34 30 20 94 100 58 102)
                (150 15 14 60 3 97 70 8 8 0 99)
                (150 53 23 23 32 26 32 37 3 13 5)
                (150 73 54 60 93 98 53 75 76 94 17)
                (150 44 51 26 73 14 66 71 73 79 33)
                (150 77 88 69 86 94 49 50 93 68 6)
                (150 19 43 7 5 22 42 29 55 62 188))
            151 #(8 2 7 3 1 9 6 5 10 4) #(NIL 4 1 3 9 7 6 2 0 5 8)))))
    (dolist (li assignment-list)
      (mesg :test out " ** ~S: ~S~2%"
            'test-munkres (car li))
      (unless (equalp (multiple-value-list (funcall #'assignment (car li)))
                      (cdr li))
        (mesg :test out " ** ~S: ERROR! Expected answer: ~S~2%"
              'test-munkres (cdr li))
        (incf num-err)))
    (mesg :test out " ** ~S: ~:D error~:P~2%" 'test-munkres num-err)
    num-err))

(defun test-base64 (&key (out *standard-output*))
  (let ((num-err 0))
    (flet ((test (vec str)
             (mesg :test out "~S: ~S<->~S~%" 'test-base64 vec str)
             (unless (equal str (base64-encode vec))
               (mesg :test out " ** ~S: ERROR: ~S~%"
                     'base64-encode (base64-encode vec))
               (incf num-err))
             (unless (equalp vec (base64-decode str))
               (mesg :test out " ** ~S: ERROR: ~S~%"
                     'base64-decode (base64-decode str))
               (incf num-err))))
      (test #(97) "YQ==")
      (test #(97 98) "YWI=")
      (test #(97 98 99) "YWJj")
      (test #(108 105 115 112 32 115 116 114 105 110 103) "bGlzcCBzdHJpbmc=")
      (test #(108 105 115 112 32 115 116 114 105 110 103 115)
            "bGlzcCBzdHJpbmdz")
      (test #(99 108 105 115 112 32 115 116 114 105 110 103 115)
            "Y2xpc3Agc3RyaW5ncw==")
      (mesg :test out "~S (random)" 'test-base64)
      (loop :with str :repeat 1000 :for vec = (make-array (random 300))
        :do (mesg :test out ".")
        (loop :for i :from 0 :below (length vec)
          :do (setf (aref vec i) (random 256)))
        (setq str (base64-encode vec))
        (unless (equalp vec (base64-decode str))
          (mesg :test out "<~S -> ~S -> ~S>" vec str (base64-decode str))
          (incf num-err)))
      (mesg :test out "~& ** ~S: ~:D error~:P~%" 'test-base64 num-err)
      num-err)))

(defun test-all (&key (out *standard-output*)
                 (what '(string math date rpm url elisp xml munkres cvs base64))
                 (disable-network-dependent-tests t))
  (mesg :test out "~& *** ~s: regression testing...~%" 'test-all)
  (let* ((num-test 0)
         (num-err (reduce #'+ what :key
                          (lambda (w)
                            (let ((sy (intern (concatenate 'string "TEST-"
                                                           (string-upcase w))
                                              "CLLIB")))
                              (if (or (not (fboundp sy))
                                      (and disable-network-dependent-tests
                                           (member
                                            sy *network-dependent-tests*)))
                                  0 (progn (incf num-test)
                                           (funcall sy :out out))))))))
    (mesg :test out " *** ~s: ~:d error~:p in ~:d test~:p~2%"
          'test-all num-err num-test)))

(provide :cllib-tests)
;;; file tests.lisp ends here
