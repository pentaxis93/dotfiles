;;; init.el --- Emacs configuration for org-mode planning infrastructure -*- lexical-binding: t; -*-

;; Beadsmith Project Planning Configuration
;; This configuration is designed for agent interaction via emacsclient
;; and provides org-mode with dependencies, queries, and stable identifiers.

;;; Package Management

;; Initialize package system
(require 'package)
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa" . "https://melpa.org/packages/")))
(package-initialize)

;; Refresh package contents if needed (only on first run)
(unless package-archive-contents
  (package-refresh-contents))

;; Helper function for ensuring packages are installed
(defun ensure-package-installed (pkg)
  "Install PKG if not already installed."
  (unless (package-installed-p pkg)
    (package-install pkg)))

;;; Core Org-Mode Configuration

(require 'org)
(require 'org-element)
(require 'org-agenda)
(require 'org-clock)
(require 'org-archive)
(require 'org-id)

;; Org-agenda files - beadsmith planning directory
;; Use absolute path for daemon mode reliability
(setq org-agenda-files '("~/src/beadsmith/planning/"))

;; Org-id configuration for stable unique identifiers
(setq org-id-track-globally t)
(setq org-id-locations-file "~/.config/emacs/.org-id-locations")
(setq org-id-link-to-org-use-id 'create-if-interactive-and-no-custom-id)

;; TODO states for project planning
(setq org-todo-keywords
      '((sequence "TODO(t)" "NEXT(n)" "WAITING(w@/!)" "|" "DONE(d!)" "CANCELLED(c@/!)")))

;; Log when tasks are completed
(setq org-log-done 'time)
(setq org-log-into-drawer t)

;; Archive configuration
(setq org-archive-location "archive.org::* Archived from %s")

;; Clock configuration for time tracking
(setq org-clock-persist t)
(setq org-clock-in-resume t)
(setq org-clock-persist-query-resume nil)
(org-clock-persistence-insinuate)

;;; External Package Installation

;; org-ql - Query language for org content
;; Essential for agent queries like "all blocked tasks" or "next actions by project"
(ensure-package-installed 'org-ql)
(require 'org-ql)

;; org-edna - Extended dependency notation
;; Models task dependencies (BLOCKER, TRIGGER)
(ensure-package-installed 'org-edna)
(require 'org-edna)
(org-edna-mode 1)

;;; Server/Daemon Configuration

;; Start server if not already running (for emacsclient access)
(require 'server)
(unless (server-running-p)
  (server-start))

;;; Utility Functions for Agent Interaction

(defun beadsmith/org-get-todo-state (id)
  "Get the TODO state of the heading with org-id ID."
  (org-with-point-at (org-id-find id 'marker)
    (org-get-todo-state)))

(defun beadsmith/org-set-todo-state (id state)
  "Set the TODO state of heading with org-id ID to STATE."
  (org-with-point-at (org-id-find id 'marker)
    (org-todo state))
  (save-some-buffers t))

(defun beadsmith/org-get-blockers (id)
  "Get BLOCKER property for heading with org-id ID."
  (org-with-point-at (org-id-find id 'marker)
    (org-entry-get nil "BLOCKER")))

(defun beadsmith/org-ql-select-next-actions ()
  "Return all NEXT action items."
  (org-ql-select (org-agenda-files)
    '(todo "NEXT")
    :action '(list (org-id-get-create)
                   (org-get-heading t t t t)
                   (org-entry-get nil "BLOCKER"))))

(defun beadsmith/org-ql-select-blocked ()
  "Return all items that have blockers."
  (org-ql-select (org-agenda-files)
    '(property "BLOCKER")
    :action '(list (org-id-get-create)
                   (org-get-heading t t t t)
                   (org-entry-get nil "BLOCKER"))))

(defun beadsmith/org-ql-select-by-project (project)
  "Return all TODO items under PROJECT heading."
  (org-ql-select (org-agenda-files)
    `(and (todo)
          (ancestors (heading ,project)))
    :action '(list (org-id-get-create)
                   (org-get-heading t t t t)
                   (org-get-todo-state))))

;;; JSON-Returning Agent API
;; These functions return JSON for reliable parsing by external agents.
;; All include error handling and return {success: bool, data/error: ...}

(require 'json)

(defun beadsmith/agent-query (query)
  "Execute org-ql QUERY, return JSON-encoded results.
QUERY should be a valid org-ql query sexp.
Returns JSON with success status and structured task data."
  (condition-case err
      (json-encode
       `(("success" . t)
         ("data" . ,(org-ql-select (org-agenda-files) query
                      :action '(list :id (org-id-get-create)
                                     :heading (substring-no-properties
                                               (org-get-heading t t t t))
                                     :todo (org-get-todo-state)
                                     :tags (org-get-tags)
                                     :priority (org-entry-get (point) "PRIORITY")
                                     :scheduled (org-entry-get (point) "SCHEDULED")
                                     :deadline (org-entry-get (point) "DEADLINE")
                                     :blocker (org-entry-get (point) "BLOCKER")
                                     :file (buffer-file-name)
                                     :line (line-number-at-pos))))))
    (error
     (json-encode `(("success" . :json-false)
                    ("error" . ,(error-message-string err)))))))

(defun beadsmith/agent-get-task (id)
  "Get task details by ID, return JSON-encoded result."
  (condition-case err
      (let ((marker (org-id-find id 'marker)))
        (if marker
            (org-with-point-at marker
              (json-encode
               `(("success" . t)
                 ("data" . ((:id . ,id)
                            (:heading . ,(substring-no-properties
                                          (org-get-heading t t t t)))
                            (:todo . ,(org-get-todo-state))
                            (:tags . ,(org-get-tags))
                            (:priority . ,(org-entry-get (point) "PRIORITY"))
                            (:scheduled . ,(org-entry-get (point) "SCHEDULED"))
                            (:deadline . ,(org-entry-get (point) "DEADLINE"))
                            (:blocker . ,(org-entry-get (point) "BLOCKER"))
                            (:trigger . ,(org-entry-get (point) "TRIGGER"))
                            (:file . ,(buffer-file-name))
                            (:line . ,(line-number-at-pos)))))))
          (json-encode '(("success" . :json-false)
                         ("error" . "ID not found")))))
    (error
     (json-encode `(("success" . :json-false)
                    ("error" . ,(error-message-string err)))))))

(defun beadsmith/agent-complete-task (id)
  "Complete task by ID, firing org-edna triggers. Return JSON status.
Uses org-todo to ensure triggers fire correctly."
  (condition-case err
      (let ((marker (org-id-find id 'marker)))
        (if marker
            (progn
              (org-with-point-at marker
                (let ((org-log-note-state nil))  ; suppress note prompts
                  (org-todo "DONE")))
              (save-some-buffers t)
              (json-encode '(("success" . t))))
          (json-encode '(("success" . :json-false)
                         ("error" . "ID not found")))))
    (error
     (json-encode `(("success" . :json-false)
                    ("error" . ,(error-message-string err)))))))

(defun beadsmith/agent-set-todo-state (id state)
  "Set TODO state of task ID to STATE. Return JSON status.
STATE should be a valid TODO keyword (TODO, NEXT, WAITING, DONE, CANCELLED)."
  (condition-case err
      (let ((marker (org-id-find id 'marker)))
        (if marker
            (progn
              (org-with-point-at marker
                (let ((org-log-note-state nil))  ; suppress note prompts
                  (org-todo state)))
              (save-some-buffers t)
              (json-encode `(("success" . t)
                             ("new_state" . ,state))))
          (json-encode '(("success" . :json-false)
                         ("error" . "ID not found")))))
    (error
     (json-encode `(("success" . :json-false)
                    ("error" . ,(error-message-string err)))))))

(defun beadsmith/agent-task-blocked-p (id)
  "Check if task ID is blocked by org-edna. Return JSON with status.
Checks ids() blockers by verifying referenced tasks are DONE.
Returns blocked=true/false and list of blocking task IDs."
  (condition-case err
      (let ((marker (org-id-find id 'marker)))
        (if marker
            (org-with-point-at marker
              (let* ((blocker-str (org-entry-get nil "BLOCKER"))
                     (blocking-ids nil))
                ;; Parse ids(...) syntax and check each referenced task
                (when (and blocker-str
                           (string-match "ids(\\([^)]+\\))" blocker-str))
                  (let ((id-list (split-string (match-string 1 blocker-str) " " t)))
                    (dolist (dep-id id-list)
                      ;; Remove quotes if present
                      (setq dep-id (replace-regexp-in-string "\"" "" dep-id))
                      (let ((dep-marker (org-id-find dep-id 'marker)))
                        (when dep-marker
                          (org-with-point-at dep-marker
                            (let ((state (org-get-todo-state)))
                              (unless (member state org-done-keywords)
                                (push dep-id blocking-ids)))))))))
                (json-encode `(("success" . t)
                               ("blocked" . ,(if blocking-ids t :json-false))
                               ("blocker_property" . ,blocker-str)
                               ("blocking_tasks" . ,(nreverse blocking-ids))))))
          (json-encode '(("success" . :json-false)
                         ("error" . "ID not found")))))
    (error
     (json-encode `(("success" . :json-false)
                    ("error" . ,(error-message-string err)))))))

(defun beadsmith/agent-list-next-actions ()
  "Return all NEXT actions as JSON."
  (beadsmith/agent-query '(todo "NEXT")))

(defun beadsmith/agent-list-blocked ()
  "Return all tasks with BLOCKER property as JSON."
  (beadsmith/agent-query '(property "BLOCKER")))

(defun beadsmith/agent-list-waiting ()
  "Return all WAITING tasks as JSON."
  (beadsmith/agent-query '(todo "WAITING")))

(defun beadsmith/agent-list-overdue ()
  "Return all overdue tasks as JSON."
  (beadsmith/agent-query '(and (not (done)) (deadline :to -1))))

(defun beadsmith/agent-list-scheduled-today ()
  "Return tasks scheduled for today or earlier as JSON."
  (beadsmith/agent-query '(and (not (done)) (scheduled :to today))))

(provide 'init)
;;; init.el ends here
