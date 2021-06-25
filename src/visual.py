

import dash.dependencies as dp
import dash_html_components as html
import dash_core_components as dcc

import src.designs as designs

def build_step_callback(app, id_value, id_slider, text):
    @app.callback(
        dp.Output(id_value, 'children'),
        dp.Input(id_slider, 'value'))
    def slider_update(value):
        return f'{text} {value}'

def build_step_slider(id_value, id_slider, text):
    return html.Div(
        [
            html.Div(text, id=id_value, style={'padding-left': '30px'}),
            dcc.Slider(
                id=id_slider,
                min=1, max=100, step=1, value=1
            ),
        ],
        style={'width': '200px'}
    )

def build_visual_selector(model, id):
    if len(model['visuals']) > 0:
        return [
            html.Div(
                dcc.Dropdown(
                    id=id,
                    options=[{'label': vis['name'], 'value': vis['id']}
                        for vis in model['visuals'].values()],
                    value=model['visual_default'],
                    style={'width': '40vw'}
                ), style=designs.col
            )
        ]
    return []