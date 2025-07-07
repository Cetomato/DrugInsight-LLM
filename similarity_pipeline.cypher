# 1. Project the full graph for GDS algorithms
CALL gds.graph.project(
  'fullGraph',    // Name of the projected graph
  '*',            // Use all node labels
  '*'             // Use all relationship types
);

# 2. Compute Jaccard similarity between DRUG nodes and export results to CSV
CALL apoc.export.csv.query(
  "
  CALL gds.nodeSimilarity.stream('fullGraph', {similarityMetric: 'JACCARD'}) 
  YIELD node1, node2, similarity
  MATCH (d1:DRUG) WHERE id(d1) = node1
  MATCH (d2:DRUG) WHERE id(d2) = node2
  WITH d1, d2, similarity
  WHERE id(d1) < id(d2)
  RETURN d1.uuid AS Drug1, d2.uuid AS Drug2, similarity
  ORDER BY similarity DESCENDING, Drug1, Drug2
  ",
  'drug_similarity_jac.csv',
  {delimiter: ','}
)
YIELD file, source, format, nodes, relationships, properties, time
RETURN 'CSV export complete: ' + file AS message;

# 3. Compute Cosine similarity between DRUG nodes and export
CALL apoc.export.csv.query(
  "
  CALL gds.nodeSimilarity.stream('fullGraph', {similarityMetric: 'COSINE'}) 
  YIELD node1, node2, similarity
  MATCH (d1:DRUG) WHERE id(d1) = node1
  MATCH (d2:DRUG) WHERE id(d2) = node2
  WITH d1, d2, similarity
  WHERE id(d1) < id(d2)
  RETURN d1.uuid AS Drug1, d2.uuid AS Drug2, similarity
  ORDER BY similarity DESCENDING, Drug1, Drug2
  ",
  'drug_similarity_cos.csv',
  {delimiter: ','}
)
YIELD file, source, format, nodes, relationships, properties, time
RETURN 'CSV export complete: ' + file AS message;

# 4. Node2Vec embedding for drug nodes
:param limit => (42);
:param config => ({
  relationshipWeightProperty: null,
  iterations: 5,
  embeddingDimension: 128,
  walkLength: 30,
  inOutFactor: 2,
  returnFactor: 1,
  writeProperty: 'node2vec'
});
:param graphConfig => ({
  nodeProjection: '*',
  relationshipProjection: {
    relType: {
      type: '*',
      orientation: 'UNDIRECTED',
      properties: {}
    }
  }
});
:param generatedName => ('node2vecc');
CALL gds.graph.project($generatedName, $graphConfig.nodeProjection, $graphConfig.relationshipProjection, {});
CALL gds.beta.node2vec.write($generatedName, $config);

# 5. KNN similarity using Node2Vec embeddings
:param graphConfig => ({
  nodeProjection: 'DRUG',
  relationshipProjection: {
    relType: {
      type: '*',
      orientation: 'NATURAL',
      properties: {}
    }
  },
  nodeProperties: ['node2vec']
});
:param config => ({
  topK: 10,
  randomJoins: 10,
  sampleRate: 0.5,
  deltaThreshold: 0.001,
  nodeProperties: {
    node2vec: 'COSINE'
  },
  writeProperty: 'score',
  writeRelationshipType: 'SIMILAR_KNN'
});
:param generatedName => ('in-memory-graph-1750918996696');
CALL gds.graph.project($generatedName, $graphConfig.nodeProjection, $graphConfig.relationshipProjection, {nodeProperties: ["node2vec"]});
CALL gds.knn.write($generatedName, $config)
