using MAT
using Random
using Profile
using JLD,FileIO
using Statistics
using PyPlot

include("local-hyper.jl")
include("evaluation.jl")
include("common.jl")

records = JLD.load("results/stackoverflow_records_vary_delta.jld")
deltas = [1.0,5.0,10.0,50.0,100.0,500.0,1000.0,5000.0,10000.0]
fig,ax = subplots(1,1,figsize=(4,2))
for label in collect(keys(records))[1:5]
    f1s_lh = []
    for key in deltas
        f1s = []
        if haskey(records[label][string(key)],"LH-2.0")
            for record in records[label][string(key)]["LH-2.0"]
                push!(f1s,record[end-1])
            end
            push!(f1s_lh,median(f1s))
            @show label, median(f1s)
        end
    end
    if length(f1s_lh) == length(deltas)
        ax.plot(deltas,f1s_lh)
    end
end
ax.set_xscale("log") 
ax.set_ylabel("F1",fontsize=bigfont)  
ax.spines["top"].set_visible(false)
ax.spines["right"].set_visible(false)
ax.set_xlabel("\$\\delta\$",fontsize=bigfont)  
for tick in ax.yaxis.get_major_ticks()
    tick.label.set_fontsize(bigfont)
end
for tick in ax.xaxis.get_major_ticks()
    tick.label.set_fontsize(bigfont)
end
fig.savefig("vary-delta-stackoverflow.pdf",bbox_inches="tight")


records = JLD.load("results/amazon_records_vary_delta.jld")
deltas = [1.0,5.0,10.0,50.0,100.0,500.0,1000.0,5000.0,10000.0]
fig,ax = subplots(1,1,figsize=(4,2))
labels = ["29","4","21","10","22"]
for label in labels
    f1s_lh = []
    for key in deltas
        f1s = []
        if haskey(records[label][string(key)],"LH-2.0")
            for record in records[label][string(key)]["LH-2.0"]
                push!(f1s,record[end-1])
            end
            push!(f1s_lh,median(f1s))
            @show label, median(f1s)
        end
    end
    if length(f1s_lh) == length(deltas)
        ax.plot(deltas,f1s_lh)
    end
end
ax.set_xscale("log") 
ax.set_ylabel("F1",fontsize=bigfont)  
ax.spines["top"].set_visible(false)
ax.spines["right"].set_visible(false)
ax.set_xlabel("\$\\delta\$",fontsize=bigfont)  
for tick in ax.yaxis.get_major_ticks()
    tick.label.set_fontsize(bigfont)
end
for tick in ax.xaxis.get_major_ticks()
    tick.label.set_fontsize(bigfont)
end

fig.savefig("vary-delta-amazon.pdf",bbox_inches="tight")