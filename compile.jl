# Usage:
#   julia path/to/eglot-jl/compile.jl [LANGUAGESERVER_PROJECT_DIR]

# Path to the LanguageServer project. In order of increasing priority:
# - path to eglot-jl: @__DIR__
# - command-line:     ARGS[1]
dir = length(ARGS) >= 1 ? ARGS[1] : @__DIR__

using Pkg
Pkg.activate(dir)
include("utils.jl")
pkg_resolve()

# Get a suitable system image name
sysimage = sysimage_path(dir)

# This tells `eglot-jl.jl` to switch to TEST mode, in which the server
# immediately reads an `exit` command after having started
ENV["EGLOT_JL_TEST"] = "1"


@info "Creating system image" path = sysimage

using PackageCompiler
create_sysimage([:LanguageServer, :SymbolServer];
                sysimage_path = sysimage,
                precompile_execution_file = joinpath(@__DIR__, "eglot-jl.jl"))

@assert isfile(sysimage)
@info "Successfully generated system image" path = sysimage
