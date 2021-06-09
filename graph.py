
# Python standard lib
import uuid
import json
import random

import plotly.graph_objects as go
import networkx as nx

import dash
import dash.dependencies as dp
import dash_core_components as dcc
import dash_bootstrap_components as dbc
import dash_html_components as html
from dash.exceptions import PreventUpdate

# data packages
import pandas as pd
import numpy as np

from addEdge import addEdge
from tracer import *
from models import *

def randomGraph(nodes=200, connect=0.125):
    graph = nx.random_geometric_graph(nodes, connect)
    #graph = nx.gn_graph(nodes)
    #nx.stochastic_graph(graph)
    return graph

def updateLayout(graph, layoutAlgorithm, default=None):
    if layoutAlgorithm == 'bipartite_layout':
        return nx.bipartite_layout(graph, x.bipartite.sets(graph)[0])
    elif layoutAlgorithm == 'circular_layout':
        return nx.circular_layout(graph)
    elif layoutAlgorithm == 'kamada_kawai_layout':
        return nx.kamada_kawai_layout(graph)
    elif layoutAlgorithm == 'planar_layout':
        return nx.planar_layout(graph)
    elif layoutAlgorithm == 'random_layout':
        return nx.random_layout(graph)
    elif layoutAlgorithm == 'shell_layout':
        return nx.shell_layout(graph)
    elif layoutAlgorithm == 'spring_layout':
        return nx.spring_layout(graph)
    elif layoutAlgorithm == 'spectral_layout':
        return nx.spectral_layout(graph)
    elif layoutAlgorithm == 'spiral_layout':
        return nx.spiral_layout(graph)
    elif layoutAlgorithm == 'default' or layoutAlgorithm is None:
        return {} if default is None else updateLayout(graph, default)
    else:
        print('Unknown Layout algorithm!', layoutAlgorithm)
        return {} if default is None else updateLayout(graph, default)

def generateFigure(graph, graphLayout, graphType):
    if graphType in dropdown_model:
        if isinstance(graph, nx.DiGraph) and dropdown_model[graphType][2] == 'u':
            graph = graph.to_undirected(as_view=True)
        elif isinstance(graph, nx.Graph) and dropdown_model[graphType][2] == 'd':
            graph = graph.to_directed(as_view=True)            

    edge_x, edge_y = [], []
    node_x, node_y = [], []
    edge_cx, edge_cy = [], []
    weights = []
    directed = isinstance(graph, nx.DiGraph)
    if directed:
        for edge in graph.edges(data=True):
            start = (graphLayout[edge[0]] if edge[0] in graphLayout else graph.nodes[edge[0]]['pos'])
            end = (graphLayout[edge[1]] if edge[1] in graphLayout else graph.nodes[edge[1]]['pos'])
            edge_x, edge_y = addEdge(start, end, edge_x, edge_y, 1.0, 'end', .01, 15, 12)
            if 'weight' in edge[2]:
                edge_cx.append((start[0] / 3 + end[0] * (2.0 / 3.0)))
                edge_cy.append((start[1] / 3 + end[1] * (2.0 / 3.0)))
                weights.append(str(edge[2]['weight']))
    else:
        for edge in graph.edges(data=True):
            x0, y0 = (graphLayout[edge[0]] if edge[0] in graphLayout else graph.nodes[edge[0]]['pos'])
            x1, y1 = (graphLayout[edge[1]] if edge[1] in graphLayout else graph.nodes[edge[1]]['pos'])
            edge_x.extend((x0, x1, None))
            edge_y.extend((y0, y1, None))

            if 'weight' in edge[2]:
                edge_cx.append((x0 + x1) / 2)
                edge_cy.append((y0 + y1) / 2)
                weights.append(str(edge[2]['weight']))


    for node in graph.nodes():
        x, y = (graphLayout[node] if node in graphLayout else graph.nodes[node]['pos'])
        node_x.append(x)
        node_y.append(y)

    edge_trace = go.Scatter(
        x=edge_x, y=edge_y,
        line=dict(width=0.5, color='#888'),
        hoverinfo='text',
        mode='lines',
    )

    edge_text_trace = go.Scatter(
        x=edge_cx, y=edge_cy,
        mode='markers',
        hoverinfo='text',
    )
    edge_text_trace.text = weights

    if graphType in dropdown_model:
        node_trace = dropdown_model[graphType][1](graph, node_x, node_y)
    else:
        print(f'Unknown graph type {graphType}')
        node_trace = generateConnectionTracer(graph, node_x, node_y)


    fig = go.Figure(
        data=[edge_trace, node_trace, edge_text_trace],
        layout=go.Layout(
            title='Network Graph Translator',
            titlefont_size=16,
            showlegend=False,
            hovermode='closest',
            margin=dict(b=0, l=0, r=0, t=60),
            annotations=[
                dict(
                    text="UNIVERSITY OF GRONINGEN | Konstantin Rolf",
                    showarrow=False,
                    xref="paper", yref="paper",
                    x=0.005, y=-0.002
                )
            ],
            xaxis=dict(showgrid=False, zeroline=False, showticklabels=False),
            yaxis=dict(showgrid=False, zeroline=False, showticklabels=False)
        )
    )
    return fig



fig_names = [
    ('bipartite_layout', 'bipartite_layout'),
    ('circular_layout', 'circular_layout'),
    ('kamada_kawai_layout', 'kamada_kawai_layout'),
    ('planar_layout', 'planar_layout'),
    ('random_layout', 'random_layout'),
    ('shell_layout', 'shell_layout'),
    ('spring_layout', 'spring_layout'),
    ('spectral_layout', 'spectral_layout'),
    ('spiral_layout', 'spiral_layout'),
    ('default', 'default'),
]

class DiscreteState:
    def __init__(self, values):
        self.values = values

    def random(self):
        return random.choice(self.values)

class ContinuesState:
    def __init__(self, start, end):
        self.start = start
        self.end = end

    def random(self, count=1):
        return [random.random() * (self.end - self.start) + self.start
            for _ in range(count)]


dropdown_model = {
    'connections': ('Connections', generateConnectionTracer, 'u', 'con', ContinuesState(0, 100000), updateDeGroot),
    'degroot': ('DeGroot', generateDeGrootTracer, 'd', 'deg', ContinuesState(0.0, 1.0), updateDeGroot),
    'threshold_uniform': ('Threshold', generateUniformThresholdTracer, 'u', 'thu', DiscreteState([0, 1]), updateDeGroot),
    'threshold_weighted': ('Weighted Threshold', generateWeightedThresholdTracer, 'd', 'thw', DiscreteState([0, 1]), updateDeGroot),
    'sis': ('SIS', generateSISTracer, 'd', 'sis', DiscreteState([0, 2]), updateDeGroot),
    'sir': ('SIR', generateSIRTracer, 'd', 'sir', DiscreteState([0, 2]), updateDeGroot),
    'social': ('Social Choice', generateSocialChoiceTracer, 'u', 'soc', DiscreteState([0, 2]), updateDeGroot),
}

def addMinRequirements(graph, layout):
    def update(node, key, value):
        if key not in node[1]:
            node[1][key] = value


    graphLayout = None
    for node in graph.nodes(data=True):
        if 'pos' not in node[1]:
            if graphLayout is None:
                graphLayout = updateLayout(graph, layout, default='spring_layout')
            data = graphLayout[node[0]]
            node[1]['pos'] = (data[0], data[1])

        update(node, 'thu', 0.0)
        update(node, 'thw_wei', 0.5)
        update(node, 'thw', 0.0)
        update(node, 'thw_wei', 0.5)

        update(node, 'deg', 0)
        update(node, 'sis', 0)
        update(node, 'sir', 0)
        update(node, 'soc', 0)

    for edge in graph.edges(data=True):
        if 'weight' not in edge[2]:
            edge[2]['weight'] = 1    
    return {} if graphLayout is None else graphLayout

def performStep(graph, modelType, steps=1):
    model = dropdown_model.get(modelType)
    if model is not None:
        model[5](graph, steps)
    else:
        print(f'Unknown type {model}')


def randomSetup(graph, modelType, prob=1.0):
    model = dropdown_model.get(modelType)
    if model is not None:
        key = model[3]
        state = model[4]
        for node in graph.nodes(data=True):
            if random.random() <= prob:
                node[1][key] = state.random()

class intlist: pass

graph_gens = {
    'balanced_tree': ('Balanced Tree', ('r', 'h'), (int, int), (3, 3), lambda r, h: nx.balanced_tree(r, h), 'balanced_tree(r, h)', 'Returns the perfectly balanced r-ary tree of height h.'),
    'barbell_graph': ('Barbell Graph', ('m1', 'm2'), (int, int), (3, 3), lambda m1, m2: nx.barbell_graph(m1, m2), 'barbell_graph(m1, m2)', 'Returns the Barbell Graph: two complete graphs connected by a path.'),
    'binomial_tree': ('Binomial Tree', ('n',), (int,), (3,), lambda n: nx.binomial_tree(n), 'binomial_tree(n)', 'Returns the Binomial Tree of order n.'),
    'complete_graph': ('Complete Graph', ('n',), (int,), (3,), lambda n: nx.complete_graph(n), 'complete_graph(n)', 'Return the complete graph K_n with n nodes.'),
    'complete_multipartite_graph': ('Complete Multipartite Graph', ('sizes',), (intlist,), ([3, 4],), lambda sizes: nx.complete_multipartite_graph(sizes), 'complete_multipartite_graph(*subset_sizes)', 'Returns the complete multipartite graph with the specified subset sizes.'),
    'circular_ladder_graph': ('Circular Ladder Graph', ('n',), (int,), (3,), lambda n: nx.circular_ladder_graph(n), 'circular_ladder_graph(n)', 'Returns the circular ladder graph 𝐶𝐿𝑛 of length n.'),
    'circulant_graph': ('Circulant Graph', ('n', 'offsets'), (int, intlist), (3, [4, 5]), lambda n, offsets: nx.circulant_graph(n, offsets), 'circulant_graph(n, offsets)', 'Generates the circulant graph 𝐶𝑖𝑛(𝑥1,𝑥2,...,𝑥𝑚) with 𝑛 vertices.'),
    'cycle_graph': ('Cycle Graph', ('n',), (int,), (3,), lambda n: nx.cycle_graph(n), 'cycle_graph(n)', 'Returns the cycle graph Cn of cyclically connected nodes.'),
    'dorogovtsev_goltsev_mendes_graph': ('Dorogovtsev Goltsev Mendes Graph', ('n',), (int,), (3,), lambda n: nx.dorogovtsev_goltsev_mendes_graph(n), 'dorogovtsev_goltsev_mendes_graph(n)', 'Returns the hierarchically constructed Dorogovtsev-Goltsev-Mendes graph.'),
    'empty_graph': ('Empty Graph', ('n',), (int,), (3,), lambda n: nx.empty_graph(n), 'empty_graph(n)', 'Returns the empty graph with n nodes and zero edges.'),
    'full_rary_tree': ('Full Rary Tree', ('r', 'n'), (int, int), (3, 3), lambda r, n: nx.full_rary_tree(r, n), 'full_rary_tree(r, n)', 'Creates a full r-ary tree of n vertices.'),
    'ladder_graph': ('Ladder Graph', ('n',), (int,), (3,), lambda n: nx.ladder_graph(n), 'ladder_graph(n)', 'Returns the Ladder graph of length n.'),
    'lollipop_graph': ('Lollipop Graph', ('m', 'n'), (int, int), (3, 3), lambda m, n: nx.lollipop_graph(m, n), 'lollipop_graph(m, n)', 'Returns the Lollipop Graph; K_m connected to P_n.'),
    'null_graph': ('Null Graph', (), (), (), lambda: nx.null_graph(), 'null_graph()', 'Returns the Null graph with no nodes or edges.'),
    'path_graph': ('Path Graph', ('n',), (int,), (3,), lambda n: nx.path_graph(n), 'path_graph(n)', 'Returns the Path graph P_n of linearly connected nodes.'),
    'star_graph': ('Star Graph', ('n',), (int,), (3,), lambda n: nx.star_graph(n), 'star_graph(n)', 'Return the star graph'),
    'trivial_graph': ('Trivial Graph', (), (), (), lambda: nx.trivial_graph(), 'trivial_graph()', 'Return the Trivial graph with one node (with label 0) and no edges.'),
    'turan_graph': ('Turan Graph', ('n', 'r'), (int, int), (3, 3), lambda n, r: nx.turan_graph(n, r), 'turan_graph(n, r)', 'Return the Turan Graph'),
    'wheel_graph': ('Wheel Graph', ('n',), (int,), (3,), lambda n: nx.wheel_graph(n), 'wheel_graph(n)', 'Return the wheel graph'),
}

external_stylesheets = [
    dbc.themes.BOOTSTRAP,
    'https://codepen.io/chriddyp/pen/bWLwgP.css', # Dash CSS
    'https://codepen.io/chriddyp/pen/brPBPO.css', # Loading screen CSS
]
app = dash.Dash(external_stylesheets=external_stylesheets)
app.config.suppress_callback_exceptions = True

col = {
    'display': 'table-cell'
}
row = {
    'display': 'table',
    'table-layout': 'fixed',
    'border-spacing': '10px',
}

def serveLayout():
    session_id = str(uuid.uuid4())
    graph = randomGraph()
    addMinRequirements(graph, 'default')

    but = {
        'height': '50px',
        'text-align': 'center',
        'display': 'inline-block',
    }

    return html.Div([
        html.Div([
            dbc.Modal(
                [
                    dbc.ModalHeader("Header"),
                    dbc.ModalBody([
                        dcc.Dropdown(
                            id='modal-gen-dropdown',
                            options=[{'label': y[0], 'value': x} for x, y in graph_gens.items()],
                            value=None,
                            style={'left': '0px', 'right': '0px'}
                        ),
                        html.Div([], id='modal-gen-comp', style=col)
                    ]),
                    dbc.ModalFooter([
                        dbc.Button("Close", id="modal-gen-close", className="ml-auto", style={'width': '10em'}),
                        dbc.Button("Generate", id="modal-gen-generate", className="ml-auto", style={'width': '10em'})
                    ], style={'margin-left': 'auto', 'margin-right': '0'}),
                ],
                id="modal",
            )
        ]),
        dcc.Store(data=session_id, id='session-id'),
        dcc.Store(data=json.loads(nx.jit_data(graph)), id='session-graph'),
        html.Div([
            html.Div([html.Button('Random', id='button', style=but)], style=col),
            html.Div([html.Button('Generate', id='modal-gen-open', style=but)], style=col),
            html.Div([html.Button('Convert', id='button-conv', style=but)], style=col),
            html.Div([html.Button('Step', id='button-step', style=but)], style=col),
            html.Div([html.Button('Random Setup', id='button-random-setup', style=but)], style=col),
        ], style=row),
        html.Div([
            html.Div([dcc.Dropdown(
                id='dropdown-layout',
                options=[{'label': x[1], 'value': x[0]} for x in fig_names],
                value=None,
                style={'width': '40vw'}
            )], style=row),
            html.Div([dcc.Dropdown(
                id='dropdown-model',
                options=[{'label': y[0], 'value': x} for x, y in dropdown_model.items()],
                value=None,
                style={'width': '40vw'}
            )], style=col),
        ], style=row),
        dcc.Loading(
            id="loading-1",
            type="default",
            children=dcc.Graph(
                id='basic-graph',
                figure=generateFigure(graph, {}, 'connections'),
                style={"height" : "90vh", "width" : "90vw", "background-color":'white'}
            )
        ),

        # modal layouts
    ])
app.layout = serveLayout


"""
@app.callback(
[dp.Output("progress", "value"), dp.Output("progress", "children")],
[dp.Input("progress-interval", "n_intervals")])
def update_progress(n):
    return 50, ''
"""

@app.callback(
    dp.Output('modal-gen-comp', 'children'),
    dp.Input('modal-gen-dropdown', 'value'))
def update_modal_gen(inp):
    data = graph_gens.get(inp)
    if data is None: return 'Unknown'
    print(data)

    return [
        # data[1]: values[0]: values 
        # data[2]: values[1]: classes
        # data[3]: values[2]: defaults
        html.Div([
            html.Div('Input {}'.format(values[0]), style={'padding-right': '10px'}),
            dcc.Input(
                id={
                    'type': 'modal-gen-input',
                    'index': idx
                },
                type='number',
                placeholder='{}'.format(values[2])
            )
        ]) for idx, values in enumerate(zip(data[1], data[2], data[3]))
        
    ]

@app.callback(
    dp.Output("modal", "is_open"),
    [dp.Input("modal-gen-open", "n_clicks"), dp.Input("modal-gen-close", "n_clicks")],
    [dp.State("modal", "is_open")])
def toggle_modal(n1, n2, is_open):
    if n1 or n2:
        return not is_open
    return is_open


@app.callback(
[
    dp.Output('session-graph', 'data'),
    dp.Output('basic-graph', 'figure'),
],
[
    dp.Input('session-graph', 'data'),
    dp.Input('button', 'n_clicks'),
    dp.Input('modal-gen-generate', 'n_clicks'),
    dp.Input('dropdown-layout', 'value'),
    dp.Input('dropdown-model', 'value'),
    dp.Input('modal-gen-dropdown', 'value'),
    dp.Input({'type': 'modal-gen-input', 'index': dp.ALL}, 'value'),
    dp.Input('button-step', 'n_clicks'),
    dp.Input('button-conv', 'n_clicks'),
    dp.Input('button-random-setup', 'n_clicks')
])
def update_output_div(graph_json, n_clicks, n_clicks_modal, layout_name, model_name, graphGenType, graphGenInput, stepNClicks, convNClicks, randomSetupNClicks):
    ctx = dash.callback_context
    if not ctx.triggered:
        graph = nx.jit_graph(graph_json)
        return graph_json, generateFigure(graph, {}, model_name)

    source = ctx.triggered[0]['prop_id'].split('.')[0]
    if source == 'dropdown-layout':
        print(f'Changing layout to {layout_name}')
        graph = nx.jit_graph(graph_json)
        graphLayout = updateLayout(graph, layout_name)
        return graph_json, generateFigure(graph, graphLayout, model_name)
    elif source == 'dropdown-model':
        print(f'Changing model type to {model_name}')
        graph = nx.jit_graph(graph_json)
        graphLayout = updateLayout(graph, layout_name)
        return graph_json, generateFigure(graph, graphLayout, model_name)
    elif source == 'button':
        print(f'Regenerating graph with layout {layout_name}')
        graph = randomGraph()
        graphLayout = addMinRequirements(graph, layout_name)
        return json.loads(nx.jit_data(graph)), generateFigure(graph, graphLayout, model_name)
    elif source == 'button-step':
        # perform a new step
        graph = nx.jit_graph(graph_json)
        performStep(graph, model_name)
        graphLayout = updateLayout(graph, layout_name)
        return json.loads(nx.jit_data(graph)), generateFigure(graph, graphLayout, model_name)
    elif source == 'button-conv':
        graph = nx.jit_graph(graph_json)
        graphLayout = updateLayout(graph, layout_name)
        return json.loads(nx.jit_data(graph)), generateFigure(graph, graphLayout, model_name)
    elif source == 'button-random-setup':
        graph = nx.jit_graph(graph_json)
        randomSetup(graph, model_name)
        graphLayout = updateLayout(graph, layout_name)
        return json.loads(nx.jit_data(graph)), generateFigure(graph, graphLayout, model_name)
    elif source == 'modal-gen-generate':
        graph_gen = graph_gens.get(graphGenType)
        if graph_gen is None:
            print(f'Could not find graph type {graph_gen}')
        else:
            inputs = [value if value is not None else graph_gen[3][idx]
                for idx, value in enumerate(graphGenInput)]
            print(f'Generating new graph with layout {graphGenType} with input {inputs}')
            graph = graph_gen[4](*inputs)
            graphLayout = addMinRequirements(graph, layout_name)
            #nx.set_node_attributes(graph, graphLayout, 'pos')
            return json.loads(nx.jit_data(graph)), generateFigure(graph, graphLayout, model_name)


    print(f'Could not trigger source: {ctx.triggered}')
    raise PreventUpdate
    #graph = nx.jit_graph(graph_json)

if __name__ == '__main__':
    app.run_server(debug=True)
    print('Done')