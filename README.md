# neo4j Practices on Game of Thrones 

- This repository belongs to an assignment of CENG790 Big Data Analytics Course, METU.

- Detailed assignment description can be found [here.](./assignment-definition.pdf) 

## Dataset: 
- [stormofswords.csv](./data/stormofswords.csv) includes `Source`, `Target`, `Weight` where Source and Target represent characters from the books, while the weight quantifies the number of interactions between these two characters.

- [family_ties.csv](./data/family_ties.csv) includes information on the family ties between the characters.

## Analysis

- **Finding the number of characters in the graph:**  
`MATCH (n) RETURN distinct labels(n), count(*)` 

The total number of characters is 107. The related screenshot from Neo4j Desktop is available in Figure 1. 

<figure>
  <img src="./figures/1.png" alt="Total Characters" style="width:100%">
  <figcaption>Fig.1 - Screenshot from Neo4j showing the number of total characters in the graph.</figcaption>
</figure>