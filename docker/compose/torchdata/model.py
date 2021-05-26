from torchvision.models.densenet import DenseNet


class ImageClassifier(DenseNet):
    def __init__(self):
        super(ImageClassifier, self).__init__(48, (6, 12, 36, 24), 96)

    def load_state_dict(self, state_dict, strict=True):
        import re
        pattern = re.compile(r'^(.*denselayer\d+\.(?:norm|relu|conv))\.((?:[12])\.(?:weight|bias|running_mean|running_var))$')

        for key in list(state_dict.keys()):
            res = pattern.match(key)
            if res:
                new_key = res.group(1) + res.group(2)
                state_dict[new_key] = state_dict[key]
                del state_dict[key]

        return super(ImageClassifier, self).load_state_dict(state_dict, strict)
