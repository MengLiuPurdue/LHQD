include("../common.jl")
cd("../")
include("../local-hyper.jl")
cd("yelp_local_algorithms")
include("../PageRank.jl")
include("../hyperlocal_code/HyperLocal.jl")

using MAT
using SparseArrays
M = matread("yelp_restaurant_H.mat")
H = M["H"]
T = M["T"]
Ht = sparse(H')
order = round.(Int64,vec(sum(H,dims=2)))
d = vec(sum(H,dims=1))
volA = sum(d)
m,n = size(H)
## The target cluster: Las Vegas area restaurants
condT, volt, cutT = tl_cond(H,T,d,1.0,volA,order)

## Parameters

# LH parameters
ratio = 0.01
max_iters = 1000000
x_eps=1.0e-8
aux_eps=1.0e-8
rho=0.5
q= 2.0
kappa_lh = 0.000025
gamma = 1.0

## Run LH
trials = 15

lh1_stats = zeros(trials,5)
lh2_stats = zeros(trials,5)
lh3_stats = zeros(trials,5)

lh1_sets = spzeros(n,trials)
lh2_sets = spzeros(n,trials)
lh3_sets = spzeros(n,trials)


## load previously generate seeds
Sd = matread("output/Vegas_Seeds.mat")
seed_sets = round.(Int64,Sd["seed_sets"])

## Run LH fo range of delta values
Deltas = [1.0; 10.0; 100.0]
for i = 1:trials
    seeds = seed_sets[i,:]
    for k = 1:3
        delta = Deltas[k]
        G = LH.HyperGraphAndDegrees(H,Ht,delta,d,order)
        L = LH.loss_type(q,delta)
        tic = time()
        x,r,iter = LH.lh_diffusion(G,seeds,gamma,kappa_lh,rho,L,max_iters=max_iters,x_eps=x_eps,aux_eps=aux_eps)
        cond,cluster = hyper_sweepcut(G.H,x,G.deg,G.delta,0.0,G.order)
        toc = time()-tic
        pr, re, f1_lh = PRF(T,cluster)
        condS, volS, cutS = tl_cond(H,cluster,d,delta,volA,order)

        if k ==1
            lh1_stats[i,:] = [pr, re, f1_lh, toc, condS]
            lh1_sets[cluster,i] .= 1
        elseif k == 2
            lh2_stats[i,:] = [pr, re, f1_lh, toc, condS]
            lh2_sets[cluster,i] .= 1
        else
            lh3_stats[i,:] = [pr, re, f1_lh, toc, condS]
            lh3_sets[cluster,i] .= 1
        end
    end
end


## Save it
matwrite("output/VaryDelta_LH_Vegas_Detect.mat",Dict(
"Deltas"=>Deltas,
"kappa_lh"=>kappa_lh,
"lh1_stats"=>lh1_stats,"lh1_sets"=>lh1_sets,
"lh2_stats"=>lh2_stats,"lh2_sets"=>lh2_sets,
"lh3_stats"=>lh3_stats,"lh3_sets"=>lh3_sets))
