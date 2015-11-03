module Exp002

export RV, sampleRV, sampleRVCond, sampleRVn

using Distributions

type RV
    funct :: Function
    parents::Array{RV,1}
end

function sampleRV(r::RV, d=Dict())
    # generate a single sample but recycle already sampled values
    key = hash(r)
    if !haskey(d, key)
        vals   = map((s)->sampleRV(s,d), r.parents)
        d[key] = r.funct(vals...)
    end
    return d[key]
end

function sampleRV(rs::Array{RV,1}, d=Dict())
    # sample simultaneously from several random variables
    return [sampleRV(r,d) for r in rs]
end

function sampleRVCond(r::RV, cond::RV, maxiter=10000)
    for i in 1:maxiter
        d   = Dict()            # each attempt gets a empty dictionary
        val = sampleRV(r, d)
        if sampleRV(cond, d)    # check condition
            return val
        end
    end
    error("couldn't fulfill condition after ", maxiter, " attempts")
end


function sampleRVn(r::RV, cond::RV, n :: Int)
    # samples random varibles r given condition cond n times
    results = Array(Real, n)
    for i in 1 : n
            results[i] = sampleRVCond(r,cond)
    end
    results
end

end
