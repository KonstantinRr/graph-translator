
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


id_sir_button_random = 'sir-button-random'
id_sir_button_step = 'sir-button-step'
id_sir_dropdown = 'sir-dropdown'

action_sir_random = 'action_sir_random'
action_sir_step = 'action_sir_step'
action_sir_visual = 'action_sir_visual'


def sir_update(args, data):
    return data


def sir_random(data, args):
    return data

def sir_build_actions():
    return {
        action_sir_random: sir_random, 
        action_sir_step: sir_update,
    }

def sir_build_callbacks(app):
    @app.callback(
        dp.Output(model_sir['session-tracer'], 'data'),
        dp.Input(id_sir_dropdown, 'value'))
    def tracer_callback(value):
        return [model_sir['id'], value]

    @app.callback(
        dp.Output(model_sir['session-actions'], 'data'),
        dp.Input(id_sir_button_random, 'n_clicks'),
        dp.Input(id_sir_button_step, 'n_clicks'),)
    def callback(n1, n2):
        ctx = dash.callback_context
        if not ctx.triggered: return []
        source = ctx.triggered[0]['prop_id'].split('.')[0]
        if source == id_sir_button_random:
            return [(model_sir['id'], action_sir_random, {})]
        elif source == id_sir_button_step:
            return [(model_sir['id'], action_sir_step, {})]
        print(f'SIR callback: Could not find property with source: {source}')
        raise PreventUpdate()

def sir_build(model_id):
    return html.Div(
        html.Div([
                html.Div([html.Button('Random', id=id_sir_button_random, style=designs.but)], style=designs.col),
                html.Div([html.Button('Step', id=id_sir_button_step, style=designs.but)], style=designs.col),
            ] + build_visual_selector(model_sir, id=id_sir_dropdown),
            style=designs.row,
            id={'type': model_sir['id'], 'index': model_sir['id']}
        ),
        id={'type': 'specific', 'index': model_id},
        style={'display': 'none'}
    )

def sir_tracer(graph, node_x, node_y):
    """ Generates the SIS tracer """
    return generate_trace(graph, node_x, node_y, 'sis', 'SIS', 'Bluered')

visual_sir = {
    'id': 'tracer_sir',
    'name': 'SIR',
    'tracer': sir_tracer,
}

model_sir = {
    'id': 'sir',
    'name': 'SIR',
    'gen': sir_tracer,
    'ui': lambda: sir_build(model_sir['id']),
    'type': 'd',
    'key': 'sir',
    'actions': sir_build_actions(),
    'callbacks': sir_build_callbacks,
    'state': DiscreteState([0, 2]),
    'update': sir_update,
    'visual_default': visual_connections['id'],
    'session-actions': 'session-actions-sir',
    'session-tracer': 'session-tracer-sir',
    'visuals': { model['id']: model for model in [
        visual_connections, visual_sir
    ]},
}