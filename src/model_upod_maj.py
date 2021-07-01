
import operator

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

from src.visual import build_visual_selector, build_step_callback, build_step_slider
from src.visual_connections import visual_connections

id_upodmaj_button_random = 'upodmaj-button-random'
id_upodmaj_button_step = 'upodmaj-button-step'
id_upodmaj_button_stochastic = 'upodmaj-button-stochastic'
id_upodmaj_dropdown = 'upodmaj-dropdown'
id_upodmaj_slider_threshold = 'upodmaj-slider-threshold'
id_upodmaj_threshold_id = 'upodmaj-slider-threshold-val'
id_upodmaj_slider_steps = 'upodmaj-slider-steps'
id_upodmaj_slider_steps_value = 'upodmaj-slider-steps-value'

action_upodmaj_random = 'action_upodmaj_random'
action_upodmaj_stochastic = 'action_upodmaj_stochastic'
action_upodmaj_step = 'action_upodmaj_step'
action_upodmaj_visual = 'action_upodmaj_visual'

def upodmaj_update(data, args):
    graph = data['graph']
    upodmaj_key = model_upodmaj['key']
    for _ in range(args['steps']):
        update_dict = {}
        for srcNode, adjacency in graph.adjacency():
            counts = {state: 0 for state in range(args['states'])} 
            for dstNode in adjacency.keys():
                counts[graph.nodes[dstNode][upodmaj_key]] += 1

            max_key, max_val = max(counts.items(), key=operator.itemgetter(1))
            del counts[max_key]
            if max_val > max(counts.values()):
                update_dict[srcNode] = max_key

        for key, value in update_dict.items():
            graph.nodes[key][upodmaj_key] = value 

    return data

def upodmaj_random(data, args):
    state = DiscreteState(list(range(args['states'])))
    for node, data_node in data['graph'].nodes(data=True):
        data_node[model_upodmaj['key']] = state.random()
    return data

def upodmaj_build_actions():
    return {
        action_upodmaj_random: upodmaj_random, 
        action_upodmaj_step: upodmaj_update,
    }

def upodmaj_build_callbacks(app):
    build_step_callback(app, id_upodmaj_slider_steps_value, id_upodmaj_slider_steps, 'Steps')

    @app.callback(
        dp.Output(model_upodmaj['session-tracer'], 'data'),
        dp.Input(id_upodmaj_dropdown, 'value'))
    def tracer_callback(value):
        return [model_upodmaj['id'], value]

    @app.callback(
        dp.Output(id_upodmaj_threshold_id, 'children'),
        dp.Input(id_upodmaj_slider_threshold, 'value'))
    def slider_update(value):
        return f'States: {value}'

    @app.callback(
        dp.Output(model_upodmaj['session-actions'], 'data'),
        dp.Input(id_upodmaj_button_random, 'n_clicks'),
        dp.Input(id_upodmaj_button_step, 'n_clicks'),
        dp.State(id_upodmaj_slider_threshold, 'value'),
        dp.State(id_upodmaj_slider_steps, 'value'))
    def callback(n1, n2, states, steps):
        ctx = dash.callback_context
        if not ctx.triggered: return []
        source = ctx.triggered[0]['prop_id'].split('.')[0]
        args = {'states': states, 'steps': steps}
        if source == id_upodmaj_button_random:
            return [(model_upodmaj['id'], action_upodmaj_random, args)]
        elif source == id_upodmaj_button_step:
            return [(model_upodmaj['id'], action_upodmaj_step, args)]
        print(f'UPODMAJ callback: Could not find property with source: {source}')
        raise PreventUpdate()

def upodmaj_build(model_id):
    return html.Div(
        html.Div([
                html.Div([html.Button('Random', id=id_upodmaj_button_random, style=designs.but)], style=designs.col),
                html.Div([html.Button('Step', id=id_upodmaj_button_step, style=designs.but)], style=designs.col),
                html.Div([build_step_slider(
                    id_upodmaj_slider_steps_value, id_upodmaj_slider_steps, 'Steps')], style=designs.col),
                html.Div(
                    html.Div(
                        [
                            html.Div('States', id=id_upodmaj_threshold_id, style={'padding-left': '30px'}),
                            dcc.Slider(
                                id=id_upodmaj_slider_threshold,
                                min=2, max=10, step=1, value=2
                            ),
                        ],
                        style={'width': '200px'}
                    ),
                    style=designs.col
                )
            ] + build_visual_selector(model_upodmaj, id=id_upodmaj_dropdown),
            style=designs.row,
            id={'type': model_upodmaj['id'], 'index': model_upodmaj['id']}
        ),
        id={'type': 'specific', 'index': model_id},
        style={'display': 'none'}
    )

def upodmaj_state_tracer(graph, node_x, node_y, node_ids):
    """ Generates the uniform threshold tracer """
    return generate_trace(graph, node_x, node_y, node_ids, model_upodmaj['key'], 'UPOD Majority State', 'Bluered')

tracer_upodmaj = {
    'id': 'tracer_upodmaj',
    'name': 'State Tracer',
    'tracer': upodmaj_state_tracer,
}

model_upodmaj = {
    'id': 'upodmaj',
    'name': 'UPOD Majority',
    'ui': lambda: upodmaj_build(model_upodmaj['id']),
    'type': 'u',
    'weighted': False,
    'key': 'upodmaj',
    'actions': upodmaj_build_actions(),
    'callbacks': upodmaj_build_callbacks,
    'update': tracer_upodmaj,
    'session-actions': 'session-actions-upodmaj',
    'session-tracer': 'session-tracer-upodmaj',
    'visual_default': visual_connections['id'],
    'visuals': { model['id']: model for model in [
        visual_connections, tracer_upodmaj
    ]},
}

if __name__ == '__main__':
    print('model: UPODMAJ')