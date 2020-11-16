using JSON
using SparseArrays
include("../common.jl")
## Read business metadata
"""
For businesses, we store the following:
    * List of business names
    * Dictionary from old ID to new integer ID
    * Label Matrix of categories: C[i,j] = 1 means business i has category j
    * Category interger ID to category name (vector of strings)
    * Location matrix: L[i,:] = [city_int, zipcode_int, state_int]
    * Location integer ID to location name (for city, zipcode and state)
"""
path_to_yelp = homedir()*"/data/yelp_dataset/"
file = path_to_yelp*"yelp_academic_dataset_business.json"
loaded = read(file, String)
objects = split(loaded, "\n")
m = length(objects)-1

cat_name2int = Dict{String,Int64}()
cat_int2name = Vector{String}()
cat_count = Vector{Int64}()         # counts the number of businesses with this tag

business_id2int = Dict{String,Int64}()
business_int2id = Vector{String}()
business_cats = Vector{Vector{Int64}}() # list of integer categories that the business is a part of
business_name = Vector{String}()

city_name2int = Dict{String,Int64}()
city_int2name = Vector{String}()

zipcode_name2int = Dict{String,Int64}()
zipcode_int2name = Vector{String}()

state_name2int = Dict{String,Int64}()
state_int2name = Vector{String}()

business_latlong = zeros(m,2)
business_locations = zeros(Int64,m,3)
business_revcount = zeros(Int64,m)
nextCatID = 1
loc_int = ones(Int64,3)

tic = time()
for j = 1:length(objects)-1
    if mod(j,10000) == 0
        println("$(100*j/length(objects)) % done")
    end
    global nextCatID
    business = JSON.parse(objects[j])
    business_id = business["business_id"]
    zipcode = business["postal_code"]
    state = business["state"]
    city = business["city"]
    bname = business["name"]
    business_revcount[j] = business["review_count"]

    business_id2int[business_id] = j
    push!(business_int2id, business_id)
    push!(business_name,bname)

    lati = business["latitude"]
    longi = business["longitude"]

    # Keep track of categories
    category_ints = Vector{Int64}()
    if ~isnothing(business["categories"])
        categories = unique(strip.(string.(split(business["categories"],","))))
        for catname in categories

            if haskey(cat_name2int,catname)
                # we've seen it before
                cat_id = cat_name2int[catname]
                cat_count[cat_id] += 1
            else
                cat_id = nextCatID
                nextCatID += 1
                push!(cat_count,1)
                push!(cat_int2name,catname)
                cat_name2int[catname] = cat_id
            end
            push!(category_ints,cat_id)
        end
    end
    push!(business_cats,category_ints)

    # Keep track of cities
    if haskey(city_name2int,city)
        city_int = city_name2int[city]
    else
        city_int = loc_int[1]
        loc_int[1] += 1
        city_name2int[city] = city_int
        push!(city_int2name,city)
    end

    # Keep track of zipcodes
    if haskey(zipcode_name2int,zipcode)
        zipcode_int = zipcode_name2int[zipcode]
    else
        zipcode_int = loc_int[2]
        loc_int[2] += 1
        zipcode_name2int[zipcode] = zipcode_int
        push!(zipcode_int2name,zipcode)
    end

    # Keep track of states
    if haskey(state_name2int,state)
        state_int = state_name2int[state]
    else
        state_int = loc_int[3]
        loc_int[3] += 1
        state_name2int[state] = state_int
        push!(state_int2name,state)
    end
    business_locations[j,:] = [city_int, zipcode_int, state_int]
    business_latlong[j,:] = [lati, longi]
end
@show time()-tic

ncats = length(cat_int2name)
C = elist2incidence(business_cats,ncats)

## save business metadata, if you wish

# using MAT
# matwrite("yelp-business-metadata.mat",Dict("C"=>C,"business_locations"=>business_locations,
# "city_int2name"=>city_int2name,"zipcode_int2name"=>zipcode_int2name,"state_int2name"=>state_int2name,
# "cat_int2name"=>cat_int2name,"business_int2name"=>business_name,"business_revcount"=>business_revcount))

## Store user metadata
file = path_to_yelp*"yelp_academic_dataset_user.json"
loaded = read(file, String)
objects = split(loaded, "\n")

n = length(objects)-1

user_id2int = Dict{String,Int64}()
user_int2id = Vector{String}()

user_elite = zeros(Int64,n)
user_revcount = zeros(Int64,n)
user_avgstar = zeros(n)

## Store user data
for j = 1:length(objects)-1
    user = JSON.parse(objects[j])
    user_id = user["user_id"]
    elite = user["elite"]
    push!(user_int2id,user_id)
    user_id2int[user_id] = j
    user_revcount[j] = user["review_count"]
    if length(elite) > 0
        user_elite[j] = 1
    end
    user_avgstar[j] = user["average_stars"]
end

## Save user metadata, not really needed for our experiments
# matwrite("yelp-user-metadata.mat",Dict("user_avgstar"=>user_avgstar,
# "user_elite"=>user_elite,"user_int2id"=>user_int2id,"user_revcount"=>user_revcount))

## See review data (takes a minute to load)

file = path_to_yelp*"yelp_academic_dataset_review.json"
loaded = read(file, String)
objects = split(loaded, "\n")

## Save them all
U = Vector{Int64}()
B = Vector{Int64}()
S = Vector{Int64}()
Y = Vector{Int64}()
for j = 1:length(objects)-1
    if mod(j,10000) == 0
        println("$(j/length(objects))")
    end
    review = JSON.parse(objects[j])
    user_id = review["user_id"]
    business_id = review["business_id"]

    # if haskey(user_id2int,user_id) && haskey(business_id2int,business_id)
    user_int = user_id2int[user_id]
    business_int = business_id2int[business_id]
    year = parse(Int64,split(review["date"])[1][1:4])
    stars = review["stars"]
    push!(U,user_int)
    push!(B,business_int)
    push!(S,stars)
    push!(Y,year)
    # end
end
## Save to .mat if desired
# matwrite("yelp-review-data.mat",Dict("U"=>U, "B"=>B, "S"=>S, "Y"=>Y,"m"=>m, "n"=>n))
