# Usage:
#   julia path/to/eglot-jl/compile.jl

using Pkg
Pkg.activate(@__DIR__)
cd(@__DIR__)

include("sysimage-path.jl")
sysimage = sysimage_path()

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
