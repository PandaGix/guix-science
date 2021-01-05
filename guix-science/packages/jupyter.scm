;;;
;;; Copyright © 2019–2021 Lars-Dominik Braun <ldb@leibniz-psychology.org>
;;;
;;; This program is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(define-module (guix-science packages jupyter)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages check)
  #:use-module (gnu packages haskell-xyz)
  #:use-module (gnu packages monitoring)
  #:use-module (gnu packages node)
  #:use-module (gnu packages sphinx)
  #:use-module (gnu packages python-check)
  #:use-module (gnu packages python-crypto)
  #:use-module (gnu packages python-web)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages textutils)
  #:use-module (gnu packages tex)
  #:use-module (gnu packages time)
  #:use-module (gnu packages xml)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix hg-download)
  #:use-module (guix utils)
  #:use-module (guix build-system python)
  #:use-module (srfi srfi-1))

;; External dependencies

(define-public python-requests-unixsocket
  (package
    (name "python-requests-unixsocket")
    (version "0.2.0")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "requests-unixsocket" version))
       (sha256
        (base32
         "1sn12y4fw1qki5gxy9wg45gmdrxhrndwfndfjxhpiky3mwh1lp4y"))))
    (build-system python-build-system)
    (arguments
     '(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'patch-setuppy
           ;; Relax version requirements, works fine.
           (lambda* (#:key inputs configure-flags #:allow-other-keys)
             (substitute* "test-requirements.txt"
                 (("==[0-9.]+") ""))
             #t))
         (replace 'check
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (add-installed-pythonpath inputs outputs)
             (invoke "pytest" "-v") #t)))))
    (propagated-inputs
     `(("python-requests" ,python-requests)
       ("python-urllib3" ,python-urllib3)))
    (native-inputs
     ;; pbr is required for setup only
     `(("python-pbr" ,python-pbr)
       ("python-waitress" ,python-waitress)
       ("python-apipkg" ,python-apipkg)
       ("python-appdirs" ,python-appdirs)
       ("python-execnet" ,python-execnet)
       ("python-packaging" ,python-packaging)
       ("python-pep8" ,python-pep8)
       ("python-py" ,python-py)
       ("python-pyparsing" ,python-pyparsing)
       ("python-pytest" ,python-pytest)
       ("python-pytest-cache" ,python-pytest-cache)
       ("python-six" ,python-six)
       ("python-pytest-pep8" ,python-pytest-pep8)))
    (home-page
     "https://github.com/msabramo/requests-unixsocket")
    (synopsis
     "Use requests to talk HTTP via a UNIX domain socket")
    (description
     "Use requests to talk HTTP via a UNIX domain socket")
    (license license:asl2.0)))

;; Jupyter depends on 0.9, which switched to pytest.
(define-public python-terminado-0.9.2
  (package
    (name "python-terminado")
    (version "0.9.2")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "terminado" version))
       (sha256
        (base32
         "0k3hr5dgd5jaba8lx4rmyydqmiswypx8v47x1z79vg74355xkrl9"))))
    (build-system python-build-system)
    (propagated-inputs
     `(("python-tornado" ,python-tornado-6.1) ; CommonTests fail with tornado <6.1
       ("python-ptyprocess" ,python-ptyprocess)))
    (native-inputs
     `(("python-pytest" ,python-pytest)))
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (replace 'check
           (lambda _ (invoke "pytest" "-v") #t)))))
    (home-page "https://github.com/takluyver/terminado")
    (synopsis "Terminals served to term.js using Tornado websockets")
    (description "This package provides a Tornado websocket backend for the
term.js Javascript terminal emulator library.")
    (license license:bsd-2)))

(define-public python-testpath-0.4
  (package
    (name "python-testpath")
    (version "0.4.4")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "testpath" version))
        (sha256
          (base32
            "0zpcmq22dz79ipvvsfnw1ykpjcaj6xyzy7ws77s5b5ql3hka7q30"))))
    (build-system python-build-system)
    (propagated-inputs
      `(("python-pathlib2" ,python-pathlib2)))
    (home-page "https://github.com/jupyter/testpath")
    (synopsis
      "Test utilities for code working with files and commands")
    (description
      "Test utilities for code working with files and commands")
    (license license:bsd-3)))

(define-public python-json-spec
  (package
    (name "python-json-spec")
    (version "0.10.1")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "json-spec" version))
        (sha256
          (base32
            "06dpbsq61ja9r89wpa2pzdii47qh3xri9ajdrgn1awfl102znchb"))))
    (build-system python-build-system)
    (propagated-inputs
      `(("python-pathlib" ,python-pathlib)
        ("python-six" ,python-six)))
    (native-inputs
      `(("python-pytest" ,python-pytest)))
    (home-page "http://py.errorist.io/json-spec")
    (synopsis
      "Implements JSON Schema, JSON Pointer and JSON Reference.")
    (description
      "Implements JSON Schema, JSON Pointer and JSON Reference.")
    (license license:bsd-3)))

(define-public python-fastjsonschema
  (package
    (name "python-fastjsonschema")
    (version "2.14.5")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "fastjsonschema" version))
        (sha256
          (base32
            "1550bxk4r9z53c25da5cpwm25ng4282ik05adkj5cqzhamb27g5g"))))
    (build-system python-build-system)
    (native-inputs
      `(("python-colorama" ,python-colorama)
        ("python-json-spec" ,python-json-spec)
        ("python-jsonschema" ,python-jsonschema)
        ("python-pylint" ,python-pylint)
        ("python-pytest" ,python-pytest)
        ("python-pytest-benchmark"
         ,python-pytest-benchmark)
        ("python-pytest-cache" ,python-pytest-cache)
        ("python-validictory" ,python-validictory)))
    (home-page
      "https://github.com/seznam/python-fastjsonschema")
    (synopsis
      "Fastest Python implementation of JSON schema")
    (description
      "Fastest Python implementation of JSON schema")
    (license license:bsd-3)))

(define-public python-json5-0.9.4
  (package
    (inherit python-json5)
    (name "python-json5")
    (version "0.9.4")
    (source
     (origin
       ;; sample.json5 is missing from PyPi source tarball
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/dpranke/pyjson5.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "14878npsn7f344pwkxcnw40lc0waqgpi8j25akd7qxlwd7nchy40"))))))

(define-public python-strict-rfc3339
  (package
    (name "python-strict-rfc3339")
    (version "0.7")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "strict-rfc3339" version))
        (sha256
          (base32
            "0xqjbsn0g1h88rayh5yrpdagq60zfwrfs3yvk6rmgby3vyz1gbaw"))))
    (build-system python-build-system)
    (home-page
      "http://www.danielrichman.co.uk/libraries/strict-rfc3339.html")
    (synopsis
      "Strict, simple, lightweight RFC3339 functions")
    (description
      "Strict, simple, lightweight RFC3339 functions")
    (license #f)))

(define-public python-anyio
  (package
    (name "python-anyio")
    (version "2.0.2")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "anyio" version))
        (sha256
          (base32
            "0dx2gkgy6ggksb45g8pbj99jvfc09rhy7zp21dzgs86g6ayml1rm"))))
    (build-system python-build-system)
    (propagated-inputs
      `(("python-async-generator"
         ,python-async-generator)
        ;("python-dataclasses" ,python-dataclasses) ; Backport for Python 3.6
        ("python-idna" ,python-idna)
        ("python-sniffio" ,python-sniffio)
        ("python-typing-extensions"
         ,python-typing-extensions)))
    (native-inputs
      `(("python-coverage" ,python-coverage)
        ("python-hypothesis" ,python-hypothesis)
        ("python-pytest" ,python-pytest)
        ("python-trustme" ,python-trustme)
        ("python-uvloop" ,python-uvloop)
        ("python-setuptools-scm" ,python-setuptools-scm)))
    (home-page "")
    (synopsis
      "High level compatibility layer for multiple asynchronous event loop implementations")
    (description
      "High level compatibility layer for multiple asynchronous event loop implementations")
    (license license:expat)))

(define-public python-pytest-console-scripts
  (package
    (name "python-pytest-console-scripts")
    (version "1.1.0")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "pytest-console-scripts" version))
        (sha256
          (base32
            "1zfcy7q8cwqxm6a3wlziqk872h0998jp1cin7r09d00dx19lhd61"))))
    (build-system python-build-system)
    (arguments
     '(#:tests? #f ; some tests fail
       #:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'patch-python
           (lambda* (#:key inputs configure-flags #:allow-other-keys)
             (let* ((python (assoc-ref inputs "python"))
                    (python-exe (string-append python "/bin/python")))
               (substitute* "pytest_console_scripts.py"
                 (("'python'")
                  (string-append "'" python-exe "'"))))
             #t)))))
    (propagated-inputs
      `(("python-mock" ,python-mock)
        ("python-pytest" ,python-pytest)))
    (native-inputs
      `(("python-setuptools-scm" ,python-setuptools-scm)
        ("python-pytest-runner" ,python-pytest-runner)))
    (home-page
      "https://github.com/kvas-it/pytest-console-scripts")
    (synopsis
      "Pytest plugin for testing console scripts")
    (description
      "Pytest plugin for testing console scripts")
    (license license:expat)))

(define-public python-pytest-tornasync
  (package
    (name "python-pytest-tornasync")
    (version "0.6.0.post2")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "pytest-tornasync" version))
        (sha256
          (base32
            "0pdyddbzppkfqwa7g17sdfl4w2v1hgsky78l8f4c1rx2a7cvd0fp"))))
    (build-system python-build-system)
    (arguments
      `(#:tests? #f ; Fails with import error.
        #:phases
         (modify-phases %standard-phases
           (replace 'check
             (lambda* (#:key tests? #:allow-other-keys)
               (when tests?
                 (invoke "pytest" "-vv" "test")))))))
    (propagated-inputs
      `(("python-pytest" ,python-pytest)
        ("python-tornado" ,python-tornado-6.1)))
    (home-page
      "https://github.com/eukaryote/pytest-tornasync")
    (synopsis
      "py.test plugin for testing Python 3.5+ Tornado code")
    (description
      "py.test plugin for testing Python 3.5+ Tornado code")
    (license #f)))

(define-public python-tornado-6.1
  (package
    (name "python-tornado")
    (version "6.1")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "tornado" version))
        (sha256
          (base32
            "14cpzdv6p6qvk6vn02krdh5rcfdi174ifdbr5s6lcnymgcfyiiik"))))
    (build-system python-build-system)
    (arguments `(#:tests? #f)) ; XXX: missing dependencies
    (home-page "http://www.tornadoweb.org/")
    (synopsis
      "Tornado is a Python web framework and asynchronous networking library, originally developed at FriendFeed.")
    (description
      "Tornado is a Python web framework and asynchronous networking library, originally developed at FriendFeed.")
    (license #f)))

(define-public python-pytest-check-links-with-updates
  (let ((parent python-pytest-check-links))
    (package
    (inherit parent)
    (propagated-inputs
      `(("python-nbconvert" ,python-nbconvert-6.0)
        ("python-nbformat" ,python-nbformat-5.0)
        ,@(fold alist-delete (package-propagated-inputs parent)
                 '("python-nbconvert" "python-nbformat")))))))

(define-public python-pytest-dependency
  (package
    (name "python-pytest-dependency")
    (version "0.5.1")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "pytest-dependency" version))
        (sha256
          (base32
            "0swl3mxca7nnjbb5grfzrm3fa2750h9vjsha0f2kyrljc6895a62"))))
    (build-system python-build-system)
    (propagated-inputs
      `(("python-pytest" ,python-pytest)))
    (home-page
      "https://github.com/RKrahl/pytest-dependency")
    (synopsis "Manage dependencies of tests")
    (description "Manage dependencies of tests")
    (license #f)))

(define-public python-nest-asyncio
  (package
    (name "python-nest-asyncio")
    (version "1.4.1")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "nest_asyncio" version))
        (sha256
          (base32
            "00afn4h0gh2aa5lb1x3ql5lh6s0wqx5qjyccrzn2wnysmf9k2v5q"))))
    (build-system python-build-system)
    (home-page
      "https://github.com/erdewit/nest_asyncio")
    (synopsis
      "Patch asyncio to allow nested event loops")
    (description
      "Patch asyncio to allow nested event loops")
    (license license:bsd-3)))


;; Jupyter components

(define-public python-jupyter-core-4.7
  (package
    (name "python-jupyter-core")
    (version "4.7.0")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "jupyter_core" version))
       (sha256
        (base32
         "1lwfvmm8qj873q3rl7sq2iwrjcr2rfqal3gy9vd75gismfb987xa"))))
    (build-system python-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (replace 'check
           (lambda* (#:key inputs outputs tests? #:allow-other-keys)
            (if tests?
             (begin
              ; Some tests write to $HOME.
              (setenv "HOME" "/tmp")
              ; Some tests load the installed package.
              (add-installed-pythonpath inputs outputs)
              (invoke "pytest" "-vv")))))
         (add-after 'unpack 'patch-testsuite
           (lambda _
             ;; test_not_on_path() and test_path_priority() try to run a test
             ;; that loads jupyter_core, so we need PYTHONPATH
             (substitute* "jupyter_core/tests/test_command.py"
               (("env = \\{'PATH': ''\\}")
                "env = {'PATH': '', 'PYTHONPATH': os.environ['PYTHONPATH']}")
               (("env = \\{'PATH':  str\\(b\\)\\}")
                "env = {'PATH': str(b), 'PYTHONPATH': os.environ['PYTHONPATH']}"))
             #t)))))
    (propagated-inputs
     `(("python-traitlets" ,python-traitlets)))
    (native-inputs
     `(("python-six" ,python-six)
       ("python-pytest" ,python-pytest)))
    ;; This package provides the `jupyter` binary and thus, should also export the
    ;; search paths instead of the jupyter meta-package.
    (native-search-paths
     (list (search-path-specification
            (variable "JUPYTER_CONFIG_DIR")
            (files '("etc/jupyter")))
           (search-path-specification
            (variable "JUPYTER_PATH")
            (files '("share/jupyter")))))
    (home-page "https://jupyter.org")
    (synopsis
     "Jupyter core package. A base package on which Jupyter projects rely.")
    (description
     "Jupyter core package. A base package on which Jupyter projects rely.")
    (license license:bsd-3)))

(define-public python-nbclassic
  (package
    (name "python-nbclassic")
    (version "0.2.5")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "nbclassic" version))
        (sha256
          (base32
            "1as08rdvivsjgi7q65c3mx55c34s7jlqxks25zk3v9knmcb23np6"))))
    (build-system python-build-system)
    (propagated-inputs
      `(("python-jupyter-server" ,python-jupyter-server)
        ("python-notebook" ,python-notebook-6.1)))
    (native-inputs
      `(("python-pytest" ,python-pytest)
        ("python-pytest-console-scripts"
         ,python-pytest-console-scripts)
        ("python-pytest-tornasync"
         ,python-pytest-tornasync)))
    (home-page "http://jupyter.org")
    (synopsis
      "Jupyter Notebook as a Jupyter Server Extension.")
    (description
      "Jupyter Notebook as a Jupyter Server Extension.")
    (license license:bsd-3)))

(define-public python-nbformat-5.0
  (package
    (name "python-nbformat")
    (version "5.0.8")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "nbformat" version))
        (sha256
          (base32
            "1y1h59q6z3hdlqn6z1zysk2jv3ibbbnqkzhzdg6gnnw670hv4igm"))))
    (build-system python-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (replace 'check
           (lambda* (#:key inputs outputs tests? #:allow-other-keys)
            (if tests?
             (begin
              (invoke "pytest" "-vv"))))))))
    (propagated-inputs
      `(("python-ipython-genutils"
         ,python-ipython-genutils)
        ("python-jsonschema" ,python-jsonschema)
        ("python-jupyter-core" ,python-jupyter-core-4.7)
        ("python-traitlets" ,python-traitlets)))
    (native-inputs
      `(("python-pytest" ,python-pytest)
        ("python-pytest-cov" ,python-pytest-cov)
        ("python-fastjsonschema" ,python-fastjsonschema) ; This is only active
        ; when setting NBFORMAT_VALIDATOR="fastjsonschema", so include it for
        ; testing only.
        ("python-testpath" ,python-testpath-0.4)))
    (home-page "http://jupyter.org")
    (synopsis "The Jupyter Notebook format")
    (description "The Jupyter Notebook format")
    (license license:bsd-3)))

(define-public python-jupyter-client-6.1
  (package
    (name "python-jupyter-client")
    (version "6.1.7")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "jupyter_client" version))
       (sha256
        (base32
         "18bpjg81q8h567784s0vc2iz20xrky6s4kkh4ikj5d74dyrr1qs9"))))
    (build-system python-build-system)
    (arguments
     '(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'patch-testsuite
           (lambda _
             ;; There is no such argument “encoding”.
             (substitute* "jupyter_client/tests/test_session.py"
               (("msgpack.unpackb\\(buf, encoding='utf8'\\)")
                "msgpack.unpackb(buf)"))
             ;; Test fails for unknown reason.
             (substitute* "jupyter_client/tests/test_session.py"
               (("import hmac" all) (string-append all "\nimport unittest"))
               (("(.+)(def test_tracking)" all indent def)
                (string-append indent "@unittest.skip('disabled by guix')\n"
                               indent def)))
             #t))
         (replace 'check
           (lambda* (#:key tests? #:allow-other-keys)
            (if tests?
             (begin
               ;; Some tests try to write to $HOME.
               (setenv "HOME" "/tmp")
               (invoke "pytest" "-vv"))))))))
    (propagated-inputs
     `(("python-dateutil" ,python-dateutil)
       ("python-jupyter-core" ,python-jupyter-core-4.7)
       ("python-pyzmq" ,python-pyzmq)
       ("python-tornado" ,python-tornado-6.1)
       ("python-traitlets" ,python-traitlets)))
    (native-inputs
     `(("python-async-generator"
        ,python-async-generator)
       ("python-ipykernel" ,python-ipykernel-5.4-bootstrap)
       ("python-ipython" ,python-ipython-with-updates)
       ("python-mock" ,python-mock)
       ("python-msgpack" ,python-msgpack)
       ("python-pytest" ,python-pytest)
       ("python-pytest-asyncio" ,python-pytest-asyncio)
       ("python-pytest-timeout" ,python-pytest-timeout)))
    (home-page "https://jupyter.org")
    (synopsis
     "Jupyter protocol implementation and client libraries")
    (description
     "Jupyter protocol implementation and client libraries")
    (license license:bsd-3)))

;; Upstream version with dep to ipykernel removed.
(define-public python-jupyter-client-6.1-bootstrap
  (let ((base python-jupyter-client-6.1))
    (package
      (inherit base)
      (name "python-jupyter-client-bootstrap")
      (arguments
       `(#:tests? #f
         ,@(package-arguments base)))
      ;; Remove loop ipykernel <-> jupyter-client
      (native-inputs `()))))

(define-public python-ipython-with-updates
  (let ((parent python-ipython))
    (package
    (inherit parent)
    (propagated-inputs
      `(("python-terminado" ,python-terminado-0.9.2)
        ("python-nbformat" ,python-nbformat-5.0)
        ,@(fold alist-delete (package-propagated-inputs parent)
                 '("python-terminado" "python-nbformat"))))
    (native-inputs
      `(("python-testpath" ,python-testpath-0.4)
        ,@(fold alist-delete (package-native-inputs parent)
                 '("python-testpath")))))))

(define-public python-ipykernel-5.4
  (package
    (inherit python-ipykernel)
    (name "python-ipykernel")
    (version "5.4.2")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "ipykernel" version))
       (sha256
        (base32
         "10p180bn1dmbqwmnnv6l7grj68qbdvkhn8z1a822akfba9zfn372"))))
    (propagated-inputs
     `(("python-ipython" ,python-ipython-with-updates)
       ("python-jupyter-client" ,python-jupyter-client-6.1)
       ("python-tornado" ,python-tornado-6.1)
       ("python-traitlets" ,python-traitlets)))
    (native-inputs
     `(("python-flaky" ,python-flaky)
       ("python-nose" ,python-nose)
       ("python-pytest" ,python-pytest)
       ("python-pytest-cov" ,python-pytest-cov)))))

;; Create a bootstrap variant, which can be used in python-jupyter-client-6.1’s
;; native-arguments
(define-public python-ipykernel-5.4-bootstrap
  (let ((parent python-ipykernel-5.4))
    (package
    (inherit parent)
    (name "python-ipykernel-bootstrap")
    (propagated-inputs
      `(("python-jupyter-client" ,python-jupyter-client-6.1-bootstrap)
        ,@(fold alist-delete (package-propagated-inputs parent)
               '("python-jupyter-client")))))))

(define-public python-jupyterlab-pygments
  (package
    (name "python-jupyterlab-pygments")
    (version "0.1.2")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "jupyterlab_pygments" version))
        (sha256
          (base32
            "0ij14mmnc39nmf84i0av6j9glazjic7wzv1qyhr0j5966s3s1kfg"))))
    (build-system python-build-system)
    (propagated-inputs
      `(("python-pygments" ,python-pygments)))
    (home-page "http://jupyter.org")
    (synopsis
      "Pygments theme using JupyterLab CSS variables")
    (description
      "Pygments theme using JupyterLab CSS variables")
    (license license:bsd-3)))

(define-public python-nbconvert-6.0
  (package
    (name "python-nbconvert")
    (version "6.0.7")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "nbconvert" version))
        (sha256
          (base32
            "00lhqaxn481qvk2w5568asqlsnvrw2fm61p1vssx3m7vdnl17g6b"))))
    (build-system python-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'fix-paths-and-tests
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (let* ((pandoc (string-append (assoc-ref inputs "pandoc") "/bin/pandoc"))
                   (texlive-root (string-append (assoc-ref inputs "texlive")))
                   (xelatex (string-append texlive-root "/bin/xelatex"))
                   (bibtex (string-append texlive-root "/bin/bibtex")))
               ;; Use pandoc binary from input.
               (substitute* "nbconvert/utils/pandoc.py"
                 (("'pandoc'") (string-append "'" pandoc "'")))
               ;; Same for LaTeX.
               (substitute* "nbconvert/exporters/pdf.py"
                 (("\"xelatex\"") (string-append "\"" xelatex "\""))
                 (("\"bibtex\"") (string-append "\"" bibtex "\"")))
               ;; Make sure tests are not skipped.
               (substitute* (find-files "." "test_.+\\.py$")
                 (("@onlyif_cmds_exist\\(('(pandoc|xelatex)'(, )?)+\\)") ""))
              ;; Pandoc is never missing, disable test.
              (substitute* "nbconvert/utils/tests/test_pandoc.py"
                (("import os" all) (string-append all "\nimport pytest"))
                (("(.+)(def test_pandoc_available)" all indent def)
                (string-append indent "@pytest.mark.skip('disabled by guix')\n"
                               indent def)))
              ; Not installing pyppeteer, delete test.
              (delete-file "nbconvert/exporters/tests/test_webpdf.py")
              (substitute* "nbconvert/tests/test_nbconvertapp.py"
                (("(.+)(def test_webpdf_with_chromium)" all indent def)
                (string-append indent "@pytest.mark.skip('disabled by guix')\n"
                               indent def)))
             #t)))
         (replace 'check
           (lambda* (#:key inputs outputs tests? #:allow-other-keys)
            (if tests?
             (begin
              ; Tries to write to this path.
              (unsetenv "JUPYTER_CONFIG_DIR")
              ; Some tests write to $HOME.
              (setenv "HOME" "/tmp")
              ; Tests depend on templates installed to output.
              (setenv "JUPYTER_PATH"
                      (string-append
                        (assoc-ref outputs "out")
                        "/share/jupyter:"
                        (getenv "JUPYTER_PATH")))
              ; Some tests invoke the installed nbconvert binary.
              (add-installed-pythonpath inputs outputs)
              (invoke "pytest" "-vv"))))))))
    (inputs
      `(("pandoc" ,pandoc)
        ; XXX: Disabled, needs substitute*.
        ;("inkscape" ,inkscape)
        ("texlive" ,texlive)))
    (propagated-inputs
      `(("python-bleach" ,python-bleach)
        ("python-defusedxml" ,python-defusedxml)
        ("python-entrypoints" ,python-entrypoints)
        ("python-jinja2" ,python-jinja2)
        ("python-jupyter-core" ,python-jupyter-core-4.7)
        ("python-jupyterlab-pygments"
         ,python-jupyterlab-pygments)
        ("python-mistune" ,python-mistune)
        ("python-nbclient" ,python-nbclient-0.5)
        ("python-nbformat" ,python-nbformat-5.0)
        ("python-pandocfilters" ,python-pandocfilters)
        ("python-pygments" ,python-pygments)
        ("python-testpath" ,python-testpath-0.4)
        ("python-traitlets" ,python-traitlets)
        ;; Required, even if [serve] is not used.
        ("python-tornado" ,python-tornado-6.1)))
    (native-inputs
      `(("python-ipykernel" ,python-ipykernel-5.4)
        ("python-ipywidgets" ,python-ipywidgets-7.6)
        ; XXX: Disabled, not in guix.
        ;("python-pyppeteer" ,python-pyppeteer)
        ("python-pytest" ,python-pytest)
        ("python-pytest-cov" ,python-pytest-cov)
        ("python-pytest-dependency"
         ,python-pytest-dependency)))
    (home-page "https://jupyter.org")
    (synopsis "Converting Jupyter Notebooks")
    (description "Converting Jupyter Notebooks")
    (license license:bsd-3)))

(define-public python-nbval-for-notebook
  (package
    (inherit python-nbval)
    (propagated-inputs
     `(("python-ipykernel" ,python-ipykernel-5.4)
       ("python-jupyter-client" ,python-jupyter-client-6.1)
       ("python-nbformat" ,python-nbformat-5.0)
       ("python-six" ,python-six)))))

(define-public python-notebook-6.1
  (package
    (name "python-notebook")
    (version "6.1.6")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "notebook" version))
       (sha256
        (base32
         "148pqvrnfazhi1xyy10zsjmmfwc7lxy718gxlasish212pwd8h6g"))))
    (build-system python-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'patch-testsuite
           (lambda _
             ;; These tests try to delete a file using gio, which fails for
             ;; /tmp.
             (substitute* "notebook/services/contents/tests/test_contents_api.py"
               ;; Add import, so we can call skip() below.
               (("import io" all) (string-append all "\nimport unittest"))
               (("(.+)(def (test_checkpoints_follow_file|test_delete|test_delete_dirs|test_delete_non_empty_dir))" all indent def)
                (string-append indent "@unittest.skip('disabled by guix')\n"
                               indent def)))
             ;; Same here.
             (substitute* "notebook/services/contents/tests/test_manager.py"
               ;; Add import, so we can call skip() below.
               (("import os" all) (string-append all "\nimport unittest"))
               (("(.+)(def test_delete)" all indent def)
                (string-append indent "@unittest.skip('disabled by guix')\n"
                               indent def)))
             ;; These tests check paths.jupyter_path(). I don’t know what
             ;; the expected outcome would be for guix.
             (substitute* "notebook/tests/test_serverextensions.py"
               ;; Add import, so we can call skip() below.
               (("import os" all) (string-append all "\nimport unittest"))
               (("(.+)(def (test_disable|test_enable|test_merge_config|test_load_ordered))" all indent def)
                (string-append indent "@unittest.skip('disabled by guix')\n"
                               indent def)))
             #t))
         (replace 'check
           (lambda* (#:key inputs outputs tests? #:allow-other-keys)
            (if tests?
             (begin
               ;; Some tests try to write to $HOME.
               (setenv "HOME" "/tmp")
               (add-installed-pythonpath inputs outputs)
               ;; Some tests call `jupyter-notebook`.
               (setenv "PATH" (string-append (getenv "PATH") ":" (assoc-ref outputs "out") "/bin"))
               ;; Python tests.
               (invoke "pytest" "-v" "--ignore" "notebook/tests/selenium" "notebook")
             )))))))
    (propagated-inputs
     `(("python-argon2-cffi" ,python-argon2-cffi)
       ("python-ipykernel" ,python-ipykernel-5.4)
       ("python-ipython-genutils"
        ,python-ipython-genutils)
       ("python-jinja2" ,python-jinja2)
       ("python-jupyter-client" ,python-jupyter-client-6.1)
       ("python-jupyter-core" ,python-jupyter-core-4.7)
       ("python-nbconvert" ,python-nbconvert-6.0)
       ("python-nbformat" ,python-nbformat-5.0)
       ("python-prometheus-client"
        ,python-prometheus-client)
       ("python-pyzmq" ,python-pyzmq)
       ("python-send2trash" ,python-send2trash)
       ("python-terminado" ,python-terminado-0.9.2)
       ("python-tornado" ,python-tornado-6.1)
       ("python-traitlets" ,python-traitlets)))
    (native-inputs
     `(("python-coverage" ,python-coverage)
       ("python-nbval" ,python-nbval-for-notebook)
       ("python-requests" ,python-requests)
       ("python-requests-unixsocket"
        ,python-requests-unixsocket)
       ("python-pytest" ,python-pytest)))
    (home-page "http://jupyter.org")
    (synopsis
     "A web-based notebook environment for interactive computing")
    (description
     "A web-based notebook environment for interactive computing")
    (license license:bsd-3)))

(define-public python-jupyterlab-server
  (package
    (name "python-jupyterlab-server")
    (version "2.0.0")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "jupyterlab_server" version))
       (sha256
        (base32
         "0669n1wqmg3adxcqikrs5z7qy7pikl5vcc4v29qnrlfkailw6l0k"))))
    (build-system python-build-system)
    (propagated-inputs
     `(("python-babel" ,python-babel)
       ("python-jinja2" ,python-jinja2)
       ("python-json5" ,python-json5)
       ("python-jsonschema" ,python-jsonschema)
       ("python-packaging" ,python-packaging)
       ("python-requests" ,python-requests)
       ("python-jupyter-server" ,python-jupyter-server)))
    (native-inputs
     `(("python-pytest" ,python-pytest)
       ("python-pytest-cov" ,python-pytest-cov)
       ("python-pytest-tornasync" ,python-pytest-tornasync)
       ("python-ipykernel" ,python-ipykernel-5.4)
       ("python-strict-rfc3339" ,python-strict-rfc3339)))
    (arguments
     `(#:tests? #f ; XXX: Locale-related tests fail.
       #:phases
       (modify-phases %standard-phases
         (replace 'check
           (lambda* (#:key tests? #:allow-other-keys)
             (when tests?
               ;; Some tests write to $HOME.
               (setenv "HOME" "/tmp")
               (invoke "pytest" "-vv")))))))
    (home-page "https://jupyter.org")
    (synopsis "JupyterLab Server")
    (description "A set of server components for JupyterLab and JupyterLab like
applications")
    (license license:bsd-3)))

(define-public python-jupyter-server
  (package
    (name "python-jupyter-server")
    (version "1.1.4")
    (source
      (origin
       ;; Tests are missing from PyPi tarball.
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/jupyter-server/jupyter_server.git")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0r7lqs1wi5p8kqi5r3nymq4wmi453b2xsc90s4m6y3gz0nhjvd6y"))))
    (build-system python-build-system)
    (arguments
     '(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'patch-setuppy
           ;; anyio has no proper version, so relax the requirement.
           (lambda* (#:key inputs configure-flags #:allow-other-keys)
             (substitute* "setup.py"
                 (("anyio>=2\\.0\\.2") "anyio"))
             #t))
         (replace 'check
           (lambda* (#:key outputs tests? #:allow-other-keys)
             (when tests?
               (setenv "HOME" "/tmp")
               ;; Some tests call `jupyter-server`.
               (setenv "PATH" (string-append
                                (getenv "PATH") ":"
                                (assoc-ref outputs "out") "/bin"))
               (invoke "pytest" "-v" "tests")))))))
    (propagated-inputs
      `(("python-anyio" ,python-anyio)
        ("python-ipython-genutils"
         ,python-ipython-genutils)
        ("python-jinja2" ,python-jinja2)
        ("python-jupyter-client" ,python-jupyter-client-6.1)
        ("python-jupyter-core" ,python-jupyter-core-4.7)
        ("python-nbconvert" ,python-nbconvert-6.0)
        ("python-nbformat" ,python-nbformat-5.0)
        ("python-prometheus-client"
         ,python-prometheus-client)
        ("python-pyzmq" ,python-pyzmq)
        ("python-send2trash" ,python-send2trash)
        ("python-terminado" ,python-terminado-0.9.2)
        ("python-tornado" ,python-tornado-6.1)
        ("python-traitlets" ,python-traitlets)))
    (native-inputs
      `(("python-coverage" ,python-coverage)
        ("python-ipykernel" ,python-ipykernel-5.4)
        ("python-pytest" ,python-pytest)
        ("python-pytest-console-scripts"
         ,python-pytest-console-scripts)
        ("python-pytest-cov" ,python-pytest-cov)
        ("python-pytest-tornasync"
         ,python-pytest-tornasync)
        ("python-requests" ,python-requests)))
    (home-page "http://jupyter.org")
    (synopsis
      "The backend—i.e. core services, APIs, and REST endpoints—to Jupyter web applications.")
    (description
      "The backend—i.e. core services, APIs, and REST endpoints—to Jupyter web applications.")
    (license license:bsd-3)))

(define-public python-jupyterlab
  (package
    (name "python-jupyterlab")
    (version "3.0.1")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "jupyterlab" version))
       (sha256
        (base32
         "0d5ynnykprzymy3jvf6w7g20p5yxfbpsakxwylxlng86sr1rwxbj"))
       (patches (search-patches "python-jupyterlab-copy-nometa.patch"))))
    (build-system python-build-system)
    (propagated-inputs
     `(("python-jinja2" ,python-jinja2)
       ("python-jupyterlab-server"
        ,python-jupyterlab-server)
       ("python-tornado" ,python-tornado-6.1)
       ("python-ipython" ,python-ipython-with-updates)
       ("python-packaging" ,python-packaging)
       ("python-jupyter-server" ,python-jupyter-server)
       ("python-nbclassic" ,python-nbclassic)
       ;; Required to rebuild assets. Depends on node>=12
       ;("node" ,node)
       ))
    (native-inputs
     `(("python-pytest" ,python-pytest)
       ("python-pytest-check-links"
        ,python-pytest-check-links-with-updates)
       ("python-requests" ,python-requests)
       ("python-ipykernel" ,python-ipykernel-5.4)
       ("python-jupyter-packaging" ,python-jupyter-packaging)
       ("python-cookiecuttor" ,python-cookiecutter)))
    (arguments
     ;; testing requires npm, so disabled for now
     '(#:tests? #f
       #:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'patch-syspath
           (lambda* (#:key outputs inputs configure-flags #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out")))
               (substitute* "jupyterlab/commands.py"
                 ;; sys.prefix defaults to Python’s prefix in the store, not
                 ;; jupyterlab’s. Fix that.
                 (("sys\\.prefix")
                  (string-append "'" out "'")))
			   ;; We do not provide jupyterhub
			   (substitute* "setup.py"
                 (("'jupyter-labhub = jupyterlab\\.labhubapp:main',")
                  "")))
             #t))
         ;; 'build does not respect configure-flags
         (replace 'build
           (lambda _
             (invoke "python" "setup.py" "build" "--skip-npm")))
         (replace 'check
           (lambda* (#:key outputs tests? #:allow-other-keys)
             (when tests?
               (invoke "pytest" "-v")))))
       #:configure-flags (list "--skip-npm")))
    (home-page "https://jupyter.org")
    (synopsis
     "The JupyterLab notebook server extension")
    (description
     "An extensible environment for interactive and reproducible computing,
based on the Jupyter Notebook and Architecture.")
    (license license:bsd-3)))

(define-public python-nbclient-0.5
  (package
    (name "python-nbclient")
    (version "0.5.1")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "nbclient" version))
        (sha256
          (base32
            "0l02zvadrzbj7zvl5l9ji1z58lql8pi8fjmpdpg2rbvfs4kdgqh1"))))
    (build-system python-build-system)
    (arguments
     `(#:tests? #f ; Depend on nbconvert.
       #:phases
       (modify-phases %standard-phases
         (replace 'check
           (lambda* (#:key inputs outputs tests? #:allow-other-keys)
            (if tests?
             (begin
              ;; Some tests write to homedir. IPython prints an unexpected
              ;; warning, which causes tests to fail.
              (setenv "HOME" "/tmp")
              (invoke "pytest" "-vv"))))))))
    (propagated-inputs
      `(("python-async-generator"
         ,python-async-generator)
        ("python-jupyter-client" ,python-jupyter-client-6.1)
        ("python-nbformat" ,python-nbformat-5.0)
        ("python-nest-asyncio" ,python-nest-asyncio)
        ("python-traitlets" ,python-traitlets)))
    (native-inputs
      `(("python-black" ,python-black)
        ("python-bumpversion" ,python-bumpversion)
        ("python-check-manifest" ,python-check-manifest)
        ("python-codecov" ,python-codecov)
        ("python-coverage" ,python-coverage)
        ("python-flake8" ,python-flake8)
        ("python-ipykernel" ,python-ipykernel-5.4)
        ("python-ipython" ,python-ipython-with-updates)
        ("python-ipywidgets" ,python-ipywidgets-7.6)
        ("python-mypy" ,python-mypy)
        ("python-pytest" ,python-pytest)
        ("python-pytest-cov" ,python-pytest-cov)
        ("python-testpath" ,python-testpath-0.4) ; missing from setup.py
        ("python-tox" ,python-tox)
        ("python-twine" ,python-twine)
        ("python-wheel" ,python-wheel)
        ("python-xmltodict" ,python-xmltodict)
        ;("python-nbconvert" ,python-nbconvert-6.0)
        ))
    (home-page "https://jupyter.org")
    (synopsis
      "A client library for executing notebooks. Formally nbconvert's ExecutePreprocessor.")
    (description
      "A client library for executing notebooks. Formally nbconvert's ExecutePreprocessor.")
    (license license:bsd-3)))

(define-public python-jupyter-packaging
  (package
    (name "python-jupyter-packaging")
    (version "0.7.9")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "jupyter-packaging" version))
        (sha256
          (base32
            "0fnfb77l98xkqfn0xwlji18rb2680rayh7myw79cxrbj6dr7bv9d"))))
    (build-system python-build-system)
    (arguments
     `(#:tests? #f ; Tests call `pip` to install packages, requiring network
                   ; access.
       #:phases
       (modify-phases %standard-phases
         (replace 'check
           (lambda* (#:key inputs outputs tests? #:allow-other-keys)
            (if tests?
             (begin
              ; Some tests write to $HOME.
              (setenv "HOME" "/tmp")
              ; Some tests load the installed package.
              (add-installed-pythonpath inputs outputs)
              (invoke "pytest" "-vv"))))))))
    (propagated-inputs
      `(("python-packaging" ,python-packaging)))
    (native-inputs
      `(("python-pytest" ,python-pytest)))
    (home-page "http://jupyter.org")
    (synopsis "Jupyter Packaging Utilities")
    (description "Jupyter Packaging Utilities")
    (license license:bsd-3)))

(define-public python-jupyterlab-widgets
  (package
    (name "python-jupyterlab-widgets")
    (version "1.0.0")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "jupyterlab_widgets" version))
        (sha256
          (base32
            "0y7vhhas3qndiypcpcfnhrj9n92v2w4hdc86nn620s9h9nl2j6jw"))))
    (build-system python-build-system)
    (native-inputs `(("python-jupyter-packaging" ,python-jupyter-packaging)))
    (home-page
      "https://github.com/jupyter-widgets/ipywidgets")
    (synopsis "A JupyterLab extension.")
    (description "A JupyterLab extension.")
    (license #f)))

(define-public python-ipywidgets-7.6
  (package
    (name "python-ipywidgets")
    (version "7.6.2")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "ipywidgets" version))
        (sha256
          (base32
            "0dkfx3nnaya43fgi9vmbfxmchylwf020rx0qqx5gy37v33783f5v"))))
    (build-system python-build-system)
    (propagated-inputs
      `(("python-ipykernel" ,python-ipykernel-5.4)
        ("python-ipython" ,python-ipython-with-updates)
        ("python-jupyterlab-widgets"
         ,python-jupyterlab-widgets)
        ("python-nbformat" ,python-nbformat-5.0)
        ("python-traitlets" ,python-traitlets)
        ("python-widgetsnbextension"
         ,python-widgetsnbextension-with-updates)))
    (native-inputs
      `(("python-mock" ,python-mock)
        ("python-pytest" ,python-pytest)
        ("python-pytest-cov" ,python-pytest-cov)))
    (home-page "http://ipython.org")
    (synopsis "IPython HTML widgets for Jupyter")
    (description "IPython HTML widgets for Jupyter")
    (license license:bsd-3)))

;; Define our own version, using an updated notebook.
(define-public python-widgetsnbextension-with-updates
  (package
    (name "python-widgetsnbextension")
    (version "3.5.1")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "widgetsnbextension" version))
        (sha256
          (base32
            "1ismyaxbv9d56yqqqb8xl58hg0iq0bbyy014a53y1g3hfbc8g7q7"))))
    (build-system python-build-system)
    ;; setup.py’s requires are wrong, there are no requirements.
    (arguments
     '(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'patch-dependencies
           (lambda _
             (substitute* "setup.py"
               (("'notebook>=4.4.1',") ""))
             #t)))))
    (home-page "http://ipython.org")
    (synopsis "IPython HTML widgets for Jupyter")
    (description "IPython HTML widgets for Jupyter")
    (license license:bsd-3)))

