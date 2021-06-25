

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

id_upoduna_button_random = 'upoduna-button-random'
id_upoduna_button_step = 'upoduna-button-step'
id_upoduna_button_stochastic = 'upoduna-button-stochastic'
id_upoduna_dropdown = 'upoduna-dropdown'
id_upoduna_slider_threshold = 'upoduna-slider-threshold'
id_upoduna_threshold_id = 'upoduna-slider-threshold-val'

action_upoduna_random = 'action_upoduna_random'
action_upoduna_stochastic = 'action_upoduna_stochastic'
action_upoduna_step = 'action_upoduna_step'
action_upoduna_visual = 'action_upoduna_visual'

def upoduna_update(data, args):
    return data

def upoduna_random(data, args):
    state = DiscreteState(list(range(args[0])))
    for node, data_node in data['graph'].nodes(data=True):
        data_node[model_upoduna['key']] = state.random()
    return data

def upoduna_build_actions():
    return {
        action_upoduna_random: upoduna_random, 
        action_upoduna_step: upoduna_update,
    }

def upoduna_build_callbacks(app):
    @app.callback(
        dp.Output(model_upoduna['session-tracer'], 'data'),
        dp.Input(id_upoduna_dropdown, 'value'))
    def tracer_callback(value):
        return [model_upoduna['id'], value]

    @app.callback(
        dp.Output(id_upoduna_threshold_id, 'children'),
        dp.Input(id_upoduna_slider_threshold, 'value'))
    def slider_update(value):
        return f'States: {value}'

    @app.callback(
        dp.Output(model_upoduna['session-actions'], 'data'),
        dp.Input(id_upoduna_button_random, 'n_clicks'),
        dp.Input(id_upoduna_button_step, 'n_clicks'),
        dp.State(id_upoduna_slider_threshold, 'value'))
    def callback(n1, n2, states):
        ctx = dash.callback_context
        if not ctx.triggered: return []
        source = ctx.triggered[0]['prop_id'].split('.')[0]
        if source == id_upoduna_button_random:
            return [(model_upoduna['id'], action_upoduna_random, (states,))]
        elif source == id_upoduna_button_step:
            return [(model_upoduna['id'], action_upoduna_step, (states,))]
        print(f'UPODUNA callback: Could not find property with source: {source}')
        raise PreventUpdate()

def upoduna_build(model_id):
    return html.Div(
        html.Div([
                html.Div([html.Button('Random', id=id_upoduna_button_random, style=designs.but)], style=designs.col),
                html.Div([html.Button('Step', id=id_upoduna_button_step, style=designs.but)], style=designs.col),
                html.Div(
                    html.Div(
                        [
                            html.Div('States', id=id_upoduna_threshold_id, style={'padding-left': '30px'}),
                            dcc.Slider(
                                id=id_upoduna_slider_threshold,
                                min=2, max=10, step=1, value=2
                            ),
                        ],
                        style={'width': '200px'}
                    ),
                    style=designs.col
                )
            ] + build_visual_selector(model_upoduna, id=id_upoduna_dropdown),
            style=designs.row,
            id={'type': model_upoduna['id'], 'index': model_upoduna['id']}
        ),
        id={'type': 'specific', 'index': model_id},
        style={'display': 'none'}
    )

def upoduna_state_tracer(graph, node_x, node_y):
    """ Generates the uniform threshold tracer """
    return generate_trace(graph, node_x, node_y, model_upoduna['key'], 'UPOD Unanimity State', 'Bluered')

tracer_upoduna = {
    'id': 'tracer_upoduna',
    'name': 'State Tracer',
    'tracer': upoduna_state_tracer,
}

model_upoduna = {
    'id': 'upoduna',
    'name': 'UPOD Unanimity',
    'ui': lambda: upoduna_build(model_upoduna['id']),
    'type': 'u',
    'key': 'upoduna',
    'actions': upoduna_build_actions(),
    'callbacks': upoduna_build_callbacks,
    'update': tracer_upoduna,
    'session-actions': 'session-actions-upoduna',
    'session-tracer': 'session-tracer-upoduna',
    'visual_default': visual_connections['id'],
    'visuals': { model['id']: model for model in [
        visual_connections, tracer_upoduna
    ]},
}

if __name__ == '__main__':
    print('model: UPODMAJ')