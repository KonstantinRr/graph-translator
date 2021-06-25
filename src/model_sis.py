
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

id_sis_button_random = 'sis-button-random'
id_sis_button_step = 'sis-button-step'
id_sis_dropdown = 'sis-dropdown'
id_sis_slider_steps = 'sis-slider-steps'
id_sis_slider_steps_value = 'sis-slider-steps-value'

action_sis_random = 'action_sis_random'
action_sis_step = 'action_sis_step'
action_sis_visual = 'action_sis_visual'

def sis_update(data, args):
    return data

def sis_random(data, args):
    state = DiscreteState([0, 1])
    for node, data_node in data['graph'].nodes(data=True):
        data_node[model_sis['key']] = state.random()
    return data

def sis_build_actions():
    return {
        action_sis_random: sis_random,
        action_sis_step: sis_update,
    }

def sis_build_callbacks(app):
    build_step_callback(app, id_sis_slider_steps_value, id_sis_slider_steps, 'Steps')

    @app.callback(
        dp.Output(model_sis['session-tracer'], 'data'),
        dp.Input(id_sis_dropdown, 'value'))
    def tracer_callback(value):
        return [model_sis['id'], value]

    @app.callback(
        dp.Output(model_sis['session-actions'], 'data'),
        dp.Input(id_sis_button_random, 'n_clicks'),
        dp.Input(id_sis_button_step, 'n_clicks'),
        dp.State(id_sis_slider_steps, 'value'))
    def callback(n1, n2, steps):
        ctx = dash.callback_context
        if not ctx.triggered: return []
        source = ctx.triggered[0]['prop_id'].split('.')[0]
        args = {'steps': steps}
        if source == id_sis_button_random:
            return [(model_sis['id'], action_sis_random, args)]
        elif source == id_sis_button_step:
            return [(model_sis['id'], action_sis_step, args)]
        print(f'SIS callback: Could not find property with source: {source}')
        raise PreventUpdate()


def sis_build(model_id):
    return html.Div(
        html.Div([
                html.Div([html.Button('Random', id=id_sis_button_random, style=designs.but)], style=designs.col),
                html.Div([html.Button('Step', id=id_sis_button_step, style=designs.but)], style=designs.col),
                html.Div([build_step_slider(
                    id_sis_slider_steps_value, id_sis_slider_steps, 'Steps')], style=designs.col)
            ] + build_visual_selector(model_sis, id=id_sis_dropdown),
            style=designs.row,
            id={'type': model_sis['id'], 'index': model_sis['id']}
        ),
        id={'type': 'specific', 'index': model_id},
        style={'display': 'none'}
    )

def sis_tracer(graph, node_x, node_y):
    """ Generates the SIS tracer """
    return generate_trace(graph, node_x, node_y, 'sis', 'SIS', 'Bluered')

visual_sis = {
    'id': 'tracer_sis',
    'name': 'State Tracer',
    'tracer': sis_tracer,
}

model_sis = {
    'id': 'sis',
    'name': 'SIS',
    'gen': sis_tracer,
    'ui': lambda: sis_build(model_sis['id']),
    'type': 'd',
    'key': 'sis',
    'weighted': False,
    'actions': sis_build_actions(),
    'callbacks': sis_build_callbacks,
    'update': sis_update,
    'session-actions': 'session-actions-sis',
    'session-tracer': 'session-tracer-sis',
    'visual_default': visual_connections['id'],
    'visuals': { model['id']: model for model in [
        visual_connections, visual_sis
    ]},
}

if __name__ == '__main__':
    print('model: SIS')