# Spatial Data 

Short exercise exploiting spatial data to compute and visualize municipal-level housing indicators in Switzerland.

## What it does
- Loads Swiss municipal boundaries and a tabular housing dataset.
- Cleans and simplifies geometry (drops Z dimension, simplifies shapes).
- Performs spatial joins to aggregate housing postings by municipality.
- Computes metrics (counts, average rent, rent per m²) for municipalities with ≥ 5 postings.
- Produces maps (choropleths) and performs a distance-based query (e.g., postings within 1 km of Ticino municipality borders).
