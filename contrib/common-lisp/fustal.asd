(asdf:defsystem #:fustal
  :description "FFI bindings for FUSTAL"
  :author "Ethan Hawk"
  :license "ISC"
  :version "0.0.1"
  :defsystem-depends-on (#:cffi/c2ffi)
  :serial t
  :components ((:file "package")
               (:module "../../output/"
                :components
                ((:cffi/c2ffi-file "fustal.h"
                  :package #:fustal.lib
                  :foreign-library-name "fustal.lib::fustal"
                  :foreign-library-spec
                  ((t (:default "../../output/fustal"))))))))
