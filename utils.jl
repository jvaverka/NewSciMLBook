using Franklin
using Weave


"""
    \\weave{
    ```julia
    # some Julia code ...
    ```
    }

A simple command to render and evaluate code chunk in Weave.jl-like way.
"""
function lx_weave(com, _)
    content = Franklin.content(com.braces[1])
    lines = split(content, '\n')
    Core.eval(Main, :(lines = $(lines)))

    i = findfirst(startswith("```julia"), lines)
    @assert !isnothing(i) "couldn't find Weave.jl header"
    lines = lines[i:end]

    header = first(lines)
    id = string("weave-chunk-id-", hash(gensym()))
    lines[1] = string(header, ':', id)

    push!(lines, "\\show{$(id)}")

    return join(lines, '\n')
end

"""
    weaveall()

Weave all lecture notes in the `_weave` directory. Run from site root.
"""
function weaveall()
    for (root, dirs, files) in walkdir("_weave")
        for file in files
            if endswith(file, "jmd")
                println("Found Weave Doc: $(joinpath(root, file))")
                weave(joinpath(root, file); out_path=:doc)
            end
        end
    end
end