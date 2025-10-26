using Revise
using BenchmarkTools
import OhMyREPL
import LanguageServer, SymbolServer, StaticLint;
OhMyREPL.colorscheme!("TomorrowNightBright")
import Pkg
Pkg.UPDATED_REGISTRY_THIS_SESSION[] = true

# Prioritize project-specific environments if they exist
if isfile("Project.toml") || isfile(joinpath(dirname(pwd()), "Project.toml"))
    # Keep using the current project environment
    @info "Using project environment: $(Base.active_project())"
else
    # Default to v1.12 environment when not in a project
    v112_env = joinpath(homedir(), ".julia", "environments", "v1.12")
    if isdir(v112_env)
        Pkg.activate(v112_env)
        @info "Activated default environment: v1.12"
    else
        # If there's no v1.12 environment, keep current environment
        # which might be version-specific or temporary
        @info "Using current environment: $(Base.active_project())"
    end
end
