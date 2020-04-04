import os
import pandas as pd
from featuresProcessing import processTitanic, processKidneys
import pulp
from tqdm import tqdm
import math
import numpy as np

def create_features(data_folder, dataset):
    data_path = os.path.join(data_folder, dataset + '.csv')

    if not os.path.exists(data_path):
        print('Error in creating features : Input file not found %s'
              % data_path)
        return

    data = pd.read_csv(data_path)

    train_data_path = os.path.join(data_folder, dataset + '_train.csv')
    test_data_path = os.path.join(data_folder, dataset + '_test.csv')

    if not os.path.exists(train_data_path) or \
       not os.path.exists(test_data_path):

        print('====== Creating features')

        if dataset == 'titanic':
            features = processTitanic(data)

        if dataset == 'kidney':
            features = processKidneys(data)

        features = features.sample(frac=1)
        trainlimit = int(float(len(features)) * 2/3)
        test = features.loc[:trainlimit]
        train = features.loc[trainlimit:]

        train.to_csv(train_data_path)
        test.to_csv(test_data_path)

    else:
        print("=== Warning: Existing features found, features creation skipped")
        print("=== Loading existing features")

        train = pd.read_csv(train_data_path, index_col=0)
        test = pd.read_csv(test_data_path, index_col=0)

    return train, test


def create_rules(dataset: str, results_folder: str, train: pd.DataFrame):
    rules_path = os.path.join(results_folder, dataset + '_rules.csv')
    rules = []

    if not os.path.exists(rules_path):
        print('=== Generating the rules')

        t = train.values[:, 1:]
        transaction_class = train.values[:, 0]
        n, d = t.shape

        mincovy = 0.05
        iterlim = 5
        RgenX = 0.1 / n
        RgenB = 0.1 / (n * d)

        all_rules = []

        for y in [0, 1]:
            print('Generating rule for class : %d' % y)

            rules = []
            s = 0
            iter = 1
            cmax = n

            pbar = tqdm(total=n)

            while cmax >= float(n) * mincovy:
                print('Cmax : %d' % cmax)
                if iter == 1:
                    s, b = solve_P(t, transaction_class, y, cmax, RgenX, RgenB, rules)
                    iter = iter + 1
                rules.append(b)
                if iter < iterlim:
                    s_temp, b = solve_P(t, transaction_class, y, cmax, RgenX, RgenB, rules)
                    if s_temp < s:
                        pbar.update(cmax - min(cmax - 1, s_temp))
                        cmax = min(cmax - 1, s_temp)
                        iter = 1
                    else:
                        iter = iter + 1
                else:
                    pbar.update(1)
                    cmax = cmax - 1
                    iter = 1
            all_rules += rules
        
    else:
        # Load rules
        pass
    return np.array(all_rules, dtype=int)

def sortRules(dataset, resultsFolder, train, rules):
    orderedRulesPath = os.path.join(resultsFolder, dataset, '_ordered_rules.csv')

    if not os.path.exists(orderedRulesPath):
        X = train.values[:, 1:]
        y = train.values[:, 0]
        n, d = X.shape

        rule_0 = np.array([0] * d).reshape(1, -1)
        rule_1 = np.array([1] * d).reshape(1, -1)

        rules = np.append(rules, rule_0, axis=0)
        rules = np.append(rules, rule_1, axis=0)
        rules = np.unique(rules, axis=0)

        L = rules.shape[0]
        index_0 = 0
        index_1 = 0
        for index in range(L):
            if (rules[index] == 0).all():
                index_0 = index
            if (rules[index] == 1).all():
                index_1 = index
        Rrank = 1/L

        p = np.zeros(shape=(n, L))

        for i in range(n):
            for l in range(L):
                if (X[i] - rules[l] >= 0).all():
                    if y[i] == rules[l, 0]:
                        p[i, l] = 1
                    else:
                        p[i, l] = -1

        v = np.abs(p)

        P = pulp.LpProblem('Problem', pulp.LpMaximize)
        #TODO : set maximum iteration
        u = pulp.LpVariable.dicts('u', [str(i) + '_' + str(j) for i in range(n) for j in range(L)], cat=pulp.LpBinary)
        r = pulp.LpVariable.dicts('r', range(L), 1, L, cat=pulp.LpInteger)
        rstar = pulp.LpVariable('rstar', 1, L)

        g = pulp.LpVariable.dicts('g', range(n), 1, L, pulp.LpInteger)

        s = pulp.LpVariable.dicts('s', [str(i) + '_' + str(j) for i in range(L) for j in range(L)], cat=pulp.LpBinary)
        rA = r[0]
        rB = r[1]
        
        alpha = pulp.LpVariable('alpha', cat=pulp.LpBinary)
        beta = pulp.LpVariable('beta', 0, 1)

        P += pulp.lpSum([p[i, j] * u[str(i) + '_' + str(j)] for i in range(n) for j in range(L)]) + Rrank * rstar

        # Constraints
        for i in range(n):
            P += pulp.lpSum([u[str(i) + '_' + str(j)] for j in range(L)]) == 1

        for i in range(n):
            for l in range(L):
                P += g[i] >= v[i, l] * r[l]
                P += g[i] <= v[i, l] * r[l] + L * (1 - u[str(i) + '_' + str(l)])

        for i in range(n):
            for l in range(L):
                P += u[str(i) + '_' + str(l)] >= 1 - g[i] + v[i, l] * r[l]
                P += u[str(i) + '_' + str(l)] <= v[i, l]

        for k in range(L):
            P += pulp.lpSum([s[str(l) + '_' + str(k)] for l in range(L)]) == 1
        for l in range(L):
            P += pulp.lpSum([s[str(l) + '_' + str(k)] for k in range(L)]) == 1
            P += r[l] == pulp.lpSum([(k + 1) * s[str(l) + '_' + str(k)] for k in range(L)])

        P += rstar >= rA
        P += rstar >= rB
        P += rstar - rA <= (L-1) * alpha
        P += rA - rstar <= (L-1) * alpha
        P += rstar - rB <= (L-1) * beta
        P += rB - rstar <= (L-1) * beta
        P += alpha + beta == 1

        for i in range(n):
            for l in range(L):
                u[str(i) + '_' + str(l)] <= 1 - (rstar - r[l])/ (L-1)
    
        P.solve()

        relevant_number_rules = L - math.trunc(pulp.value(rstar)) + 1
        rules_order = [int(pulp.value(r[l])) - 1 for l in range(L)]
        ordered_rules = rules[rules_order]

        return ordered_rules
    else:
        pass

def solve_P(t, transaction_class, y, cmax, RgenX, RgenB, rules):
    """
    Solve the problem P.
    """

    n, d = t.shape

    P = pulp.LpProblem('Problem', pulp.LpMaximize)
    x = pulp.LpVariable.dicts('x', range(n), 0, 1, cat=pulp.LpContinuous)
    b = pulp.LpVariable.dicts('b', range(d), 0, 1, cat=pulp.LpBinary)

    # Objective function
    mask = (transaction_class == y)
    P += pulp.lpSum([x[index] for index in range(n) if mask[index]]) - RgenX * pulp.lpSum(x) - RgenB * pulp.lpSum(b)

    # Constraints
    # (1)
    for i in range(n):
        for j in range(d):
            P += x[i] <= 1 + (t[i, j] - 1) * b[j]
    
    # (2)
    for i in range(n):
        P += x[i] >= 1 + pulp.lpSum([(t[i, j] - 1)*b[j] for j in range(d)])
    
    # (3)
    P += pulp.lpSum(x) <= cmax

    # Don't regenerate the same rules
    for rule in rules:
        P += pulp.lpSum([b[j] for j in range(d) if rule[j] == 0]) + pulp.lpSum([1 - b[j] for j in range(d) if rule[j] == 1]) >= 1
    
    # Solving problem (P)
    P.solve()

    s = 0
    rule = []
    for i in range(n):
        s += pulp.value(x[i])
    for j in range(d):
        rule.append(pulp.value(b[j]))

    return s, rule

def showStatistics(ordered_rules, df):
    n = len(df)

    tp = 0.
    fp = 0.
    fn = 0.
    tn = 0.

    X = df.values[:, 1:]
    y = df.values[:, 0]

    class_size = [0, 0]
    for i in range(n):
        mask  = ordered_rules <= X[i]
        mask = mask.sum(axis=1)
        for rule_id in range(n):
            if mask[rule_id] == X.shape[1]:
                break
        if ordered_rules[rule_id, 0] == y[i]:

            if y[i] == 0:
                tp += 1
                class_size[0] += 1
            else:
                tn += 1
                class_size[1] += 1
        else:
            if y[i] == 0:
                fn += 1
                class_size[0] += 1
            else:
                fp += 1
                class_size[1] += 1
    
    precision = tp / (tp + fp)
    recall = tp / (tp + fn)

    return precision, recall