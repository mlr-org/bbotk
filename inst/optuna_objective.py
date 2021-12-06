import optuna

class Objective(object):
    def __init__(self, param_set):
        self.param_set = param_set

    def __call__(self, trial):
        xs = self.suggest_trial(trial)
        return - (xs['x1'] - 2) ** 2 - (xs['x2'] + 3) ** 2 + 10

    def suggest_trial(self, trial):
        param_values = {}
        for row in self.param_set.itertuples():
            if row[2] == 'ParamDbl':
                param_values[row[1]] = trial.suggest_float(row[1], row[3], row[4])
            elif row[2] == 'ParamInt':
                param_values[row[1]] = trial.suggest_int(row[1], row[3], row[4])
            elif row[2] == 'ParamFct':
                param_values[row[1]] = trial.suggest_categorical(row[1], row[5])

        return param_values
