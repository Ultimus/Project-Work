using Distributions

type RV
    distgenerator::Function
    value
    parents
    memoize ::Bool
end

A = RV(() -> Normal(), null, [],false)
B = RV((x)-> Normal(x,1), null, [A],false)
C = RV((x)-> Normal(x,1), null, [A],false)
D = RV((x,y)-> Normal(x, abs(y)), null, [B,C], false)


function sampleRV(r :: RV)
    if (r.value == null)
        ##needs work
        map(sampleRV, r.parents)
        PValues= map((x-> x.value), r.parents )
        r.value = rand(r.distgenerator(PValues...))
    end
    return r.value
end

function resetRV(x::RV)   #works
    for i in x.parents
        resetRV(i)
    end
    if (x.memoize != false && x.value != null)
        return
    else
        x.value = null
    end
end

function sampleProcess(x)
    s = sampleRV(x)
    resetRV(x)
    return s
end


function sampleModel()
  Ds = []
  As = []
 for i in 1:100
    sampleRV(D)
    Ds = [Ds, D.value]
    As = [As, A.value]
    resetRV(D)
    end
  return (Ds, As)
  end

#print(sampleModel()) #Caution!!! BIG!
println("As an example; the first value of a set of 100 samples where all A's and D's are saved:\n")
println(sampleModel()[1][1])


#Sampling with a condition

function sample_cond(rv, cond, args)   #isless` has no method matching isless(::Int64, ::Function)

    maximum = 10000
    map(sampleRV,args)
    while false == cond(map((x -> x.value), args)...) && maximum >0#do while
        map(resetRV, args)
        map(sampleRV,args)
        maximum = maximum -1
    end
  if maximum == 0 return false end
    result = sampleRV(rv)
    map(resetRV, args)
    resetRV(rv)
    return (maximum,result)
end

println("Sample with a condition:\n")
println(sample_cond(D,
             (x,y,z,w) -> x > 0 && z > 1 && y < 1 && w < -1,   #macro wäre cool: @cond x > 0 && z> 0 && y <0
             [A,B,C,D]))

function sampleModel2()
  cond = (x,y,z,w) -> x > 0 && z > 1 && y < 1 && w < -1
  args = [A,B,C,D]
  Cs = []
 for i in 1:100
    Cs = [Cs , sample_cond(D, cond, args)[2]]
    resetRV(D)
    end
  return Cs
  end
println("hist function on 100 samples with condition:\n")
println(hist(sampleModel2()))