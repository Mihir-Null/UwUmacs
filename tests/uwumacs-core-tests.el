;;; uwumacs-core-tests.el --- Native map foundation checks -*- lexical-binding: t; -*-
;; Run with -Q --batch, EMACS_DOTS_TEST_PACKAGES,
;;   -l tests/uwumacs-test-helper.el -l this-file -f ert-run-tests-batch-and-exit

(require 'ert)
(require 'cl-lib)
(require 'seq)
(require 'uwumacs-test-helper)

(defconst uwumacs-core-tests-library-loaded (require 'uwumacs nil t)
  "Non-nil when the production entry point exists and loaded successfully.")


;;;; Native map contract

(ert-deftest uwumacs-native-leader-map ()
  (let ((map (make-sparse-keymap)))
    (keymap-set map "f" (make-sparse-keymap))
    (keymap-set map "f f" #'find-file)
    (should (eq (keymap-lookup map "f f") #'find-file))))


;;;; Public foundation

(ert-deftest uwumacs-core-publishes-the-exact-customization-defaults ()
  "A changed default here would make P02 activate a different physical prefix."
  (should uwumacs-core-tests-library-loaded)
  (should (equal (default-value 'uwumacs-leader-key) "SPC"))
  (should (equal (default-value 'uwumacs-localleader-key) "m"))
  (should (equal (default-value 'uwumacs-leader-alt-key) "C-c C-SPC"))
  (should-not (default-value 'uwumacs-integrations)))

(ert-deftest uwumacs-core-builds-the-owned-find-file-binding-natively ()
  "Removing the core file binding must break native lookup and its owner label."
  (should uwumacs-core-tests-library-loaded)
  (should (keymapp uwumacs-leader-map))
  (should (keymapp uwumacs-user-leader-map))
  (should (eq (keymap-lookup uwumacs-leader-map "f f") #'find-file))
  (should (equal (uwumacs--binding-metadata "f f")
                 '(:owner files :label "Find file"))))


;;;; Native composition and user authority

(ert-deftest uwumacs-core-user-map-wins-and-nil-falls-through ()
  "Reversing composed-map order or treating nil as a block breaks user policy."
  (should uwumacs-core-tests-library-loaded)
  (let ((uwumacs-user-leader-map (make-sparse-keymap)))
    (keymap-set uwumacs-user-leader-map "f" (make-sparse-keymap))
    (should (eq (keymap-lookup (uwumacs--effective-leader-map) "f f")
                #'find-file))
    (keymap-set uwumacs-user-leader-map "f f" #'ignore)
    (should (eq (keymap-lookup (uwumacs--effective-leader-map) "f f")
                #'ignore))))

(ert-deftest uwumacs-core-user-undefined-binding-blocks-fallthrough ()
  "Replacing explicit `undefined' with nil would accidentally expose defaults."
  (should uwumacs-core-tests-library-loaded)
  (let ((uwumacs-user-leader-map (make-sparse-keymap)))
    (keymap-set uwumacs-user-leader-map "f" (make-sparse-keymap))
    (keymap-set uwumacs-user-leader-map "f f" #'undefined)
    (should (eq (keymap-lookup (uwumacs--effective-leader-map) "f f")
                #'undefined))))

(ert-deftest uwumacs-core-higher-priority-source-wins-with-matching-metadata ()
  "Sorting specificity backwards would advertise and execute the common owner."
  (should uwumacs-core-tests-library-loaded)
  (let* ((candidate
          (uwumacs--build-map-candidate
           '((:owner common :priority 0
              :bindings (("x" ignore "Common action")))
              (:owner specific :priority 20
               :bindings (("x" ignore-errors "Specific action"))))))
         (map (plist-get candidate :map))
         (metadata (plist-get candidate :metadata)))
    (should (eq (keymap-lookup map "x") #'ignore-errors))
    (should (equal (uwumacs--binding-metadata "x" metadata)
                   '(:owner specific :label "Specific action")))))

(ert-deftest uwumacs-core-equivalent-key-spellings-share-owner-metadata ()
  "Textual metadata keys must not disagree with native event-identity lookup."
  (should uwumacs-core-tests-library-loaded)
  (let* ((candidate
          (uwumacs--build-map-candidate
           '((:owner low :priority 0
              :bindings (("C-i" forward-char "Low")))
             (:owner high :priority 20
              :bindings (("TAB" backward-char "High"))))))
         (map (plist-get candidate :map))
         (metadata (plist-get candidate :metadata))
         (expected '(:owner high :label "High")))
    (should (equal (key-parse "C-i") (key-parse "TAB")))
    (should (eq (keymap-lookup map "C-i") #'backward-char))
    (should (equal (uwumacs--binding-metadata "C-i" metadata) expected))
    (should (equal (uwumacs--binding-metadata "TAB" metadata) expected))))

(ert-deftest uwumacs-core-explicit-empty-metadata-does-not-read-active-table ()
  "An empty candidate table must remain distinguishable from an omitted table."
  (should uwumacs-core-tests-library-loaded)
  (should (uwumacs--binding-metadata "f f"))
  (should-not (uwumacs--binding-metadata "f f" nil)))


;;;; Transactional validation

(ert-deftest uwumacs-core-duplicate-defaults-name-both-owners-and-keep-active-map ()
  "Silent equal-priority replacement would make load order part of the API."
  (should uwumacs-core-tests-library-loaded)
  (let ((old-map uwumacs-leader-map)
        (old-metadata uwumacs--leader-metadata)
        message)
    (condition-case err
        (uwumacs--replace-leader-definitions
         '((:owner files :priority 10
            :bindings (("f f" find-file "Find file")))
           (:owner project :priority 10
            :bindings (("f f" project-find-file "Project file")))))
      (error (setq message (error-message-string err))))
    (should (string-match-p "files" message))
    (should (string-match-p "project" message))
    (should (eq uwumacs-leader-map old-map))
    (should (eq uwumacs--leader-metadata old-metadata))
    (should (eq (keymap-lookup uwumacs-leader-map "f f") #'find-file))))

(ert-deftest uwumacs-core-prefix-collision-names-both-owners-and-keeps-active-map ()
  "A leaf that occupies another owner's prefix must fail before map replacement."
  (should uwumacs-core-tests-library-loaded)
  (let ((old-map uwumacs-leader-map)
        message)
    (condition-case err
        (uwumacs--replace-leader-definitions
         '((:owner files :priority 10
            :bindings (("f" find-file "Find file")))
           (:owner project :priority 10
            :bindings (("f p" project-switch-project "Switch project")))))
      (error (setq message (error-message-string err))))
    (should (string-match-p "files" message))
    (should (string-match-p "project" message))
    (should (eq uwumacs-leader-map old-map))))

(ert-deftest uwumacs-core-custom-prefixes-reject-leader-alt-overlap ()
  "Allowing either prefix to contain the other makes activation ambiguous."
  (should uwumacs-core-tests-library-loaded)
  (dolist (candidate '("SPC m" "C-c"))
    (let ((old-leader uwumacs-leader-key)
          (old-alt uwumacs-leader-alt-key)
          (old-map uwumacs-leader-map))
      (should-error
       (if (equal candidate "SPC m")
           (customize-set-variable 'uwumacs-leader-alt-key candidate)
         (customize-set-variable 'uwumacs-leader-key candidate)))
      (should (equal uwumacs-leader-key old-leader))
      (should (equal uwumacs-leader-alt-key old-alt))
      (should (eq uwumacs-leader-map old-map)))))

(ert-deftest uwumacs-core-invalid-customization-retains-values-and-maps ()
  "Setting an invalid key must not partly commit customization or active maps."
  (should uwumacs-core-tests-library-loaded)
  (let ((old-leader uwumacs-leader-key)
        (old-localleader uwumacs-localleader-key)
        (old-alt uwumacs-leader-alt-key)
        (old-map uwumacs-leader-map)
        (old-metadata uwumacs--leader-metadata))
    (should-error
     (customize-set-variable 'uwumacs-localleader-key "C-"))
    (should (equal uwumacs-leader-key old-leader))
    (should (equal uwumacs-localleader-key old-localleader))
    (should (equal uwumacs-leader-alt-key old-alt))
    (should (eq uwumacs-leader-map old-map))
    (should (eq uwumacs--leader-metadata old-metadata))))

(ert-deftest uwumacs-core-metadata-holds-labels-and-owners-not-commands ()
  "Copying commands into metadata would create a second executable binding tree."
  (should uwumacs-core-tests-library-loaded)
  (let ((entry (uwumacs--binding-metadata "f f")))
    (should (equal (sort (mapcar #'car (seq-partition entry 2))
                         (lambda (left right)
                           (string< (symbol-name left) (symbol-name right))))
                   '(:label :owner)))
    (should-not (memq #'find-file entry))))

(provide 'uwumacs-core-tests)

;;; uwumacs-core-tests.el ends here
