import dash_html_components as html

import plotly.graph_objects as go

def connection_tracer(graph, node_x, node_y):
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

    node_trace.marker.color = [len(adj[1]) for _, adj in enumerate(graph.adjacency())]
    node_trace.text = ['# of connections: ' + str(len(adj[1]))
        for _, adj in enumerate(graph.adjacency())]
    return node_trace


visual_connections = {
    'id': 'tracer_connections',
    'name': 'Connections',
    'tracer': connection_tracer,
}