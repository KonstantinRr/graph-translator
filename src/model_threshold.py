

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

id_thu_button_random = 'thu-button-random'
id_thu_button_step = 'thu-button-step'
id_thu_dropdown = 'thu-dropdown'

action_thu_random = 'action_thu_random'
action_thu_step = 'action_thu_step'
action_thu_visual = 'action_thu_visual'

def thu_update(args, data):
    return data

def thu_random(data, args):
    return data

def thu_build_actions():
    return {
        action_thu_random: thu_random, 
        action_thu_step: thu_update,
    }

def threshold_uniform_build_callbacks(app):
    @app.callback(
        dp.Output(model_thu['session-tracer'], 'data'),
        dp.Input(id_thu_dropdown, 'value'))
    def tracer_callback(value):
        return [model_thu['id'], value]

    @app.callback(
        dp.Output(model_thu['session-actions'], 'data'),
        dp.Input(id_thu_button_random, 'n_clicks'),
        dp.Input(id_thu_button_step, 'n_clicks'),)
    def callback(n1, n3):
        ctx = dash.callback_context
        if not ctx.triggered: return []
        source = ctx.triggered[0]['prop_id'].split('.')[0]
        if source == id_thu_button_random:
            return [(model_thu['id'], action_thu_random, {})]
        elif source == id_thu_button_step:
            return [(model_thu['id'], action_thu_step, {})]
        print(f'THW callback: Could not find property with source: {source}')
        raise PreventUpdate()

def threshold_uniform_build(model_id):
    return html.Div(
        html.Div([
                html.Div([html.Button('Random', id=id_thu_button_random, style=designs.but)], style=designs.col),
                html.Div([html.Button('Step', id=id_thu_button_step, style=designs.but)], style=designs.col),
            ] + build_visual_selector(model_thu, id=id_thu_dropdown),
            style=designs.row,
            id={'type': model_thu['id'], 'index': model_thu['id']}
        ),
        id={'type': 'specific', 'index': model_id},
        style={'display': 'none'}
    )

def threshold_uniform_tracer(graph, node_x, node_y):
    """ Generates the uniform threshold tracer """
    return generate_trace(graph, node_x, node_y, 'thu', 'Uniform Threshold', 'Bluered')

visual_thu = {
    'id': 'tracer_thu',
    'name': 'Threshold uniform',
    'tracer': threshold_uniform_tracer,
}

model_thu = {
    'id': 'threshold_uniform',
    'name': 'Threshold',
    'gen': threshold_uniform_tracer,
    'ui': lambda: threshold_uniform_build(model_thu['id']),
    'type': 'u',
    'key': 'thu',
    'actions': thu_build_actions(),
    'callbacks': threshold_uniform_build_callbacks,
    'state': DiscreteState([0, 1]),
    'update': thu_update,
    'visual_default': visual_connections['id'],
    'session-actions': 'session-actions-thu',
    'session-tracer': 'session-tracer-thu',
    'visuals': { model['id']: model for model in [
        visual_connections, visual_thu
    ]},
}