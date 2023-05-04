(define-module (c0x0o packages perl-text)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (guix download)
  #:use-module (guix packages)
  #:use-module (guix build-system perl))

(define-public perl-podlators
  (package
    (name "perl-podlators")
    (version "5.01")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "mirror://cpan/authors/id/R/RR/RRA/podlators-" version
                    ".tar.gz"))
              (sha256
               (base32
                "0wdw41q5pq96jqiwgwli4k77h3zlbanqywbdrrdhjzx4y7wivzfc"))))
    (build-system perl-build-system)
    (home-page "https://www.eyrie.org/~eagle/software/podlators/")
    (synopsis "Translator for @acronym{POD, Plain Old Documentation}")
    (description
     "Podlators convert @acronym{POD, Plain Old Documentation}
input to *roff source output, suitable for man pages, or plain text.")
    (license license:perl-license)))
