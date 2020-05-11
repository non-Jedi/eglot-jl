# Usage:
#   julia --project path/to/eglot-jl/eglot-jl.jl [DEPOT_PATH]

# Get the project environment.
#
# WARNING: this script must be called with the `--project` command-line switch
# for this to work reliably.
project_path = dirname(Base.load_path()[1])

# Get the depot path. In order of increasing priority
# - default value: ""
# - environment:   ENV["JULIA_DEPOT_PATH"]
# - command-line:  ARGS[1]
depot_path = get(ENV, "JULIA_DEPOT_PATH", "")
if length(ARGS) >= 1
    depot_path = ARGS[1]
end

# Make sure that we only load packages from the eglot-jl environment specifically.
import Pkg
Pkg.activate(@__DIR__)
empty!(LOAD_PATH)
push!(LOAD_PATH, "@")

# In julia 1.4 this operation takes under a second. This can be
# crushingly slow in older versions of julia though.
Pkg.instantiate()

using LanguageServer, SymbolServer

@info "Running language server" env=Base.load_path()[1] src_path=pwd() project_path depot_path
server = LanguageServerInstance(stdin, stdout, project_path, depot_path)
run(server)
