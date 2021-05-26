docker run -v $(pwd)/torchdata:/data -u root pytorch/torchserve:latest /bin/bash

cd /data
mkdir model_store
torch-model-archiver --model-name densenet161 --version 1.0 --model-file model.py --serialized-file densenet161-8d451a50.pth --export-path model_store --extra-files index_to_name.json --handler image_classifier


curl -O https://raw.githubusercontent.com/pytorch/serve/master/docs/images/kitten_small.jpg
curl http://127.0.0.1:9091/predictions/densenet161 -T kitten_small.jpg
