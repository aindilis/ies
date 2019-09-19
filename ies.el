;; similar to NLU, but intended to markup text for extraction

(add-to-list 'load-path "/var/lib/myfrdcsa/codebases/minor/ies/frdcsa/emacs")

(global-set-key "\C-cies" 'ies-ghost-buffer)
(global-set-key "\C-cieg" 'ies-ghost-mode)

(define-derived-mode ies-mode
 nlu-mode "IES"
 "Major mode for asserting knowledge about text.
\\{ies-mode-map}"
 (setq case-fold-search nil)
 
 (define-key ies-mode-map "ls" 'ies-load-label-scheme)
 (define-key ies-mode-map "lm" 'ies-load-model)

 (define-key ies-mode-map "lr" 'ies-label-region)

 ;; (suppress-keymap nlu-mode-map)

 ;; ensure buffer is ghosted
 )

(define-derived-mode ies-ghost-mode
 nlu-ghost-mode "IES-Ghost"
 "Major mode for asserting knowledge about text ghost.
\\{ies-ghost-mode-map}"
 (setq case-fold-search nil)
 ;; (define-key nlu-ghost-mode-map "cb" 'clear-queue-current-buffer-referent)
 (nlu-read-only t)

 (define-key ies-ghost-mode-map "ls" 'ies-load-label-scheme)
 (define-key ies-ghost-mode-map "lm" 'ies-load-model)

 (define-key ies-ghost-mode-map "lr" 'ies-label-region)

 (define-key nlu-ghost-mode-map "ts" 'ies-ghost-save-with-properties-and-tags)
 )

(defun ies-ghost-buffer ()
 ""
 (interactive)
 (nlu-ghost-buffer)
 (ies-ghost-mode))

(defvar ies-label-scheme-directory (frdcsa-el-concat-dir (list "/var/lib/myfrdcsa/codebases/minor/ies" "data-git/schemes")))

(defvar ies-current-scheme nil)
(defvar ies-current-scheme-directory nil)

(defvar ies-current-model nil)
(defvar ies-current-model-directory nil)

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

(defun ies-redisplay-text-with-tags-emphasized ()
 "Redraw the text, taking care to colorize and put on special fonts for each text item"
 (interactive)
 (let ((min (min (mark) (point)))
       (max (max (mark) (point))))
  (save-excursion
   (goto-char min)
   (nlu-unlock-temporarily-and-execute
    '(while (<= (point) max)
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
  (mapcar #'read
   (delete-dups
    (sort
     (mapcar #'prin1-to-string
      (mapcar #'car
       (mapcar (lambda (n)
		(nlu-tags (text-properties-at n text)))
	(seq 0 length))))
     'string<)))))

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
 (mark-whole-buffer)
 (setq enriched-translations (ies-list-properties-in-region))
 (save-buffer))

(ies-reset-colors-for-tags)
