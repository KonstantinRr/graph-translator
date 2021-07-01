#!/usr/bin/env python3

""" Graph file """

import uuid
import string
import random
import json
import re
import itertools

from itertools import combinations
import networkx as nx

import dash
import dash.dependencies as dp
import dash_core_components as dcc
import dash_bootstrap_components as dbc
import dash_html_components as html
from dash.exceptions import PreventUpdate
from networkx.exception import NetworkXError

import src.designs as designs
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


germanLegal = html.Div([
    html.H3('Angaben gemäß § 5 TMG'),
    html.P([
        'Konstantin Rolf', html.Br(),
        'Lilienstr. 22', html.Br(),
        '48231 Warendorf'
    ]),
    html.H3('Kontakt'),
    html.P([
        'Telefon: +4915737145293', html.Br(),
        'E-Mail: konstantin.rolf@gmail.com'
    ]),
])
englishLegal = html.Div([
    html.H3('Legal Notice according to § 5 TMG'),
    html.P([
        'Konstantin Rolf', html.Br(),
        'Lilienstr. 22', html.Br(),
        '48231 Warendorf'
    ]),
    html.H3('Contact'),
    html.P([
        'Telephone: +4915737145293', html.Br(),
        'E-Mail: konstantin.rolf@gmail.com'
    ]),
])
info = [
    html.H2('Opinion Diffusion Tool'),
    html.P(
        'This project was developed during the Bachelor Thesis at'
        ' the University of Groningen. The project implements common'
        ' diffusion models and is able to simulate them with customize'
        ' initial distributions. This tool supports currently the'
        ' following models: SIS, SIR, Threshold, Weighted Threshold'
        ' DeGroot, Three-State-Threshold Model, Majority Model,'
        ' and the Unanimity Model. See the paper for more information'
        ' about the models.'),
    html.P('Find the paper at (link coming soon)'),
    html.P('Find the source code at https://github.com/KonstantinRr/odt'),
    germanLegal, englishLegal,
    html.P('Made by Konstantin Rolf | UNIVERSITY OF GRONINGEN'),
]


def generateDefaultGraph():
    defaultGen = graph_gens['random_geometric']
    return defaultGen['gen'](*defaultGen['argvals'])

def input_generate(data, args):
    lines = args['text'].splitlines()
    graph = nx.DiGraph()

    reg_ctx = re.compile(r'\s*([a-zA-Z0-9]+)\s*')
    reg_ctx_statement = re.compile(r'\s*([a-zA-Z0-9]+)\s*:\s*(-?[0-9]+)\s*')
    reg_full_statement = re.compile(r'\s*([a-zA-Z0-9]+)\[([a-zA-Z0-9]+)\]\s*:\s*(-?[0-9]+)\s*')
    reg_edge = re.compile(r'\s*(?:[a-zA-Z0-9]+\s*){2,}\s*')
    reg_white = re.compile(r'\s*')

    valid_contexts = ('sis', 'sir', 'degroot', 'thw', 'thu', 'tha', 'upodmaj', 'upoduna')
    context = 'thu'
    for idx, line in enumerate(lines):
        if reg_white.fullmatch(line) is not None:
            continue

        # matches a context statement
        match_ctx = reg_ctx.fullmatch(line)
        if match_ctx is not None:
            ctx = match_ctx.group(1).lower()
            if ctx not in valid_contexts:
                raise Exception(f'Line {idx}: Context must be one of: {valid_contexts}.')
            context = ctx
            continue

        # matches context specific statements
        match_ctx_statement = reg_ctx_statement.fullmatch(line)
        if match_ctx_statement is not None:
            node = match_ctx_statement.group(1)
            graph.add_node(node)
            graph.nodes[node][context] = int(match_ctx_statement.group(2))
            continue

        # matches edges specific statements
        match_edge = reg_edge.fullmatch(line)
        if match_edge is not None:
            nodes = line.split()
            for src, dst in combinations(nodes, 2):
                graph.add_edge(src, dst)
            continue

        # matches full specific statements
        match_full_statement = reg_full_statement.fullmatch(line)
        if match_full_statement is not None:
            node = match_full_statement.group(1)
            model_key = match_full_statement.group(2).lower()
            if model_key not in valid_contexts:
                raise Exception(f'Line {idx}: Context must be one of: {valid_contexts}.')
            graph.add_node(node)
            graph.nodes[node][model_key] = int(match_full_statement.group(3))
            continue

        # no statement found
        raise Exception(f'Line {idx}: Unknown statement')

    data['graph'] = addMinRequirements(graph)
    return data

def serveLayout():
    session_id = str(uuid.uuid4())
    graph = addMinRequirements(generateDefaultGraph())
    tracer = [
        dropdown_model[dropdown_model_default]['id'],
        dropdown_model[dropdown_model_default]['visual_default']]
    return html.Div([
        html.Div([
            dbc.Modal(
                [
                    dbc.ModalHeader('Generate'),
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
                        dbc.Button('Close', id='modal-gen-close', className='ml-auto', style={'width': '10em'}),
                        dbc.Button('Generate', id='modal-gen-generate', className='ml-auto', style={'width': '10em'})
                    ], style={'margin-left': 'auto', 'margin-right': '0'}),
                ],
                id='modal',
            ),
            dbc.Modal(
                [
                    dbc.ModalHeader('Information | Legal Notice'),
                    dbc.ModalBody(info),
                    dbc.ModalFooter([
                        dbc.Button('Close', id='modal-info-close', className='ml-auto', style={'width': '10em'}),
                    ], style={'margin-left': 'auto', 'margin-right': '0'}),
                ],
                id='modal-info',
                size='xl'
            ),
            dbc.Modal(
                [
                    dbc.ModalHeader('Input'),
                    dbc.ModalBody([
                        dcc.Textarea(
                            id='model-input-textarea',
                            value='',
                            style={'width': '100%', 'height': 300},
                        ),
                    ]),
                    dbc.ModalFooter([
                        dbc.Button('Close', id='modal-input-close', className='ml-auto', style={'width': '10em'}),
                        dbc.Button('Generate', id='modal-input-generate', className='ml-auto', style={'width': '10em'})
                    ], style={'margin-left': 'auto', 'margin-right': '0'}),
                ],
                id='modal-input'
            ),
        ]),
        dcc.Store(data=session_id, id='session-id'),
        dcc.Store(data=[], id='session-actions'),
        dcc.Store(data=tracer, id='session-tracer'),
        dcc.Store(data=json.loads(nx.jit_data(graph)), id='session-graph'),

        html.Div([dcc.Store(data=[], id=model['session-tracer'])
            for model in dropdown_model.values()]),
        html.Div([dcc.Store(data=[], id=model['session-actions'])
            for model in dropdown_model.values()]),
        html.Div(dcc.Store(data=[], id='session-graph-actions')),

        html.Div([
            html.Div(
                dbc.DropdownMenu(
                    [
                        dbc.DropdownMenuItem(
                            'Save', id='action-menu-save', className='m-1', style={'width': '200px'}
                        ),
                        dbc.DropdownMenuItem(
                            'Load', id='action-menu-load', className='m-1', style={'width': '200px'}
                        ),
                        dbc.DropdownMenuItem(divider=True),
                        dbc.DropdownMenuItem(
                            'Sources', href='https://github.com/KonstantinRr', className='m-1', style={'width': '200px'}
                        ),
                        dbc.DropdownMenuItem(
                            'Author', href='https://github.com/KonstantinRr', className='m-1', style={'width': '200px'}
                        ),
                        dbc.DropdownMenuItem(divider=True),
                        dbc.DropdownMenuItem(
                            'Generate', id='modal-gen-open', className='m-1', style={'width': '200px'}
                        ),
                        dbc.DropdownMenuItem(
                            'Custom', id='modal-input-open', className='m-1', style={'width': '200px'}
                        ),
                        dbc.DropdownMenuItem(divider=True),
                        dbc.DropdownMenuItem(
                            'Info', id='modal-info-open', className='m-1', style={'width': '200px'}
                        ),
                    ],
                    label='Menu',
                    bs_size='lg',
                    className='mb-3',
                ),
                style=designs.col
            ),
            html.Div([
                dcc.Loading(
                    id='loading-1',
                    type='default',
                    children=html.Div('', id='loader', style={'width': '80px', 'padding-top': '20px'}),
                ),
            ], style=designs.col),
            html.Div([html.Button('Add', id='action-add', style=designs.but)], style=designs.col),
            html.Div([html.Button('Delete', id='action-delete', style=designs.but)], style=designs.col),
            html.Div([html.Button('Connect', id='action-connect', style=designs.but)], style=designs.col),
            html.Div([html.Button('Deconnect', id='action-deconnect', style=designs.but)], style=designs.col),
            html.Div([
                'Layout',
                html.Div([dcc.Dropdown(
                    id='dropdown-layout',
                    options=[{'label': val['name'], 'value': key}
                        for key, val in layouts.items()],
                    value=layouts_default,
                    style={'width': '300px'}
                )], style=designs.col),
                'Model',
                html.Div([dcc.Dropdown(
                    id='dropdown-model',
                    options=[{'label': value['name'], 'value': key}
                        for key, value in dropdown_model.items()],
                    value=dropdown_model_default,
                    style={'width': '300px'}
                )], style=designs.col),
            ], style=designs.row),
        ], style=designs.row),
        html.Div([model['ui']() for model in dropdown_model.values()], id='tab-specific'),
        dcc.Graph(
            id='basic-graph',
            figure=generateFigure(graph, dropdown_model_default, dropdown_model, tracer),
            style={'height' : '90vh', 'width' : '90vw', 'background-color': 'white'}
        )
    ])

external_stylesheets = [
    dbc.themes.BOOTSTRAP,
    'https://codepen.io/chriddyp/pen/bWLwgP.css', # Dash CSS
    'https://codepen.io/chriddyp/pen/brPBPO.css', # Loading screen CSS
]
app = dash.Dash(external_stylesheets=external_stylesheets)
app.config.suppress_callback_exceptions = True
app.layout = serveLayout

def randAlphaNumeric(length=8):
    return ''.join(random.choice(
        string.ascii_uppercase + string.ascii_lowercase + string.digits
    ) for _ in range(length))

def randName(graph):
    nodeName = randAlphaNumeric(8)
    while nodeName in graph:
        nodeName = randAlphaNumeric(8)
    return nodeName

def get_node_names(selected):
    if selected is None: return []
    return [qq['customdata'] for qq in selected['points']]

def action_add(data, args):
    graph = data['graph']
    graph.add_node(randName(graph))
    addMinRequirements(graph)
    return data

def action_connect(data, args):
    graph, selected = data['graph'], args['selected']
    for s1, s2 in itertools.combinations(get_node_names(selected), 2):
        graph.add_edge(s1, s2)
    addMinRequirements(graph)
    return data

def action_deconnect(data, args):
    graph, selected = data['graph'], args['selected']
    for s1, s2 in itertools.combinations(get_node_names(selected), 2):
        graph.remove_edges_from([(s1, s2), (s2, s1)])
    return data

def action_delete(data, args):
    graph, selected = data['graph'], args['selected']
    graph.remove_nodes_from(get_node_names(selected))
    return data

actions_exec = {
    'session-graph-actions': {
        'input': input_generate,
        'add': action_add,
        'connect': action_connect,
        'deconnect': action_deconnect,
        'delete': action_delete,
    },
}
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
    dp.Output('modal', 'is_open'),
    [dp.Input('modal-gen-open', 'n_clicks'), dp.Input('modal-gen-close', 'n_clicks')],
    [dp.State('modal', 'is_open')])
def toggle_modal(n1, n2, is_open):
    if n1 or n2:
        return not is_open
    return is_open

@app.callback(
    dp.Output('modal-info', 'is_open'),
    [dp.Input('modal-info-open', 'n_clicks'), dp.Input('modal-info-close', 'n_clicks')],
    [dp.State('modal-info', 'is_open')])
def toggle_modal_info(n1, n2, is_open):
    if n1 or n2:
        return not is_open
    return is_open


@app.callback(
    dp.Output('modal-input', 'is_open'),
    [dp.Input('modal-input-open', 'n_clicks'), dp.Input('modal-input-close', 'n_clicks')],
    [dp.State('modal-input', 'is_open')])
def toggle_input_modal(n1, n2, is_open):
    if n1 or n2:
        return not is_open
    return is_open

@app.callback(
    dp.Output('session-actions', 'data'),
    dp.Input('session-graph-actions', 'data'),
    [dp.Input(src['session-actions'], 'data') for src in dropdown_model.values()],
    dp.State('session-actions', 'data'))
def session_actions_unify(graph_actions, *args):
    actions, current = args[:-1], args[-1]
    ctx = dash.callback_context
    if not ctx.triggered:
        return current

    source = ctx.triggered[0]['prop_id'].split('.')[0]
    if source == 'session-graph-actions':
        return graph_actions
    # otherwise use model handlers
    for idx, model in enumerate(dropdown_model.values()):
        if model['session-actions'] == source:
            return actions[idx]
    print('Could not unify action')
    raise PreventUpdate()

@app.callback(
    dp.Output('session-tracer', 'data'),
    dp.Input('dropdown-model', 'value'),
    [dp.Input(source['session-tracer'], 'data') for source in dropdown_model.values()],
    dp.State('session-tracer', 'data'),)
def session_tracer_unify(dropdown, *args):
    tracers, current = args[:-1], args[-1]
    ctx = dash.callback_context
    if not ctx.triggered:
        return current

    source = ctx.triggered[0]['prop_id'].split('.')[0]
    if source == 'dropdown-model':
        return [dropdown, dropdown_model[dropdown]['visual_default']]
    for idx, model in enumerate(dropdown_model.values()):
        if model['session-tracer'] == source:
            return tracers[idx]
    print('Could not unify tracers')
    raise PreventUpdate()

@app.callback(
    dp.Output('session-graph-actions', 'data'),
    dp.Input('modal-input-generate', 'n_clicks'),
    dp.Input('action-delete', 'n_clicks'),
    dp.Input('action-add', 'n_clicks'),
    dp.Input('action-connect', 'n_clicks'),
    dp.Input('action-deconnect', 'n_clicks'),
    dp.State('model-input-textarea', 'value'),
    dp.State('basic-graph', 'selectedData'))
def modal_input_generate(n1, n2, n3, n4, n5, text, selected):
    ctx = dash.callback_context
    if not ctx.triggered:
        return []

    source = ctx.triggered[0]['prop_id'].split('.')[0]
    args = {'text': text, 'selected': selected}
    if source == 'modal-input-generate':
        return [('session-graph-actions', 'input', args)]
    elif source == 'action-delete':
        return [('session-graph-actions', 'delete', args)]
    elif source == 'action-add':
        return [('session-graph-actions', 'add', args)]
    elif source == 'action-connect':
        return [('session-graph-actions', 'connect', args)]
    elif source == 'action-deconnect':
        return [('session-graph-actions', 'deconnect', args)]
    print('Graph Action: Could not update')
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
    dp.Output('loader', 'children'),
],
[
    dp.Input('session-graph', 'data'),
    dp.Input('modal-gen-generate', 'n_clicks'),
    dp.Input('dropdown-layout', 'value'),
    dp.Input('dropdown-model', 'value'),
    dp.Input('modal-gen-dropdown', 'value'),
    dp.Input('session-actions', 'data'),
    dp.Input('session-tracer', 'data'),
],
    dp.State({'type': 'modal-gen-input', 'index': dp.ALL}, 'value'),
)
def update_output_div(graph_json, n_clicks_modal,
    layout_name, model_name, graphGenType, actions, tracer, graphGenInput):
    ctx = dash.callback_context
    if not ctx.triggered:
        graph = nx.jit_graph(graph_json)
        return graph_json, generateFigure(graph, model_name, dropdown_model, tracer), ''

    source = ctx.triggered[0]['prop_id'].split('.')[0]
    if source == 'dropdown-layout':
        print(f'Changing layout to {layout_name}')
        graph = nx.jit_graph(graph_json)
        updateLayout(graph, layout_name, layouts)
        return graph_json, generateFigure(graph, model_name, dropdown_model, tracer), ''
    elif source == 'dropdown-model':
        print(f'Changing model type to {model_name}')
        graph = nx.jit_graph(graph_json)
        updateLayout(graph, layout_name, layouts)
        return graph_json, generateFigure(graph, model_name, dropdown_model, tracer), ''
    elif source == 'session-actions':
        if len(actions) == 0:
            raise PreventUpdate()
        for action in actions:
            executor = actions_exec.get(action[0])
            if executor is not None:
                function = executor.get(action[1])
                if function is not None:
                    graph = nx.jit_graph(graph_json)
                    newData = function({'graph': graph},
                        action[2] if len(action) > 2 else [])
                    graph = newData['graph']
                    updateLayout(graph, layout_name, layouts)
                    return (json.loads(nx.jit_data(graph)),
                        generateFigure(graph, model_name, dropdown_model, tracer), '')
                else:
                    print(f'Could not find function {action[1]}')
            else:
                print(f'Could not find executor {action[0]}')
    elif source == 'session-tracer':
        graph = nx.jit_graph(graph_json)
        return graph_json, generateFigure(graph, model_name, dropdown_model, tracer), ''
    elif source == 'modal-gen-generate':
        graph_gen = graph_gens.get(graphGenType)
        if graph_gen is None:
            print(f'Could not find graph type {graph_gen}')
        else:
            inputs = [value if value is not None else graph_gen['argvals'][idx]
                for idx, value in enumerate(graphGenInput)]
            print(f'Generating new graph with layout {graphGenType} with input {inputs}')
            graph = addMinRequirements(graph_gen['gen'](*inputs))
            return json.loads(nx.jit_data(graph)), generateFigure(graph, model_name, dropdown_model, tracer), ''
    print(f'Could not trigger source: {ctx.triggered}')
    raise PreventUpdate


"""
@app.callback(
    dp.Output('hover-data', 'children'),
    dp.Input('basic-interactions', 'hoverData'))
def display_hover_data(hoverData):
    return json.dumps(hoverData, indent=2)


@app.callback(
    dp.Output('click-data', 'children'),
    dp.Input('basic-interactions', 'clickData'))
def display_click_data(clickData):
    return json.dumps(clickData, indent=2)


@app.callback(
    dp.Output('selected-data', 'children'),
    dp.Input('basic-interactions', 'selectedData'))
def display_selected_data(selectedData):
    return json.dumps(selectedData, indent=2)


@app.callback(
    dp.Output('relayout-data', 'children'),
    dp.Input('basic-interactions', 'relayoutData'))
def display_relayout_data(relayoutData):
    return json.dumps(relayoutData, indent=2)
"""
