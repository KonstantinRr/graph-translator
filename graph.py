#!/usr/bin/env python3

import argparse

from src import graph
from src import models

import networkx as nx

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Dash - opinion diffusion tool')
    parser.add_argument('--host', type=str, default='0.0.0.0',
        help='an integer for the accumulator')
    parser.add_argument('--port', type=int, default=8080,
        help='Port that the server is using (default: 8080)')
    parser.add_argument('--threads', type=int, default=16,
        help='Number of threads the server is using (default: 16)')
    parser.add_argument('--release', action='store_true')

    args = vars(parser.parse_args())

    if args['release']:
        print(f'Running server in release mode: {args.get("host")}:{args.get("port")}')
        from waitress import serve
        serve(graph.app.server, host=args['host'], port=args['port'], threads=args['threads'])
    else:
        print('Running server in development mode')
        graph.app.run_server(debug=True)
        print('Done')