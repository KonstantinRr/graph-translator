
import numpy as np
import networkx as nx

import dash
import dash.dependencies as dp
import dash_core_components as dcc
import dash_bootstrap_components as dbc
import dash_html_components as html
from dash.exceptions import PreventUpdate

from src.tracer import generate_trace
from src.models import ContinuesState, stochastic_callback
import src.designs as designs

from src.visual import build_visual_selector
from src.visual_connections import visual_connections

id_degroot_button_random = 'degroot-button-random'
id_degroot_button_stochastic = 'degroot-button-stochastic'
id_degroot_button_step = 'degroot-button-step'
id_degroot_dropdown = 'degroot-dropdown'

action_degroot_random = 'action_degroot_random'
action_degroot_stochastic = 'action_degroot_stochastic'
action_degroot_step = 'action_degroot_step'
action_degroot_visual = 'action_degroot_visual'

def degroot_update(data, args):
    transpose = True
    graph = data['graph']
    # create the matrix version of the graph
    npMatrix = nx.to_numpy_matrix(graph, weight='weight')
    if transpose:
        npMatrix = np.transpose(npMatrix)
    # calculates the number of steps 
    convMatrix = np.linalg.matrix_power(npMatrix, 1)
    # gets the current state as numpy vector
    state = np.array([node[1]['deg'] for node in graph.nodes(data=True)])
    # calculates the new state by multiplying with the matrix
    newState = np.asarray(np.dot(convMatrix, state)).reshape(-1)
    # apply the new state to the model
    for val, node in zip(newState, graph.nodes(data=True)):
        node[1]['deg'] = val
    return data

def degroot_random(data, args):
    for node, data_node in data['graph'].nodes(data=True):
        data_node[model_degroot['key']] = model_degroot['state'].random()
    return data

def degroot_build(model_id):
    return html.Div(
        html.Div([
                html.Div([html.Button('Random', id=id_degroot_button_random, style=designs.but)], style=designs.col),
                html.Div([html.Button('Stochastic', id=id_degroot_button_stochastic, style=designs.but)], style=designs.col),
                html.Div([html.Button('Step', id=id_degroot_button_step, style=designs.but)], style=designs.col),
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
    }

def build_degroot_callbacks(app):
    @app.callback(
        dp.Output('session-tracer-degroot', 'data'),
        dp.Input(id_degroot_dropdown, 'value'))
    def tracer_callback(value):
        return [model_degroot['id'], value]

    @app.callback(
        dp.Output('session-actions-degroot', 'data'),
        dp.Input(id_degroot_button_random, 'n_clicks'),
        dp.Input(id_degroot_button_stochastic, 'n_clicks'),
        dp.Input(id_degroot_button_step, 'n_clicks'),)
    def callback(n1, n2, n3):
        ctx = dash.callback_context
        if not ctx.triggered: return []
        source = ctx.triggered[0]['prop_id'].split('.')[0]
        if source == id_degroot_button_random:
            return [(model_degroot['id'], action_degroot_random, {})]
        elif source == id_degroot_button_stochastic:
            return [(model_degroot['id'], action_degroot_stochastic, {})]
        elif source == id_degroot_button_step:
            return [(model_degroot['id'], action_degroot_step, {})]
        print(f'DeGroot callback: Could not find property with source: {source}')
        raise PreventUpdate()

def degroot_tracer(graph, node_x, node_y):
    return generate_trace(graph, node_x, node_y, 'deg', 'DeGroot', 'YlGnBu')

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
    'key': 'deg',
    'actions': degroot_build_actions(),
    'callbacks': build_degroot_callbacks,
    'state': ContinuesState(0.0, 1.0),
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