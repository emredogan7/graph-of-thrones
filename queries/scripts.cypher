LOAD CSV WITH HEADERS FROM "file:///family_ties.csv" AS line WITH line
RETURN line
------------------------------------------------------------------------
CREATE CONSTRAINT ON (c:Character) ASSERT c.name IS UNIQUE;

CALL db.constraints

LOAD CSV WITH HEADERS FROM "https://www.macalester.edu/~abeverid/data/stormofswords.csv" AS row 
MERGE (src:Character {name: row.Source}) 
MERGE (tgt:Character {name: row.Target}) 
MERGE (src)-[r:INTERACTS]->(tgt) 
ON CREATE SET r.weight = toInt(row.Weight)

MATCH (n) RETURN distinct labels(n), count(*)

MATCH (c:Character)-[i:INTERACTS]->() 
WITH c.name AS name, min(i.weight) 
AS min, max(i.weight) AS max, avg(i.weight) AS avg 
RETURN name, min, max, avg

// Shortest path from Arya to Ramsay 
MATCH (arya:Character {name:"Arya"}), (ramsay:Character {name:"Ramsay"}) 
MATCH sPath=shortestPath((arya)-[:INTERACTS*]-(ramsay)) 
RETURN sPath

// All shortest pathes from Arya to Ramsay 
MATCH (arya:Character {name:"Arya"}), (ramsay:Character {name:"Ramsay"}) 
MATCH sPathes = allShortestPaths((arya)-[:INTERACTS*]-(ramsay)) 
RETURN sPathes


// Shortest path from Arya to Ramsay --working 
MATCH (start:Character{name:'Arya'}), (end:Character{name:'Ramsay'})
CALL algo.shortestPath.stream(start, end, 'weight')
YIELD nodeId, cost
RETURN algo.asNode(nodeId).name AS name, cost

// ALL Pathes-Algo.

CALL algo.allShortestPaths.stream('weight',{nodeQuery:'Character',defaultValue:1.0})
YIELD sourceNodeId, targetNodeId, distance
WITH sourceNodeId, targetNodeId, distance
WHERE algo.isFinite(distance) = true

MATCH (source:Character{name:'Arya'}) WHERE id(source) = sourceNodeId
MATCH (target:Character{name:'Ramsay'}) WHERE id(target) = targetNodeId
WITH source, target, distance WHERE source <> target

RETURN source.name AS source, target.name AS target, distance
ORDER BY distance DESC


////////////////////
CALL algo.allShortestPaths.stream('weight',{nodeQuery:'Character',defaultValue:1.0})
YIELD sourceNodeId, targetNodeId, distance
WITH sourceNodeId, targetNodeId, distance
WHERE algo.isFinite(distance) = true

MATCH (source:Character{name:'Arya'}) WHERE id(source) = 4
MATCH (target:Character{name:'Ramsay'}) WHERE id(target) =104
WITH source, target, distance WHERE source <> target WHERE distance>0

RETURN source.name AS source, target.name AS target, distance
ORDER BY distance ASC
LIMIT 100





MATCH (n:Character) RETURN { id: ID(n), name: n.name } as user LIMIT 110
