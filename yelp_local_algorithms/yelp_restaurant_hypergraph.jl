using MAT
using SparseArrays
using MatrixNetworks

"""
Construct a hypergraph of yelp-reviewed restaurants.
Extract Las Vegas restarurants cluster.
"""

# You should either load data from .mat files, or get it from read_data.jl
function load_data()
end

function load_data_from_mat()
    # User metadata
    Us = matread("yelp-user-metadata.mat")
    user_avgstar = Us["user_avgstar"]
    user_elite = Us["user_elite"]
    user_int2id = Us["user_int2id"]
    user_revcount = Us["user_revcount"]

    # Business metadata
    Bus = matread("yelp-business-metadata.mat")
    C = Bus["C"]
    business_locations = Bus["business_locations"] #[city_int, zipcode_int, state_int]
    city_int2name = Bus["city_int2name"]
    zipcode_int2name = Bus["zipcode_int2name"]
    state_int2name = Bus["state_int2name"]
    cat_int2name = Bus["cat_int2name"]
    business_name = Bus["business_int2name"]
    business_latlong = Bus["business_latlong"]
    business_revcount = Bus["business_revcount"]

    # Review data
    M = matread(homedir()*"/data/yelp_dataset/yelp-review-data.mat")
    B = M["B"]
    U = M["U"]
    n = M["n"]
    m = M["m"]
end

## Load
@time load_data()

## Build the hypergraph
m = length(business_name)
n = length(user_revcount)
H = sparse(U,B,ones(length(U)),n,m)


# if the same set of businesses is reviewed by two users, just store the hyepredge once
I,J,V = findnz(H)
H = sparse(I,J,ones(length(I)),n,m)

## Restrict to Restaurants

rest_id = findall(x->occursin("Restaurants",x),cat_int2name)[1]
Restaurants = findall(x->x>0,C[:,rest_id])

H = H[:,Restaurants]
locations = business_locations[Restaurants,:]
latlong = business_latlong[Restaurants,:]
name = business_name[Restaurants]

d = vec(sum(H,dims=1))
order = round.(Int64,vec(sum(H,dims=2)))
volA = sum(d)
m,n = size(H)


## remove trivial edges
edges = findall(x->x>1,order)
H = H[edges,:]
order = order[edges]
d = vec(sum(H,dims=1))
volA = sum(d)
m,n = size(H)

## Form bipartite expansion to find largest connected component

A = [spzeros(m,m) H; sparse(H') spzeros(n,n)]
lcc, pcc = largest_component(A)
p_nodes = pcc[m+1:end]
p_edges = pcc[1:m]
H = H[p_edges,p_nodes]

locations = locations[p_nodes,:]  #[city_int, zipcode_int, state_int]
latlong = latlong[p_nodes,:]
name = name[p_nodes]

m,n = size(H)

## Las Vegas zipcodes from: https://worldpostalcode.com/united-states/nevada/las-vegas,
# Plus just few more from surrounding region: 89031; 89032;89084;89085;89087;89086;89030;89081
VegasZips = vec([89031  89032 89084 89085 89087 89086 89030 89081 89101 89102 89103 89104 89105 89106 89107 89108 89109 89110 89111 89112 89113 89114 89115 89116 89117 89118 89119 89120 89121 89122 89123 89124 89125 89126 89127 89128 89129 89130 89131 89132 89133 89134 89135 89136 89137 89138 89139 89140 89141 89142 89143 89144 89145 89146 89147 89148 89149 89150 89151 89152 89153 89154 89155 89156 89157 89158 89159 89160 89161 89162 89164 89165 89166 89169 89170 89173 89177 89178 89179 89180 89183 89185 89193 89195 89199])

## Extract all the businesses that have a Las Vegas zipcode

# First map zipcodes to zipcode IDs
# This removes some zipcodes that aren't represented in the data
zip_ints = Vector{Int64}()
for i = 1:length(VegasZips)
    zip = string(VegasZips[i])
    place = findall(x->x==zip,zipcode_int2name)
    if length(place) > 0
        push!(zip_ints,place[1])
    end
end
@show(length(zip_ints))

# get all businesses in these zip codes
AllVegas = findall(x->in(x,zip_ints),locations[:,2])

e_vegas = zeros(n)
e_vegas[AllVegas] .= 1



## Save hypergraph

matwrite("yelp_restaurant_hypergraph.mat", Dict("H"=>H, "locations"=>locations, "name"=>name,
"city_int2name"=>city_int2name,"zipcode_int2name"=>zipcode_int2name,
"state_int2name"=>state_int2name,"latlong"=>latlong, "e_vegas"=>e_vegas))
