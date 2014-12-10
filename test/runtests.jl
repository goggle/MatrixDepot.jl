using MatrixDepot
using Base.Test

include("test_cauchy.jl")
include("test_circul.jl")
include("test_hadamard.jl")
include("test_hilb.jl")
include("test_dingdong.jl")
include("test_frank.jl")
include("test_invhilb.jl")
include("test_forsythe.jl")
include("test_magic.jl")
include("test_grcar.jl")
include("test_triw.jl")
include("test_moler.jl")
include("test_pascal.jl")
include("test_kahan.jl")
include("test_pei.jl")
include("test_vand.jl")
include("test_invol.jl")

println("Success in all tests.")
