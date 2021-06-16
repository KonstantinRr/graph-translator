

import numpy as np
import networkx as nx

import dash
import dash.dependencies as dp
import dash_core_components as dcc
import dash_bootstrap_components as dbc
import dash_html_components as html
from dash.exceptions import PreventUpdate

from src.tracer import generate_trace
import src.designs as designs
from src.models import DiscreteState

from src.visual import build_visual_selector
from src.visual_connections import visual_connections

id_threshold_weighted_dropdown = 'threshold_weighted_dropdown'

def threshold_weighted_update(graph, steps=1):
    pass

def threshold_weighted_actions():
    return {}

def threshold_weighted_build_callbacks(app):
    pass

def threshold_weighted_tracer(graph, node_x, node_y):
    """ Generates the uniform threshold tracer """
    return generate_trace(graph, node_x, node_y, 'thw', 'Weighted Threshold', 'Bluered')

def threshold_weighted_build(model_id):
    return html.Div([
        html.Div([html.Button('Random', id='threshold-button-random', style=designs.but)], style=designs.col),
        html.Div([html.Button('Convert', id='threshold-button-conv', style=designs.but)], style=designs.col),
        html.Div([html.Button('Step', id='threshold-button-step', style=designs.but)], style=designs.col),
    ] + build_visual_selector(model_threshold_weighted, id_threshold_weighted_dropdown),
        id={'type': 'specific', 'index': model_id},
        style={'display': 'none'})

tracer_weighted_threshold = {
    'id': 'tracer_threshold',
    'name': 'Threshold Tracer',
    'tracer': threshold_weighted_tracer,
}

model_threshold_weighted = {
    'id': 'threshold_weighted',
    'name': 'Weighted Threshold',
    'ui': lambda: threshold_weighted_build('threshold_weighted'),
    'type': 'd',
    'key': 'thw',
    'actions': threshold_weighted_actions(),
    'callbacks': threshold_weighted_build_callbacks,
    'state': DiscreteState([0, 1]),
    'update': threshold_weighted_tracer,
    'visual_default': visual_connections['id'],
    'visuals': {
        visual_connections['id']: visual_connections,
        tracer_weighted_threshold['id']: tracer_weighted_threshold,
    }
}