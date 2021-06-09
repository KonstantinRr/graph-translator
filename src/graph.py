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

def performStep(graph, modelType, steps=1):
    model = dropdown_model.get(modelType)
    if model is not None:
        model['update'](graph, steps)
    else:
        print(f'Unknown type {model}')

def randomSetup(graph, modelType, prob=1.0):
    model = dropdown_model.get(modelType)
    if model is not None:
        for node in graph.nodes(data=True):
            if random.random() <= prob:
                node[1][model['id']] = model['state'].random()

def generateDefaultGraph():
    defaultGen = graph_gens['random_geometric']
    return defaultGen['gen'](*defaultGen['argvals'])

def serveLayout():
    session_id = str(uuid.uuid4())
    graph, graphLayout = addMinRequirements(generateDefaultGraph())

    return html.Div([
        html.Div([
            dbc.Modal(
                [
                    dbc.ModalHeader("Header"),
                    dbc.ModalBody([
                        dcc.Dropdown(
                            id='modal-gen-dropdown',
                            options=[{'label': y['name'], 'value': x} for x, y in graph_gens.items()],
                            value=graph_gens_default,
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
                options=[{'label': val['name'], 'value': key} for key, val in layouts.items()],
                value=layouts_default,
                style={'width': '40vw'}
            )], style=col),
            html.Div([dcc.Dropdown(
                id='dropdown-model',
                options=[{'label': value['name'], 'value': key} for key, value in dropdown_model.items()],
                value=dropdown_model_default,
                style={'width': '40vw'}
            )], style=col),
        ], style=row),
        dcc.Loading(
            id='loading-1',
            type='default',
            children=dcc.Graph(
                id='basic-graph',
                figure=generateFigure(graph, {}, 'connections', dropdown_model),
                style={'height' : '90vh', 'width' : '90vw', 'background-color': 'white'}
            )
        ),
    ])

# stylesheet for a simple column
col = {
    'display': 'table-cell'
}
# stylesheet for a simple row
row = { 
    'display': 'table',
    'table-layout': 'fixed',
    'border-spacing': '10px',
}
# stylesheet for a simple button
but = {
    'height': '50px',
    'text-align': 'center',
    'display': 'inline-block',
}
external_stylesheets = [
    dbc.themes.BOOTSTRAP,
    'https://codepen.io/chriddyp/pen/bWLwgP.css', # Dash CSS
    'https://codepen.io/chriddyp/pen/brPBPO.css', # Loading screen CSS
]
app = dash.Dash(external_stylesheets=external_stylesheets)
app.config.suppress_callback_exceptions = True
app.layout = serveLayout


@app.callback(
    dp.Output('modal-gen-comp', 'children'),
    dp.Input('modal-gen-dropdown', 'value'))
def update_modal_gen(inp):
    data = graph_gens.get(inp)
    if data is None: return 'Unknown'
    return [
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
        return graph_json, generateFigure(graph, {}, model_name, dropdown_model)

    source = ctx.triggered[0]['prop_id'].split('.')[0]
    if source == 'dropdown-layout':
        print(f'Changing layout to {layout_name}')
        graph = nx.jit_graph(graph_json)
        graphLayout = updateLayout(graph, layout_name, layouts)
        return graph_json, generateFigure(graph, graphLayout, model_name, dropdown_model)
    elif source == 'dropdown-model':
        print(f'Changing model type to {model_name}')
        graph = nx.jit_graph(graph_json)
        graphLayout = updateLayout(graph, layout_name, layouts)
        return graph_json, generateFigure(graph, graphLayout, model_name, dropdown_model)
    elif source == 'button':
        print(f'Regenerating graph with layout {layout_name}')
        graph, graphLayout = addMinRequirements(generateDefaultGraph())
        return json.loads(nx.jit_data(graph)), generateFigure(graph, graphLayout, model_name, dropdown_model)
    elif source == 'button-step':
        # perform a new step
        graph = nx.jit_graph(graph_json)
        performStep(graph, model_name)
        graphLayout = updateLayout(graph, layout_name, layouts)
        return json.loads(nx.jit_data(graph)), generateFigure(graph, graphLayout, model_name, dropdown_model)
    elif source == 'button-conv':
        # perform the graph conversion
        graph = nx.jit_graph(graph_json)
        graph, graphLayout = addMinRequirements(convert(graph, 'thu_th', 'weight', 'thu'))
        return json.loads(nx.jit_data(graph)), generateFigure(graph, graphLayout, model_name, dropdown_model)
    elif source == 'button-random-setup':
        graph = nx.jit_graph(graph_json)
        randomSetup(graph, model_name)
        graphLayout = updateLayout(graph, layout_name, layouts)
        return json.loads(nx.jit_data(graph)), generateFigure(graph, graphLayout, model_name, dropdown_model)
    elif source == 'modal-gen-generate':
        graph_gen = graph_gens.get(graphGenType)
        if graph_gen is None:
            print(f'Could not find graph type {graph_gen}')
        else:
            inputs = [value if value is not None else graph_gen['argvals'][idx]
                for idx, value in enumerate(graphGenInput)]
            print(f'Generating new graph with layout {graphGenType} with input {inputs}')
            graph, graphLayout = addMinRequirements(graph_gen['gen'](*inputs))
            return json.loads(nx.jit_data(graph)), generateFigure(graph, graphLayout, model_name, dropdown_model)

    print(f'Could not trigger source: {ctx.triggered}')
    raise PreventUpdate

def runProject():
    app.run_server(debug=True)
    print('Done')


if __name__ == '__main__':
    runProject()