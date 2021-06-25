

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

from src.visual import build_visual_selector, build_step_callback, build_step_slider
from src.visual_connections import visual_connections

id_tha_button_random = 'tha-button-random'
id_tha_button_step = 'tha-button-step'
id_tha_dropdown = 'tha-dropdown'
id_tha_slider_steps = 'tha-slider-steps'
id_tha_slider_steps_value = 'tha-slider-steps-value'

action_tha_random = 'action_tha_random'
action_tha_step = 'action_tha_step'
action_tha_visual = 'action_tha_visual'

def tha_update(data, args):
    graph = data['graph']
    return data

def tha_random(data, args):
    state = DiscreteState([0, 1, 2])
    for node, data_node in data['graph'].nodes(data=True):
        data_node[model_tha['key']] = state.random()
    return data

def tha_build_actions():
    return {
        action_tha_random: tha_random, 
        action_tha_step: tha_update,
    }

def tha_build_callbacks(app):
    build_step_callback(app, id_tha_slider_steps_value, id_tha_slider_steps, 'Steps')

    @app.callback(
        dp.Output(model_tha['session-tracer'], 'data'),
        dp.Input(id_tha_dropdown, 'value'))
    def tracer_callback(value):
        return [model_tha['id'], value]

    @app.callback(
        dp.Output(model_tha['session-actions'], 'data'),
        dp.Input(id_tha_button_random, 'n_clicks'),
        dp.Input(id_tha_button_step, 'n_clicks'),
        dp.State(id_tha_slider_steps, 'value'))
    def callback(n1, n2, steps):
        ctx = dash.callback_context
        if not ctx.triggered: return []
        source = ctx.triggered[0]['prop_id'].split('.')[0]
        args = {'steps': steps}
        if source == id_tha_button_random:
            return [(model_tha['id'], action_tha_random, args)]
        elif source == id_tha_button_step:
            return [(model_tha['id'], action_tha_step, args)]
        print(f'THW callback: Could not find property with source: {source}')
        raise PreventUpdate()

def tha_build(model_id):
    return html.Div(
        html.Div([
                html.Div([html.Button('Random', id=id_tha_button_random, style=designs.but)], style=designs.col),
                html.Div([html.Button('Step', id=id_tha_button_step, style=designs.but)], style=designs.col),
                html.Div([build_step_slider(
                    id_tha_slider_steps_value, id_tha_slider_steps, 'Steps')], style=designs.col)
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
    'weighted': False,
    'key': 'tha',
    'actions': tha_build_actions(),
    'callbacks': tha_build_callbacks,
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