#!/usr/bin/env python3

""" Contains data representations of objects """

import networkx as nx

import src.models as md
import src.tracer as tr

__author__ = "Created by Konstantin Rolf | University of Groningen"
__copyright__ = "Copyright 2021, Konstantin Rolf"
__credits__ = [""]
__license__ = "GPL"
__version__ = "0.1"
__maintainer__ = "Konstantin Rolf"
__email__ = "konstantin.rolf@gmail.com"
__status__ = "Development"

dropdown_model_default = 'connections'
dropdown_model = {
    'connections': {
        'name': 'Connections',
        'gen': tr.generateConnectionTracer,
        'type': 'u',
        'id': 'con',
        'state': md.ContinuesState(0, 100000),
        'update': md.updateConnections,
    },
    'degroot': {
        'name': 'DeGroot',
        'gen': tr.generateDeGrootTracer,
        'type': 'd',
        'id': 'deg',
        'state': md.ContinuesState(0.0, 1.0),
        'update': md.updateDeGroot,
    },
    'threshold_uniform': {
        'name': 'Threshold',
        'gen': tr.generateUniformThresholdTracer,
        'type': 'u',
        'id': 'thu',
        'state': md.DiscreteState([0, 1]),
        'update': md.updateDeGroot,
    },
    'threshold_weighted': {
        'name': 'Weighted Threshold',
        'gen': tr.generateWeightedThresholdTracer,
        'type': 'd',
        'id': 'thw',
        'state': md.DiscreteState([0, 1]),
        'update': md.updateDeGroot,
    },
    'sis': {
        'name': 'SIS',
        'gen': tr.generateSISTracer,
        'type': 'd',
        'id': 'sis',
        'state': md.DiscreteState([0, 2]),
        'update': md.updateDeGroot,
    },
    'sir': {
        'name': 'SIR',
        'gen': tr.generateSIRTracer,
        'type': 'd',
        'id': 'sir',
        'state': md.DiscreteState([0, 2]),
        'update': md.updateDeGroot,
    },
    'social': {
        'name': 'Social Choice',
        'gen': tr.generateSocialChoiceTracer,
        'type': 'u',
        'id': 'soc',
        'state': md.DiscreteState([0, 2]),
        'update': md.updateDeGroot,
    },
}

def generateDefaultLayout(graph):
    return {nodeTuple[0]: nodeTuple[1]['pos']
        for nodeTuple in graph.nodes(data=True)}


layouts_default = 'default'
layouts = {
    'bipartite_layout': {
        'name': 'Bipartite Layout',
        'gen': lambda graph: nx.circular_layout(graph),
    },
    'circular_layout': {
        'name': 'Circular Layout',
        'gen': lambda graph: nx.circular_layout(graph),
    },
    'kamada_kawai_layout': {
        'name': 'Kamada Kawai Layout',
        'gen': lambda graph: nx.kamada_kawai_layout(graph),
    },
    'planar_layout': {
        'name': 'Planar Layout',
        'gen': lambda graph: nx.planar_layout(graph),
    },
    'random_layout': {
        'name': 'Random Layout',
        'gen': lambda graph: nx.random_layout(graph),
    },
    'shell_layout': {
        'name': 'Shell Layout',
        'gen': lambda graph: nx.shell_layout(graph),
    },
    'spring_layout': {
        'name': 'Spring Layout',
        'gen': lambda graph: nx.spring_layout(graph),
    },
    'spectral_layout': {
        'name': 'Spectral Layout',
        'gen': lambda graph: nx.spectral_layout(graph),
    },
    'spiral_layout': {
        'name': 'Spiral Layout',
        'gen': lambda graph: nx.spiral_layout(graph)
    },
    'default': {
        'name': 'Default Layout',
        'gen': generateDefaultLayout,
    }
}

class intlist: pass

graph_gens_default = 'random_geometric'
graph_gens = {
    'balanced_tree': {
        'name': 'Balanced Tree',
        'args': ('r', 'h'),
        'argtypes': (int, int),
        'argvals': (3, 3),
        'gen': lambda r, h: nx.balanced_tree(r, h),
        'description_fn': 'balanced_tree(r, h)',
        'description': 'Returns the perfectly balanced r-ary tree of height h.'
    },
    'barbell_graph': {
        'name': 'Barbell Graph',
        'args': ('m1', 'm2'),
        'argtypes': (int, int),
        'argvals': (3, 3),
        'gen': lambda m1, m2: nx.barbell_graph(m1, m2),
        'description_fn': 'barbell_graph(m1, m2)',
        'description': 'Returns the Barbell Graph: two complete graphs connected by a path.'
    },
    'binomial_tree': {
        'name': 'Binomial Tree',
        'args': ('n',),
        'argtypes': (int,),
        'argvals': (3,),
        'gen': lambda n: nx.binomial_tree(n),
        'description_fn': 'binomial_tree(n)',
        'description': 'Returns the Binomial Tree of order n.',
    },
    'circular_ladder_graph': {
        'name': 'Circular Ladder Graph',
        'args': ('n',),
        'argtypes': (int,),
        'argvals': (3,),
        'gen': lambda n: nx.circular_ladder_graph(n),
        'description_fn': 'circular_ladder_graph(n)',
        'description': 'Returns the circular ladder graph CLn of length n.'
    },
    'cycle_graph': {
        'name': 'Cycle Graph',
        'args': ('n',),
        'argtypes': (int,),
        'argvals': (3,),
        'gen': lambda n: nx.cycle_graph(n),
        'description_fn': 'cycle_graph(n)',
        'description': 'Returns the cycle graph Cn of cyclically connected nodes.',
    },
    'dorogovtsev_goltsev_mendes_graph': {
        'name': 'Dorogovtsev Goltsev Mendes Graph',
        'args': ('n',),
        'argtypes': (int,),
        'argvals': (3,),
        'gen': lambda n: nx.dorogovtsev_goltsev_mendes_graph(n),
        'description_fn': 'dorogovtsev_goltsev_mendes_graph(n)',
        'description': 'Returns the hierarchically constructed Dorogovtsev-Goltsev-Mendes graph.',
    },
    'dorogovtsev_goltsev_mendes_graph': {
        'name': 'Dorogovtsev Goltsev Mendes Graph',
        'args': ('n',),
        'argtypes': (int,),
        'argvals': (3,),
        'gen': lambda n: nx.dorogovtsev_goltsev_mendes_graph(n),
        'description_fn': 'dorogovtsev_goltsev_mendes_graph(n)',
        'description': 'Returns the hierarchically constructed Dorogovtsev-Goltsev-Mendes graph.',
    },
    'empty_graph': {
        'name': 'Empty Graph',
        'args': ('n',),
        'argtypes': (int,),
        'argvals': (3,),
        'gen': lambda n: nx.empty_graph(n),
        'description_fn': 'empty_graph(n)',
        'description': 'Returns the empty graph with n nodes and zero edges.',
    },
    'full_rary_tree': {
        'name': 'Full Rary Tree',
        'args': ('r', 'n'),
        'argtypes': (int, int),
        'argvals': (3, 3),
        'gen': lambda r, n: nx.full_rary_tree(r, n),
        'description_fn': 'full_rary_tree(r, n)',
        'description': 'Creates a full r-ary tree of n vertices.',
    },
    'ladder_graph': {
        'name': 'Ladder Graph',
        'args': ('n',),
        'argtypes': (int,),
        'argvals': (3,),
        'gen': lambda n: nx.ladder_graph(n),
        'description_fn': 'ladder_graph(n)',
        'description': 'Returns the Ladder graph of length n.',
    },
    'lollipop_graph': {
        'name': 'Lollipop Graph',
        'args': ('m', 'n'),
        'argtypes': (int, int),
        'argvals': (3, 3),
        'gen': lambda m, n: nx.lollipop_graph(m, n),
        'description_fn': 'lollipop_graph(m, n)',
        'description': 'Returns the Lollipop Graph; K_m connected to P_n.',
    },
    'null_graph': {
        'name': 'Null Graph',
        'args': (),
        'argtypes': (),
        'argvals': (),
        'gen': nx.null_graph(),
        'description_fn': 'null_graph()',
        'description': 'Returns the Null graph with no nodes or edges.',
    },
    'path_graph': {
        'name': 'Path Graph',
        'args': ('n',),
        'argtypes': (int,),
        'argvals': (3,),
        'gen': lambda n: nx.path_graph(n),
        'description_fn': 'path_graph(n)',
        'description': 'Returns the Path graph P_n of linearly connected nodes.',
    },
    'star_graph': {
        'name': 'Star Graph',
        'args': ('n',),
        'argtypes': (int,),
        'argvals': (3,),
        'gen': lambda n: nx.star_graph(n),
        'description_fn': 'star_graph(n)',
        'description': 'Return the star graph',
    },
    'trivial_graph': {
        'name': 'Trivial Graph',
        'args': (),
        'argtypes': (),
        'argvals': (),
        'gen': nx.trivial_graph(),
        'description_fn': 'trivial_graph()',
        'description': 'Return the Trivial graph with one node (with label 0) and no edges.',
    },
    'turan_graph': {
        'name': 'Turan Graph',
        'args': ('n', 'r'),
        'argtypes': (int, int,),
        'argvals': (3, 3),
        'gen': lambda n, r: nx.turan_graph(n, r),
        'description_fn': 'turan_graph(n, r)',
        'description': 'Return the Turan Graph',
    },
    'wheel_graph': {
        'name': 'Wheel Graph',
        'args': ('n',),
        'argtypes': (int,),
        'argvals': (3,),
        'gen': lambda n: nx.wheel_graph(n),
        'description_fn': 'wheel_graph(n)',
        'description': 'Return the wheel graph',
    },
    'random_geometric': {
        'name': 'Random Geometric',
        'args': ('n', 'c'),
        'argtypes': (int, float),
        'argvals': (100, 0.125),
        'gen': lambda n, c: nx.random_geometric_graph(n, c),
        'description_fn': 'random_geometric_graph(n, c)',
        'description': 'Returns a random geometric graph in the unit cube of dimensions dim.',
    }
}
