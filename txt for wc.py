
        # CREATE A SHAP TREE EXPLAINER FOR THE MODEL
        explainer = shap.TreeExplainer(modelh)

        self.logger.log("Fetching SHAP values")

        # CREATE SHAP VALUES FOR ALL FEATURES
        sValues = explainer.shap_values(x)

        # OVERALL MEAN PREDICTION
        meanPred = explainer.expected_value

        # CONVERT SHAP VALUES TO DATAFRAME
        # Use a flat list of column names, not a nested list
        shapDf = pd.DataFrame(sValues, columns=x.columns.tolist())

        # ADD BASELINE PREDICTION
        shapDf["baseline_mean"] = meanPred

        # PRESERVE ROW ORDER
        scored.reset_index(drop=True, inplace=True)
        shapDf.reset_index(drop=True, inplace=True)

        # COMBINE PREDICTIONS AND SHAP VALUES
        scoredShap = pd.concat([scored, shapDf], axis=1, sort=False)

        # EXPORT OUTPUT
        self.logger.log("Exporting Output: model_shap.csv")

        scoredShap.to_csv(
            os.path.join(self.lob_output_dir, "model_shap.csv"),
            index=True
        )

        # CHECK OUTPUT FILE
        output_file_path = os.path.join(
            self.lob_output_dir, "model_shap.csv"
        )

        if os.path.isfile(output_file_path):
            self.logger.log("Model executed successfully")
            self.logger.log(
                "Output file generated: model_shap.csv",
                color=Fore.YELLOW
            )
