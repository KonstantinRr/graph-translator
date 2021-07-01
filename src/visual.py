
import dash
import dash.dependencies as dp
import dash_html_components as html
import dash_core_components as dcc
import dash_bootstrap_components as dbc

import src.designs as designs

def build_init_modal(id_modal, slider_id, generate_id, text, min, max, step, value):
    return dbc.Modal(
        [
            dbc.ModalHeader('Initialize'),
            dbc.ModalBody([
                html.Div(
                    [
                        html.Div(text, id=f'{slider_id}-value', style={'padding-left': '30px'}),
                        dcc.Slider(
                            id=slider_id,
                            min=min, max=max,
                            step=step, value=value
                        ),
                    ],
                    style={'width': '200px'}
                )
            ]),
            dbc.ModalFooter([
                dbc.Button('Close', id=f'modal-{id_modal}-close', className='ml-auto', style={'width': '10em'}),
                dbc.Button('Generate', id=generate_id, className='ml-auto', style={'width': '10em'})
            ], style={'margin-left': 'auto', 'margin-right': '0'}),
        ],
        id=f'modal-{id_modal}'
    )

def build_init_button(id_modal):
    return html.Div([html.Button(
        'Init', id=f'modal-{id_modal}-open', style=designs.but)], style=designs.col)

def build_init_callback(app, id_modal, slider_id, text):
    @app.callback(
        dp.Output(f'{slider_id}-value', 'children'),
        dp.Input(f'{slider_id}', 'value'))
    def slider_update(value):
        return f'{text} {value}'

    @app.callback(
        dp.Output(f'modal-{id_modal}', 'is_open'),
        dp.Input(f'modal-{id_modal}-open', 'n_clicks'),
        dp.Input(f'modal-{id_modal}-close', 'n_clicks'),
        dp.State(f'modal-{id_modal}', 'is_open'))
    def toggle_modal_init(n1, n2, is_open):
        if n1 or n2:
            return not is_open
        return is_open


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