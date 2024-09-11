;;; mmixal-mode.el --- sample major mode for editing MMIXAL. -*- coding: utf-8; lexical-binding: t; -*-

;; 05/09/2023 -- 11/09/2023
;; MMIXAL Major mode
;; Le Minh Quy
;; Email: leminhquyht@gmail.com

;; I have tried to make this mode match Knuth's TAOCP as much as I can.
;; There are other cases not solved yet. Firstly, determining comment for `GREG'.
;; In particular, if `GREG' doesn't have an operand (which is implied 0), a delimiter is neccessary for a comment.
;; Secondly, dealing with the case where label names is the same as opcode names.
;; In this case, when we use those labels, they would be highlighted same color as opcodes.
;; Thirdly, the major mode has not yet successfully highlighted indented labeled intructions.
;; I will also study how to optimize the code of `mmixal-font-lock-highlights' definition using `mmixal-instruction-normal-form'.

;; Thanks for mixal-mode.el, xahlee's Emacs tutorial, and Tony Aldon's Youtube video. This major mode would not be able to completed without them.





;;-----------------MMIX "keywords"-----------------
(defvar mmix-opcodes
  '("2ADDU" "2ADDUI" "4ADDU" "4ADDUI" "8ADDU" "8ADDUI" "16ADDU" "16ADDUI" "ADD" "ADDI" "ADDU" "ADDUI" "AND" "ANDI" "ANDN" "ANDNH" "ANDNI" "ANDNL" "ANDNMH" "ANDNML" "BDIF" "BDIFI" "BEV" "BEVB" "BN" "BNB" "BNN" "BNNB" "BNP" "BNPB" "BNZ" "BNZB" "BOD" "BODB" "BP" "BPB" "BZ" "BZB" "CMP" "CMPI" "CMPU" "CMPUI" "CSEV" "CSEVI" "CSN" "CSNI" "CSNN" "CSNNI" "CSNP" "CSNPI" "CSNZ" "CSNZI" "CSOD" "CSODI" "CSP" "CSPI" "CSWAP" "CSWAPI" "CSZ" "CSZI" "DIV" "DIVI" "DIVU" "DIVUI" "FADD" "FCMP" "FCMPE" "FDIV" "FEQL" "FEQLE" "FINT" "FIX" "FIXU" "FLOT" "FLOTI" "FLOTU" "FLOTUI" "FMUL" "FREM" "FSQRT" "FSUB" "FUN" "FUNE" "GET" "GETA" "GETAB" "GO" "GOI" "INCH" "INCL" "INCMH" "INCML" "JMP" "JMPB" "LDB" "LDBI" "LDBU" "LDBUI" "LDHT" "LDHTI" "LDO" "LDOI" "LDOU" "LDUNC" "LDUNCI" "LDOUI" "LDSF" "LDSFI" "LDT" "LDTI" "LDTU" "LDTUI" "LDVTS" "LDVTSI" "LDW" "LDWI" "LDWU" "LDWUI" "MOR" "MORI" "MUL" "MULI" "MULU" "MULUI" "MUX" "MUXI" "MXOR" "MXORI" "NAND" "NANDI" "NEG" "NEGI" "NEGU" "NEGUI" "NOR" "NORI" "NXOR" "NXORI" "ODIF" "ODIFI" "OR" "ORH" "ORI" "ORL" "ORMH" "ORML" "ORN" "ORNI" "PBEV" "PBEVB" "PBN" "PBNB" "PBNN" "PBNNB" "PBNP" "PBNPB" "PBNZ" "PBNZB" "PBOD" "PBODB" "PBP" "PBPB" "PBZ" "PBZB" "POP" "PREGO" "PREGOI" "PRELD" "PRELDI" "PREST" "PRESTI" "PUSHGO" "PUSHGOI" "PUSHJ" "PUSHJB" "PUT" "PUTI" "RESUME" "SADD" "SADDI" "SAVE" "SETH" "SETL" "SETMH" "SETML" "SFLOT" "SFLOTI" "SFLOTU" "SFLOTUI" "SL" "SLI" "SLU" "SLUI" "SR" "SRI" "SRU" "SRUI" "STB" "STBI" "STBU" "STBUI" "STCO" "STCOI" "STHT" "STHTI" "STO" "STOI" "STOU" "STUNC" "STUNCI" "STOUI" "STSF" "STSFI" "STT" "STTI" "STTU" "STTUI" "STW" "STWI" "STWU" "STWUI" "SUB" "SUBI" "SUBU" "SUBUI" "SWYM" "SYNC" "SYNCD" "SYNCDI" "SYNCID" "SYNCIDI" "TDIF" "TDIFI" "TRAP" "TRIP" "UNSAVE" "WDIF" "WDIFI" "XOR" "XORI" "ZSEV" "ZSEVI" "ZSN" "ZSNI" "ZSNN" "ZSNNI" "ZSNP" "ZSNPI" "ZSNZ" "ZSNZI" "ZSOD" "ZSODI" "ZSP" "ZSPI" "ZSZ" "ZSZI" "LDA" "SET")
  "MMIX opcodes collected from Knuth's website.")

(defvar mmixal-pseudoinstructions
  '("GREG" "LOC" "IS" "BYTE" "OCTA" "TETRA" "WYDE" "PREFIX")
  "MMIXAL pseudointrustions collected from Knuth's TAOCP Volume 1, Fascicle 1.")

(defvar mmixal-macro
  '("Halt" "Fputs" "Fgets" "Fopen" "Fclose" "Fread" "Fgetws" "Fwrite" "Fputws" "Fseek" "Ftell" "TextRead" "TextWrite" "BinaryRead" "BinaryWrite" "BinaryReadWrite" "StdOut" "StdIn" "StdErr" "Data_Segment" "Pool_Segment" "Stack_Segment" "@")
  "Symbols defined for special uses such TRAP, I/O, etc. collected from Knuth's TAOCP Volume 1, Fascicle 1.")

(defvar mmix-special-registers
  '("rJ" "rA" "rB" "rC" "rD" "rE" "rF" "rG" "rH" "rI" "rK" "rL" "rM" "rN" "rO" "rP" "rQ" "rR" "rS" "rT" "rU" "rV" "rW" "rX" "rY" "rZ" "rBB" "rTT" "rWW" "rXX" "rYY" "rZZ")
  "Special registers in MMIX collected from Knuth's website.")

(defvar mmix-registers
      (mapcar (lambda (x)
		(concat "$" (number-to-string x)))
	      (number-sequence 0 255))
      "Registers $0, $1, ..., $255 in MMIX.")

;;--------MMIXAL hook--------
(defvar mmixal-mode-hook nil "Hook for function `mmixal-mode'.")

;;--------REGEX for instructions--------
(defvar mmixal-regex-operands
  "\\(?:\\(?:\"[^\"]+\"\\|'[[:ascii:]]'\\|[^ \t\n,;]+\\),\\)*\\(?:\"[^\"]+\"\\|'[[:ascii:]]'\\|[^ \t\n,;]+\\)"
  "Regex presents operands.")

(defvar regex-mmixal-instruction-normal-form
  (concat "[[:alnum:]_]*[ \t]+[[:alnum:]]+[ \t]+" mmixal-regex-operands "[ \t]*")
  "That is Label OP X,Y,Z.")

(defvar regex-mmixal-first-instruction
  (concat "^" regex-mmixal-instruction-normal-form)
  "This regex specify form of instructions when they begin at ^.")

(defvar regex-mmixal-secondary-instruction
  (concat ";" regex-mmixal-instruction-normal-form)
  "This regex specify form of instructions when they begin follow others on the same line, via ;.")

(defvar regex-mmixal-general-inline-instruction
  (concat regex-mmixal-first-instruction "\\(?:" regex-mmixal-secondary-instruction "\\)*;?")
  "This regex specify form of some instructions on the same line.")

(defconst mmixal-syntax-propertize-function ;; Regex, fortunenately, tries to match satisfied string as long as possible, which we need to parse the comment.
  (syntax-propertize-rules
   ("^[ \t]*[^[:alnum:] \t\n_]" (0 "<")) ;; start of comment on a single line
   ((concat regex-mmixal-general-inline-instruction "[ \t]*\\([ \t][^ \t\n]\\|$\\)") (1 "<")) ;; start of comment after intructions
   ("\n" (0 ">")) ;; end of comment
   ))

;;--------set up font for keywords--------
(defvar mmixal-font-lock-label-face
  'font-lock-variable-name-face
  "Face name to use for label names.")

(defvar mmixal-font-lock-operation-face
  'font-lock-keyword-face
  "Face name to use for opcode names.")

(defvar mmixal-font-lock-assembly-pseudoinstruction-face
  'font-lock-builtin-face
  "Face name to use for assembly pseudoinstruction names.")

(defvar mmixal-font-lock-register-face
  'font-lock-function-call-face
  "Face name to use for register names.")

(defvar mmixal-font-lock-speical-constant-face
  'font-lock-constant-face
  "Face name to use for speial constant names. Such as Halt, StdIn, Data_Segment.")

(defvar mmixal-font-lock-highlights ;; needs (regex . font-lock)
      `(("\\(^\\|;\\)\\([[:alnum:]_]+\\)" . (2 mmixal-font-lock-label-face))
	(,(regexp-opt mmix-opcodes 'symbols) . mmixal-font-lock-operation-face)
	(,(regexp-opt mmixal-pseudoinstructions 'symbols) . mmixal-font-lock-assembly-pseudoinstruction-face)
	(,(regexp-opt mmixal-macro 'symbols) . mmixal-font-lock-speical-constant-face)
	(,(regexp-opt mmix-registers 'symbols) . mmixal-font-lock-register-face)
	(,(regexp-opt mmix-special-registers 'symbols) . mmixal-font-lock-register-face)
	))

;;--------Major mode--------
(define-derived-mode mmixal-mode prog-mode "mmixal"
  "major mode for MMIXAL"
  (setq-local font-lock-defaults '(mmixal-font-lock-highlights)
	      indent-tabs-mode t
	      tab-width 8
	      tab-stop-list (number-sequence 8 200 8)
	      comment-start "% "
	      comment-start-skip "%[ \t]*"
	      comment-end ""
	      syntax-propertize-function mmixal-syntax-propertize-function)
  (run-hooks 'mmixal-mode-hook))

;; set up files ending with .mms to open in mmixal-mode
(add-to-list 'auto-mode-alist '("\\.mms\\'" . mmixal-mode))

(provide 'mmixal-mode)
