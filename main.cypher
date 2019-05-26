// ceng790 hw4
// emre dogan
// this file includes the queries of hw4 solutions.


CREATE CONSTRAINT ON (c:Character) ASSERT c.name IS UNIQUE;


CALL db.constraints

// importing the dataset.
LOAD CSV WITH HEADERS FROM "https://www.macalester.edu/~abeverid/data/stormofswords.csv" AS row 
MERGE (src:Character {name: row.Source}) 
MERGE (tgt:Character {name: row.Target}) 
MERGE (src)-[r:INTERACTS]->(tgt) 
ON CREATE SET r.weight = toInt(row.Weight)

// observe the graph
MATCH (n) RETURN n

//question 2
// finding the number of characters in the graph.
MATCH (n) RETURN distinct labels(n), count(*)

// question 3
// The summary statistics for each character
MATCH (c:Character)-[i:INTERACTS]->() 
WITH c.name AS name, min(i.weight) 
AS min, max(i.weight) AS max, avg(i.weight) AS avg 
RETURN name, min, max, avg

//question 4
// Shortest path from Arya to Ramsay -- weight based 
MATCH (start:Character{name:'Arya'}), (end:Character{name:'Ramsay'})
CALL algo.shortestPath.stream(start, end, 'weight')
YIELD nodeId, cost
RETURN algo.asNode(nodeId).name AS name, cost

// Shortest path from Arya to Ramsay -- step based
MATCH (arya:Character {name:"Arya"}), (ramsay:Character {name:"Ramsay"}) 
MATCH sPath=shortestPath((arya)-[:INTERACTS*]-(ramsay)) 
RETURN sPath

// ALL Shortest Paths between Arya and Ramsay
CALL algo.allShortestPaths.stream('weight',{nodeQuery:'Character',defaultValue:1.0})
YIELD sourceNodeId, targetNodeId, distance
WITH sourceNodeId, targetNodeId, distance
WHERE algo.isFinite(distance) = true
MATCH (source:Character{name:'Arya'}) WHERE id(source) = sourceNodeId
MATCH (target:Character{name:'Ramsay'}) WHERE id(target) = targetNodeId
WITH source, target, distance WHERE source <> target
RETURN source.name AS source, target.name AS target, distance
ORDER BY distance DESC

// question 5
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

// question 6
// Characters with interaction distance 4 to Cersei 
MATCH (n:Character {name:'Cersei'})
CALL algo.shortestPath.deltaStepping.stream(n, 'weight', 3.0)
YIELD nodeId, distance WHERE distance=4
RETURN algo.asNode(nodeId).name AS destination, distance


// Importing the second dataset--family_ties.csv
LOAD CSV WITH HEADERS FROM "file:///family_ties.csv" AS row MERGE (src:Character {name: row.character1})
MERGE (tgt:Character {name: row.character2})
MERGE (tgt)-[r:RELATIONSHIP]->(src)
ON CREATE SET r.tie = row.tie


// question 7
// checking the parents of Jon Snow
MATCH (char2:Character)-[r:RELATIONSHIP]->(char1:Character{name:'Jon'}) 
RETURN char1,r,char2;

// question 8
// create sibling relationships!
MATCH ((kid1:Character)<-[:RELATIONSHIP]-(parent1:Character)),((kid2:Character)<-[:RELATIONSHIP]-(parent2:Character)) 
WHERE parent1.name=parent2.name
//RETURN kid1,kid2
CREATE (kid1)-[r:RELATIONSHIP{tie:'Sibling'}]->( kid2)

// question 9
// children of incestuous relationships!
MATCH ((kid1_:Character)<-[:RELATIONSHIP{tie:'mother'}]-(parent1_:Character)),
((kid1_:Character)<-[:RELATIONSHIP{tie:'father'}]-(parent2_:Character)) 
WHERE (parent1_:Character)<-[:RELATIONSHIP{tie:'Sibling'}]-(parent2_:Character)
RETURN kid1_,parent1_,parent2_

//observe the final version of the graph
MATCH (n) RETURN n