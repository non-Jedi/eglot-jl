import Pkg
Pkg.activate(@__DIR__)

using LanguageServer

server = LanguageServerInstance(stdin, stdout, false, ARGS[1], ARGS[2], Dict())
run(server)
