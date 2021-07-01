
from math import gcd

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
from src.models import DiscreteState, stochastic_callback, addMinRequirements, init_value
import src.designs as designs

from src.visual import *
from src.visual_connections import visual_connections

id_thw_button_random = 'thw-button-random'
id_thw_button_step = 'thw-button-step'
id_thw_button_stochastic = 'thw-button-stochastic'
id_thw_button_convert = 'thw-button-convert'

id_thw_dropdown = 'thw-dropdown'
id_thw_slider_steps = 'thw-slider-steps'
id_thw_slider_steps_value = 'thw-slider-steps-value'
id_thw_modal = 'thw-init'
id_thw_modal_generate = 'thw-init-generate'
id_thw_modal_init_slider = 'thw-init-slider'

action_thw_random = 'action_thw_random'
action_thw_stochastic = 'action_thw_stochastic'
action_thw_step = 'action_thw_step'
action_thw_convert = 'action_thw_step'
action_thw_visual = 'action_thw_visual'
action_thw_init = 'action_thw_init'

def thw_update(data, args):
    graph = data['graph']
    thw_key, thw_th_key, thw_weight_key = model_thw['key'], 'thu_th', 'weight'
    for i in range(args['steps']):
        update_dict = {}
        for srcNode, adjacency in graph.adjacency():
            count = 0.0
            for dstNode, edge in adjacency.items():
                if graph.nodes[dstNode][thw_key] > 0.5:
                    count += edge['weight']
            update_dict[srcNode] = 0 if count <= srcNode[thw_th_key] else 1

        # applies the update dictionary
        for key, value in update_dict.items():
            graph.nodes[key][thw_key] = value
    return data

def thw_convert(data, args):
    new_graph = convert(data['graph'],
        'thu_th', 'weight', model_thw['key'])
    data['graph'] = addMinRequirements(new_graph)
    return data

def convert(graph, thresholdKey, weightKey, valueKey):
    outGraph = nx.empty_graph()

    base = 10 ** 3
    edgeIdx, nodeIdx = 0, 0

    for nd, data in graph.nodes(data=True):
        # adds the node with the data key
        outGraph.add_nodes_from([(nd, {valueKey: data[valueKey]})])

    for src, adjacency in graph.adjacency():
        # gets an integer representation of the threshold
        threshold = int(graph.nodes[src][thresholdKey] * base)

        # calculates the LCM of the threshold and all the outgoing edges
        lcm = threshold
        for dst, edgeData in adjacency.items(): # all adjacent nodes
            weight = int(edgeData[weightKey] * base)
            lcm = lcm * weight // gcd(lcm, weight)

        for dst, edgeData in adjacency.items(): # all adjacent nodes
            # calculates the weight in digit count
            weight = int(edgeData[weightKey] * base)

            # adds the node constructs
            for i in range(lcm // weight):
                t1, t2, b = f'f_{edgeIdx}_{i}_0', f'f_{edgeIdx}_{i}_1', f'b_{edgeIdx}_{i}'
                outGraph.add_nodes_from([
                    (t1, {valueKey: 0}),
                    (t2, {valueKey: 0}),
                    (b, {valueKey: 0}),
                ])
                # adds the connecting 
                outGraph.add_edges_from([
                    (t1, src), (t2, src),
                    (b, t1), (b, t2),
                    (dst, b)
                ])

            # adds the counter nodes to the source
            for i in range(2 * (lcm // weight)):
                counterNode = f'c_{edgeIdx}_{i}'
                outGraph.add_nodes_from([(counterNode, {valueKey: 1})])
                outGraph.add_edge(counterNode, src)

            # adds the threshold nodes to the destination
            for i in range(lcm // threshold):
                counterNode = f't_{edgeIdx}_{i}'
                outGraph.add_nodes_from([(counterNode, {valueKey: 0})])
                outGraph.add_edge(counterNode, dst)
            edgeIdx += 1
    return outGraph        

def thw_random(data, args):
    state = DiscreteState([0, 1])
    for node, data_node in data['graph'].nodes(data=True):
        data_node[model_thw['key']] = state.random()
    return data

def thw_build_actions():
    return {
        action_thw_random: thw_random, 
        action_thw_step: thw_update,
        action_thw_stochastic: stochastic_callback,
        action_thw_convert: thw_convert,
        action_thw_init: lambda data, args: init_value(data, args, model_thw['key']),
    }

def thw_build_callbacks(app):
    build_step_callback(app, id_thw_slider_steps_value, id_thw_slider_steps, 'Steps')
    build_init_callback(app, id_thw_modal, id_thw_modal_init_slider, 'Threshold Weighted')

    @app.callback(
        dp.Output(model_thw['session-tracer'], 'data'),
        dp.Input(id_thw_dropdown, 'value'))
    def tracer_callback(value):
        return [model_thw['id'], value]

    @app.callback(
        dp.Output(model_thw['session-actions'], 'data'),
        dp.Input(id_thw_button_random, 'n_clicks'),
        dp.Input(id_thw_button_stochastic, 'n_clicks'),
        dp.Input(id_thw_button_step, 'n_clicks'),
        dp.Input(id_thw_button_convert, 'n_clicks'),
        dp.Input(id_thw_modal_generate, 'n_clicks'),
        dp.State(id_thw_modal_init_slider, 'value'),
        dp.State(id_thw_slider_steps, 'value'))
    def callback(n1, n2, n3, n4, n5, init, steps):
        ctx = dash.callback_context
        if not ctx.triggered: return []
        source = ctx.triggered[0]['prop_id'].split('.')[0]
        args = {'steps': steps, 'init': init}
        ac = {
            id_thw_button_random: action_thw_random,
            id_thw_button_stochastic: action_thw_stochastic,
            id_thw_button_step: action_thw_step,
            id_thw_button_convert: action_thw_convert,
            id_thw_modal_generate: action_thw_init,
        }
        if source in ac:
            return [(model_thw['id'], ac[source], args)]
        print(f'THW callback: Could not find property with source: {source}')
        raise PreventUpdate()

def threshold_weighted_build(model_id):
    return html.Div(
        html.Div([
                build_init_modal(
                    id_thw_modal, id_thw_modal_init_slider,
                    id_thw_modal_generate, model_thw['name'],
                    0, 1, 1, 0
                ),
                build_init_button(id_thw_modal),
                html.Div([html.Button('Random', id=id_thw_button_random, style=designs.but)], style=designs.col),
                html.Div([html.Button('Stochastic', id=id_thw_button_stochastic, style=designs.but)], style=designs.col),
                html.Div([html.Button('Step', id=id_thw_button_step, style=designs.but)], style=designs.col),
                html.Div([html.Button('Convert', id=id_thw_button_convert, style=designs.but)], style=designs.col),
                html.Div([build_step_slider(
                    id_thw_slider_steps_value, id_thw_slider_steps, 'Steps')], style=designs.col)
            ] + build_visual_selector(model_thw, id=id_thw_dropdown),
            style=designs.row,
            id={'type': model_thw['id'], 'index': model_thw['id']}
        ),
        id={'type': 'specific', 'index': model_id},
        style={'display': 'none'}
    )

def threshold_weighted_tracer(graph, node_x, node_y, node_ids):
    """ Generates the uniform threshold tracer """
    return generate_trace(graph, node_x, node_y, node_ids,
        model_thw['key'], model_thw['name'], 'Bluered')

tracer_weighted_threshold = {
    'id': 'tracer_threshold',
    'name': 'State Tracer',
    'tracer': threshold_weighted_tracer,
}

def thw_th_tracer(graph, node_x, node_y, node_ids):
    return generate_trace(graph, node_x, node_y, node_ids, 'thw_th', 'Threshold', 'Bluered')

tracer_thw_th = {
    'id': 'tracer_thw_thw_th',
    'name': 'Threshold Tracer',
    'tracer': thw_th_tracer
}

model_thw = {
    'id': 'threshold_weighted',
    'name': 'Weighted Threshold',
    'ui': lambda: threshold_weighted_build(model_thw['id']),
    'type': 'u',
    'weighted': True,
    'key': 'thw',
    'actions': thw_build_actions(),
    'callbacks': thw_build_callbacks,
    'update': threshold_weighted_tracer,
    'session-actions': 'session-actions-thw',
    'session-tracer': 'session-tracer-thw',
    'visual_default': tracer_weighted_threshold['id'],
    'visuals': { model['id']: model for model in [
        visual_connections, tracer_weighted_threshold, tracer_thw_th
    ]},
}

if __name__ == '__main__':
    print('model: Threshold Weighted')