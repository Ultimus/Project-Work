module Rv

export RV, sampleRV, sampleRVTrace, sampleRVTimes, rejectionSampler

using Distributions

#shortcut
flip(x) = Bernoulli(x)

type RV
    distgenerator::Function
    name #String or Char
    parents
end

function sampleRV(r::RV)
    # generate a single sample from scratch
    return sampleRV(r, Dict())
end

function sampleRV(r::RV, d::Dict{Any,Any})
    # generate a single sample but recycle already sampled values
    key = r.name
    if !haskey(d, key)
        vals   = map((s)->sampleRV(s,d), r.parents)
        d[key] = rand(r.distgenerator(vals...))
    end
    return d[key]
end

function sampleRV(rs::Array{RV,1}, d=Dict())
    # sample simultaneously from several random variables
    return [sampleRV(r,d) for r in rs]
end

#samples a given RV n times. An array is returned, which containes all sampled values as Float64
function sampleRVTimes(r::RV, n :: Integer)
    result = Array(Float64,n)
    for i in 1:n
        result[i] = sampleRV(r)
    end
    result
end

#a rejectionSampler that takes the maximum value of the samples as the envelope function.
# The Rv is sampled n-times. An array with accepted values will be returned
# M is a factor for tuning the envelope function c.
#It can be passed to the hist() function to see the PDF
function rejectionSampler(r::RV, M, c :: Function,n=1000::Int64)
    f = sampleRVTimes(r,n)
    #g funktion
    result = Float64[]
    #c * g(x) müssen immer >= f(x) sein
    i = 1
    while i < n
        if rand() <= abs((val = sampleRV(r))/ (M*c(i)))
            push!(result,val)
        end
        i += 1
    end
    result
end





end
