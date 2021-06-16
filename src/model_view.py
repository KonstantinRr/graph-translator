

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

def view_actions():
    return {}

def view_callbacks(app):
    pass

def view_build(model_id):
    return html.Div([], id={'type': 'specific', 'index': model_id}, style={'display': 'none'})

def threshold_uniform_tracer(graph, node_x, node_y):
    """ Generates the uniform threshold tracer """
    return generate_trace(graph, node_x, node_y, 'thu', 'Uniform Threshold', 'Bluered')

model_threshold_uniform = {
    'id': 'view',
    'name': 'View',
    'ui': lambda: view_build('view'),
    'type': 'u',
    'key': 'thu',
    'actions': view_actions,
    'callbacks': view_callbacks,
    'state': DiscreteState([0, 1]),
    'visual_default': visual_connections['id'],
    'visuals': {
        visual_connections['id']: visual_connections,
    }
}