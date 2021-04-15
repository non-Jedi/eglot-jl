# Usage:
#   julia --project=path/to/eglot-jl path/to/eglot-jl/eglot-jl.jl [SOURCE_PATH] [DEPOT_PATH]

# For convenience, Pkg isn't included in eglot-jl
# Project.toml. Importing Pkg here relies on the standard library
# being available on LOAD_PATH
import Pkg

include("utils.jl")
if Base.JLOptions().image_file_specified == 1
    @info "Using custom sysimage" path=unsafe_string(Base.JLOptions().image_file)
else
    pkg_resolve()
end

# Get the source path. In order of increasing priority:
# - default value:  pwd()
# - command-line:   ARGS[1]
src_path = length(ARGS) >= 1 ? ARGS[1] : pwd()

# Get the depot path. In order of increasing priority:
# - default value:  ""
# - environment:    ENV["JULIA_DEPOT_PATH"]
# - command-line:   ARGS[2]
depot_path = get(ENV, "JULIA_DEPOT_PATH", "")
if length(ARGS) >= 2
    depot_path = ARGS[2]
end

# Get the project environment from the source path
project_path = something(Base.current_project(src_path), Base.load_path_expand(LOAD_PATH[2])) |> dirname

# Make sure that we only load packages from this environment specifically.
empty!(LOAD_PATH)
push!(LOAD_PATH, "@")

using LanguageServer.JSON
if get(ENV, "EGLOT_JL_TEST", "0") == "1"
    msg = Dict("jsonrpc" => "2.0",
               "id"      => 1,
               "method"  => "exit",
               "params"  => Dict()) |> JSON.json
    input = IOBuffer("Content-Length: $(length(msg))\n\n$msg")
    mode = "TEST"
else
    mode = "RUN"
    input = stdin
end

using LanguageServer, SymbolServer

@info "Running language server" mode env=Base.load_path()[1] src_path project_path depot_path
server = LanguageServerInstance(input, stdout, project_path, depot_path)
run(server)
