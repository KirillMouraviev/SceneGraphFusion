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

def find_source(node_id, node_type):
    nodes = []
    for edge in j['edges']:
        if edge['target'] == node_id:
            source_node = node_by_id[edge['source']]
            if source_node['attributes']['type'].startswith(node_type):
                nodes.append(source_node)
    #for node in nodes:
    #    print(node['attributes']['type'][:-14])
    return nodes

object_nodes = [node for node in j['nodes'] if node['attributes']['type'].startswith('Object')]
object_clusters = {}
for i, node in enumerate(object_nodes):
    place_nodes = find_source(node['id'], 'Place')
    room_nodes = []
    for place_node in place_nodes:
        room_nodes = room_nodes + find_source(place_node['id'], 'Room')
    if len(room_nodes) > 0:
        parent_node_id = room_nodes[0]['id']
    elif len(place_nodes) > 0:
        parent_node_id = place_nodes[0]['id']
    else:
        parent_node_id = node['id']
    if parent_node_id not in object_clusters:
        object_clusters[parent_node_id] = [node]
    else:
        object_clusters[parent_node_id].append(node)

print('Number of objects:', len(object_nodes))
print('Number of object clusters:', len(object_clusters))

fout = open('graph_dumps/full_graph.json', 'w')
json.dump(j, fout)
fout.close()