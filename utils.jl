import SHA
import Pkg

"""
    pkg_resolve()

Resolve the currently active environment, in order to make sure it is compatible
with the Julia version in use.
"""
function pkg_resolve()
    # Resolving the environment is necessary for cases where the shipped
    # Manifest.toml is not compatible with the Julia version.
    for _ in 1:2
        try
            Pkg.resolve(io=stderr)
            @info "Environment successfully resolved"
            break
        catch err
            # Downgrading from 1.6 to 1.5 sometimes causes temporary errors
            @warn "Error while resolving the environment; retrying..." err
        end
    end

    # In julia 1.4 this operation takes under a second. This can be
    # crushingly slow in older versions of julia though.
    Pkg.instantiate()
end

"""
    sysimage_path(dir)

Return a suitable name for the system image of a project in `dir`. In order to
avoid problems when/if Julia or the project dependencies get updated, all
versions get encoded in the system image file name.
"""
function sysimage_path(dir)
    ext = if Sys.iswindows()
        "dll"
    elseif Sys.isapple()
        "dylib"
    else
        "so"
    end

    hash = open(SHA.sha1, joinpath(dir, "Manifest.toml")) |> bytes2hex

    joinpath(dir, "eglot-jl_$(Base.VERSION)_$hash.$ext")
end


# When used as a script: resolve the environment and print a suitable sysimage
# name
if abspath(PROGRAM_FILE) == @__FILE__
    pkg_resolve()
    print(sysimage_path(ARGS[1]))
end
