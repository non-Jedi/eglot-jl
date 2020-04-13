# This script must be called with LOAD_PATH set to ["@"] so that the
# wrong versions of packages aren't picked up. If called with the
# normal LOAD_PATH, due to the stacked environments, this could pick
# up a package from "@v#.#".
import Pkg
# In julia 1.4 this operation takes under a second. This can be
# crushingly slow in older versions of julia though.
Pkg.instantiate()

using LanguageServer, SymbolServer

server = LanguageServerInstance(stdin, stdout, false, ARGS[1], ARGS[2])
# The run command starts additional julia processes which must have a
# normal LOAD_PATH.
delete!(ENV, "JULIA_LOAD_PATH")
run(server)
