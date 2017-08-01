module E = Errormsg
module A = Arg

let srcFile = ref ""
let specFile = ref ""
let dstFile = ref None
let ltl2ba_path = ref "ltl2ba"
let tmp_path = ref "."
let output_dot = ref false
let verbose = ref false
let debug = ref false

let checker_assert = ref "__ESBMC_assert"
let checker_assume = ref "__ESBMC_assume"
let checker_atomic_begin = ref "__ESBMC_atomic_begin"
let checker_atomic_end = ref "__ESBMC_atomic_end"
let checker_non_det = ref "nondet_uint"

let argSpec = [
  ("-i", A.Set_string srcFile, "The file to instrument");
  ("-s", A.Set_string specFile, "The specification used for instrumentation");
  ("-o", A.String (fun s -> dstFile := Some s),
   "The output file (default : the standard output)");
  ("--ltl2ba", A.Set_string ltl2ba_path,
   "The path to ltl2ba (with json output) (in the PATH by default)");
  ("--tmp", A.Set_string tmp_path,
   "The folder where temporary files are created (current folder by default)");
  ("-v", A.Set verbose, "More detailed log messages");
  ("-d", A.Set debug, "Display debug messages");
  ("--dot", A.Set output_dot, "Output the Büchi automaton in dot format");
]

let annon s = ()

let usage_msg = "Build the product between a C code file and a Büchi automaton\
                representing the never-claim of a given LTL formula.\n\
                Options:"

let arg_parse () =
  A.parse argSpec annon usage_msg;
  if !srcFile = "" || !specFile = "" then
    E.s (E.error "The input file and the specification file must be \
    provided.\n\n%s" (A.usage_string argSpec usage_msg))
