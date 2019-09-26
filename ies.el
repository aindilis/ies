;; see also nlu/ipa.el

;; similar to NLU, but intended to markup text for extraction

(add-to-list 'load-path "/var/lib/myfrdcsa/codebases/minor/ies/frdcsa/emacs")

(global-set-key "\C-cies" 'ies-ghost-buffer)
(global-set-key "\C-cieg" 'ies-ghost-mode)

;; (define-derived-mode ies-mode
;;  nlu-mode "IES"
;;  "Major mode for asserting knowledge about text.
;; \\{ies-mode-map}"
;;  (setq case-fold-search nil)
 
;;  (define-key ies-mode-map "ls" 'ies-load-label-scheme)
;;  (define-key ies-mode-map "lm" 'ies-load-model)
;;  (define-key ies-mode-map "lr" 'ies-label-region)

;;  ;; (suppress-keymap nlu-mode-map)

;;  ;; ensure buffer is ghosted
;;  )

(define-derived-mode ies-ghost-mode
 nlu-ghost-mode "IES-Ghost"
 "Major mode for asserting knowledge about text ghost.
\\{ies-ghost-mode-map}"
 (setq case-fold-search nil)
 ;; (define-key nlu-ghost-mode-map "cb" 'clear-queue-current-buffer-referent)
 (nlu-read-only nil)

 (define-key ies-ghost-mode-map "ls" 'ies-load-label-scheme)
 (define-key ies-ghost-mode-map "lm" 'ies-load-model)
 (define-key ies-ghost-mode-map "lr" 'ies-label-region)
 (define-key ies-ghost-mode-map "lt" 'ies-label-tap)
 (define-key ies-ghost-mode-map "ld" 'ies-label-at-point-delete)
 (define-key ies-ghost-mode-map "le" 'ies-labels-extract)

 (define-key ies-ghost-mode-map "ts" 'ies-ghost-save-with-properties-and-tags)

 (define-key ies-ghost-mode-map "ct" 'ies-train-region)
 (define-key ies-ghost-mode-map "cc" 'ies-classify-region)

 (define-key ies-ghost-mode-map "rl" 'ies-reopen-file-literally)
 (define-key ies-ghost-mode-map "rn" 'ies-reopen-file-normally)

 (define-key ies-ghost-mode-map "rw" 'ies-open-ghosted-html-as-w3m)


 (setq-local use-hard-newlines nil)
 (enriched-mode t)
 (mark-whole-buffer)
 (ies-redisplay-text-with-tags-emphasized)
 (set-mark (point))
 (ies-ghost-save-with-properties-and-tags)
 (nlu-read-only t)
 (message "IES Ghost Mode loaded successfully apparently.")
 )

(defun ies-ghost-buffer ()
 ""
 (interactive)
 (if (not (kmax-mode-is-derived-from 'doc-view-mode))
  (fundamental-mode))
 (nlu-ghost-buffer)
 (ies-ghost-mode))


(defvar ies-label-scheme-directory (frdcsa-el-concat-dir (list "/var/lib/myfrdcsa/codebases/minor/ies" "data-git/schemes")))

(defvar ies-current-scheme nil)
(defvar ies-current-scheme-directory nil)

(defvar ies-current-model nil)
(defvar ies-current-model-directory nil)

(defvar ies-current-tokenizer "textmine")
;; (setq ies-current-tokenizer "default")

(defun ies-load-label-scheme ()
 ""
 (interactive)
 (ies-load-label-scheme-helper
  (completing-read
   "Label Scheme: "
   (kmax-directory-files-no-hidden ies-label-scheme-directory))))

(defun ies-load-label-scheme-helper (scheme)
 (setq ies-current-scheme scheme)
 (setq ies-current-scheme-directory
  (kmax-create-directory-if-not-exists-and-return-directory-name
   (frdcsa-el-concat-dir
    (list
     "/var/lib/myfrdcsa/codebases/minor/ies"
     "data-git/schemes"
     scheme)))))

(defvar ies-model-directory (frdcsa-el-concat-dir (list "/var/lib/myfrdcsa/codebases/minor/ies" "data-git/models")))

(defun ies-load-model ()
 ""
 (interactive)
 (kmax-not-yet-implemented)
 (ies-load-model-helper
  (completing-read
   "Model: "
   (kmax-directory-files-no-hidden ies-model-directory))))

(defun ies-load-model-helper (model)
 (setq ies-current-model model)
 (setq ies-current-scheme-directory
  (kmax-create-directory-if-not-exists-and-return-directory-name
   (frdcsa-el-concat-dir
    (list
     "/var/lib/myfrdcsa/codebases/minor/ies"
     "data-git/models"
     model)))))

;; (ies-label-belongs-to-scheme-p "systemUrl" "CSO")

(defun ies-label-region ()
 ""
 (interactive)
 (let* ((labels (ies-labels))
	(label (completing-read "Label: " (ies-guess-labels-for-region))))

  (if (not (ies-label-belongs-to-scheme-p label ies-current-scheme))
   (ies-create-new-label-for-scheme label))
  (nlu-add-tag-to-region (read label))
  (ies-redisplay-text-with-tags-emphasized)))

(defun ies-label-tap ()
 ""
 (interactive)
 (let* ((labels (ies-labels))
	(label (completing-read "Label: " (ies-guess-labels-for-region))))
  (if (not (ies-label-belongs-to-scheme-p label ies-current-scheme))
   (ies-create-new-label-for-scheme label))
  (let* ((bounds (bounds-of-thing-at-point 'symbol))
	 (point (car bounds))
	 (mark (cdr bounds)))
   (nlu-add-tag point mark (read label) t)
   (ies-redisplay-text-with-tags-emphasized point mark))))

;; (ies-labels)

(defun ies-labels ()
 ""
 (unless ies-current-scheme
  (ies-load-label-scheme))
 (ies-sync-scheme-label-cache ies-current-scheme)
 ies-scheme-label-cache)

(defun ies-guess-labels-for-region ()
 ""
 ;; does a model already exist, and is trained
 ;; (ies-run-current-model-on-region)
 (unless ies-current-scheme
  (ies-load-label-scheme))
 (ies-sync-scheme-label-cache ies-current-scheme)
 ies-scheme-label-cache)

(defun ies-label-belongs-to-scheme-p (label scheme)
 ""
 (ies-label-belongs-to-scheme-freekbs2-p label scheme))

(defun ies-label-belongs-to-scheme-freekbs2-p (label scheme)
 ""
 (ies-sync-scheme-label-cache scheme)
 (non-nil (member label ies-scheme-label-cache)))

(defun ies-create-new-label-for-scheme (label scheme)
 ""
 (ies-create-new-label-for-scheme-freekbs2 label scheme))

(defun ies-create-new-label-for-scheme-freekbs2 (label scheme)
 ""
 (if (not (ies-label-belongs-to-scheme-freekbs2-p label scheme))
  (freekbs2-assert (list "hasLabel" label) (ies-scheme-to-context-freekbs2 scheme))))

(defvar ies-scheme-label-cache nil)

;; (ies-sync-scheme-label-cache ies-current-scheme t)

(defun ies-sync-scheme-label-cache (scheme &optional force)
 ""
 (if (or force
      (null ies-scheme-label-cache))
  (progn
   (if (not uea-connected)
    (uea-connect-emacs-client))
   (setq ies-scheme-label-cache
   (ies-extract-labels-from-query-results
    (freekbs2-query (list "hasLabel" 'var-label) (ies-scheme-to-context-freekbs2 scheme)))))))

(defun ies-scheme-to-context-freekbs2 (scheme)
 ""
 (concat "Org::FRDCSA::IES::Scheme::" scheme))

;; (ies-extract-labels-from-query-results '(("CycL" ((var-label "systemUrl")) ((var-label "system")))))

(defun ies-extract-labels-from-query-results (results)
 ""
 (mapcar (lambda (result) (cadr (assoc 'var-label result))) (cdar results)))

;; (ies-create-new-label-for-scheme-freekbs2 "systemName" "CSO")
;; (ies-create-new-label-for-scheme-freekbs2 "systemUrl" "CSO")
;; (ies-create-new-label-for-scheme-freekbs2 "description" "CSO")
;; (ies-sync-scheme-label-cache "CSO")

;; (nlu-get-face-for-tag "url")
;; (nlu-get-face-for-tag "name")
;; (nlu-get-face-for-tag "description")

;; (nlu-redisplay-text-with-tags-emphasized)

;; (prin1 (face-list))
;; (prin1 (mapcar 'face-all-attributes (face-list)))

;; (put-text-property (point) (mark) 'face (cons 'foreground-color "red"))

;; (prin1 (defined-colors))

(defun ies-redisplay-text-with-tags-emphasized (&optional point-arg mark-arg)
 "Redraw the text, taking care to colorize and put on special fonts for each text item"
 (interactive)
 (let* ((point (or point-arg (point)))
	(mark (or mark-arg (mark)))
	(min (min mark point))
	(max (max mark point)))
  (save-excursion
   (goto-char min)
   (nlu-unlock-temporarily-and-execute
    '(while (< (point) max)
      (dolist (tag (plist-keys (nlu-tags (text-properties-at (point))))) 
       (put-text-property (point) (+ (point) 1) 'face (cons 'foreground-color (ies-get-color-for-tag tag))))
      (forward-char))))))

(defvar ies-possible-colors nil)
(defvar ies-colors-for-tags nil)

;; (list-colors-display)

;; (ies-reset-colors-for-tags)


(defun ies-reset-colors-for-tags ()
 ""
 (interactive)
 (if (equal window-system "x")
  (setq ies-possible-colors (reverse (kmax-list-last-n-elements-of-list (defined-colors) (- (length (defined-colors)) 18))))
  (setq ies-possible-colors (reverse (defined-colors))))
 (shift ies-possible-colors)
 (setq ies-colors-for-tags nil))

(defun ies-get-next-unique-color ()
 ""
 (if (not (boundp 'ies-last-color))
  (setq ies-last-color "black"))
 (while (progn
	 (setq ies-current-color (shift ies-possible-colors))
	 (equal
	  (color-values ies-current-color)
	  (color-values ies-last-color)))
  t)
 ies-current-color)

(defun ies-get-color-for-tag (tag)
 "Return the face associated with a tag, or associate a new face
with the tag and return that"
 (let* ((printed (prin1-to-string tag))
	(color (cdr (assoc printed ies-colors-for-tags))))
  (if (not (rassoc color ies-colors-for-tags))
   (push (cons printed (ies-get-next-unique-color)) ies-colors-for-tags))
  (setq ies-last-color color))
 (cdr (assoc (prin1-to-string tag) ies-colors-for-tags)))


;; (insert (prin1-to-string (face-all-attributes 'ies-face-1 (car (frame-list)))))

(defun ies-undo-label-region ()
 ""
 (interactive)
 (kmax-not-yet-implemented))

;; enriched-translations

;; FIXME: This function is total bullshit
(defun ies-list-properties-in-region ()
 ""
 (interactive)
 (let* ((text (buffer-substring (point) (mark)))
	(length (length text)))
  (mapcar (lambda (prop)
	   (let ((prop-string (format "%s" prop)))
	    (list prop (list t prop-string))))
   (remove nil
    (mapcar #'read
     (delete-dups
      (sort
       (mapcar #'prin1-to-string
	(mapcar #'car
	 (mapcar (lambda (n)
		  (nlu-tags (text-properties-at n text)))
	  (seq 0 length))))
       'string<)))))))

(defun ies-list-properties-for-scheme ()
 ""
 (interactive)
 (mapcar (lambda (label)
	  (list (read (concat nlu-property-header label))
		 (list t (concat nlu-property-header label))))
  (ies-labels)))

;; (defun ies-ghost-save-with-properties-and-tags ()
;;  ""
;;  ;; https://ftp.gnu.org/old-gnu/Manuals/elisp-manual-20-2.5/html_node/elisp_514.html#SEC517
;;  ;; write-region-annotate-functions
;;  ;; after-insert-file-functions
;;  )

;; (makunbound 'ies-ghost-save-with-properties-and-tags)

(defun ies-ghost-save-with-properties-and-tags ()
 ""
 (interactive)
 (setq enriched-translations
  '(
    ;; (face
    ;;  (bold-italic "bold" "italic")
    ;;  (bold "bold")
    ;;  (italic "italic")
    ;;  (underline "underline")
    ;;  (fixed "fixed")
    ;;  (excerpt "excerpt")
    ;;  (default)
    ;;  (nil enriched-encode-other-face))
    (left-margin
     (4 "indent"))
    (right-margin
     (4 "indentright"))
    (justification
     (none "nofill")
     (right "flushright")
     (left "flushleft")
     (full "flushboth")
     (center "center"))
    (PARAMETER
     (t "param"))
    (read-only
     (t "x-read-only"))
    (unknown
     (nil format-annotate-value)))
  )
 (mark-whole-buffer)
 (mapcar (lambda (prop-desc) (add-to-list 'enriched-translations prop-desc)) (ies-list-properties-for-scheme)) ;; (ies-list-properties-in-region))
 (set-mark (point))
 (add-to-list 'enriched-ignore 'x-color)
 (add-to-list 'enriched-ignore 'param)
 (save-buffer))

(ies-reset-colors-for-tags)




(defun ies-test-display (a b)
 (see (prin1-to-string (list a b))))

;; (format-annotate-region (mark) (point) enriched-translations 'ies-test-display enriched-ignore)

;; (format-annotate-region (mark) (point) enriched-translations 'enriched-make-annotation enriched-ignore)

;; (format-annotate-location (point) nil enriched-ignore enriched-translations)

;; (format-annotate-single-property-change 'x-nlu-name nil t enriched-translations)





;; format-annotate-region

(defun format-annotate-location (loc all ignore translations)
 "Return annotation(s) needed at location LOC.
This includes any properties that change between LOC - 1 and LOC.
If ALL is true, don't look at previous location, but generate annotations for
all non-nil properties.
Third argument IGNORE is a list of text-properties not to consider.
Use the TRANSLATIONS alist (see `format-annotate-region' for doc).

Return value is a vector of 3 elements:
1. List of annotations to close
2. List of annotations to open.
3. List of properties that were ignored or couldn't be annotated.

The annotations in lists 1 and 2 need not be strings.
They can be whatever the FORMAT-FN in `format-annotate-region'
can handle.  If that is `enriched-make-annotation', they can be
either strings, or lists of the form (PARAMETER VALUE)."
 (let* ((prev-loc (1- loc))
	(before-plist (if all nil (text-properties-at prev-loc)))
	(after-plist (text-properties-at loc))
	p negatives positives prop props not-found)
  ;; make list of all property names involved
  ;; (see before-plist)
  ;; (see after-plist)
  (setq p before-plist)
  (while p
   (if (not (memq (car p) props))
    (push (car p) props))
   (setq p (cdr (cdr p))))
  (setq p after-plist)
  (while p
   (if (not (memq (car p) props))
    (push (car p) props))
   (setq p (cdr (cdr p))))
  (while props
   (setq prop (pop props))
   (if (memq prop ignore)
    nil  ; If it's been ignored before, ignore it now.
    (let ((before (if all nil (car (cdr (memq prop before-plist)))))
	  (after (car (cdr (memq prop after-plist)))))
     (if (equal before after)
      nil ; no change; ignore
      (progn
       ;; (see (list 'format-annotate-single-property-change prop before after translations))
       (let ((result (ies-format-annotate-single-property-change
		      prop before after translations)))
	;; (see result)
	(if (not result)
	 (push prop not-found)
	 (setq negatives (nconc negatives (car result))
	  positives (nconc positives (cdr result))))))))))
  (vector negatives positives not-found)))

;; (let ((result (ies-format-annotate-single-property-change 'x-nlu-name nil t '((x-nlu-name (t "x-nlu-name")) (x-nlu-description (t "x-nlu-description")) (face (bold-italic "bold" "italic") (bold "bold") (italic "italic") (underline "underline") (fixed "fixed") (excerpt "excerpt") (default) (nil enriched-encode-other-face)) (left-margin (4 "indent")) (right-margin (4 "indentright")) (justification (none "nofill") (right "flushright") (left "flushleft") (full "flushboth") (center "center")) (PARAMETER (t "param")) (read-only (t "x-read-only")) (unknown (nil format-annotate-value))))))
;;  (see result))

;; (defun ies-format-annotate-single-property-change (prop before after translations)
;;  (format-annotate-single-property-change prop before after translations))

(defun ies-format-annotate-single-property-change (prop before after translations)
 (let ((prop-string (format "%s" prop)))
  (if (and
       (>= (length prop-string) (length nlu-property-header))
       (string= (substring prop-string 0 (length nlu-property-header)) nlu-property-header))
   (if before (list (list (list prop-string)))
    (if after (list nil (list prop-string))))
   (format-annotate-single-property-change prop before after translations))))

(defun ies-reopen-file-literally ()
 ""
 (interactive)
 (let* ((buffer (current-buffer))
	(file (buffer-file-name buffer)))
  (kill-buffer buffer)
  (find-file-literally file)))

(defun ies-reopen-file-normally ()
 ""
 (interactive)
 (let* ((buffer (current-buffer))
	(file (buffer-file-name buffer)))
  (condition-case nil 
   (save-mark-and-excursion
    (kill-buffer buffer)
    (find-file file)
    (ies-ghost-mode)))))

(defun ies-open-ghosted-html-as-w3m ()
 ""
 (interactive)
 (assert
  (kmax-mode-is-derived-from 'ies-ghost-mode))
 (let ((contents (kmax-buffer-contents))
       (new-buffer-name (concat "Temporary HTML for " (buffer-name (current-buffer)) ".html")))
  (pop-to-buffer (get-buffer-create new-buffer-name))
  (insert contents)
  (write-file (concat "/tmp/" new-buffer-name))
  (html-mode)
  (kmax-view-current-html-file)))

(defun ies-train-region ()
 ""
 (interactive)
 (let ((contents (buffer-substring (point) (mark))))
  (ffap "/var/lib/myfrdcsa/codebases/minor/ies/data-git/train.txt")
  (kmax-clear-buffer)
  (setq-local use-hard-newlines nil)
  (enriched-mode t)
  (insert contents)
  (save-buffer)
  (kill-buffer))
 (shell-command-to-string
  (concat
   "cd /var/lib/myfrdcsa/codebases/minor/ies/scripts/ && ./train.pl  -t "
   (shell-quote-argument ies-current-tokenizer))))

(defun ies-classify-region ()
 ""
 (interactive)
 (save-mark-and-excursion
  (let ((contents (buffer-substring (point) (mark))))
   (ffap "/var/lib/myfrdcsa/codebases/minor/ies/data-git/classify.txt")
   (kmax-clear-buffer)
   (setq-local use-hard-newlines nil)
   (enriched-mode t)
   (insert contents)
   (save-buffer)
   (kill-buffer)))
 (shell-command-to-string
  (concat
   "cd /var/lib/myfrdcsa/codebases/minor/ies/scripts/ && ./classify.pl -t "
   (shell-quote-argument ies-current-tokenizer)))
 (nlu-read-only nil)
 (kmax-replace-region
  (kmax-file-contents-with-properties
   "/var/lib/myfrdcsa/codebases/minor/ies/scripts/untokenize/labeled.txt"))
 (ies-redisplay-text-with-tags-emphasized)
 (nlu-read-only t)
 )

(defun ies-label-at-point-delete ()
 ""
 (interactive)
 (let* ((point (point))
	(mark (mark))
	(tagname (nlu-get-tagname-at-point))
	(beg (progn
	      (nlu-back-to-beginning-of-tag tagname)
	      (point)))
	(end (progn
	      (nlu-forward-to-ending-of-tag tagname)
	      (point))))
  (goto-char point)
  (nlu-remove-tag-at-point)
  (set-mark beg)
  (goto-char end)
  (erc-remove-text-properties-region beg end)
  (ies-redisplay-text-with-tags-emphasized)
  (set-mark mark)
  (goto-char point)))

(defun ies-labels-extract ()
 ""
 (interactive)
 (let ((contents (shell-command-to-string
		  (concat
		   "/var/lib/myfrdcsa/codebases/minor/ies/scripts/extract-labels/extract-labels.pl -f "
		   (shell-quote-argument buffer-file-name)))))
  (kmax-edit-temp-buffer "*LABELS*")
  (insert contents)
  (beginning-of-buffer)))
 

