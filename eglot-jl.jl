# Make sure that we only load packages from this environment specifically.
empty!(LOAD_PATH)
push!(LOAD_PATH, "@")

import Pkg
# In julia 1.4 this operation takes under a second. This can be
# crushingly slow in older versions of julia though.
Pkg.instantiate()

using LanguageServer, SymbolServer

server = LanguageServerInstance(stdin, stdout, false, ARGS[1], ARGS[2])
run(server)
