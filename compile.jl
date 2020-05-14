# Usage:
#   julia path/to/eglot-jl/compile.jl

using Pkg
Pkg.activate(@__DIR__)
cd(@__DIR__)

# System image path: /path/to/eglot-jl/eglot-jl.X.Y.Z.EXT
# - X.Y.Z: Julia version
# - EXT:   according to OS
sysimage_path = let
    ext = if Sys.iswindows()
        "dll"
    elseif Sys.isapple()
        "dylib"
    else
        "so"
    end

    joinpath(@__DIR__, "eglot-jl.$(Base.VERSION).$ext")
end

# This tells `eglot-jl.jl` to switch to TEST mode, in which the server
# immediately reads an `exit` command after having started
ENV["EGLOT_JL_TEST"] = "1"


@info "Creating system image" path = sysimage_path

using PackageCompiler
create_sysimage([:LanguageServer, :SymbolServer];
                sysimage_path = sysimage_path,
                precompile_execution_file = joinpath(@__DIR__, "eglot-jl.jl"))

@assert isfile(sysimage_path)
@info "Successfully generated system image" path = sysimage_path
