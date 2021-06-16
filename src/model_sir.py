
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


def sir_update(graph, steps=1):
    pass

def sir_build_actions():
    return {}

def sir_build_callbacks(app):
    pass

def sir_build(model_id):
    return html.Div([], id={'type': 'specific', 'index': model_id}, style={'display': 'none'})

def sir_tracer(graph, node_x, node_y):
    """ Generates the SIS tracer """
    return generate_trace(graph, node_x, node_y, 'sis', 'SIS', 'Bluered')


model_sir = {
    'id': 'sir',
    'name': 'SIR',
    'gen': sir_tracer,
    'ui': lambda: sir_build('sir'),
    'type': 'd',
    'key': 'sir',
    'actions': sir_build_actions(),
    'callbacks': sir_build_callbacks,
    'state': DiscreteState([0, 2]),
    'update': sir_update,
    'visual_default': visual_connections['id'],
    'visuals': {
        visual_connections['id']: visual_connections,
    }
}