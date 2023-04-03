import json
# Change to your actual path
path_to_json = '/home/kirill/hydra_ws/src/hydra/hydra_dsg_builder/output/mp3d/backend/dsg.json'
fin = open(path_to_json, 'r')
j = json.load(fin)
fin.close()

node_by_id = {}
for node in j['nodes']:
    node_by_id[node['id']] = node

all_types = []
for node in j['nodes']:
    all_types.append(node['attributes']['type'])
all_types = list(set(all_types))

for node_type in all_types:
    graph_of_type = {'nodes': [], 'edges': []}
    for node in j['nodes']:
        if node['attributes']['type'] == node_type:
            node['neighbors'] = []
            graph_of_type['nodes'].append(node)
    for edge in j['edges']:
        n1 = node_by_id[edge['source']]
        n2 = node_by_id[edge['target']]
        if n1['attributes']['type'] == node_type and n2['attributes']['type'] == node_type:
            graph_of_type['edges'].append(edge)
            n1['neighbors'].append(n2['id'])
            n2['neighbors'].append(n1['id'])
    #print(graph_of_type['nodes'][0])
    print('Graph of {}s contains {} nodes and {} edges'.format(node_type[:-14], len(graph_of_type['nodes']), len(graph_of_type['edges'])))
    fout = open('graph_dumps/{}s.json'.format(node_type[:-14]), 'w')
    json.dump(graph_of_type, fout)
    fout.close()

fout = open('graph_dumps/full_graph.json', 'w')
json.dump(j, fout)
fout.close()