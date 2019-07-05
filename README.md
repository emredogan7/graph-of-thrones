# neo4j Practices on Game of Thrones Dataset

- This repository belongs to an assignment of CENG790 Big Data Analytics Course, METU.

- Detailed assignment description can be found [here.](./assignment-definition.pdf) 

## Dataset: 
- [stormofswords.csv](./data/stormofswords.csv) includes `Source`, `Target`, `Weight` where Source and Target represent characters from the books, while the weight quantifies the number of interactions between these two characters.

- [family_ties.csv](./data/family_ties.csv) includes information on the family ties between the characters.

## Analysis

### Finding the number of characters in the graph:
`MATCH (n) RETURN distinct labels(n), count(*)` 

The total number of characters is 107. The related screenshot from Neo4j Desktop is available in Figure 1. 

<figure>
  <img src="./figures/1.png" alt="Total Characters" style="width:100%">
  <figcaption>Fig.1 - Screenshot from Neo4j showing the number of total characters in the graph.</figcaption>
</figure>


### Summary  statistics  for each character:

The summary  statistics  for  the  minimum,  maximum  and  average  number  of  characters  each character has interacted with is achieved with the following cypher query.

```
MATCH (c:Character)-[i:INTERACTS]->() 
WITH c.name AS name, min(i.weight) 
AS min, max(i.weight) AS max, avg(i.weight) AS avg 
RETURN name, min, max, avg
```
The resulting screenshot is given in Figure 2.

<figure>
  <img src="./figures/2.png" alt="summary statistics" style="width:100%">
  <figcaption>Fig.2 - Summary statistics for the minimum, maximum and average number of characters each character has interacted with.</figcaption>
</figure>


### Finding the shortest path between two characters:
In order to find the shortest path between two characters (i.e. from Arya to Ramsay), I tried the default shortestPath algorithm defined in the Neo4j. But this function does not take into account the weight property and calculate the distance as the steps between source and target nodes.For our case (Arya -> Ramsay), the shortest path results with 2 steps which does not consider the weights.  

For this reason, I installed the plugin of [Graph  Algorithms](https://github.com/neo4j-contrib/neo4j-graph-algorithms) implemented for Neo4j and used the shortest path algorithm within this library. The related query is given below:  

```
// Shortest path from Arya to Ramsay –Graph Algorithms implementation
MATCH (start:Character{name:'Arya'}), (end:Character{name:'Ramsay'})
CALL algo.shortestPath.stream(start, end, 'weight')
YIELD nodeId, costRETURN algo.asNode(nodeId).name AS name, cost
```

The result is given in Figure 3. Shortest path beween Arya and Ramsay is 13.

<figure>
  <img src="./figures/4.png" alt="shortest path" style="width:100%">
  <figcaption>Fig.3 - Shortest path between the characters Arya and Ramsay.</figcaption>
</figure>


### Finding the longest shortest path between any two characters:
To find the longest shortest path within the graph, I used  `algo.allShortestPaths.streamfunction`  from  the  Graph  Algorithms  plugin.  The query is in the following form:

```
// Finding the longest shortest path!
CALL algo.allShortestPaths.stream('weight',{nodeQuery:'Character',defaultValue:1.0})
YIELD sourceNodeId, targetNodeId, distance
WITH sourceNodeId, targetNodeId, distance
WHERE algo.isFinite(distance) = true
MATCH (source:Character) WHERE id(source) = sourceNodeId
MATCH (target:Character) WHERE id(target) = targetNodeId
WITH source, target, distance WHERE source <> target
RETURN source.name AS source, target.name AS target, distance
ORDER BY distance DESC
```

The longest shortest pathes are given in Figure 4.

<figure>
  <img src="./figures/6.png" alt="longest shortest path" style="width:100%">
  <figcaption>Fig.4 - The list of longest shortest pathes between any 2 characters.</figcaption>
</figure>


