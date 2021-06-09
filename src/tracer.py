#!/usr/bin/env python3

""" Tracers """

import plotly.graph_objects as go
import networkx as nx

from src.addEdge import addEdge

__author__ = "Created by Konstantin Rolf | University of Groningen"
__copyright__ = "Copyright 2021, Konstantin Rolf"
__credits__ = [""]
__license__ = "GPL"
__version__ = "0.1"
__maintainer__ = "Konstantin Rolf"
__email__ = "konstantin.rolf@gmail.com"
__status__ = "Development"


# additional colorscale options
#'Greys' | 'YlGnBu' | 'Greens' | 'YlOrRd' | 'Bluered' | 'RdBu' |
#'Reds' | 'Blues' | 'Picnic' | 'Rainbow' | 'Portland' | 'Jet' |
#'Hot' | 'Blackbody' | 'Earth' | 'Electric' | 'Viridis' |

def generateFigure(graph, graphLayout, graphType, models):
    if graphType in models:
        if isinstance(graph, nx.DiGraph) and models[graphType]['type'] == 'u':
            graph = graph.to_undirected(as_view=True)
        elif isinstance(graph, nx.Graph) and models[graphType]['type'] == 'd':
            graph = graph.to_directed(as_view=True)

    edge_x, edge_y = [], []
    node_x, node_y = [], []
    edge_cx, edge_cy = [], []
    weights = []
    directed = isinstance(graph, nx.DiGraph)
    if directed:
        for edge in graph.edges(data=True):
            start = (graphLayout[edge[0]] if edge[0] in graphLayout else graph.nodes[edge[0]]['pos'])
            end = (graphLayout[edge[1]] if edge[1] in graphLayout else graph.nodes[edge[1]]['pos'])
            edge_x, edge_y = addEdge(start, end, edge_x, edge_y, 1.0, 'end', .01, 15, 12)
            if 'weight' in edge[2]: # checks if we have a weight
                edge_cx.append((start[0] / 3 + end[0] * (2.0 / 3.0)))
                edge_cy.append((start[1] / 3 + end[1] * (2.0 / 3.0)))
                weights.append(str(edge[2]['weight']))
    else:
        for edge in graph.edges(data=True):
            x0, y0 = (graphLayout[edge[0]] if edge[0] in graphLayout else graph.nodes[edge[0]]['pos'])
            x1, y1 = (graphLayout[edge[1]] if edge[1] in graphLayout else graph.nodes[edge[1]]['pos'])
            edge_x.extend((x0, x1, None))
            edge_y.extend((y0, y1, None))
            if 'weight' in edge[2]: # checks if we have a weight
                edge_cx.append((x0 + x1) / 2)
                edge_cy.append((y0 + y1) / 2)
                weights.append(str(edge[2]['weight']))


    for node in graph.nodes():
        x, y = (graphLayout[node] if node in graphLayout else graph.nodes[node]['pos'])
        node_x.append(x)
        node_y.append(y)

    edge_trace = go.Scatter(
        x=edge_x, y=edge_y,
        line=dict(width=0.5, color='#888'),
        hoverinfo='text',
        mode='lines',
    )

    edge_text_trace = go.Scatter(
        x=edge_cx, y=edge_cy,
        mode='markers',
        hoverinfo='text',
    )
    edge_text_trace.text = weights

    if graphType in models:
        node_trace = models[graphType]['gen'](graph, node_x, node_y)
    else:
        print(f'Unknown graph type {graphType}')
        node_trace = generateConnectionTracer(graph, node_x, node_y)

    fig = go.Figure(
        data=[edge_trace, node_trace, edge_text_trace],
        layout=go.Layout(
            title='Network Graph Translator',
            titlefont_size=16,
            showlegend=False,
            hovermode='closest',
            margin=dict(b=0, l=0, r=0, t=60),
            annotations=[
                dict(
                    text="UNIVERSITY OF GRONINGEN | Konstantin Rolf",
                    showarrow=False,
                    xref="paper", yref="paper",
                    x=0.005, y=-0.002
                )
            ],
            xaxis=dict(showgrid=False, zeroline=False, showticklabels=False),
            yaxis=dict(showgrid=False, zeroline=False, showticklabels=False)
        )
    )
    return fig


def generateConnectionTracer(graph, node_x, node_y):
    node_trace = go.Scatter(
        x=node_x, y=node_y,
        mode='markers',
        hoverinfo='text',
        marker=dict(
            showscale=True,
            colorscale='YlGnBu',
            reversescale=True,
            color=[],
            size=10,
            colorbar=dict(
                thickness=15,
                title='Node Connections',
                xanchor='left',
                titleside='right'
            ),
            line_width=2
        )
    )

    node_trace.marker.color = [len(adj[1]) for _, adj in enumerate(graph.adjacency())]
    node_trace.text = ['# of connections: ' + str(len(adj[1]))
        for _, adj in enumerate(graph.adjacency())]
    return node_trace

def _generateThresholdTrace(graph, node_x, node_y, key, title, color):
    node_trace = go.Scatter(
        x=node_x, y=node_y,
        mode='markers',
        hoverinfo='text',
        marker=dict(
            showscale=True,
            colorscale=color,
            reversescale=True,
            color=[],
            size=10,
            colorbar=dict(
                thickness=15,
                title=title,
                xanchor='left',
                titleside='right'
            ),
            line_width=2
        )
    )

    node_trace.marker.color = [node[1][key] for node in graph.nodes(data=True)]
    node_trace.text = [str(node[1][key]) for node in graph.nodes(data=True)]
    return node_trace

def generateUniformThresholdTracer(graph, node_x, node_y):
    """ Generates the uniform threshold tracer """
    return _generateThresholdTrace(graph, node_x, node_y, 'thu', 'Uniform Threshold', 'Bluered')

def generateWeightedThresholdTracer(graph, node_x, node_y):
    """ Generates the weighted threshold tracer """
    return _generateThresholdTrace(graph, node_x, node_y, 'thw', 'Weighted Threshold', 'Bluered')

def generateSocialChoiceTracer(graph, node_x, node_y):
    """ Generates the social choice tracer """
    return _generateThresholdTrace(graph, node_x, node_y, 'soc', 'Social Choice', 'Bluered')

def generateDeGrootTracer(graph, node_x, node_y):
    """ Generates the DeGroot tracer """
    return _generateThresholdTrace(graph, node_x, node_y, 'deg', 'DeGroot', 'YlGnBu')

def generateSISTracer(graph, node_x, node_y):
    """ Generates the SIS tracer """
    return _generateThresholdTrace(graph, node_x, node_y, 'sis', 'SIS', 'Bluered')

def generateSIRTracer(graph, node_x, node_y):
    """ Generates the SIR tracer """
    return _generateThresholdTrace(graph, node_x, node_y, 'sir', 'SIR', 'Bluered')

if __name__ == '__main__':
    print('tracer.py')