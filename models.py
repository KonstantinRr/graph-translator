import networkx as nx
import numpy as np

def _updateThresholdNode(node, adjacencies, threshold):
    total = len(adjacencies)
    count = 0
    for adjacency in adjacencies.items():
        if graph.nodes[node]['thw'] > 0.5:
            count += 1
    return count <= threshold * total

def updateThreshold(graph, threshold, steps=1):
    state = np.array([node[1]['deg'] for node in graph.nodes(data=True)])
    npMatrix = nx.to_numpy_matrix(graph, weight='weight')
    
def updateSocialChoice(graph, steps=1):
    pass

def updateDeGroot(graph, steps=1):
    # create the matrix version of the graph
    npMatrix = nx.to_numpy_matrix(graph, weight='weight')
    # calculates the number of steps 
    convMatrix = np.linalg.matrix_power(npMatrix, steps)
    # gets the current state as numpy vector
    state = np.array([node[1]['deg'] for node in graph.nodes(data=True)])
    # calculates the new state by multiplying with the matrix
    newState = np.asarray(np.dot(convMatrix, state)).reshape(-1)
    # apply the new state to the model
    for val, node in zip(newState, graph.nodes(data=True)):
        node[1]['deg'] = val
