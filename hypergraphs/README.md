## README

Information about each hypergraph.

To download the largest two hypergraphs (used in the KDD 2020 paper), here are links:

[https://drive.google.com/file/d/166myErQy1HgGMg7gGshE6MgE5mBDDotA/view?usp=sharing](https://drive.google.com/file/d/166myErQy1HgGMg7gGshE6MgE5mBDDotA/view?usp=sharing)

[https://drive.google.com/file/d/1jhcu9kr2ipttiAbpJmPTuIarvjQRK6Mh/view?usp=sharing](https://drive.google.com/file/d/1jhcu9kr2ipttiAbpJmPTuIarvjQRK6Mh/view?usp=sharing)

Each .mat file primarily includes an edge by node (|E| x |V|) hypergraph incidence matrix, where B(e,u) = 1 indicates edge e contains node u.

If anything isn't filled in that needs to be, I can hunt down details. -Nate

### Math overflow and Stack overflow

Nodes are questions asked on a forum (either mathoverflow.com or stackoverflow.com), and hyperedges are questions answered by the same user.

Each question is associated with a set of tags (e.g., "abstract algebra", "lie groups" for mathoverflow), which in some cases correspond to decent clusters, though not always. 

### Amazon Reviews-Products

Nodes are products, and hyperedges are products that are co-reviewed. 

Metadata is product category --- these tend to correspond very well to clustering structure. The smallest clusters are very tiny compared to the overall hypergraph, so this is a great dataset for local clustering experiments.

### Walmart

https://www.cs.cornell.edu/~arb/data/walmart-trips/

Nodes are products, and hyperedges are co-purchased products.

Two types of labels: products are organized by product category (e.g. HEALTH AND BEAUTY AIDS), and these are then organized into larger "department" clusters (e.g. "Clothing, Shoes and Accessories").

### Cooking

These are various hypergraphs constructed from the What's Cooking dataset: https://www.kaggle.com/c/whats-cooking.

Nodes are recipes, and labels are the world cuisine each recipe belongs to (e.g., Korean, Spanish, Italian)

Each hyperedge correspond to an ingredient, and is made up of all recipes (nodes) that use that ingredient.

The number indicates that largest hyperedge size.

These should all be connected hypergraphs. 

### Newsgroups

4 large clusters corresponding to types of documents. Not great for local clustering experiments.
