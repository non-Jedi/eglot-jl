# This script must be called with LOAD_PATH set to ["@"] so that the
# wrong versions of packages aren't picked up. If called with the
# normal LOAD_PATH, due to the stacked environments, this could pick
# up a package from "@v#.#".
try
    @eval using LanguageServer, SymbolServer
catch
    @warn "Unable to import LanguageServer. Instantiating project."
    Pkg.instantiate()
    @eval using LanguageServer, SymbolServer
end#try

server = LanguageServerInstance(stdin, stdout, false, ARGS[1], ARGS[2])
# The run command starts additional julia processes which must have a
# normal LOAD_PATH.
delete!(ENV, "JULIA_LOAD_PATH")
run(server)
