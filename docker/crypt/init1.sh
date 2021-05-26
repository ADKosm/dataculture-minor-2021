#!/bin/bash

set -xe

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

mkdir -p crypt

cat > crypt/crypt.py <<END
import sys
from pathlib import Path

from cryptography.fernet import Fernet

key = b'-H5QKgetGkLdGK3eimqnujur0JLr4GUL5L75-E6VdmE='


def main(command, filepath):
    path = Path(filepath)
    assert path.exists(), "No such file {}".format(filepath)
    fnet = Fernet(key)
    with open(filepath, 'rb') as f:
        data = f.read()

    if command == 'encrypt':
        result = fnet.encrypt(data)
    elif command == 'decrypt':
        result = fnet.decrypt(data.decode('utf-8').strip().encode('utf-8'))
    else:
        print("No such command {}".format(command))

    print(result.decode('utf-8'))


if __name__ == "__main__":
    assert len(sys.argv) >= 1, "Not enough arguments. Pass command and path"
    _, command, filepath = sys.argv
    main(command, filepath)
END

cat > crypt/Dockerfile <<END
FROM python:3.7

RUN pip install cryptography

COPY crypt.py /app

ENTRYPOINT ["python3", "/app/crypt.py"]
END
