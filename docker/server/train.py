from sklearn import datasets
from sklearn.linear_model import LogisticRegression
from joblib import dump, load
import sys


def main(output):
    iris = datasets.load_iris()
    X = iris.data
    y = iris.target

    clf = LogisticRegression(random_state=0).fit(X, y)
    print(clf.score(X, y))

    dump(clf, output)

if __name__ == "__main__":
    assert len(sys.argv) >= 1, "Not enough arguments. Pass path"
    _, filepath = sys.argv
    main(filepath)
