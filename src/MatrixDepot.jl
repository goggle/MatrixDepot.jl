# The implementations are inspired by MatrixMarket.jl
# https://github.com/JuliaSparse/MatrixMarket.jl
# The MatrixMarket.jl package is licensed under the MIT Expat License:
# Copyright (c) 2013: Viral B. Shah.

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

"""julia
    MatrixDepot

Give access to a wealth of sample and test matrices and accompanying data.
A set of matrices is generated locally (with arguments controlling the special case).
Another set is loaded from one of the publicly accessible matrix collections
`SuiteSparse Matrix Collection` (formerly `University of Florida Matrix Collection`)
and the `Matrix Market Collection`.

Access is like

    using MatrixDepot

    A = matrixdepot("hilb", 10) # locally generated hilbert matrix dimensions (10,10)

    A = matrixdepot("HB/1138_bus")     # named matrix of the SuiteSparse Collection
    A = matrixdepot(sp(1))             # same matrix using numerical id
    A = matrixdepot("Harwell*/*/1138_bus") # matrix from the Matrix Market Collection

    md = mdopen("*/bfly")   # named matrix with some extra data
    A = md.A
    co = md.coord
    tx = md("Gname_10.txt")

    md = mdopen("gravity", 10, false) # localy generated example with rhs and solution
    A = md.A
    b = md.b
    x = md.x

###### commands:
    mdinfo, listdir, listgroups, matrixdepot, mdopen, listdata, mdlist,
    metasymbols, setgroup!, deletegroup!.
###### selector patterns:
    strings, string-patterns (using "*", "?", "[]", "/", "**"), regular expressions: for names
    builtin(42), user(3,5), sp(10:11,6,2833), mm(1), mm(:): to access by integer id or all
    sp(pattern), mm(pattern) to access corresponding (alternative) matrix for other collection
###### predicate patterns:
    isboolean, isinteger, isreal, iscomplex
    isgeneral, issymmetric, ishermitian, isskew
    isbuiltin, isuser, islocal, isremote, isloaded, isunloaded
    issvdok
    keyword(string expression), logical, hasdata(symbol), @pred(expression)

    see also: "logical" for logical combinations of all kinds of patterns.
"""
module MatrixDepot
using LinearAlgebra, SparseArrays, Serialization
using Scratch
import Base: show

export matrixdepot
export listnames, listdir, listdata, listgroups, mdlist, mdinfo, metasymbols, mdopen
export @addgroup, @rmgroup, @modifygroup # deprecated
export setgroup!, deletegroup!

# exports for predicate functions in `logical.jl`
export builtin, user, sp, mm, logical
export isgeneral, issymmetric, isskew, ishermitian
export iscomplex, isreal, isinteger, isboolean
export isremote, islocal, isloaded, isunloaded, isbuiltin, isuser
export issvdok, isposdef
export @pred, keyword, hasdata, charfun

# The following functions are re-used as predicate functions / logical operators
import Base: isreal, isinteger
import LinearAlgebra: issymmetric, ishermitian
import SparseArrays: issparse
import Base: &, |, *, ~

include("types.jl")         # common data type definitions
include("higham.jl")        # test matrices
include("regu.jl")          # regularization test problem
include("graph.jl")         # adjacency matrices for graphs
include("data.jl")          # global variables and matrix data
include("common.jl")        # main functions
include("logical.jl")       # operations on patterns and predicates
include("download.jl")      # download data from the UF and MM sparse matrix collection
include("datareader.jl")    # read matrix data from local storage
include("matrixmarket.jl")  # read matrix data from local storage
include("markdown.jl")      # construct MD objects
include("downloadmm.jl")    # read metatdata from MM database
include("downloadsp.jl")    # read metatdata from SS database

function init(;ignoredb::Bool=false)
    GROUP = "group.jl"
    GENERATOR = "generator.jl"
    url_redirect()          # env MATRIXDEPOT_URL_REDIRECT == "1"

    if !isdir(data_dir())   # env MATRIXDEPOT_DATA
        mkpath(data_dir())
    end

    @info("verify download of index files...")
    downloadindices(MATRIX_DB, ignoredb=ignoredb)
    @info("used remote sites are $(remote_name(preferred(SSRemoteType))) and $(remote_name(preferred(MMRemoteType)))")
    nothing
end

# will be called automatically once after `using`, `import`, `require`.
function __init__()
    try init() catch ex; @warn "exception during initialization: '$ex'"
    end
end

end # end module
