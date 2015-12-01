module MatrixDepot
using Compat # support v3 and v4
using GZip
using MatrixMarket

import Base: show, search

if VERSION < v"0.4-"
    using Docile
end

export

# main function
matrixdepot,

@addgroup, @rmgroup

include("ufreader.jl")
include("common.jl")        # main functions
include("higham.jl")        # test matrices
include("regu.jl")          # regularization test problem
include("data.jl")              # matrix data
include("download.jl")          # download data from the UF sparse matrix collection

const MY_DEPOT_DIR = joinpath(dirname(@__FILE__), "..", "myMatrixDepot")

function __init__()
    if !isdir(MY_DEPOT_DIR)
        mkdir(MY_DEPOT_DIR)
        open(string(MY_DEPOT_DIR, "/group.jl"), "w") do f
            write(f, "usermatrixclass = \n @compat Dict( \n \n \n );")
        end
        open(string(MY_DEPOT_DIR, "/generator.jl"), "w") do f
            write(f, "# put your matrix generators below ")
        end
    end
end

if isdir(MY_DEPOT_DIR)
    include("../myMatrixDepot/group.jl")
    include("../myMatrixDepot/generator.jl")
end

end # end module
