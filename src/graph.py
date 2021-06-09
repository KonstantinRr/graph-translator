#!/usr/bin/env python3

""" Graph file """

import uuid
import json
import random

import plotly.graph_objects as go
import networkx as nx

import dash
import dash.dependencies as dp
import dash_core_components as dcc
import dash_bootstrap_components as dbc
import dash_html_components as html
from dash.exceptions import PreventUpdate

# data packages
import pandas as pd
import numpy as np

from src.addEdge import addEdge
from src.tracer import *
from src.models import *
from src.info import *

__author__ = "Created by Konstantin Rolf | University of Groningen"
__copyright__ = "Copyright 2021, Konstantin Rolf"
__credits__ = [""]
__license__ = "GPL"
__version__ = "0.1"
__maintainer__ = "Konstantin Rolf"
__email__ = "konstantin.rolf@gmail.com"
__status__ = "Development"

def randomGraph(nodes=200, connect=0.125):
    graph = nx.random_geometric_graph(nodes, connect)
    #graph = nx.gn_graph(nodes)
    #nx.stochastic_graph(graph)
    return graph

def updateLayout(graph, layoutAlgorithm, default=None):
    if layoutAlgorithm == 'bipartite_layout':
        return nx.circular_layout(graph)
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
        return {} if default is None else updateLayout(graph, default)
    else:
        print('Unknown Layout algorithm!', layoutAlgorithm)
        return {} if default is None else updateLayout(graph, default)

def generateFigure(graph, graphLayout, graphType):
    if graphType in dropdown_model:
        if isinstance(graph, nx.DiGraph) and dropdown_model[graphType][2] == 'u':
            graph = graph.to_undirected(as_view=True)
        elif isinstance(graph, nx.Graph) and dropdown_model[graphType][2] == 'd':
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
            if 'weight' in edge[2]:
                edge_cx.append((start[0] / 3 + end[0] * (2.0 / 3.0)))
                edge_cy.append((start[1] / 3 + end[1] * (2.0 / 3.0)))
                weights.append(str(edge[2]['weight']))
    else:
        for edge in graph.edges(data=True):
            x0, y0 = (graphLayout[edge[0]] if edge[0] in graphLayout else graph.nodes[edge[0]]['pos'])
            x1, y1 = (graphLayout[edge[1]] if edge[1] in graphLayout else graph.nodes[edge[1]]['pos'])
            edge_x.extend((x0, x1, None))
            edge_y.extend((y0, y1, None))

            if 'weight' in edge[2]:
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

    if graphType in dropdown_model:
        node_trace = dropdown_model[graphType][1](graph, node_x, node_y)
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

def addMinRequirements(graph, layout):
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

def performStep(graph, modelType, steps=1):
    model = dropdown_model.get(modelType)
    if model is not None:
        model[5](graph, steps)
    else:
        print(f'Unknown type {model}')


def randomSetup(graph, modelType, prob=1.0):
    model = dropdown_model.get(modelType)
    if model is not None:
        key = model[3]
        state = model[4]
        for node in graph.nodes(data=True):
            if random.random() <= prob:
                node[1][key] = state.random()

external_stylesheets = [
    dbc.themes.BOOTSTRAP,
    'https://codepen.io/chriddyp/pen/bWLwgP.css', # Dash CSS
    'https://codepen.io/chriddyp/pen/brPBPO.css', # Loading screen CSS
]
app = dash.Dash(external_stylesheets=external_stylesheets)
app.config.suppress_callback_exceptions = True

col = {
    'display': 'table-cell'
}
row = {
    'display': 'table',
    'table-layout': 'fixed',
    'border-spacing': '10px',
}

def serveLayout():
    session_id = str(uuid.uuid4())
    graph = randomGraph()
    addMinRequirements(graph, 'default')

    but = {
        'height': '50px',
        'text-align': 'center',
        'display': 'inline-block',
    }

    return html.Div([
        html.Div([
            dbc.Modal(
                [
                    dbc.ModalHeader("Header"),
                    dbc.ModalBody([
                        dcc.Dropdown(
                            id='modal-gen-dropdown',
                            options=[{'label': y['name'], 'value': x} for x, y in graph_gens.items()],
                            value=None,
                            style={'left': '0px', 'right': '0px'}
                        ),
                        html.Div([], id='modal-gen-comp', style=col)
                    ]),
                    dbc.ModalFooter([
                        dbc.Button("Close", id="modal-gen-close", className="ml-auto", style={'width': '10em'}),
                        dbc.Button("Generate", id="modal-gen-generate", className="ml-auto", style={'width': '10em'})
                    ], style={'margin-left': 'auto', 'margin-right': '0'}),
                ],
                id="modal",
            )
        ]),
        dcc.Store(data=session_id, id='session-id'),
        dcc.Store(data=json.loads(nx.jit_data(graph)), id='session-graph'),
        html.Div([
            html.Div([html.Button('Random', id='button', style=but)], style=col),
            html.Div([html.Button('Generate', id='modal-gen-open', style=but)], style=col),
            html.Div([html.Button('Convert', id='button-conv', style=but)], style=col),
            html.Div([html.Button('Step', id='button-step', style=but)], style=col),
            html.Div([html.Button('Random Setup', id='button-random-setup', style=but)], style=col),
        ], style=row),
        html.Div([
            html.Div([dcc.Dropdown(
                id='dropdown-layout',
                options=[{'label': x[1], 'value': x[0]} for x in fig_names],
                value=None,
                style={'width': '40vw'}
            )], style=row),
            html.Div([dcc.Dropdown(
                id='dropdown-model',
                options=[{'label': y[0], 'value': x} for x, y in dropdown_model.items()],
                value=None,
                style={'width': '40vw'}
            )], style=col),
        ], style=row),
        dcc.Loading(
            id="loading-1",
            type="default",
            children=dcc.Graph(
                id='basic-graph',
                figure=generateFigure(graph, {}, 'connections'),
                style={"height" : "90vh", "width" : "90vw", "background-color":'white'}
            )
        ),

        # modal layouts
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
    dp.Output('modal-gen-comp', 'children'),
    dp.Input('modal-gen-dropdown', 'value'))
def update_modal_gen(inp):
    data = graph_gens.get(inp)
    if data is None: return 'Unknown'
    print(data)

    return [
        # data[1]: values[0]: values 
        # data[2]: values[1]: classes
        # data[3]: values[2]: defaults
        html.Div([
            html.Div('Input {}'.format(values[0]), style={'padding-right': '10px'}),
            dcc.Input(
                id={
                    'type': 'modal-gen-input',
                    'index': idx
                },
                type='number',
                placeholder='{}'.format(values[2])
            )
        ]) for idx, values in enumerate(zip(data['args'], data['argtypes'], data['argvals']))
        
    ]

@app.callback(
    dp.Output("modal", "is_open"),
    [dp.Input("modal-gen-open", "n_clicks"), dp.Input("modal-gen-close", "n_clicks")],
    [dp.State("modal", "is_open")])
def toggle_modal(n1, n2, is_open):
    if n1 or n2:
        return not is_open
    return is_open


@app.callback(
[
    dp.Output('session-graph', 'data'),
    dp.Output('basic-graph', 'figure'),
],
[
    dp.Input('session-graph', 'data'),
    dp.Input('button', 'n_clicks'),
    dp.Input('modal-gen-generate', 'n_clicks'),
    dp.Input('dropdown-layout', 'value'),
    dp.Input('dropdown-model', 'value'),
    dp.Input('modal-gen-dropdown', 'value'),
    dp.Input({'type': 'modal-gen-input', 'index': dp.ALL}, 'value'),
    dp.Input('button-step', 'n_clicks'),
    dp.Input('button-conv', 'n_clicks'),
    dp.Input('button-random-setup', 'n_clicks')
])
def update_output_div(graph_json, n_clicks, n_clicks_modal, layout_name, model_name, graphGenType, graphGenInput, stepNClicks, convNClicks, randomSetupNClicks):
    ctx = dash.callback_context
    if not ctx.triggered:
        graph = nx.jit_graph(graph_json)
        return graph_json, generateFigure(graph, {}, model_name)

    source = ctx.triggered[0]['prop_id'].split('.')[0]
    if source == 'dropdown-layout':
        print(f'Changing layout to {layout_name}')
        graph = nx.jit_graph(graph_json)
        graphLayout = updateLayout(graph, layout_name)
        return graph_json, generateFigure(graph, graphLayout, model_name)
    elif source == 'dropdown-model':
        print(f'Changing model type to {model_name}')
        graph = nx.jit_graph(graph_json)
        graphLayout = updateLayout(graph, layout_name)
        return graph_json, generateFigure(graph, graphLayout, model_name)
    elif source == 'button':
        print(f'Regenerating graph with layout {layout_name}')
        graph = randomGraph()
        graphLayout = addMinRequirements(graph, layout_name)
        return json.loads(nx.jit_data(graph)), generateFigure(graph, graphLayout, model_name)
    elif source == 'button-step':
        # perform a new step
        graph = nx.jit_graph(graph_json)
        performStep(graph, model_name)
        graphLayout = updateLayout(graph, layout_name)
        return json.loads(nx.jit_data(graph)), generateFigure(graph, graphLayout, model_name)
    elif source == 'button-conv':
        graph = nx.jit_graph(graph_json)
        graphLayout = updateLayout(graph, layout_name)
        return json.loads(nx.jit_data(graph)), generateFigure(graph, graphLayout, model_name)
    elif source == 'button-random-setup':
        graph = nx.jit_graph(graph_json)
        randomSetup(graph, model_name)
        graphLayout = updateLayout(graph, layout_name)
        return json.loads(nx.jit_data(graph)), generateFigure(graph, graphLayout, model_name)
    elif source == 'modal-gen-generate':
        graph_gen = graph_gens.get(graphGenType)
        if graph_gen is None:
            print(f'Could not find graph type {graph_gen}')
        else:
            inputs = [value if value is not None else graph_gen['argvals'][idx]
                for idx, value in enumerate(graphGenInput)]
            print(f'Generating new graph with layout {graphGenType} with input {inputs}')
            graph = graph_gen['gen'](*inputs)
            graphLayout = addMinRequirements(graph, layout_name)
            #nx.set_node_attributes(graph, graphLayout, 'pos')
            return json.loads(nx.jit_data(graph)), generateFigure(graph, graphLayout, model_name)


    print(f'Could not trigger source: {ctx.triggered}')
    raise PreventUpdate
    #graph = nx.jit_graph(graph_json)

def runProject():
    app.run_server(debug=True)
    print('Done')


if __name__ == '__main__':
    runProject()