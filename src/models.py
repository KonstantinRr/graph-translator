#!/usr/bin/env python3

""" Models """

import random
from math import gcd

import networkx as nx
from networkx.readwrite.json_graph import adjacency
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

def stochastic_callback(data, args):
    if isinstance(data['graph'], nx.Graph):
        # undirected graph: convert
        data['graph'] = nx.DiGraph(data['graph'])
    nx.stochastic_graph(data['graph'], copy=False, weight='weight')
    return data

def updateLayout(graph, layoutAlgorithm, layouts):
    """ Updates the layout of the graph """
    if layoutAlgorithm in layouts:
        graphLayout = layouts[layoutAlgorithm]['gen'](graph)
        for node, pos in graphLayout.items():
            graph.nodes[node]['layout'] = pos
    else:
        print('UNKNOWN LAYOUT ALGORITHM')


def addMinRequirements(graph):
    """ Adds the minimum requirements to the graph """
    def update(node, key, value):
        if key not in node[1]:
            node[1][key] = value

    graphLayout = None
    for node in graph.nodes(data=True):
        if 'pos' not in node[1]:
            if graphLayout is None:
                graphLayout = nx.spring_layout(graph)
            data = graphLayout[node[0]]
            node[1]['pos'] = (data[0], data[1])

        update(node, 'thu', 0.0)
        update(node, 'thu_th', 0.5)
        update(node, 'thw', 0.0)
        update(node, 'thw_th', 0.5)

        update(node, 'deg', 0)
        update(node, 'sis', 0)
        update(node, 'sir', 0)
        update(node, 'soc', 0)

    for edge in graph.edges(data=True):
        if 'weight' not in edge[2]:
            edge[2]['weight'] = 1    
    return graph


def convert(graph, thresholdKey, weightKey, valueKey):
    outGraph = nx.empty_graph()

    base = 10 ** 3
    edgeIdx, nodeIdx = 0, 0
    for src, adjacency in graph.adjacency():
        # gets an integer representation of the threshold
        threshold = int(graph.nodes[src][thresholdKey] * base)

        # calculates the LCM of the threshold and all the outgoing edges
        lcm = threshold
        for dst, edgeData in adjacency.items(): # all adjacent nodes
            weight = int(edgeData[weightKey] * base)
            lcm = lcm * weight // gcd(lcm, weight)

        # adds the node without the data
        outGraph.add_node(src)

        for dst, edgeData in adjacency.items(): # all adjacent nodes
            # calculates the weight in digit count
            weight = int(edgeData[weightKey] * base)

            # adds the node constructs
            for i in range(lcm // weight):
                t1, t2, b = f'f_{edgeIdx}_{i}_0', f'f_{edgeIdx}_{i}_1', f'b_{edgeIdx}_{i}'
                outGraph.add_nodes_from([
                    (t1, {valueKey: 0}),
                    (t2, {valueKey: 0}),
                    (b, {valueKey: 0}),
                ])
                # adds the connecting 
                outGraph.add_edges_from([
                    (t1, src), (t2, src),
                    (b, t1), (b, t2),
                    (dst, b)
                ])

            # adds the counter nodes to the source
            for i in range(2 * (lcm // weight)):
                counterNode = f'c_{edgeIdx}_{i}'
                outGraph.add_nodes_from([(counterNode, {valueKey: 1})])
                outGraph.add_edge(counterNode, src)

            # adds the threshold nodes to the destination
            for i in range(lcm // threshold):
                counterNode = f't_{edgeIdx}_{i}'
                outGraph.add_nodes_from([(counterNode, {valueKey: 0})])
                outGraph.add_edge(counterNode, dst)
            edgeIdx += 1
    return outGraph        

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

def updateConnections(graph, steps=1):
    pass


if __name__ == '__main__':
    print('models.py')