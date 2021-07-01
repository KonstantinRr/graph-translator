

from networkx.readwrite.json_graph import adjacency
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

from src.visual import build_visual_selector, build_step_slider, build_step_callback
from src.visual_connections import visual_connections

id_thu_button_random = 'thu-button-random'
id_thu_button_step = 'thu-button-step'
id_thu_dropdown = 'thu-dropdown'
id_thu_slider_threshold = 'thu-slider-threshold'
id_thu_threshold_id = 'thu-slider-threshold-val'
id_thu_slider_steps = 'thu-slider-steps'
id_thu_slider_steps_value = 'thu-slider-steps-value'

action_thu_random = 'action_thu_random'
action_thu_step = 'action_thu_step'
action_thu_visual = 'action_thu_visual'

def thu_update(data, args):
    threshold = args['threshold']
    graph = data['graph']
    thu_key = model_thu['key']

    for i in range(args['steps']):
        update_dict = {}
        for srcNode, adjacency in graph.adjacency():
            count, total = 0, len(adjacency)
            for dstNode in adjacency.keys():
                if graph.nodes[dstNode][thu_key] > 0.5:
                    count += 1
            update_dict[srcNode] = 0 if count < threshold * total else 1

        # applies the update dictionary
        for key, value in update_dict.items():
            graph.nodes[key][thu_key] = value
    return data

def thu_random(data, args):
    state = DiscreteState([0, 1])
    for node, data_node in data['graph'].nodes(data=True):
        data_node[model_thu['key']] = state.random()
    return data


def thu_build_actions():
    return {
        action_thu_random: thu_random, 
        action_thu_step: thu_update,
    }

def threshold_uniform_build_callbacks(app):
    build_step_callback(app, id_thu_slider_steps_value, id_thu_slider_steps, 'Steps')

    @app.callback(
        dp.Output(model_thu['session-tracer'], 'data'),
        dp.Input(id_thu_dropdown, 'value'))
    def tracer_callback(value):
        return [model_thu['id'], value]

    @app.callback(
        dp.Output(id_thu_threshold_id, 'children'),
        dp.Input(id_thu_slider_threshold, 'value'))
    def slider_update(value):
        return f'Threshold: {value}'

    @app.callback(
        dp.Output(model_thu['session-actions'], 'data'),
        dp.Input(id_thu_button_random, 'n_clicks'),
        dp.Input(id_thu_button_step, 'n_clicks'),
        dp.State(id_thu_slider_threshold, 'value'),
        dp.State(id_thu_slider_steps, 'value'))
    def callback(n1, n2, threshold, steps):
        ctx = dash.callback_context
        if not ctx.triggered: return []
        source = ctx.triggered[0]['prop_id'].split('.')[0]
        args = {'threshold': threshold, 'steps': steps}
        if source == id_thu_button_random:
            return [(model_thu['id'], action_thu_random, args)]
        elif source == id_thu_button_step:
            return [(model_thu['id'], action_thu_step, args)]
        print(f'THW callback: Could not find property with source: {source}')
        raise PreventUpdate()

def threshold_uniform_build(model_id):
    return html.Div(
        html.Div([
                html.Div([html.Button('Random', id=id_thu_button_random, style=designs.but)], style=designs.col),
                html.Div([html.Button('Step', id=id_thu_button_step, style=designs.but)], style=designs.col),
                html.Div([build_step_slider(
                    id_thu_slider_steps_value, id_thu_slider_steps, 'Steps')], style=designs.col),
                
                html.Div(
                    html.Div(
                        [
                            html.Div('Threshold', id=id_thu_threshold_id, style={'padding-left': '30px'}),
                            dcc.Slider(
                                id=id_thu_slider_threshold,
                                min=0.0, max=1.0, step=0.1, value=0.5
                            ),
                        ],
                        style={'width': '200px'}
                    ),
                    style=designs.col
                )
            ] + build_visual_selector(model_thu, id=id_thu_dropdown),
            style=designs.row,
            id={'type': model_thu['id'], 'index': model_thu['id']}
        ),
        id={'type': 'specific', 'index': model_id},
        style={'display': 'none'}
    )

def threshold_uniform_tracer(graph, node_x, node_y, node_ids):
    """ Generates the uniform threshold tracer """
    return generate_trace(graph, node_x, node_y, node_ids, 'thu', 'Uniform Threshold', 'Bluered')

visual_thu = {
    'id': 'tracer_thu',
    'name': 'State Tracer',
    'tracer': threshold_uniform_tracer,
}

model_thu = {
    'id': 'threshold_uniform',
    'name': 'Threshold',
    'gen': threshold_uniform_tracer,
    'ui': lambda: threshold_uniform_build(model_thu['id']),
    'type': 'u',
    'weighted': False,
    'key': 'thu',
    'actions': thu_build_actions(),
    'callbacks': threshold_uniform_build_callbacks,
    'update': thu_update,
    'session-actions': 'session-actions-thu',
    'session-tracer': 'session-tracer-thu',
    'visual_default': visual_connections['id'],
    'visuals': { model['id']: model for model in [
        visual_connections, visual_thu
    ]},
}

if __name__ == '__main__':
    print('model: Threshold Uniform')