## Yelp Experiment Readme

This readme outlines how to obtain data and run the full experiment for the las-vegas yelp dataset in the introduction. 

### Original Data

The original data is available at [https://www.yelp.com/dataset](https://www.yelp.com/dataset)

It is free to download if you register your name, email address, and consent to the dataset license. Download the data and store it in a folder. You will then have access to several JSON files with metadata and review. For this experiment we only require three of the JSON files.

Metadata for businesses:

	yelp_academic_dataset_business.json

Metadata for users:

Review information:

	yelp_academic_dataset_review.json

### Building the hypergraph

Run the following julia files in order:

1. **read\_data.jl**
Extracts and stores the needed review data and business metadata from the original JSON files to files yelp-review-data.mat and yelp-business-metadata.mat

2. **yelp\_restaurant\_hypergraph.jl** 
Converts processed data into a connected hypergraph of just businesses that are restaurants. Also extracts the Las Vegas cluster, which corresponds to all restaurants with a Las Vegas area zip code (obtained elsewhere).

The end result is a hypergraph stored in yelp\_restaurant\_hypergraph.mat where each node is a restaurant from the dataset and a hyperedge is the set of restaurants reviewed by the same user. 

The hypergraph has the following statistics:

nodes
hyperedges
max hyperedge size
average hyperedge size
median hyperedge size

Node metadata:

* Latitute and longitude
* City, State, and Zipcode
* {0,1} vector of whether node is in Las Vegas area. 7403 nodes are in this cluster.


### Other julia files

For generating the clique expansion and star expansion (which you can run once and then save the output from)

1. **yelp_expansions.jl**: Produces star and clique expansion for hypergraph
2. **spectral_vegas**: produces xy coordinates for visualizing restaurants in las vegas, using a eigenvectors of the Laplacian of a nearest neighbors matrix on latitude-longitude data

### Running Local Hypergraph Experiments

Experiments for all algorithms are run local_clustering_yelp.jl

To generate plots from the output, run plot_lasvegas_results.jl

#### Experimental Setup

We randomly generate 15 sets of 10 seed nodes, taken uniformly at random from the Las Vegas cluster (7403 nodes).

For each set of seed nodes, we run 5 methods:

* LH: our new method
* HyperLocal (flow) by itself
* Peform clique expansion and run ACL
* Perform star expansion and run ACL
* Run HyperLocal on the output of LH

For all methods, we use a shared parameter

delta = 5000.0

This controls the hyperedge cut penalty. For HyperLocal, this is equivalent to running the method on a star expansion, since 5000 is larger than the maximum hyperedge size.

#### HyperLocal Parameters and Details

We force the algorithm to keep the 10 nodes as a seed set. We additionally grow the seeds to include 1000 arbitrary nodes from the 1-hop neighborhood, since the method performs poorly on small seed sets. Even so, the method does poorly.

When refining the output of LH, we set epsilon = 1.0 since the cluster is already large and we want to just explore more locally and not necessarily grow the input set. We still force the 10 seed original nodes to be included in the output.

#### Other Parameters

gamma = 1.0, kappa = 0.000025. See .jl file for more details about parameters and settings for expansions + ACL. We try a few different parameter settings and select the most favorable outcome for these approaches.


