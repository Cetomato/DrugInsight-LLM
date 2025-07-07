# Example: Query for a specific drug and retrieve associated genes, pathways, and similar drugs
MATCH (drug:DRUG)
WHERE toLower(drug.Name) = '", drugkeyword, "'
WITH drug
OPTIONAL MATCH (drug)-[r1 {source: '", "DrugBank", "'}]-(g1:GENE)
WITH drug, collect({r1: r1, g1: g1}) AS r1_g1_pairs
WITH drug, apoc.coll.randomItems(r1_g1_pairs, 30) AS limited_r1_g1_pairs
WITH drug, [pair IN limited_r1_g1_pairs | pair.r1] AS limited_p1_list, [pair IN limited_r1_g1_pairs | pair.g1] AS limited_g1_list
UNWIND limited_g1_list AS g1
OPTIONAL MATCH p3 = (drug)-[r3:SIMILAR]-(extdrug2:DRUG) 
WHERE r3.", llm, " >= ", simcutoffllm, "
WITH drug, limited_p1_list, limited_g1_list, collect({r3: r3, d: extdrug2, g1: g1}) AS r3_d_pairs
WITH drug, limited_p1_list, limited_g1_list, apoc.coll.randomItems(r3_d_pairs, 30) AS limited_r3_d_pairs
WITH drug, limited_p1_list, limited_g1_list, [pair IN limited_r3_d_pairs | pair.r3] AS limited_p3_list, [pair IN limited_r3_d_pairs | pair.d] AS limited_d_list
UNWIND limited_g1_list AS g1
OPTIONAL MATCH (g1)-[r2]-(pw:", Reactome, ")
WITH drug, limited_p1_list, limited_p3_list, limited_d_list, limited_g1_list, collect({r2: r2, pw: pw, g1: g1}) AS r2_pw_pairs
WITH drug, limited_p1_list, limited_p3_list, limited_d_list, limited_g1_list, apoc.coll.randomItems(r2_pw_pairs, 50) AS limited_r2_pw_pairs
WITH drug, limited_p1_list, limited_p3_list, limited_d_list, limited_g1_list, [pair IN limited_r2_pw_pairs | pair.r2] AS limited_p2_list, [pair IN limited_r2_pw_pairs | pair.pw] AS limited_pw_list
RETURN drug, limited_p1_list, limited_p2_list, limited_pw_list, limited_p3_list, limited_d_list, limited_g1_list
