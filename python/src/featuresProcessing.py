import numpy as np
import pandas as pd


def processTitanic(data):
    features = pd.DataFrame()

    features['Survived'] = data['Survived']
    create_columns('Age', [0, 17, 50, np.inf], data, features)
    create_columns('Fare', [0, 10, 20, np.inf], data, features)

    features['Sex'] = (data['Sex'] == 'female').astype(int)

    for a in np.sort(np.unique(data['Pclass'])):
        features['Class' + str(a)] = (data['Pclass'] <= a).astype(int)

    features['Relative'] = \
        ((data['Siblings/Spouses Aboard'] +
          data['Parents/Children Aboard']) > 0).astype(int)

    return features


def processKidneys(data):
    features = pd.DataFrame()

    # We want to predict data['class']
    features['class'] = (data['class'] == 'ckd').astype(int)

    # We select sg / sod / hemo / rbcc / appet / al
    create_columns('sg',
                   [0., 1., 1.01, 1.020, 1.025, np.inf],
                   data, features)
    create_columns('hemo', [0, 10, 15, 20, np.inf], data, features)

    return features


def create_columns(header, intervals, data, features):
    for i in range(len(intervals) - 1):
        lb = intervals[i]
        ub = intervals[i+1]
        features[header + str(lb) + '-' + str(ub)] = \
            ((data[header] >= lb) & (data[header] < ub)).astype(int)
