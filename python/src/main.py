from functions import create_features, create_rules, sortRules, showStatistics

dataset = 'kidney'
data_folder = '../data/'
results_folder = '../res/'

train, test = create_features(data_folder, dataset)

rules = create_rules(dataset, results_folder, train)
ordered_rules = sortRules(dataset, results_folder, train, rules)

precision, recall = showStatistics(ordered_rules, test)