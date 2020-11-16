using JLD,FileIO
using PyPlot
using Statistics
using PyCall

@pyimport numpy as np

records = load("results/amazon_records.jld")

labels = [12,18,17,25,15,24]
datasets = ["amazon"]
colors = ["#F2AA4CFF" for i =1:100]

function myplot(f1,xmin,xmax)
    fig,ax = subplots(1,1,figsize=(4,2))
    patches = ax.violinplot(f1,vert=false,showextrema=false)
    patch = patches["bodies"][1]
    patch.set_facecolor(colors[1])
    patch.set_edgecolor("k")
    patch.set_alpha(0.6)
    ax.plot([minimum(f1),maximum(f1)],[1,1],color="k")

    ax.set_xlim(xmin,xmax)
    ax.spines["top"].set_visible(false)
    ax.spines["right"].set_visible(false)
    ax.spines["left"].set_visible(false)
    ax.spines["bottom"].set_visible(false)
    ax.yaxis.set_ticklabels([])
    ax.tick_params(axis="y", which="both", length=0)
    ax.xaxis.set_ticklabels([])
    ax.tick_params(axis="x", which="both", length=0)
    fig.tight_layout(pad=0)
    return fig
end

function get_f1(records)
    f1 = []
    for tmp in records
        push!(f1,tmp[end-1])
    end
    return f1
end

for name in datasets
    for label in labels
        for method in ["LH-2.0","BN","acl","LH-1.4","OneHop+flow-005","TN","clique+acl","weighted_clique+acl","HGCRD"]
            f1 = get_f1(records[string(label)][method])
            fig = myplot(f1,0.0,1.0)
            label = Int(label)
            method = replace(method,"."=>"")
            fig.savefig("f1-$name-$label-$method.pdf",bbox_inches="tight",pad_inches=0)
        end
    end
end
