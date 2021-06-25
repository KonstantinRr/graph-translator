

import numpy as np
import networkx as nx

import dash
import dash.dependencies as dp
import dash_core_components as dcc
import dash_bootstrap_components as dbc
import dash_html_components as html
from dash.exceptions import PreventUpdate

from src.tracer import generate_trace
from src.models import DiscreteState
import src.designs as designs

from src.visual import build_visual_selector
from src.visual_connections import visual_connections

id_tha_button_random = 'tha-button-random'
id_tha_button_step = 'tha-button-step'
id_tha_dropdown = 'tha-dropdown'

action_tha_random = 'action_tha_random'
action_tha_step = 'action_tha_step'
action_tha_visual = 'action_tha_visual'

def tha_update(data, args):
    graph = data['graph']
    return data

def tha_random(data, args):
    for node, data_node in data['graph'].nodes(data=True):
        data_node[model_tha['key']] = model_tha['state'].random()
    return data

def tha_build_actions():
    return {
        action_tha_random: tha_random, 
        action_tha_step: tha_update,
    }

def tha_build_callbacks(app):
    @app.callback(
        dp.Output(model_tha['session-tracer'], 'data'),
        dp.Input(id_tha_dropdown, 'value'))
    def tracer_callback(value):
        return [model_tha['id'], value]

    @app.callback(
        dp.Output(model_tha['session-actions'], 'data'),
        dp.Input(id_tha_button_random, 'n_clicks'),
        dp.Input(id_tha_button_step, 'n_clicks'),)
    def callback(n1, n2):
        ctx = dash.callback_context
        if not ctx.triggered: return []
        source = ctx.triggered[0]['prop_id'].split('.')[0]
        if source == id_tha_button_random:
            return [(model_tha['id'], action_tha_random, {})]
        elif source == id_tha_button_step:
            return [(model_tha['id'], action_tha_step, {})]
        print(f'THW callback: Could not find property with source: {source}')
        raise PreventUpdate()

def tha_build(model_id):
    return html.Div(
        html.Div([
                html.Div([html.Button('Random', id=id_tha_button_random, style=designs.but)], style=designs.col),
                html.Div([html.Button('Step', id=id_tha_button_step, style=designs.but)], style=designs.col),
            ] + build_visual_selector(model_tha, id=id_tha_dropdown),
            style=designs.row,
            id={'type': model_tha['id'], 'index': model_tha['id']}
        ),
        id={'type': 'specific', 'index': model_id},
        style={'display': 'none'}
    )

def tha_tracer(graph, node_x, node_y):
    """ Generates the uniform threshold tracer """
    return generate_trace(graph, node_x, node_y, model_tha['key'], 'Threshold Automata', 'Bluered')

tracer_tha_state = {
    'id': 'tracer_threshold_automata',
    'name': 'State Tracer',
    'tracer': tha_tracer,
}

model_tha = {
    'id': 'threshold_automata',
    'name': 'Threshold Automata',
    'ui': lambda: tha_build(model_tha['id']),
    'type': 'd',
    'key': 'tha',
    'actions': tha_build_actions(),
    'callbacks': tha_build_callbacks,
    'state': DiscreteState([0, 1, 2]),
    'update': tha_tracer,
    'session-actions': 'session-actions-tha',
    'session-tracer': 'session-tracer-tha',
    'visual_default': visual_connections['id'],
    'visuals': { model['id']: model for model in [
        visual_connections, tracer_tha_state
    ]},
}

if __name__ == '__main__':
    print('model: Threshold Weighted')