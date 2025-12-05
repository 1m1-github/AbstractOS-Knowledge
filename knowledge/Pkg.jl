import Pkg

"`@install Pkg1, Pkg2, Pkg3, ...` runs `Pkg.add` and `using` if not already loaded"
@api macro install(pkgs...)
    new_pkgs = Symbol[]
    f = first(pkgs)
    if isa(f, Expr)
        new_pkgs = f.args
    elseif isa(f, Symbol)
        new_pkgs = [f]
    else
        throw("unknown type of first(pkgs): $(typeof(f))")
    end
    new_pkgs = filter(pkg -> !isdefined(Main, pkg), new_pkgs)
    isempty(new_pkgs) && return
    Pkg.add.(string.(new_pkgs))
    usings = [:(using $pkg) for pkg in new_pkgs]
    eval(Expr(:block, usings...))
end
