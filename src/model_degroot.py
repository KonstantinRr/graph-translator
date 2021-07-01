
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
from src.models import ContinuesState, stochastic_callback
import src.designs as designs

from src.visual import *
from src.visual_connections import visual_connections

id_degroot_button_random = 'degroot-button-random'
id_degroot_button_stochastic = 'degroot-button-stochastic'
id_degroot_button_step = 'degroot-button-step'
id_degroot_dropdown = 'degroot-dropdown'
id_degroot_slider_steps = 'degroot-slider-steps'
id_degroot_slider_steps_value = 'degroot-slider-steps-value'
id_degroot_modal = 'degroot-init'
id_degroot_modal_generate = 'degroot-init-generate'
id_degroot_modal_init_slider = 'degroot-init-slider'

action_degroot_random = 'action_degroot_random'
action_degroot_stochastic = 'action_degroot_stochastic'
action_degroot_step = 'action_degroot_step'
action_degroot_visual = 'action_degroot_visual'
action_degroot_init = 'action_degroot_init'

def degroot_update(data, args):
    transpose, clip = False, False
    graph = data['graph']

    key = model_degroot['key']
    # create the matrix version of the graph
    npMatrix = nx.to_numpy_matrix(graph, weight='weight')
    if transpose:
        npMatrix = np.transpose(npMatrix)
    # calculates the number of steps 
    convMatrix = np.linalg.matrix_power(npMatrix, args['steps'])
    # gets the current state as numpy vector
    state = np.array([node[1][key] for node in graph.nodes(data=True)])
    # calculates the new state by multiplying with the matrix
    newState = np.asarray(np.dot(convMatrix, state)).reshape(-1)
    if clip:
        newState = np.clip(newState, 0.0, 1.0)
    # apply the new state to the model
    for val, node in zip(newState, graph.nodes(data=True)):
        node[1][key] = val
    return data

def degroot_random(data, args):
    state = ContinuesState(0.0, 1.0)
    for node, data_node in data['graph'].nodes(data=True):
        data_node[model_degroot['key']] = state.random()
    return data

def degroot_init(data, args):
    graph, key = data['graph'], model_degroot['key']
    for node in get_node_names(args['selected']):
        graph.nodes[node][key] = args['init']
    return data

def degroot_build(model_id):
    return html.Div(
        html.Div([
                build_init_modal(
                    id_degroot_modal, id_degroot_modal_init_slider,
                    id_degroot_modal_generate, 'DeGroot',
                    0.0, 1.0, 0.05, 0.0
                ),
                html.Div([html.Button('Random', id=id_degroot_button_random, style=designs.but)], style=designs.col),
                build_init_button(id_degroot_modal),
                html.Div([html.Button('Stochastic', id=id_degroot_button_stochastic, style=designs.but)], style=designs.col),
                html.Div([html.Button('Step', id=id_degroot_button_step, style=designs.but)], style=designs.col),
                html.Div([build_step_slider(
                    id_degroot_slider_steps_value, id_degroot_slider_steps, 'Steps')], style=designs.col)
            ] + build_visual_selector(model_degroot, id=id_degroot_dropdown),
            style=designs.row,
            id={'type': model_degroot['id'], 'index': model_degroot['id']}
        ),
        id={'type': 'specific', 'index': model_id},
        style={'display': 'none'}
    )

def degroot_build_actions():
    return {
        action_degroot_random: degroot_random, 
        action_degroot_stochastic: stochastic_callback,
        action_degroot_step: degroot_update,
        action_degroot_init: degroot_init,
    }

def build_degroot_callbacks(app):
    build_step_callback(app, id_degroot_slider_steps_value, id_degroot_slider_steps, 'Steps')
    build_init_callback(app, id_degroot_modal, id_degroot_modal_init_slider, 'DeGroot')

    @app.callback(
        dp.Output('session-tracer-degroot', 'data'),
        dp.Input(id_degroot_dropdown, 'value'))
    def tracer_callback(value):
        return [model_degroot['id'], value]

    @app.callback(
        dp.Output('session-actions-degroot', 'data'),
        dp.Input(id_degroot_button_random, 'n_clicks'),
        dp.Input(id_degroot_button_stochastic, 'n_clicks'),
        dp.Input(id_degroot_button_step, 'n_clicks'),
        dp.Input(id_degroot_modal_generate, 'n_clicks'),
        dp.State(id_degroot_modal_init_slider, 'value'),
        dp.State(id_degroot_slider_steps, 'value'))
    def callback(n1, n2, n3, n4, init, steps):
        ctx = dash.callback_context
        if not ctx.triggered: return []
        source = ctx.triggered[0]['prop_id'].split('.')[0]
        args = {'steps': steps, 'init': init}
        if source == id_degroot_button_random:
            return [(model_degroot['id'], action_degroot_random, args)]
        elif source == id_degroot_button_stochastic:
            return [(model_degroot['id'], action_degroot_stochastic, args)]
        elif source == id_degroot_button_step:
            return [(model_degroot['id'], action_degroot_step, args)]
        elif source == id_degroot_modal_generate:
            return [(model_degroot['id'], action_degroot_init, args)] 
        print(f'DeGroot callback: Could not find property with source: {source}')
        raise PreventUpdate()

def degroot_tracer(graph, node_x, node_y, node_ids):
    return generate_trace(graph, node_x, node_y, node_ids, model_degroot['key'], 'DeGroot', 'YlGnBu')

visual_degroot = {
    'id': 'tracer_degroot',
    'name': 'State Tracer',
    'tracer': degroot_tracer,
}

model_degroot = {
    'id': 'degroot',
    'name': 'DeGroot',
    'ui': lambda: degroot_build(model_degroot['id']),
    'type': 'd',
    'weighted': True,
    'key': 'deg',
    'actions': degroot_build_actions(),
    'callbacks': build_degroot_callbacks,
    'update': degroot_update,
    'session-actions': 'session-actions-degroot',
    'session-tracer': 'session-tracer-degroot',
    'visual_default': visual_connections['id'],
    'visuals': { model['id']: model for model in [
        visual_connections, visual_degroot
    ]},
}

if __name__ == '__main__':
    print('model: DeGroot')