using Plots
using MAT
using SparseArrays

M = matread("Vegas_latlong_xy.mat")
latlong = M["latlong"]

XY = matread("Vegas_spectral_xy.mat")
xy_ll = latlong[T,2:-1:1]    # layout that's just latitude/longitude
xy_spectral = XY["xy"]       # layout based on spectral embedding of lat/long data

# Choose an embedding type
xy = xy_ll

# Choose plot limits
xl = yl = false # good choice for spectral embedding

xl = [-115.4,-115.0] # crops out outskirts of town
yl = [36,36.3]

## Load output
LHmat = matread("output/LH_Vegas_Detect.mat")
lh_stats = LHmat["lh_stats"]
lh_sets = LHmat["lh_sets"]

FlowMat =  matread("output/Flow_Vegas_Detect.mat")
flow_stats = FlowMat["flow_stats"]
flow_sets = FlowMat["flow_sets"]
flowref_stats = FlowMat["flowref_stats"]
flowref_sets = FlowMat["flowref_sets"]

P = matread("output/CliqueACL_Vegas_Detect.mat")
pr1_stats = P["pr1_stats"]
pr1_sets = P["pr1_sets"]
pr2_stats = P["pr2_stats"]
pr2_sets = P["pr2_sets"]
pr3_stats = P["pr3_stats"]
pr3_sets = P["pr3_sets"]

P = matread("output/StarACL_Vegas_Detect.mat")
star1_stats = P["star1_stats"]
star1_sets = P["star1_sets"]
star2_stats = P["star2_stats"]
star2_sets = P["star2_sets"]
star3_stats = P["star3_stats"]
star3_sets = P["star3_sets"]

P = matread("output/QPR_Vegas_Detect.mat")
qpr_stats = P["qdsfmpr_stats"]
qpr_sets = P["qdsfmpr_sets"]


##  Alpha values for transparency
lht = vec(round.(Int64,sum(lh_sets[T,:],dims = 2)))
prt = vec(round.(Int64,sum(pr2_sets[T,:],dims = 2)))
flowt = vec(round.(Int64,sum(flow_sets[T,:],dims = 2)))
frt = vec(round.(Int64,sum(flowref_sets[T,:],dims = 2)))
start = vec(round.(Int64,sum(star2_sets[T,:],dims = 2)))
qprt = vec(round.(Int64,sum(qpr_sets[T,:],dims = 2)))

lh_alpha = 1 .- lht./15
pr_alpha = 1 .- prt./15
flow_alpha = 1 .- flowt./15
flowref_alpha = 1 .- frt./15
star_alpha = 1 .- start./15
qpr_alpha = 1 .- qprt./15

## Colors for showing number of mistakes
ColorMap = cgrad([:firebrick1,:goldenrod1], collect(LinRange(0.0,1.0,16))[2:end-1])
cl_lh = Vector{Any}()
cl_pr = Vector{Any}()
cl_flow = Vector{Any}()
cl_flowref = Vector{Any}()
cl_star = Vector{Any}()
cl_qpr = Vector{Any}()
for j = 1:length(T)
    push!(cl_lh,ColorMap[1+lht[j]])
    push!(cl_pr,ColorMap[1+prt[j]])
    push!(cl_flow,ColorMap[1+flowt[j]])
    push!(cl_flowref,ColorMap[1+frt[j]])
    push!(cl_star,ColorMap[1+start[j]])
    push!(cl_qpr, Colormap[1+qprt[j]])
end

## Plot on spectral embedding
allms = 6
ms = 5
bcolor = RGB(0,.1,.8)

# False brings red to the front
rev = false
p = sortperm(lh_alpha,rev=rev)
med = round.(mean(lh_stats,dims = 1),digits = 2)
pr = med[1]; re = med[2]; f1 = med[3]
# p = 1:length(T)
p1 = scatter(xy[:,1],xy[:,2],markerstrokecolor = bcolor,markercolor = bcolor,markersize = ms)
p1 = scatter!(xy[p,1],xy[p,2], grid = false, axis = false,legend = false,
                markeralpha = lh_alpha[p], xlim =xl ,ylim = yl,
                title = "LH-2.0: pr = $pr re = $re",titlefontsize=14,
                markerstrokewidth = 0, markerstrokecolor = cl_lh[p],
                markercolor = cl_lh[p],markersize = allms)

savefig("Plots/LH_heatmap.pdf")
## Now for PR
rev = false
p = sortperm(pr_alpha,rev=rev)
med = round.(mean(pr2_stats,dims = 1),digits = 2)
pr = med[1]; re = med[2]; f1 = med[3]
# p = 1:length(T)
p2 = scatter(xy[:,1],xy[:,2], markerstrokecolor = bcolor,markercolor = bcolor,markersize = ms)
p2 = scatter!(xy[p,1],xy[p,2], grid = false, axis = false,legend = false,
                markeralpha = pr_alpha[p], xlim =xl ,ylim = yl,
                title = "WCE+ACL: pr = $pr re = $re",titlefontsize=14,
                markerstrokewidth = 0, markerstrokecolor = cl_pr[p],
                markercolor = cl_pr[p],markersize = allms)
savefig("Plots/CliqueACL_heatmap.pdf")

## star2artite
rev = false
p = sortperm(star_alpha,rev=rev)
med = round.(mean(star2_stats,dims = 1),digits = 2)
pr = med[1]; re = med[2]; f1 = med[3]
p3 = scatter(xy[:,1],xy[:,2],  markerstrokecolor = bcolor,markercolor = bcolor,markersize = ms)
p3 = scatter!(xy[p,1],xy[p,2], grid = false, axis = false,legend = false,
            markeralpha = star_alpha[p],xlim =xl ,ylim = yl,
            title = "star+ACL: pr = $pr re = $re",titlefontsize=14,
            markerstrokewidth = 0, markerstrokecolor = cl_star[p],
            markercolor = cl_star[p],markersize = allms)
savefig("Plots/StarACL_heatmap.pdf")

## Flow
rev = false
p = sortperm(flow_alpha,rev=rev)
med = round.(mean(flow_stats,dims = 1),digits = 2)
pr = med[1]; re = med[2]; f1 = med[3]
p4 = scatter(xy[:,1],xy[:,2], markerstrokecolor = bcolor, markercolor = bcolor,markersize = ms)
p4 = scatter!(xy[p,1],xy[p,2], grid = false, axis = false,legend = false,
                markeralpha = flow_alpha[p],xlim =xl ,ylim = yl,
                title = "Flow: pr = $pr re = $re",titlefontsize=14,
                markerstrokewidth = 0, markerstrokecolor = cl_flow[p],
                markercolor = cl_flow[p],markersize = allms)

savefig("Plots/Flow_heatmap.pdf")


## Flow refining LH output
rev = false
p = sortperm(flowref_alpha,rev=rev)
med = round.(mean(flowref_stats,dims = 1),digits = 2)
pr = med[1]; re = med[2]; f1 = med[3]
p5 = scatter(xy[:,1],xy[:,2], markerstrokecolor = bcolor, markercolor = bcolor,markersize = ms)
p5 = scatter!(xy[p,1],xy[p,2], grid = false, axis = false,legend = false,
                markeralpha = flowref_alpha[p],xlim =xl,ylim = yl,
                title = "LH+Flow: pr = $pr re = $re",titlefontsize=14,
                markerstrokewidth = 0, markerstrokecolor = cl_flowref[p],
                markercolor = cl_flowref[p],markersize = allms)

savefig("Plots/Flow_refinement_heatmap.pdf")

## QPR output
rev = false
p = sortperm(qpr_alpha,rev=rev)
med = round.(mean(qpr_stats,dims = 1),digits = 2)
pr = med[1]; re = med[2]; f1 = med[3]
p5 = scatter(xy[:,1],xy[:,2], markerstrokecolor = bcolor, markercolor = bcolor,markersize = ms)
p5 = scatter!(xy[p,1],xy[p,2], grid = false, axis = false,legend = false,
                markeralpha = qpr_alpha[p],xlim =xl,ylim = yl,
                title = "QHPR: pr = $pr re = $re",titlefontsize=14,
                markerstrokewidth = 0, markerstrokecolor = cl_qpr[p],
                markercolor = cl_qpr[p],markersize = allms)

savefig("Plots/Qpr_heatmap.pdf")

## Plot multiple
l = @layout [a b; c d]

plot(p1,p2,p3,p4,layout = l)
savefig("Plots/AllPlots_$(allms)_$(ms).pdf")
