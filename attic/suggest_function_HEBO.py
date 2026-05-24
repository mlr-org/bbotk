def suggest(self, n_suggestions=1, fix_input=None):
    # --- MACE-specific: batch suggestions are only supported with MACE ---
    # HEBO only supports parallel suggestions when using MACE acquisition.
    if self.acq_cls != MACE and n_suggestions != 1:
        raise RuntimeError("Parallel optimization is supported only for MACE acquisition")

    # Cold-start phase: before enough observations are available, return Sobol / quasi-random points.
    if self.X.shape[0] < self.rand_sample:
        sample = self.quasi_sample(n_suggestions, fix_input)
        return sample
    else:
        # Convert observed configurations to HEBO's internal numeric/categorical representation.
        X, Xe = self.space.transform(self.X)

        try:
            # Normalize + power-transform objectives for more stable surrogate fitting.
            # Use Yeo-Johnson if values can be <= 0, otherwise Box-Cox first.
            if self.y.min() <= 0:
                y = torch.FloatTensor(power_transform(self.y / self.y.std(), method="yeo-johnson"))
            else:
                y = torch.FloatTensor(power_transform(self.y / self.y.std(), method="box-cox"))
                if y.std() < 0.5:
                    y = torch.FloatTensor(power_transform(self.y / self.y.std(), method="yeo-johnson"))

            # Abort transformed path if output has too little variation.
            if y.std() < 0.5:
                raise RuntimeError("Power transformation failed")

            # Build and fit surrogate model on transformed observations.
            model = get_model(
                self.model_name,
                self.space.num_numeric,
                self.space.num_categorical,
                1,
                **self.model_config
            )
            model.fit(X, Xe, y)
        except:
            # Fallback path: fit model on raw y if transformation fails.
            y = torch.FloatTensor(self.y).clone()
            model = get_model(self.model_name, self.space.num_numeric, self.space.num_categorical, 1, **self.model_config)
            model.fit(X, Xe, y)

        # Get current incumbent (best observed point under optional fixed-context constraints).
        best_id = self.get_best_id(fix_input)
        best_x = self.X.iloc[[best_id]]
        best_y = y.min()

        # Predict at incumbent and use predicted mean as reference in acquisition.
        py_best, ps2_best = model.predict(*self.space.transform(best_x))
        py_best = py_best.detach().numpy().squeeze()
        ps_best = ps2_best.sqrt().detach().numpy().squeeze()

        # Compute kappa (exploration strength) with iteration-dependent scaling.
        iter = max(1, self.X.shape[0] // n_suggestions)
        upsi = 0.5
        delta = 0.01
        # kappa = np.sqrt(upsi * 2 * np.log(iter **  (2.0 + self.X.shape[1] / 2.0) * 3 * np.pi**2 / (3 * delta)))
        kappa = np.sqrt(upsi * 2 * ((2.0 + self.X.shape[1] / 2.0) * np.log(iter) + np.log(3 * np.pi**2 / (3 * delta))))

        # Optimize acquisition with evolutionary search to obtain candidate recommendations.
        acq = self.acq_cls(model, best_y=py_best, kappa=kappa)  # LCB < py_best
        mu = Mean(model)
        sig = Sigma(model, linear_a=-1.0)
        opt = EvolutionOpt(self.space, acq, pop=100, iters=100, verbose=False, es=self.es)
        rec = opt.optimize(initial_suggest=best_x, fix_input=fix_input).drop_duplicates()
        rec = rec[self.check_unique(rec)]

        # Ensure enough unique candidates; if needed, backfill with quasi-random points.
        cnt = 0
        while rec.shape[0] < n_suggestions:
            rand_rec = self.quasi_sample(n_suggestions - rec.shape[0], fix_input)
            rand_rec = rand_rec[self.check_unique(rand_rec)]
            rec = pd.concat([rec, rand_rec], axis=0, ignore_index=True)
            cnt += 1
            if cnt > 3:
                # Sometimes the design space is so small that duplicates are unavoidable.
                break
        if rec.shape[0] < n_suggestions:
            rand_rec = self.quasi_sample(n_suggestions - rec.shape[0], fix_input)
            rec = pd.concat([rec, rand_rec], axis=0, ignore_index=True)

        # --- Batch-selection heuristic (practically relevant when using MACE in parallel mode) ---
        # Select final batch; for larger batches force one uncertain and one best-predicted point.
        select_id = np.random.choice(rec.shape[0], n_suggestions, replace=False).tolist()
        x_guess = []
        with torch.no_grad():
            py_all = mu(*self.space.transform(rec)).squeeze().numpy()
            ps_all = -1 * sig(*self.space.transform(rec)).squeeze().numpy()
            best_pred_id = np.argmin(py_all)
            best_unce_id = np.argmax(ps_all)
            # These replacements are only triggered for n_suggestions > 2 (batch mode).
            # In this HEBO implementation, batch mode is gated by the MACE check above.
            if best_unce_id not in select_id and n_suggestions > 2:
                select_id[0] = best_unce_id
            if best_pred_id not in select_id and n_suggestions > 2:
                select_id[1] = best_pred_id
            rec_selected = rec.iloc[select_id].copy()

        # Return proposed configuration(s) as a pandas DataFrame.
        return rec_selected
