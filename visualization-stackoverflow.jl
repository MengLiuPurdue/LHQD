using JLD,FileIO
using PyPlot
using Statistics
using PyCall
include("local-hyper.jl")
include("common.jl")

@pyimport numpy as np

records = JLD.load("results/stackoverflow_records.jld")
labels_to_remove = collect(keys(records))[1:5]
labels_to_evaluate = setdiff(collect(keys(records)),labels_to_remove)
colors = ["orange","green","turquoise","goldenrod","purple","grey","pink","royalblue"]
H,clusters = read_dataset("stackoverflow")
label_names = [clusters[parse(Int64,label)][3] for label in labels_to_evaluate]
methods = ["LH-1.4","LH-2.0+flow","star+ACL","WCE+ACL","UCE+ACL","OneHop+flow","HGCRD","LH-2.0"]
f1s = zeros(length(labels_to_evaluate),length(methods))
q20 = zeros(length(labels_to_evaluate),length(methods))
q80 = zeros(length(labels_to_evaluate),length(methods))
for (i,key) in enumerate(labels_to_evaluate)
    record = records[key]
    for (j,method) in enumerate(methods)
        if method == "OneHop+flow"
            curr_f1s = [t[6] for t in record["OneHop+flow"]]
            f1s[i,j] = median(curr_f1s)
        elseif method == "BN/TN"
            curr_f1s_1 = [t[6] for t in record["BN"]]
            curr_f1s_2 = [t[6] for t in record["TN"]]
            f1s[i,j] = max(median(curr_f1s_1),median(curr_f1s_2))
        elseif method == "WCE+ACL"
            curr_f1s = [t[6] for t in record["weighted_clique+acl"]]
            f1s[i,j] = median(curr_f1s)
        elseif method == "UCE+ACL"
            curr_f1s = [t[6] for t in record["clique+acl"]]
            f1s[i,j] = median(curr_f1s)
        elseif method == "star+ACL"
            curr_f1s = [t[6] for t in record["acl"]]
            f1s[i,j] = median(curr_f1s)
        else
            curr_f1s = [t[6] for t in record[method]]
            f1s[i,j] = median(curr_f1s)
        end
    end
end
bigfont = 18
fig,ax = subplots(figsize=(8,4))
order = sortperm(f1s[:,1])
handles = []
for j = 1:length(methods)
    alpha = 1.0
    handle = ax.scatter(1:size(f1s,1),f1s[order,j],alpha=alpha,color=colors[j])
    push!(handles,handle)
end
ax.spines["top"].set_visible(false)
ax.spines["right"].set_visible(false)
ax.set_xticks(1:length(labels_to_evaluate))
ax.set_xticklabels(label_names,rotation=30,ha="right",fontsize=7)

for tick in ax.yaxis.get_major_ticks()
    tick.label.set_fontsize(bigfont)
end
fig.legend(vcat(handles[end],handles[1:(end-1)]),vcat(methods[end],methods[1:(end-1)]),bbox_to_anchor=(0.9,1.1),fontsize=14,ncol=4,handletextpad=0.1,columnspacing=0.1)
ax.set_ylabel("F1",fontsize=bigfont)
fig.tight_layout()
fig.savefig("stackoverflow-f1.pdf",bbox_inches="tight")
fig


runtimes = zeros(length(labels_to_evaluate),length(methods))
q20 = zeros(length(labels_to_evaluate),length(methods))
q80 = zeros(length(labels_to_evaluate),length(methods))
for (i,key) in enumerate(collect(labels_to_evaluate)[order])
    record = records[key]
    for (j,method) in enumerate(methods)
        if method == "OneHop+flow"
            curr_runtime_2 = [t[end] for t in record["OneHop+flow"]]
            runtimes[i,j] = median(curr_runtime_2)
        elseif method == "BN/TN"
            curr_runtime_1 = [t[end] for t in record["BN"]]
            curr_runtime_2 = [t[end] for t in record["TN"]]
            runtimes[i,j] = max(median(curr_runtime_1),median(curr_runtime_2))
        elseif method == "WCE+ACL"
            curr_runtime = [t[end] for t in record["weighted_clique+acl"]]
            runtimes[i,j] = median(curr_runtime)
        elseif method == "UCE+ACL"
            curr_runtime= [t[end] for t in record["clique+acl"]]
            runtimes[i,j] = median(curr_runtime)
        elseif method == "star+ACL"
            curr_runtime= [t[end] for t in record["acl"]]
            runtimes[i,j] = median(curr_runtime)
        else
            curr_runtime = [t[end] for t in record[method]]
            if method == "LH-2.0"
                @show key,median(curr_runtime)
            end
            runtimes[i,j] = median(curr_runtime)
        end
    end
end

fig,ax = subplots(figsize=(8,4))

for j = 1:length(methods)
    if methods[j] == "BN/TN"
        continue
    end
    alpha = 1.0
    ax.scatter(1:size(runtimes,1),runtimes[order,j],alpha=alpha,color=colors[j])
end
ax.spines["top"].set_visible(false)
ax.spines["right"].set_visible(false)

ax.set_ylabel("runtime",fontsize=bigfont)
ax.set_yscale("log")
ax.set_xticks(1:length(labels_to_evaluate))
ax.set_xticklabels(label_names,rotation=30,ha="right",fontsize=7)
for tick in ax.yaxis.get_major_ticks()
    tick.label.set_fontsize(bigfont)
end
ax.spines["top"].set_visible(false)
ax.spines["right"].set_visible(false)
fig.tight_layout()
fig.savefig("stackoverflow-runtime.pdf",bbox_inches="tight")
fig



conds = zeros(length(labels_to_evaluate),length(methods))
q20 = zeros(length(labels_to_evaluate),length(methods))
q80 = zeros(length(labels_to_evaluate),length(methods))
for (i,key) in enumerate(collect(labels_to_evaluate)[order])
    record = records[key]
    for (j,method) in enumerate(methods)
        if method == "OneHop+flow"
            curr_cond_2 = [t[2] for t in record["OneHop+flow"]]
            conds[i,j] = median(curr_cond_2)
        elseif method == "BN/TN"
            curr_cond_1 = [t[2] for t in record["BN"]]
            curr_cond_2 = [t[2] for t in record["TN"]]
            conds[i,j] = max(median(curr_cond_1),median(curr_cond_2))
        elseif method == "WCE+ACL"
            curr_cond = [t[2] for t in record["weighted_clique+acl"]]
            conds[i,j] = median(curr_cond)
        elseif method == "UCE+ACL"
            curr_cond= [t[2] for t in record["clique+acl"]]
            conds[i,j] = median(curr_cond)
        elseif method == "star+ACL"
            curr_cond= [t[2] for t in record["acl"]]
            conds[i,j] = median(curr_cond)
        else
            curr_cond = [t[2] for t in record[method]]
            if method == "LH-2.0"
                @show key,median(curr_cond)
            end
            conds[i,j] = median(curr_cond)
        end
    end
end

fig,ax = subplots(figsize=(8,4))

for j = 1:length(methods)
    if methods[j] == "BN/TN"
        continue
    end
    alpha = 1.0
    ax.scatter(1:size(conds,1),conds[order,j],alpha=alpha,color=colors[j])
end
ax.spines["top"].set_visible(false)
ax.spines["right"].set_visible(false)

ax.set_ylabel("conductance",fontsize=bigfont)
ax.set_yscale("log")
ax.set_xticks(1:length(labels_to_evaluate))
ax.set_xticklabels(label_names,rotation=30,ha="right",fontsize=7)
for tick in ax.yaxis.get_major_ticks()
    tick.label.set_fontsize(bigfont)
end
ax.spines["top"].set_visible(false)
ax.spines["right"].set_visible(false)
fig.tight_layout()
fig.savefig("stackoverflow-conductance.pdf",bbox_inches="tight")
fig