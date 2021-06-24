#!/usr/bin/env python3

""" Graph file """

import uuid
import json
import random
from dash_core_components.Input import Input

import plotly.graph_objects as go
import networkx as nx

import dash
import dash.dependencies as dp
import dash_core_components as dcc
import dash_bootstrap_components as dbc
import dash_html_components as html
from dash.exceptions import PreventUpdate

import src.designs as designs
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
                node[1][model['key']] = model['state'].random()

def generateDefaultGraph():
    defaultGen = graph_gens['random_geometric']
    return defaultGen['gen'](*defaultGen['argvals'])


def serveLayout():
    session_id = str(uuid.uuid4())
    graph = addMinRequirements(generateDefaultGraph())
    tracer = [model_degroot['id'], model_degroot['visual_default']]
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
                        html.Div([], id='modal-gen-comp', style=designs.col)
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
        dcc.Store(data=[], id='session-actions'),
        dcc.Store(data=tracer, id='session-tracer'),
        dcc.Store(data=json.loads(nx.jit_data(graph)), id='session-graph'),

        html.Div([dcc.Store(data=[], id=model['session-tracer']) for model in dropdown_model.values()]),
        html.Div([dcc.Store(data=[], id=model['session-actions']) for model in dropdown_model.values()]),

        html.Div([
            html.Div([html.Button('Generate', id='modal-gen-open', style=designs.but)], style=designs.col),
            html.Div([
                'Layout',
                html.Div([dcc.Dropdown(
                    id='dropdown-layout',
                    options=[{'label': val['name'], 'value': key} for key, val in layouts.items()],
                    value=layouts_default,
                    style={'width': '300px'}
                )], style=designs.col),
                'Model',
                html.Div([dcc.Dropdown(
                    id='dropdown-model',
                    options=[{'label': value['name'], 'value': key} for key, value in dropdown_model.items()],
                    value=dropdown_model_default,
                    style={'width': '300px'}
                )], style=designs.col),
            ], style=designs.row),
        ], style=designs.row),
        html.Div([model['ui']() for model in dropdown_model.values()], id='tab-specific'),
        dcc.Loading(
            id='loading-1',
            type='default',
            children=dcc.Graph(
                id='basic-graph',
                figure=generateFigure(graph, dropdown_model_default, dropdown_model, tracer),
                style={'height' : '90vh', 'width' : '90vw', 'background-color': 'white'}
            )
        ),
    ])

external_stylesheets = [
    dbc.themes.BOOTSTRAP,
    'https://codepen.io/chriddyp/pen/bWLwgP.css', # Dash CSS
    'https://codepen.io/chriddyp/pen/brPBPO.css', # Loading screen CSS
]
app = dash.Dash(external_stylesheets=external_stylesheets)
app.config.suppress_callback_exceptions = True
app.layout = serveLayout

actions_exec = {}
for model in dropdown_model.values():
    # registers the actions
    actions_exec[model['id']] = model['actions']
    # registers the callbacks
    model['callbacks'](app)

@app.callback(
    dp.Output('tab-specific', 'children'),
    dp.Input('dropdown-model', 'value'))
def update_specific(value):
    raise PreventUpdate()

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
    dp.Output('session-actions', 'data'),
    [dp.Input(src['session-actions'], 'data') for src in dropdown_model.values()],
    dp.State('session-actions', 'data'))
def session_actions_unify(*args):
    actions, current = args[:-1], args[-1]
    ctx = dash.callback_context
    if not ctx.triggered:
        return current

    source = ctx.triggered[0]['prop_id'].split('.')[0]
    for idx, model in enumerate(dropdown_model.values()):
        if model['session-actions'] == source:
            return actions[idx]
    print('Could not unify action')
    raise PreventUpdate()

@app.callback(
    dp.Output('session-tracer', 'data'),
    [dp.Input(source['session-tracer'], 'data') for source in dropdown_model.values()],
    dp.State('session-tracer', 'data'),)
def session_tracer_unify(*args):
    actions, current = args[:-1], args[-1]
    ctx = dash.callback_context
    if not ctx.triggered:
        return current

    source = ctx.triggered[0]['prop_id'].split('.')[0]
    for idx, model in enumerate(dropdown_model.values()):
        if model['session-tracer'] == source:
            return actions[idx]
    print('Could not unify tracers')
    raise PreventUpdate()

@app.callback(
    dp.Output({'type': 'specific', 'index': dp.ALL}, 'style'),
    dp.Input('dropdown-model', 'value'),
    dp.State({'type': 'specific', 'index': dp.ALL}, 'id'),)
def make_input_visible(update, old):
    if not update: return [{'display': 'none'}] * len(old)
    return [{'display': 'none'} if update != z['index'] else {} for z in old]

@app.callback(
[
    dp.Output('session-graph', 'data'),
    dp.Output('basic-graph', 'figure'),
],
[
    dp.Input('session-graph', 'data'),
    dp.Input('modal-gen-generate', 'n_clicks'),
    dp.Input('dropdown-layout', 'value'),
    dp.Input('dropdown-model', 'value'),
    dp.Input('modal-gen-dropdown', 'value'),
    dp.Input({'type': 'modal-gen-input', 'index': dp.ALL}, 'value'),
    dp.Input('session-actions', 'data'),
    dp.Input('session-tracer', 'data'),
])
def update_output_div(graph_json, n_clicks_modal, layout_name, model_name, graphGenType, graphGenInput, actions, tracer):
    ctx = dash.callback_context
    if not ctx.triggered:
        graph = nx.jit_graph(graph_json)
        return graph_json, generateFigure(graph, model_name, dropdown_model, tracer)

    source = ctx.triggered[0]['prop_id'].split('.')[0]

    if source == 'dropdown-layout':
        print(f'Changing layout to {layout_name}')
        graph = nx.jit_graph(graph_json)
        updateLayout(graph, layout_name, layouts)
        return graph_json, generateFigure(graph, model_name, dropdown_model, tracer)
    elif source == 'dropdown-model':
        print(f'Changing model type to {model_name}')
        graph = nx.jit_graph(graph_json)
        updateLayout(graph, layout_name, layouts)
        return graph_json, generateFigure(graph, model_name, dropdown_model, tracer)
    elif source == 'session-actions':
        if len(actions) == 0:
            raise PreventUpdate()
        for action in actions:
            print('ACTION', action)
            executor = actions_exec.get(action[0])
            if executor is not None:
                function = executor.get(action[1])
                if function is not None:
                    graph = nx.jit_graph(graph_json)
                    newData = function({'graph': graph}, action[2])
                    graph = newData['graph']
                    updateLayout(graph, layout_name, layouts)
                    return (json.loads(nx.jit_data(graph)),
                        generateFigure(graph, model_name, dropdown_model, tracer))
                else:
                    print(f'Could not find function {action[1]}')
            else:
                print(f'Could not find executor {action[0]}')
    elif source == 'session-tracer':
        graph = nx.jit_graph(graph_json)
        return graph_json, generateFigure(graph, model_name, dropdown_model, tracer)
    elif source == 'button':
        print(f'Regenerating graph with layout {layout_name}')
        graph = addMinRequirements(generateDefaultGraph())
        return json.loads(nx.jit_data(graph)), generateFigure(graph, model_name, dropdown_model, tracer)
    elif source == 'button-step':
        # perform a new step
        graph = nx.jit_graph(graph_json)
        performStep(graph, model_name)
        updateLayout(graph, layout_name, layouts)
        return json.loads(nx.jit_data(graph)), generateFigure(graph, model_name, dropdown_model, tracer)
    elif source == 'button-conv':
        # perform the graph conversion
        graph = nx.jit_graph(graph_json)
        graph = addMinRequirements(convert(graph, 'thu_th', 'weight', 'thu'))
        return json.loads(nx.jit_data(graph)), generateFigure(graph, model_name, dropdown_model, tracer)
    elif source == 'button-random-setup':
        graph = nx.jit_graph(graph_json)
        randomSetup(graph, model_name)
        updateLayout(graph, layout_name, layouts)
        return json.loads(nx.jit_data(graph)), generateFigure(graph, model_name, dropdown_model,tracer)
    elif source == 'modal-gen-generate':
        graph_gen = graph_gens.get(graphGenType)
        if graph_gen is None:
            print(f'Could not find graph type {graph_gen}')
        else:
            inputs = [value if value is not None else graph_gen['argvals'][idx]
                for idx, value in enumerate(graphGenInput)]
            print(f'Generating new graph with layout {graphGenType} with input {inputs}')
            graph = addMinRequirements(graph_gen['gen'](*inputs))
            return json.loads(nx.jit_data(graph)), generateFigure(graph, model_name, dropdown_model, tracer)

    print(f'Could not trigger source: {ctx.triggered}')
    raise PreventUpdate

def runProject():
    app.run_server(debug=True)
    print('Done')


if __name__ == '__main__':
    runProject()