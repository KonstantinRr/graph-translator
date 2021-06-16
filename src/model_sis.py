
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

from src.visual import build_visual_selector
from src.visual_connections import visual_connections

def sis_update(graph, steps=1):
    pass

def sis_actions():
    return {}

def sis_build_callbacks(app):
    pass

def sis_build(model_id):
    return html.Div([], id={'type': 'specific', 'index': model_id}, style={'display': 'none'})

def sis_tracer(graph, node_x, node_y):
    """ Generates the SIS tracer """
    return generate_trace(graph, node_x, node_y, 'sis', 'SIS', 'Bluered')


model_sis = {
    'id': 'sis',
    'name': 'SIS',
    'gen': sis_tracer,
    'ui': lambda: sis_build('sis'),
    'type': 'd',
    'key': 'sis',
    'actions': sis_actions(),
    'callbacks': sis_build_callbacks,
    'state': DiscreteState([0, 2]),
    'update': sis_update,
    'visual_default': visual_connections['id'],
    'visuals': {
        visual_connections['id']: visual_connections,
    }
}
