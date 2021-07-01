

import numpy as np
import networkx as nx

import dash
import dash.dependencies as dp
import dash_core_components as dcc
import dash_bootstrap_components as dbc
import dash_html_components as html
from dash.exceptions import PreventUpdate

from src.interaction import *
from src.tracer import generate_trace
from src.models import DiscreteState, init_value
import src.designs as designs

from src.visual import *
from src.visual_connections import visual_connections

id_upoduna_button_random = 'upoduna-button-random'
id_upoduna_button_step = 'upoduna-button-step'
id_upoduna_button_stochastic = 'upoduna-button-stochastic'
id_upoduna_dropdown = 'upoduna-dropdown'
id_upoduna_slider_threshold = 'upoduna-slider-threshold'
id_upoduna_threshold_id = 'upoduna-slider-threshold-val'
id_upoduna_slider_steps = 'upoduna-slider-steps'
id_upoduna_slider_steps_value = 'upoduna-slider-steps-value'
id_upoduna_modal = 'upoduna-init'
id_upoduna_modal_generate = 'upoduna-init-generate'
id_upoduna_modal_init_slider = 'upoduna-init-slider'

action_upoduna_random = 'action_upoduna_random'
action_upoduna_stochastic = 'action_upoduna_stochastic'
action_upoduna_step = 'action_upoduna_step'
action_upoduna_visual = 'action_upoduna_visual'
action_upoduna_init = 'action_upoduna_init'

def upoduna_update(data, args):
    graph = data['graph']
    upoduna_key = model_upoduna['key']
    for _ in range(args['steps']):
        update_dict = {}
        for srcNode, adjacency in graph.adjacency():
            counts = {state: 0 for state in range(args['states'])} 
            total = len(adjacency)
            for dstNode in adjacency.keys():
                counts[graph.nodes[dstNode][upoduna_key]] += 1

            for key, value in counts.items():
                if value == total:
                    update_dict[srcNode] = key
                    break

        for key, value in update_dict.items():
            graph.nodes[key][upoduna_key] = value 

    return data

def upoduna_random(data, args):
    state = DiscreteState(list(range(args['states'])))
    for node, data_node in data['graph'].nodes(data=True):
        data_node[model_upoduna['key']] = state.random()
    return data

def upoduna_build_actions():
    return {
        action_upoduna_random: upoduna_random, 
        action_upoduna_step: upoduna_update,
        action_upoduna_init: lambda data, args: init_value(data, args, model_upoduna['key']),
    }

def upoduna_build_callbacks(app):
    build_step_callback(app, id_upoduna_slider_steps_value, id_upoduna_slider_steps, 'Steps')
    build_init_callback(app, id_upoduna_modal, id_upoduna_modal_init_slider, 'UPOD Una')


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
        dp.Input(id_upoduna_modal_generate, 'n_clicks'),
        dp.State(id_upoduna_modal_init_slider, 'value'),
        dp.State(id_upoduna_slider_threshold, 'value'),
        dp.State(id_upoduna_slider_steps, 'value'))
    def callback(n1, n2, n3, init, states, steps):
        ctx = dash.callback_context
        if not ctx.triggered: return []
        source = ctx.triggered[0]['prop_id'].split('.')[0]
        args = {'states': states, 'steps': steps, 'init': init}
        ac = {
            id_upoduna_button_random: action_upoduna_random,
            id_upoduna_button_step: action_upoduna_step,
            id_upoduna_modal_generate: action_upoduna_init,
        }
        if source in ac:
            return [(model_upoduna['id'], ac[source], args)]
        print(f'UPODUNA callback: Could not find property with source: {source}')
        raise PreventUpdate()

def upoduna_build(model_id):
    return html.Div(
        html.Div([
                build_init_modal(
                    id_upoduna_modal, id_upoduna_modal_init_slider,
                    id_upoduna_modal_generate, model_upoduna['name'],
                    0, 10, 1, 0
                ),
                html.Div([html.Button('Random', id=id_upoduna_button_random, style=designs.but)], style=designs.col),
                html.Div([html.Button('Step', id=id_upoduna_button_step, style=designs.but)], style=designs.col),
                html.Div([build_step_slider(
                    id_upoduna_slider_steps_value, id_upoduna_slider_steps, 'Steps')], style=designs.col),
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

def upoduna_state_tracer(graph, node_x, node_y, node_ids):
    """ Generates the uniform threshold tracer """
    return generate_trace(graph, node_x, node_y, node_ids,
        model_upoduna['key'], model_upoduna['name'], 'Bluered')

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
    'weighted': False,
    'key': 'upoduna',
    'actions': upoduna_build_actions(),
    'callbacks': upoduna_build_callbacks,
    'update': tracer_upoduna,
    'session-actions': 'session-actions-upoduna',
    'session-tracer': 'session-tracer-upoduna',
    'visual_default': tracer_upoduna['id'],
    'visuals': { model['id']: model for model in [
        visual_connections, tracer_upoduna
    ]},
}

if __name__ == '__main__':
    print('model: UPODMAJ')