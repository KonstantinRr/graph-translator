import string
import random

def randAlphaNumeric(length=8):
    return ''.join(random.choice(
        string.ascii_uppercase + string.ascii_lowercase + string.digits
    ) for _ in range(length))

def randName(graph):
    nodeName = randAlphaNumeric(8)
    while nodeName in graph:
        nodeName = randAlphaNumeric(8)
    return nodeName

def get_node_names(selected):
    if selected is None: return []
    return [qq['customdata'] for qq in selected['points']
        if 'customdata' in qq]