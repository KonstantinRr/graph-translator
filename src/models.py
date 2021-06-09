#!/usr/bin/env python3

""" Models """

import random

import networkx as nx
import numpy as np

__author__ = "Created by Konstantin Rolf | University of Groningen"
__copyright__ = "Copyright 2021, Konstantin Rolf"
__credits__ = [""]
__license__ = "GPL"
__version__ = "0.1"
__maintainer__ = "Konstantin Rolf"
__email__ = "konstantin.rolf@gmail.com"
__status__ = "Development"

class DiscreteState:
    def __init__(self, values):
        self.values = values

    def random(self):
        return random.choice(self.values)

class ContinuesState:
    def __init__(self, start, end):
        self.start = start
        self.end = end

    def random(self, count=1):
        return [random.random() * (self.end - self.start) + self.start
            for _ in range(count)]

def updateLayout(graph, layoutAlgorithm, layouts, default=None):
    """ Updates the layout of the graph """
    if layoutAlgorithm in layouts:
        return layouts[layoutAlgorithm]['gen'](graph)
    elif layoutAlgorithm == 'default' or layoutAlgorithm is None:
        return {} if default is None else updateLayout(graph, default, layouts)
    else:
        print('Unknown Layout algorithm!', layoutAlgorithm)
        return {} if default is None else updateLayout(graph, default, layouts)


def addMinRequirements(graph, layout):
    """ Adds the minimum requirements to the graph """
    def update(node, key, value):
        if key not in node[1]:
            node[1][key] = value

    graphLayout = None
    for node in graph.nodes(data=True):
        if 'pos' not in node[1]:
            if graphLayout is None:
                graphLayout = updateLayout(graph, layout, default='spring_layout')
            data = graphLayout[node[0]]
            node[1]['pos'] = (data[0], data[1])

        update(node, 'thu', 0.0)
        update(node, 'thw_wei', 0.5)
        update(node, 'thw', 0.0)
        update(node, 'thw_wei', 0.5)

        update(node, 'deg', 0)
        update(node, 'sis', 0)
        update(node, 'sir', 0)
        update(node, 'soc', 0)

    for edge in graph.edges(data=True):
        if 'weight' not in edge[2]:
            edge[2]['weight'] = 1    
    return {} if graphLayout is None else graphLayout


def _updateThresholdNode(node, adjacencies, threshold):
    pass
    #total = len(adjacencies)
    #count = 0
    #for adjacency in adjacencies.items():
    #    if graph.nodes[node]['thw'] > 0.5:
    #        count += 1
    #return count <= threshold * total

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

if __name__ == '__main__':
    print('models.py')