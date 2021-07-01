import random

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

from src.visual import (build_visual_selector, build_step_slider, build_step_callback,
    build_prob_callback, build_prob_slider, build_infection_slider, build_infection_callback)
from src.visual_connections import visual_connections


id_sir_button_random = 'sir-button-random'
id_sir_button_step = 'sir-button-step'
id_sir_button_one = 'sir-button-one'
id_sir_dropdown = 'sir-dropdown'

id_sir_slider_steps = 'sir-slider-steps'
id_sir_slider_steps_value = 'sir-slider-steps-value'
id_sir_slider_prob = 'sir-slider-prob'
id_sir_slider_prob_value = 'sir-slider-prob-value'
id_sir_slider_itime = 'sir-slider-itime'
id_sir_slider_itime_value = 'sir-slider-itime-value'

action_sir_one = 'action_sis_one'
action_sir_random = 'action_sir_random'
action_sir_step = 'action_sir_step'
action_sir_visual = 'action_sir_visual'


def sir_update(data, args):
    graph = data['graph']
    sir_key = model_sir['key']

    for i in range(args['steps']):
        update_dict = {}
        for srcNode, adjacency in graph.adjacency():
            state = graph.nodes[srcNode][sir_key]
            if state == 0: # node is suspectible
                count = 0
                for dstNode in adjacency.keys():
                    if graph.nodes[dstNode][sir_key] >= 1:
                        count += 1 # neighbour node is infected
                # 1 minus healthy prob
                infection_prob = 1.0 - (1.0 - args['prob']) ** count
                if np.random.random() <= infection_prob:
                    update_dict[srcNode] = args['itime']
            elif state > 0: # node is infected
                if state == 1:
                    update_dict[srcNode] = -1 # recovered
                else:
                    update_dict[srcNode] = state - 1 # less infected
            elif state == -1: # node is recovered
                pass

        # applies the update dictionary
        for key, value in update_dict.items():
            graph.nodes[key][sir_key] = value
    return data

def sir_one(data, args):
    rand = random.choice(data['graph'].nodes)
    rand[model_sir['key']] = args['itime']
    return data

def sir_random(data, args):
    for node, data_node in data['graph'].nodes(data=True):
        data_node[model_sir['key']] = random.choice([0, args['itime']])
    return data

def sir_build_actions():
    return {
        action_sir_random: sir_random, 
        action_sir_step: sir_update,
        action_sir_one: sir_one,
    }

def sir_build_callbacks(app):
    build_step_callback(app, id_sir_slider_steps_value, id_sir_slider_steps, 'Steps')
    build_prob_callback(app, id_sir_slider_prob_value, id_sir_slider_prob)
    build_infection_callback(app, id_sir_slider_itime_value, id_sir_slider_itime)

    @app.callback(
        dp.Output(model_sir['session-tracer'], 'data'),
        dp.Input(id_sir_dropdown, 'value'))
    def tracer_callback(value):
        return [model_sir['id'], value]

    @app.callback(
        dp.Output(model_sir['session-actions'], 'data'),
        dp.Input(id_sir_button_random, 'n_clicks'),
        dp.Input(id_sir_button_step, 'n_clicks'),
        dp.Input(id_sir_button_one, 'n_clicks'),
        dp.State(id_sir_slider_steps, 'value'),
        dp.State(id_sir_slider_prob, 'value'),
        dp.State(id_sir_slider_itime, 'value'),)
    def callback(n1, n2, n3, steps, prob, itime):
        ctx = dash.callback_context
        if not ctx.triggered: return []
        source = ctx.triggered[0]['prop_id'].split('.')[0]
        args = {'steps': steps, 'prob': prob, 'itime': itime}
        if source == id_sir_button_random:
            return [(model_sir['id'], action_sir_random, args)]
        elif source == id_sir_button_step:
            return [(model_sir['id'], action_sir_step, args)]
        elif source == id_sir_button_one:
            return [(model_sir['id'], action_sir_one, args)]
        print(f'SIR callback: Could not find property with source: {source}')
        raise PreventUpdate()

def sir_build(model_id):
    return html.Div(
        html.Div([
                html.Div([html.Button('Random', id=id_sir_button_random, style=designs.but)], style=designs.col),
                html.Div([html.Button('Step', id=id_sir_button_step, style=designs.but)], style=designs.col),
                html.Div([html.Button('One', id=id_sir_button_one, style=designs.but)], style=designs.col),
                html.Div([build_step_slider(
                    id_sir_slider_steps_value, id_sir_slider_steps, 'Steps')], style=designs.col),
                html.Div([build_prob_slider(
                    id_sir_slider_prob_value, id_sir_slider_prob)]),
                html.Div([build_infection_slider(
                    id_sir_slider_itime_value, id_sir_slider_itime)], style=designs.col),
            ] + build_visual_selector(model_sir, id=id_sir_dropdown),
            style=designs.row,
            id={'type': model_sir['id'], 'index': model_sir['id']}
        ),
        id={'type': 'specific', 'index': model_id},
        style={'display': 'none'}
    )

def sir_tracer(graph, node_x, node_y, node_ids):
    """ Generates the SIS tracer """
    return generate_trace(graph, node_x, node_y, node_ids, 'sir', 'SIR', 'Bluered')

visual_sir = {
    'id': 'tracer_sir',
    'name': 'State Tracer',
    'tracer': sir_tracer,
}

model_sir = {
    'id': 'sir',
    'name': 'SIR',
    'gen': sir_tracer,
    'ui': lambda: sir_build(model_sir['id']),
    'type': 'd',
    'weighted': False,
    'key': 'sir',
    'actions': sir_build_actions(),
    'callbacks': sir_build_callbacks,
    'update': sir_update,
    'session-actions': 'session-actions-sir',
    'session-tracer': 'session-tracer-sir',
    'visual_default': visual_connections['id'],
    'visuals': { model['id']: model for model in [
        visual_connections, visual_sir
    ]},
}

if __name__ == '__main__':
    print('model: SIR')