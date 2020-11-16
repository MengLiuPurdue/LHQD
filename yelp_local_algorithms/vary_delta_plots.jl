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
LHmat = matread("output/VaryDelta_LH_Vegas_Detect.mat")
lh1_stats = LHmat["lh1_stats"]
lh1_sets = LHmat["lh1_sets"]
lh2_stats = LHmat["lh2_stats"]
lh2_sets = LHmat["lh2_sets"]
lh3_stats = LHmat["lh3_stats"]
lh3_sets = LHmat["lh3_sets"]

##  Alpha values for transparency
lh1t = vec(round.(Int64,sum(lh1_sets[T,:],dims = 2)))
lh2t = vec(round.(Int64,sum(lh2_sets[T,:],dims = 2)))
lh3t = vec(round.(Int64,sum(lh3_sets[T,:],dims = 2)))

trials = size(lh3_stats,1)
lh1_alpha = 1 .- lh1t./trials
lh2_alpha = 1 .- lh2t./trials
lh3_alpha = 1 .- lh3t./trials

## Colors for showing number of mistakes
ColorMap = cgrad([:firebrick1,:goldenrod1], collect(LinRange(0.0,1.0,16))[2:end-1])
cl_lh1 = Vector{Any}()
cl_lh2 = Vector{Any}()
cl_lh3 = Vector{Any}()
for j = 1:length(T)
    push!(cl_lh1,ColorMap[1+lh1t[j]])
    push!(cl_lh2,ColorMap[1+lh2t[j]])
    push!(cl_lh3,ColorMap[1+lh3t[j]])
end

CL = Vector{Any}()
push!(CL, cl_lh1)
push!(CL, cl_lh2)
push!(CL, cl_lh3)
AL = [lh1_alpha lh2_alpha lh3_alpha]
mean1 = round.(mean(lh1_stats,dims = 1),digits = 2)
mean2 = round.(mean(lh2_stats,dims = 1),digits = 2)
mean3 = round.(mean(lh3_stats,dims = 1),digits = 2)
Means = [mean1; mean2; mean3]
## Plot on spectral embedding
allms = 4.5
ms = 4
bcolor = RGB(0,.1,.8)

# False brings red to the front
rev = true

for j = 1:3
    delta = Deltas[j]
    p = sortperm(AL[:,j],rev=rev)
    mn = Means[j,:]
    pr = mn[1]; re = mn[2]; f1 = mn[3]

    p1 = scatter(xy[:,1],xy[:,2],markerstrokecolor = bcolor,markercolor = bcolor,markersize = ms)
    p1 = scatter!(xy[p,1],xy[p,2], grid = false, axis = false,legend = false,
                    markeralpha = AL[:,j][p], xlim =xl ,ylim = yl,
                    title = "LH-2.0: pr = $pr re = $re",titlefontsize=14,
                    markerstrokewidth = 0, markerstrokecolor = CL[j][p],
                    markercolor = CL[j][p],markersize = allms)
 savefig("Plots/LH_heatmap_delta_$delta.pdf")
end
