

import numpy as np
import networkx as nx

import dash
import dash.dependencies as dp
import dash_core_components as dcc
import dash_bootstrap_components as dbc
import dash_html_components as html
from dash.exceptions import PreventUpdate

from src.tracer import generate_trace
from src.models import DiscreteState, stochastic_callback
import src.designs as designs

from src.visual import build_visual_selector
from src.visual_connections import visual_connections

id_thw_button_random = 'thw-button-random'
id_thw_button_step = 'thw-button-step'
id_thw_button_stochastic = 'thw-button-stochastic'
id_thw_dropdown = 'thw-dropdown'

action_thw_random = 'action_thw_random'
action_thw_stochastic = 'action_thw_stochastic'
action_thw_step = 'action_thw_step'
action_thw_visual = 'action_thw_visual'

def thw_update(data, args):
    graph = data['graph']
    thu_key, thu_th_key, thu_weight_key = model_thw['key'], 'thu_th', 'weight'
    update_dict = {}
    for srcNode, adjacency in graph.adjacency():
        count, total = 0, len(adjacency)
        for dstNode in adjacency.keys():
            if graph.nodes[dstNode][thu_key] > 0.5:
                count += 1
        update_dict[srcNode] = 0 if count <= 0.5 * total else 1

    # applies the update dictionary
    for key, value in update_dict.items():
        graph.nodes[key][thu_key] = value
    return data

def thw_random(data, args):
    state = DiscreteState([0, 1])
    for node, data_node in data['graph'].nodes(data=True):
        data_node[model_thw['key']] = state.random()
    return data

def thw_build_actions():
    return {
        action_thw_random: thw_random, 
        action_thw_step: thw_update,
        action_thw_stochastic: stochastic_callback,
    }

def thw_build_callbacks(app):
    @app.callback(
        dp.Output(model_thw['session-tracer'], 'data'),
        dp.Input(id_thw_dropdown, 'value'))
    def tracer_callback(value):
        return [model_thw['id'], value]

    @app.callback(
        dp.Output(model_thw['session-actions'], 'data'),
        dp.Input(id_thw_button_random, 'n_clicks'),
        dp.Input(id_thw_button_stochastic, 'n_clicks'),
        dp.Input(id_thw_button_step, 'n_clicks'),)
    def callback(n1, n2, n3):
        ctx = dash.callback_context
        if not ctx.triggered: return []
        source = ctx.triggered[0]['prop_id'].split('.')[0]
        if source == id_thw_button_random:
            return [(model_thw['id'], action_thw_random, {})]
        elif source == id_thw_button_stochastic:
            return [(model_thw['id'], action_thw_stochastic, {})]
        elif source == id_thw_button_step:
            return [(model_thw['id'], action_thw_step, {})]
        print(f'THW callback: Could not find property with source: {source}')
        raise PreventUpdate()

def threshold_weighted_build(model_id):
    return html.Div(
        html.Div([
                html.Div([html.Button('Random', id=id_thw_button_random, style=designs.but)], style=designs.col),
                html.Div([html.Button('Stochastic', id=id_thw_button_stochastic, style=designs.but)], style=designs.col),
                html.Div([html.Button('Step', id=id_thw_button_step, style=designs.but)], style=designs.col),
            ] + build_visual_selector(model_thw, id=id_thw_dropdown),
            style=designs.row,
            id={'type': model_thw['id'], 'index': model_thw['id']}
        ),
        id={'type': 'specific', 'index': model_id},
        style={'display': 'none'}
    )

def threshold_weighted_tracer(graph, node_x, node_y):
    """ Generates the uniform threshold tracer """
    return generate_trace(graph, node_x, node_y, 'thw', 'Weighted Threshold', 'Bluered')

tracer_weighted_threshold = {
    'id': 'tracer_threshold',
    'name': 'State Tracer',
    'tracer': threshold_weighted_tracer,
}

def thw_th_tracer(graph, node_x, node_y):
    return generate_trace(graph, node_x, node_y, 'thw_th', 'Threshold', 'Bluered')

tracer_thw_th = {
    'id': 'tracer_thw_thw_th',
    'name': 'Threshold Tracer',
    'tracer': thw_th_tracer
}

model_thw = {
    'id': 'threshold_weighted',
    'name': 'Weighted Threshold',
    'ui': lambda: threshold_weighted_build(model_thw['id']),
    'type': 'd',
    'key': 'thw',
    'actions': thw_build_actions(),
    'callbacks': thw_build_callbacks,
    'update': threshold_weighted_tracer,
    'session-actions': 'session-actions-thw',
    'session-tracer': 'session-tracer-thw',
    'visual_default': visual_connections['id'],
    'visuals': { model['id']: model for model in [
        visual_connections, tracer_weighted_threshold, tracer_thw_th
    ]},
}

if __name__ == '__main__':
    print('model: Threshold Weighted')