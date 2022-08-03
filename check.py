import json
import sys
import re
import platform
import subprocess
from pathlib import Path

ROOT_DIR = Path(__file__).parent


def to_widget(data: str) -> None:
    sys.stdout.buffer.write(data.encode("utf8"))


def ping(host, count: str = "1"):
    param = '-n' if platform.system().lower() == 'windows' else '-c'
    command = ['ping', param, count, host]
    try:
        data_ = subprocess.check_output(command).decode('utf-8')
        pattern = re.compile("\d+(?:[.,]\d+)?")
        for line in data_.split("\n"):
            if "round-trip" in line:
                data_ = dict(zip(['min', 'avg', 'max', 'stddev'], re.findall(pattern, line)))
                data_['host'] = host
                data_['is_alive'] = True
                data_['avg'] = float(data_['avg'])
                del data_['min']
                del data_['max']
                del data_['stddev']

        return data_
    except subprocess.CalledProcessError:
        return {"avg": 999.99, "host": host, "is_alive": False}


def read_list():
    with open(ROOT_DIR /'list.txt', 'r') as f:
        return f.readlines()
    return []


if __name__ == '__main__':
    if data_list := read_list():
        data = [ping(host.strip()) for host in read_list()]
        to_widget(json.dumps(data))
    else:
        to_widget(json.dumps(
            []
        ))
