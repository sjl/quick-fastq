(asdf:defsystem :quick-fastq
  :description "A tool for quickly generating synthetic FASTQ files."
  :author "Steve Losh <steve@stevelosh.com>"
  :homepage "https://github.com/sjl/quick-fastq"

  :license "GPL-3.0-or-later"

  :depends-on (:alexandria :iterate)

  :serial t
  :components ((:file "quick-fastq")))


