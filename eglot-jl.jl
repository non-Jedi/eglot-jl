import Pkg
Pkg.activate(@__DIR__)

try
    @eval using LanguageServer
catch
    @warn "Unable to import LanguageServer. Instantiating project."
    Pkg.instantiate()
    @eval using LanguageServer
end#try

server = LanguageServerInstance(stdin, stdout, false, ARGS[1], ARGS[2], Dict())
run(server)
