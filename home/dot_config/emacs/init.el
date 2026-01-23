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

(provide 'init)
;;; init.el ends here
