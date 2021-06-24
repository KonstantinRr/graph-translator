

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

def thw_update(args, data):
    return data

def thw_random(data, args):
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

def threshold_weighted_tracer(graph, node_x, node_y):
    """ Generates the uniform threshold tracer """
    return generate_trace(graph, node_x, node_y, 'thw', 'Weighted Threshold', 'Bluered')

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

tracer_weighted_threshold = {
    'id': 'tracer_threshold',
    'name': 'Threshold Tracer',
    'tracer': threshold_weighted_tracer,
}

model_thw = {
    'id': 'threshold_weighted',
    'name': 'Weighted Threshold',
    'ui': lambda: threshold_weighted_build(model_thw['id']),
    'type': 'd',
    'key': 'thw',
    'actions': thw_build_actions(),
    'callbacks': thw_build_callbacks,
    'state': DiscreteState([0, 1]),
    'update': threshold_weighted_tracer,
    'visual_default': visual_connections['id'],
    'session-actions': 'session-actions-thw',
    'session-tracer': 'session-tracer-thw',
    'visuals': { model['id']: model for model in [
        visual_connections, tracer_weighted_threshold
    ]},
}