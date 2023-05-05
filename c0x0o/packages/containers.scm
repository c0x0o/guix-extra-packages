(define-module (c0x0o packages containers)
  #:use-module (guix build-system go)
  #:use-module (guix build-system python)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (gnu packages base)
  #:use-module ((gnu packages containers) #:prefix gnu-containers:)
  #:use-module (gnu packages check)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages golang)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages virtualization))

(define-public buildah
  (package
    (name "buildah")
    (version "1.29.1")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/containers/buildah")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1mcqkz68fjccdla1bgxw57w268a586brm6x28fcm6x425ah0w07h"))))
    (build-system go-build-system)
    (arguments
      (list #:import-path "github.com/containers/buildah/cmd/buildah"
            #:unpack-path "github.com/containers/buildah"
            ; Some dependencies require go-1.18 to build
            #:go go-1.18
            #:tests? #f
            #:install-source? #f
            #:phases
            #~(modify-phases %standard-phases
                (add-after 'unpack 'prepare-install-docs
                  (lambda* (#:key unpack-path #:allow-other-keys)
                    (substitute* (string-append "src/"
                                                unpack-path
                                                "/docs/Makefile")
                      (("../tests/tools/build/go-md2man")
                       (which "go-md2man")))
                    (substitute* (string-append "src/"
                                                unpack-path
                                                "/docs/Makefile")
                      (("/usr/local") (string-append #$output)))))
                (add-after 'build 'build-docs
                  (lambda* (#:key unpack-path #:allow-other-keys)
                    (let*
                      ((doc-path (string-append "src/" unpack-path "/docs")))
                      (invoke "make" "-C" doc-path))))
                (add-after 'install 'install-docs
                  (lambda* (#:key unpack-path #:allow-other-keys)
                    (let*
                      ((doc-path (string-append "src/" unpack-path "/docs")))
                      (invoke "make" "-C" doc-path "install")))))))
    (inputs (list btrfs-progs
                  gnu-containers:cni-plugins
                  gnu-containers:conmon
                  eudev
                  glib
                  gpgme
                  libassuan
                  libseccomp
                  lvm2
                  runc))
    (native-inputs
     (list go-github-com-go-md2man
           gnu-make
           pkg-config))
    (synopsis
     "Build Open Container Initiative images")
    (description
     "Buildah is used to build Open Container Initiative
@acronym{OCI, Open Container Initiative} compatible containers.")
    (home-page "https://buildah.io")
    (license license:asl2.0)))

(define-public podman
  (package
    (inherit gnu-containers:podman)
    (version "4.4.1")
    (outputs '("out" "docker"))
    (properties
      `((output-synopsis "docker" "docker alias for podman")))
    (arguments
      (substitute-keyword-arguments (package-arguments gnu-containers:podman)
        ((#:phases phases)
         #~(modify-phases #$phases
             (add-after 'fix-hardcoded-paths 'fix-docker-hardcoded-paths
               (lambda* (#:key outputs #:allow-other-keys)
                 (substitute* "docker"
                   (("/usr/bin/podman")
                   (string-append (assoc-ref outputs "out")
                                  "/bin/podman")))))
             (add-after 'install 'install-docker-doc
               (lambda* (#:key outputs #:allow-other-keys)
                 (let*
                   ((docker (assoc-ref outputs "docker")))
                   (install-file "docker" (string-append docker "/bin"))))))))
      )))

(define-public podman-compose
  (package
    (name "podman-compose")
    (version "1.0.6")
    (source (origin
              (method url-fetch)
              (uri (pypi-uri "podman-compose" version))
              (sha256
               (base32
                "1rd29mysfdlbvn0m9zfyp2n0v5lch0bsj4fmzyjaal6akw23bcid"))))
    (build-system python-build-system)
    (arguments '(#:tests? #f))
    (inputs (list python-pyyaml
                  python-dotenv))
    (home-page "https://github.com/containers/podman-compose")
    (synopsis "An implementation of Compose Spec with Podman backend")
    (description
     "An implementation of Compose Spec with Podman backend")
    (license license:gpl2)))
