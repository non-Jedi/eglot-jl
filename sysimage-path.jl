import SHA
import Pkg

"""
    sysimage_path()

Return a suitable name for the system image of the currently active project. In
order to avoid problems when/if Julia or the project dependencies get updated,
all versions get encoded in the system image file name.
"""
function sysimage_path()
    # This is a rather expensive way to retrieve the project path from Julia itself.
    #
    # FIXME? We could propagate the value of `eglot-jl-language-server-project`
    # by other means in order to reduce latency. Possibilities include:
    # - command-line argument
    # - environment variable
    dir = try
        dirname(Pkg.project().path)
    catch
        # Sane default for Julia <1.4, where Pkg.project() is not provided
        @__DIR__
    end

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
