
# Python standard lib
import uuid
import json

import plotly.graph_objects as go
import networkx as nx

import dash
import dash.dependencies as dp
import dash_core_components as dcc
import dash_bootstrap_components as dbc
import dash_html_components as html

from flask_caching import Cache

# data packages
import pandas as pd
import numpy as np

from addEdge import addEdge

def randomGraph(nodes=200, connect=0.125):
    graph = nx.random_geometric_graph(nodes, connect)
    #graph = nx.gn_graph(nodes)
    #nx.stochastic_graph(graph)
    return graph

def updateLayout(graph, layoutAlgorithm):
    if layoutAlgorithm == 'bipartite_layout':
        top = nx.bipartite.sets(graph)[0]
        return nx.bipartite_layout(graph, top)
    elif layoutAlgorithm == 'circular_layout':
        return nx.circular_layout(graph)
    elif layoutAlgorithm == 'kamada_kawai_layout':
        return nx.kamada_kawai_layout(graph)
    elif layoutAlgorithm == 'planar_layout':
        return nx.planar_layout(graph)
    elif layoutAlgorithm == 'random_layout':
        return nx.random_layout(graph)
    elif layoutAlgorithm == 'shell_layout':
        return nx.shell_layout(graph)
    elif layoutAlgorithm == 'spring_layout':
        return nx.spring_layout(graph)
    elif layoutAlgorithm == 'spectral_layout':
        return nx.spectral_layout(graph)
    elif layoutAlgorithm == 'spiral_layout':
        return nx.spiral_layout(graph)
    elif layoutAlgorithm == 'default' or layoutAlgorithm is None:
        return {}
    else:
        print('Unknown Layout algorithm!', layoutAlgorithm)
        return {}

def generateFigure(graph, graphLayout):
    edge_x, edge_y = [], []
    node_x, node_y = [], []
    edge_cx, edge_cy = [], []
    weights = []
    directed = True
    if directed:
        for edge in graph.edges(data=True):
            start = (graphLayout[edge[0]] if edge[0] in graphLayout else graph.nodes[edge[0]]['pos'])
            end = (graphLayout[edge[1]] if edge[1] in graphLayout else graph.nodes[edge[1]]['pos'])
            edge_x, edge_y = addEdge(start, end, edge_x, edge_y, 1.0, 'end', .01, 15, 12)
            edge_cx.append((start[0] + end[0]) / 2)
            edge_cy.append((start[1] + end[1]) / 2)
            #weights.append(edge[2]['weight'])
    else:
        for edge in graph.edges(data=True):
            x0, y0 = (graphLayout[edge[0]] if edge[0] in graphLayout else graph.nodes[edge[0]]['pos'])
            x1, y1 = (graphLayout[edge[1]] if edge[1] in graphLayout else graph.nodes[edge[1]]['pos'])
            edge_x.extend((x0, x1, None))
            edge_y.extend((y0, y1, None))
            edge_cx.append((x0 + x1) / 2)
            edge_cy.append((y0 + y1) / 2)
            #weights.append(edge[2]['weight'])


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
    #edge_trace.text = [str(weight) for weight in weights]



    node_trace = go.Scatter(
        x=node_x, y=node_y,
        mode='markers',
        hoverinfo='text',
        marker=dict(
            showscale=True,
            # colorscale options
            #'Greys' | 'YlGnBu' | 'Greens' | 'YlOrRd' | 'Bluered' | 'RdBu' |
            #'Reds' | 'Blues' | 'Picnic' | 'Rainbow' | 'Portland' | 'Jet' |
            #'Hot' | 'Blackbody' | 'Earth' | 'Electric' | 'Viridis' |
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


    node_adjacencies = []
    node_text = []
    for node, adjacencies in enumerate(graph.adjacency()):
        node_adjacencies.append(len(adjacencies[1]))
        node_text.append('# of connections: ' + str(len(adjacencies[1])))

    node_trace.marker.color = node_adjacencies
    node_trace.text = node_text


    fig = go.Figure(
        data=[edge_trace, node_trace],
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



fig_names = [
    ('bipartite_layout', 'bipartite_layout'),
    ('circular_layout', 'circular_layout'),
    ('kamada_kawai_layout', 'kamada_kawai_layout'),
    ('planar_layout', 'planar_layout'),
    ('random_layout', 'random_layout'),
    ('shell_layout', 'shell_layout'),
    ('spring_layout', 'spring_layout'),
    ('spectral_layout', 'spectral_layout'),
    ('spiral_layout', 'spiral_layout'),
    ('default', 'default'),
]

external_stylesheets = [
    'https://codepen.io/chriddyp/pen/bWLwgP.css', # Dash CSS
    'https://codepen.io/chriddyp/pen/brPBPO.css' # Loading screen CSS
]
app = dash.Dash(__name__, external_stylesheets=external_stylesheets)

def serveLayout():
    session_id = str(uuid.uuid4())
    graph = randomGraph()
    return html.Div([
        dcc.Store(data=session_id, id='session-id'),
        dcc.Store(data=json.loads(nx.jit_data(graph)), id='session-graph'),
        html.Div([
            html.Button('Regenerate', id='button'),
            html.Button('Step', id='step'),
            html.Button('Step', id='convert'),
            html.Div([
                dcc.Dropdown(
                    id='fig_dropdown',
                    options=[{'label': x[0], 'value': x[1]} for x in fig_names],
                    value=None
                ),
            ]),
        ]),
        dcc.Loading(
            id="loading-1",
            type="default",
            children=dcc.Graph(
                id='basic-graph',
                figure=generateFigure(graph, {}),
                style={"height" : "90vh", "width" : "90vw", "background-color":'white'}
            )
        )
    ])
app.layout = serveLayout


"""
@app.callback(
[dp.Output("progress", "value"), dp.Output("progress", "children")],
[dp.Input("progress-interval", "n_intervals")])
def update_progress(n):
    return 50, ''
"""

@app.callback(
[
    dp.Output('session-graph', 'data'),
    dp.Output('basic-graph', 'figure'),
],
[
    dp.Input('session-graph', 'data'),
    dp.Input('button', 'n_clicks'),
    dp.Input('fig_dropdown', 'value')
])
def update_output_div(graph_json, n_clicks, layout_name):
    ctx = dash.callback_context
    if not ctx.triggered:
        graph = nx.jit_graph(graph_json)
        return graph_json, generateFigure(graph, {})

    source = ctx.triggered[0]['prop_id'].split('.')[0]
    if source == 'fig_dropdown':
        print(f'Changing layout to {layout_name}')
        graph = nx.jit_graph(graph_json)
        graphLayout = updateLayout(graph, layout_name)
        return graph_json, generateFigure(graph, graphLayout)
    elif source == 'button':
        print(f'Regenerating graph with layout {layout_name}')
        graph = randomGraph()
        graphLayout = updateLayout(graph, layout_name)
        return json.loads(nx.jit_data(graph)), generateFigure(graph, graphLayout)

    print(ctx.triggered)
    #graph = nx.jit_graph(graph_json)

app.run_server(debug=True)
print('Done')