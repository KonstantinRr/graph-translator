

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

def build_prob_callback(app, id_value, id_slider):
    @app.callback(
        dp.Output(id_value, 'children'),
        dp.Input(id_slider, 'value'))
    def slider_update(value):
        return f'Probability {value}'

def build_prob_slider(id_value, id_slider, default=0.05):
    return html.Div(
        [
            html.Div('Probability', id=id_value, style={'padding-left': '30px'}),
            dcc.Slider(
                id=id_slider,
                min=0.0, max=1.0, step=0.05, value=0.05
            ),
        ],
        style={'width': '200px'}
    )

def build_infection_callback(app, id_value, id_slider):
    @app.callback(
        dp.Output(id_value, 'children'),
        dp.Input(id_slider, 'value'))
    def slider_update(value):
        return f'Infection Time {value}'

def build_infection_slider(id_value, id_slider):
    return html.Div(
        [
            html.Div('Infection Time', id=id_value, style={'padding-left': '30px'}),
            dcc.Slider(
                id=id_slider,
                min=1, max=100, step=1, value=20
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