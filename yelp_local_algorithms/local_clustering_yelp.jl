cd("../")
include("common.jl")
include("local-hyper.jl")
include("qdsfm-ppr.jl")
include("hgcrd.jl")
include("PageRank.jl")
include("hyperlocal_code/HyperLocal.jl")
cd("yelp_local_algorithms")

using MAT
using SparseArrays
M = matread("yelp_restaurant_H.mat")
H = M["H"]
T = M["T"]
Ht = sparse(H')
order = round.(Int64,vec(sum(H,dims=2)))

dh = zeros(Int,size(H,2))
for i=1:size(H,2)
  dh[i] = sum(order[H.rowval[H.colptr[i]:H.colptr[i+1]-1]])
end
d = vec(sum(H,dims=1))
volA = sum(d)
m,n = size(H)
## The target cluster: Las Vegas area restaurants
condT, volt, cutT = tl_cond(H,T,d,1.0,volA,order)

## Form a clique expansion
@time A = WeightedCliqueExpansion(H,order)
dA = vec(sum(A,dims=1))
#matwrite("yelp_restaurant_clique_exp.mat",Dict("A"=>A,"dA"=>dA))

## Parameters

# LH parameters
ratio = 0.01
max_iters = 1000000
x_eps=1.0e-8
aux_eps=1.0e-8
rho=0.5
q= 2.0
kappa_lh = 0.000025

# HyperLocal (Flow) parameters
epsilon = 0.01
grownum = 2000  # adding nodes from one hop neighborhood of seeds

# Expansion + ACL parameters, try 3 kappa values, take best

k_clique = [0.0001; 0.00005; 0.00001]
k_star = [0.000025; 0.00001; 0.000005]

# shared parameters
delta = 5000.0
gamma = 1.0
G = LH.HyperGraphAndDegrees(H,Ht,delta,d,order)

## Run LH

trials = 15
lh_stats = zeros(trials,5)
pr1_stats = zeros(trials,5)
pr2_stats = zeros(trials,5)
pr3_stats = zeros(trials,5)
flow_stats = zeros(trials,5)
flowref_stats = zeros(trials,5)
star1_stats = zeros(trials,5)
star2_stats = zeros(trials,5)
star3_stats = zeros(trials,5)
qdsfmpr_stats = zeros(trials,5)
hgcrd_stats = zeros(trials,5)

lh_sets = spzeros(n,trials)
flow_sets = spzeros(n,trials)
flowref_sets = spzeros(n,trials)
pr1_sets = spzeros(n,trials)
pr2_sets = spzeros(n,trials)
pr3_sets = spzeros(n,trials)
star1_sets = spzeros(n,trials)
star2_sets = spzeros(n,trials)
star3_sets = spzeros(n,trials)
hgcrd_sets = spzeros(n,trials)




seednum = 10



## Generate Seed sets
# seed_sets = zeros(trials,seednum)
# for i = 1:trials
#     # Random seed set
#     pm = randperm(length(T))
#     seeds = T[pm[1:seednum]]
#     seed_sets[i,:] = seeds
#
# end
# matwrite("output/Vegas_Seeds.mat", Dict("seed_sets"=>seed_sets))
## load previously generate seeds
Sd = matread("output/Vegas_Seeds.mat")
seed_sets = round.(Int64,Sd["seed_sets"])

## Run PageRank on star expansion
Ga,deg = hypergraph_to_bipartite(G)

for i = 1:trials

    seeds = round.(Int64,seed_sets[i,:])
    # Try three different kappa values
    for k = 1:3

        kappa = k_star[k]
        tic = time()
        x = PageRank.acl_diffusion(Ga,deg,seeds,gamma,kappa)
        x = x[1:size(G.H,2)]
        condS,S = hyper_sweepcut(G.H,x,G.deg,G.delta,0.0,G.order)
        toc = time()-tic
        pr, re, f1 = PRF(T,S)

        println("$i $k $pr $re $f1")
        if k == 1
            star1_stats[i,:] = [pr, re, f1,toc,condS]
            star1_sets[S,i] .= 1
        elseif k == 2
            star2_stats[i,:] = [pr, re, f1,toc,condS]
            star2_sets[S,i] .= 1
        else
            star3_stats[i,:] = [pr, re, f1,toc,condS]
            star3_sets[S,i] .= 1
        end
    end

end

## save
# matwrite("output/StarACL_Vegas_Detect.mat",Dict("star1_stats"=>star1_stats,"star2_stats"=>star2_stats,
# "star1_sets"=>star1_sets,"star2_sets"=>star2_sets,"star3_sets"=>star3_sets,"star3_stats"=>star3_stats,"k_star"=>k_star))

## Run Clique + ACL

for i = 1:trials
    seeds = round.(Int64,seed_sets[i,:])

    # Three different kappa values
    for k = 1:3
        kappa = k_clique[k]
        tic = time()
        x = PageRank.acl_diffusion(A,dA,seeds,gamma,kappa)
        x = x[1:size(G.H,2)]
        condS,S = hyper_sweepcut(G.H,x,G.deg,G.delta,0.0,G.order)
        toc = time()-tic
        pr, re, f1 = PRF(T,S)

        if k == 1
            pr1_stats[i,:] = [pr, re, f1,toc,condS]
            pr1_sets[S,i] .= 1
        elseif k == 2
            pr2_stats[i,:] = [pr, re, f1,toc,condS]
            pr2_sets[S,i] .= 1
        else
            pr3_stats[i,:] = [pr, re, f1,toc,condS]
            pr3_sets[S,i] .= 1
        end
        print("$k: $f1 \t ")
    end
    println("")
end

## Save it
# matwrite("output/CliqueACL_Vegas_Detect.mat",Dict("pr1_stats"=>pr1_stats,"pr2_stats"=>pr2_stats,
# "pr1_sets"=>pr1_sets,"pr2_sets"=>pr2_sets,"pr3_sets"=>pr3_sets,"pr3_stats"=>pr3_stats,"k_clique"=>k_clique))

## Run LH

for i = 1:trials

    seeds = seed_sets[i,:]
    L = LH.loss_type(q,delta)
    tic = time()
    x,r,iter = LH.lh_diffusion(G,seeds,gamma,kappa_lh,rho,L,max_iters=max_iters,x_eps=x_eps,aux_eps=aux_eps)
    cond,cluster = hyper_sweepcut(G.H,x,G.deg,G.delta,0.0,G.order)
    toc = time()-tic
    println("nnz=$(sum( x.> 1e-9))")
    pr, re, f1_lh = PRF(T,cluster)
    condS, volS, cutS = tl_cond(H,cluster,d,delta,volA,order)
    lh_stats[i,:] = [pr, re, f1_lh, toc, condS]
    lh_sets[cluster,i] .= 1

    println("$f1_lh ")
end

## Save it
# matwrite("output/LH_Vegas_Detect.mat",Dict("lh_stats"=>lh_stats,"delta"=>delta,
# "kappa_lh"=>kappa_lh,"lh_sets"=>lh_sets))

## HyperLocal alone, and then with refinement
for i = 1:trials
    # Random seed set
    seeds = round.(Int64,seed_sets[i,:])

    # epsilon = 0.01
    # # Run HyperLocal Along
    # OneHop = get_immediate_neighbors(H,Ht,seeds)
    # Rmore = BestNeighbors(H,d,seeds,OneHop,grownum)
    # R = union(Rmore,seeds)
    # Rs = findall(x->in(x,seeds),R)   # Force seed nodes to be in output set
    # tic = time()
    # S, lcond = HyperLocal(H,Ht,order,d,R,epsilon,delta,Rs,true)
    # hl_time = time()-tic
    # condHL, volS, cutS = tl_cond(H,S,d,delta,volA,order)
    # pr, re, f1_flow1 = PRF(T,S)
    # flow_stats[i,:] = [pr, re, f1_flow1, hl_time,condHL]
    # flow_sets[S,i] .= 1

    epsilon = 1.0
    # Refine with HyperLocal
    R = findall(x->x>0,lh_sets[:,i])
    Rs = findall(x->in(x,seeds),R)   # Force seed nodes to be in output set
    s = time()
    S, lcond = HyperLocal(H,Ht,order,d,R,epsilon,delta,Rs,true)
    hl_time = time()-s
    condHL, volS, cutS = tl_cond(H,S,d,delta,volA,order)
    pr_flow, re_flow, f1_flow = PRF(T,S)
    flowref_stats[i,:] = [pr_flow, re_flow, f1_flow,hl_time,condHL]
    flowref_sets[S,i] .= 1
    @show f1_flow #f1_flow
end

## Save it
# matwrite("output/Flow_Vegas_Detect.mat",Dict("flowref_stats"=>flowref_stats,
# "flowref_sets"=>flowref_sets, "flow_stats"=>flow_stats,
# "flow_sets"=>flow_sets,"delta"=>delta))


## Run QDSFM-PPR
for i = 1:trials
    # Random seed set
    seeds = round.(Int64,seed_sets[i,:])
    s = time()
    x = QDSFMPageRank.qdsfmpr_ppr_euler(G.Ht , seeds, 0.01, 100, 0.1)
    cond,cluster = hyper_sweepcut(G.H,x./G.deg,G.deg,G.delta,0.0,G.order)
    qpr_time = time()-s
    println("cluster len=$(length(cluster)) qpr_time=$qpr_time nnz=$(sum( x.> 1e-9))")
    pr, re, f1_qpr = PRF(T,cluster)
    condS, volS, cutS = tl_cond(G.H,cluster,d,delta,volA,order)
    qdsfmpr_stats[i,:] = [pr, re, f1_qpr, 0, condS]
    qdsfmpr_sets[cluster,i] .= 1

    println("$f1_qpr ($pr, $re)")
end
## Save it
matwrite("output/QPR_Vegas_Detect.mat",Dict("qdsfmpr_stats"=>qdsfmpr_stats,
"qdsfmpr_sets"=>qdsfmpr_sets))

## Run HGCRD
for i = 1:trials
    # Random seed set
    seeds = round.(Int64,seed_sets[i,:])

    #val_hgcrd(G,T,seed;
    # ratio=0.01,)
    #s1 = time()

    U=3
    h=2
    w=2
    iterations=15
    alpha=1
    tau=0.1
    cond, cluster = HGCRD.capacityReleasingDiffusion(G.H,Ht,G.order,seeds,U,h,w,iterations,alpha,tau,volA,G.deg, dh)
    println("cluster len=$(length(cluster)) cond=$(cond)")
    pr, re, f1_hgcrd = PRF(T,cluster)
    condS, volS, cutS = tl_cond(G.H,cluster,d,delta,volA,order)
    hgcrd_stats[i,:] = [pr, re, f1_hgcrd, 0, condS]
    hgcrd_sets[cluster,i] .= 1

    println("$f1_hgcrd ($pr, $re)")
end
## Save it
matwrite("output/HGCRD_Vegas_Detect.mat",Dict("qdsfmpr_stats"=>qdsfmpr_stats,
"qdsfmpr_sets"=>qdsfmpr_sets))