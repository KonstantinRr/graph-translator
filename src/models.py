#!/usr/bin/env python3

""" Models """

import random

import networkx as nx

from src.interaction import *

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

    def random(self):
        return random.random() * (self.end - self.start) + self.start

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

def init_value(data, args, key):
    graph = data['graph']
    for node in get_node_names(args['selected']):
        graph.nodes[node][key] = args['init']
    return data


def addMinRequirements(graph):
    """ Adds the minimum requirements to the graph """
    def update(node, key, value, range):
        if key not in node[1]:
            node[1][key] = value

    graphLayout = None
    for node in graph.nodes(data=True):
        if 'pos' not in node[1]:
            if graphLayout is None:
                graphLayout = nx.spring_layout(graph)
            data = graphLayout[node[0]]
            node[1]['pos'] = (data[0], data[1])

        update(node, 'thu', 0, (0, 1))
        update(node, 'thu_th', 0.5, (0, 1))
        update(node, 'thw', 0, (0, 1))
        update(node, 'thw_th', 0.5, (0, 1))

        update(node, 'tha', 0, (0, 1))
        update(node, 'deg', 0, (0, 1))
        update(node, 'sis', 0, (0, None))
        update(node, 'sir', 0, (-1, None))
        update(node, 'upodmaj', 0, (None, None))
        update(node, 'upoduna', 0, (None, None))

    for edge in graph.edges(data=True):
        if 'weight' not in edge[2]:
            edge[2]['weight'] = 1    
    return graph


if __name__ == '__main__':
    print('models.py')