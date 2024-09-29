;;; bakefile-mode.el -- Emacs major mode for editing Bakefiles and developing bake.
;;; Commentary:
;;;
;;; bakefile-mode is an Emacs major mode for editing Bakefiles and developing bake.
;;; bake can be found on github: https://github.com/kyleburton/bake
;;;

;;; Code:

;; followed this guide: https://www.omarpolo.com/post/writing-a-major-mode.html

(defconst bakefile--font-lock-defaults
  (let ((keywords '("bake_task"))
        (types '("BAKEFILE" "BAKEPATH")))
    `(((,(rx-to-string `(: (or ,@keywords))) 0 font-lock-keyword-face)
       ("\\([[:word:]]+\\)\s*(" 1 font-lock-function-name-face)
       (,(rx-to-string `(: (or ,@types))) 0 font-lock-type-face)))))

;; TODO: bake and bakefiles are bash so we should be "derived" from bash and not need a syntax table
;; (defvar bakefile-mode-syntax-table
;;   (let ((st (make-syntax-table)))
;;     (modify-syntax-entry ?\{ "(}" st)
;;     (modify-syntax-entry ?\} "){" st)
;;     (modify-syntax-entry ?\( "()" st)

;;     ;; - and _ are word constituents
;;     (modify-syntax-entry ?_ "w" st)
;;     (modify-syntax-entry ?- "w" st)

;;     ;; both single and double quotes makes strings
;;     (modify-syntax-entry ?\" "\"" st)
;;     (modify-syntax-entry ?' "'" st)

;;     ;; add comments. lua-mode does something similar, so it shouldn't
;;     ;; bee *too* wrong.
;;     (modify-syntax-entry ?# "<" st)
;;     (modify-syntax-entry ?\n ">" st)

;;     ;; '==' as punctuation
;;     (modify-syntax-entry ?= ".")
;;     st))

(defvar bakefile-mode-abbrev-table nil
  "Abbreviation table used in `bakefile-mode' buffers.")

(define-abbrev-table 'bakefile-mode-abbrev-table
  '())

;; keymappings

(defvar bakefile-mode-local-keymap
  (let ((map (make-sparse-keymap)))
    (define-key map "\C-cbnt" 'bakefile-interactive-new-task)
    (define-key map "\C-cbda" 'bakefile-interactive-document-api)
    (define-key map "\C-cbdt" 'bakefile-interactive-document-task)
    ;; insert stanza for while [[ $1 == --* ]] + case statement
    (define-key map "\C-cbpo" 'bakefile-interactive-parse-options)
    map)
  "My special key map.")

;;;###autoload
(define-derived-mode bakefile-mode shell-script-mode "Bakefile"
  "Major mode for Bakefile files and developing bake."
  :abbrev-table bakefile-mode-abbrev-table
  (setq font-lock-defaults bakefile--font-lock-defaults)
  (setq-local indent-tabs-mode nil))

;;;###autoload
(add-to-list 'auto-mode-alist '("Bakefile" . bakefile-mode))

(provide 'bakefile-mode)
;;; bakefile-mode.el ends here
