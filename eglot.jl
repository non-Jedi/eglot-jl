import Pkg
Pkg.activate(@__DIR__)

using LanguageServer, Sockets, SymbolServer

server = LanguageServer.LanguageServerInstance(stdin, stdout, false,
                                               ARGS[1], ARGS[2], Dict())
server.runlinter = true
run(server)
