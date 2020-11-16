using MAT
using Random
using Profile
using JLD,FileIO
using Statistics
using PyPlot

include("local-hyper.jl")
include("evaluation.jl")
include("common.jl")

records = JLD.load("results/amazon_records_vary_seeds.jld")
ratios = [0.001,0.002,0.004,0.008,0.02,0.04,0.08,0.1]
clusters = collect(keys(records["0.001"]))
methods = ["LH-2.0","LH-1.4","OneHop+flow","flow","acl","clique+acl","weighted_clique+acl","HGCRD"]
method_map = Dict("LH-2.0"=>"LH-2.0","LH-1.4"=>"LH-1.4","flow"=>"flow")
method_map["acl"] = "star+ACL"
method_map["clique+acl"] = "UCE+ACL"
method_map["weighted_clique+acl"] = "WCE+ACL"
method_map["OneHop+flow"] = "OneHop+flow"
method_map["HGCRD"] = "HGCRD"
fig,ax = subplots(1,1,figsize=(6,3))
for method in methods
    f1s_all = []
    stds_all = []
    q20s_all = []
    q80s_all = []
    for ratio in ratios
        f1s = []
        q20 = []
        q80 = []
        for key in clusters
            push!(f1s,median([t[end-1] for t in records[string(ratio)][string(key)][method]]))
            push!(q20,quantile([t[end-1] for t in records[string(ratio)][string(key)][method]],0.2))
            push!(q80,quantile([t[end-1] for t in records[string(ratio)][string(key)][method]],0.8))
        end
        push!(f1s_all,median(f1s))
        push!(stds_all,std(f1s)/sqrt(6))
        push!(q20s_all,median(q20))
        push!(q80s_all,median(q80))
    end
    if length(f1s_all) == length(ratios)
        ax.plot(ratios,f1s_all)
        ax.fill_between(ratios, f1s_all-stds_all, f1s_all+stds_all, alpha=0.3)
    end
end
bigfont = 16 
ax.spines["top"].set_visible(false)
ax.spines["right"].set_visible(false)
ax.set_ylabel("F1",fontsize=bigfont)
ax.set_xlabel("ratio",fontsize=bigfont)
ax.set_xscale("log")
for tick in ax.yaxis.get_major_ticks()
    tick.label.set_fontsize(bigfont)
end
for tick in ax.xaxis.get_major_ticks()
    tick.label.set_fontsize(bigfont)
end
fig.legend([method_map[m] for m in methods],bbox_to_anchor=(1.03,1.15),fontsize=12,ncol=4,handletextpad=0.3, columnspacing=0.7)
fig.tight_layout()
fig.savefig("vary-seeds-amazon-f1.pdf",bbox_inches="tight")


fig,ax = subplots(1,1,figsize=(6,3))
for method in methods
    f1s_all = []
    stds_all = []
    q20s_all = []
    q80s_all = []
    for ratio in ratios
        f1s = []
        q20 = []
        q80 = []
        for key in clusters
            push!(f1s,median([t[2] for t in records[string(ratio)][string(key)][method]]))
        end
        push!(f1s_all,median(f1s))
        push!(stds_all,std(f1s)/sqrt(6))
    end
    if length(f1s_all) == length(ratios)
        ax.plot(ratios,f1s_all)
        ax.fill_between(ratios, f1s_all-stds_all, f1s_all+stds_all, alpha=0.3)
    end
end
bigfont = 16 
ax.spines["top"].set_visible(false)
ax.spines["right"].set_visible(false)
ax.set_ylabel("conductance",fontsize=bigfont)
ax.set_xlabel("ratio",fontsize=bigfont)
ax.set_xscale("log")
for tick in ax.yaxis.get_major_ticks()
    tick.label.set_fontsize(bigfont)
end
for tick in ax.xaxis.get_major_ticks()
    tick.label.set_fontsize(bigfont)
end
fig.tight_layout()
fig.savefig("vary-seeds-amazon-cond.pdf",bbox_inches="tight")