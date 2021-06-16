

import dash_html_components as html
import dash_core_components as dcc

import src.designs as designs

def build_visual_selector(model, id):
    if len(model['visuals']) > 0:
        print(model['visuals'])
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