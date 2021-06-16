

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

id_threshold_dropdown = 'threshold-dropdown'

def threshold_update(graph, steps=1):
    pass

def threshold_uniform_actions():
    return {}

def threshold_uniform_build_callbacks(app):
    pass

def threshold_uniform_build(model_id):
    return html.Div([], id={'type': 'specific', 'index': model_id}, style={'display': 'none'})

def threshold_uniform_tracer(graph, node_x, node_y):
    """ Generates the uniform threshold tracer """
    return generate_trace(graph, node_x, node_y, 'thu', 'Uniform Threshold', 'Bluered')

model_threshold_uniform = {
    'id': 'threshold_uniform',
    'name': 'Threshold',
    'gen': threshold_uniform_tracer,
    'ui': lambda: threshold_uniform_build('threshold_uniform'),
    'type': 'u',
    'key': 'thu',
    'actions': threshold_uniform_actions,
    'callbacks': threshold_uniform_build_callbacks,
    'state': DiscreteState([0, 1]),
    'update': threshold_update,
    'visual_default': visual_connections['id'],
    'visuals': {
        visual_connections['id']: visual_connections,
    }
}