import plotly.graph_objects as go

# colorscale options
#'Greys' | 'YlGnBu' | 'Greens' | 'YlOrRd' | 'Bluered' | 'RdBu' |
#'Reds' | 'Blues' | 'Picnic' | 'Rainbow' | 'Portland' | 'Jet' |
#'Hot' | 'Blackbody' | 'Earth' | 'Electric' | 'Viridis' |

def generateConnectionTracer(graph, node_x, node_y):
    node_trace = go.Scatter(
        x=node_x, y=node_y,
        mode='markers',
        hoverinfo='text',
        marker=dict(
            showscale=True,
            colorscale='YlGnBu',
            reversescale=True,
            color=[],
            size=10,
            colorbar=dict(
                thickness=15,
                title='Node Connections',
                xanchor='left',
                titleside='right'
            ),
            line_width=2
        )
    )


    node_adjacencies = []
    node_text = []
    for node, adjacencies in enumerate(graph.adjacency()):
        node_adjacencies.append(len(adjacencies[1]))
        node_text.append('# of connections: ' + str(len(adjacencies[1])))

    node_trace.marker.color = node_adjacencies
    node_trace.text = node_text
    return node_trace

def _generateThresholdTrace(graph, node_x, node_y, key, title, color):
    node_trace = go.Scatter(
        x=node_x, y=node_y,
        mode='markers',
        hoverinfo='text',
        marker=dict(
            showscale=True,
            colorscale=color,
            reversescale=True,
            color=[],
            size=10,
            colorbar=dict(
                thickness=15,
                title=title,
                xanchor='left',
                titleside='right'
            ),
            line_width=2
        )
    )

    node_trace.marker.color = [node[1][key] for node in graph.nodes(data=True)]
    node_trace.text = [str(node[1][key]) for node in graph.nodes(data=True)]
    return node_trace

def generateUniformThresholdTracer(graph, node_x, node_y):
    return _generateThresholdTrace(graph, node_x, node_y, 'thu', 'Uniform Threshold', 'Bluered')

def generateWeightedThresholdTracer(graph, node_x, node_y):
    return _generateThresholdTrace(graph, node_x, node_y, 'thw', 'Weighted Threshold', 'Bluered')

def generateSocialChoiceTracer(graph, node_x, node_y):
    return _generateThresholdTrace(graph, node_x, node_y, 'soc', 'Social Choice', 'Bluered')

def generateDeGrootTracer(graph, node_x, node_y):
    return _generateThresholdTrace(graph, node_x, node_y, 'deg', 'DeGroot', 'YlGnBu')

def generateSISTracer(graph, node_x, node_y):
    return _generateThresholdTrace(graph, node_x, node_y, 'sis', 'SIS', 'Bluered')

def generateSIRTracer(graph, node_x, node_y):
    return _generateThresholdTrace(graph, node_x, node_y, 'sir', 'SIR', 'Bluered')