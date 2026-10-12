from typing import List
import catboost as cb
from colorama import Fore
from datetime import datetime
from lob.base import BaseLOB
import numpy as np
import os
import pandas as pd
import shap
from utils import calculate_time, convert_path_to_lib, save_sas_log, handle_error


class WorkersComp(BaseLOB):

    def get_lob_name(self) -> str:
        return "Workers Comp"

    def get_script_names(self) -> List[str]:
        return [
            "1. Data Prep - WC WPC Data Prep.sas",
            "3. Import and Prep Python Output FINAL.sas",
            "WCv21",
        ]

    def get_output_file_names(self) -> List[str]:
        return [
            "QlikAdjustmentsSAS_wc.xlsx",
            "QlikSuperfileSAS_wc.xlsx",
        ]

    def initialize_variables_for_sas(self):
        if self.path_type == "local":
            self.WC = self.lib_path
        else:
            self.WC = convert_path_to_lib(self.lib_path)

    @calculate_time
    @handle_error
    def step_1(self):
        """
        lob: Workers Comp
        script: 1. Data Prep - WC WPC Data Prep.sas
        """

        self.sas_client.saslib("WC", path=self.WC)

        # fetch code from the SAS Script
        with open(
            os.path.join(self.sas_scripts_path, "1. Data Prep - WC WPC Data Prep.sas")
        ) as file:
            code = file.read()

        self.sas_client.symput("flag", self.flag)
        self.sas_client.symput("output_path_csv", self.WC)

        # Submitting SAS code to the SASPY engine
        results_dict = self.sas_client.submit(code)
        sas_log = os.path.abspath(os.path.join(self.lob_output_dir, "Log_SAS1.txt"))
        save_sas_log(sas_log, results_dict["LOG"])

        # Checking whether the output generated in the designated folder or not.
        output_file_paths = [
            os.path.join(self.lob_output_dir, file)
            for file in ["wc_wpc_for_scoring.sas7bdat", "WC_WPC_for_scoring.csv"]
        ]
        if all(map(lambda path: os.path.isfile(path), output_file_paths)):
            self.logger.log("SAS script 1 executed successfully")
            self.logger.log(
                "Output file generated: wc_wpc_for_scoring.sas7bdat and WC_WPC_for_scoring.csv",
                color=Fore.YELLOW,
            )

    @calculate_time
    @handle_error
    def step_2(self):
        """
        lob: Workers Comp
        script: 2. WC WPC - Model Scoring Final.exe
        """

        data_path = os.path.join(self.lob_output_dir, "WC_WPC_for_scoring.csv")
        self.logger.log("Fetching Data - WC_WPC_for_scoring.csv")
        df1 = pd.read_csv(data_path)  # reading data
        self.logger.log("WC_WPC_for_scoring read success")

        # create key field to index and merge on shap results
        df1["KeyField"] = (
            df1["CLM_NR"].astype(str)
            + "-"
            + df1["AdjNu"].astype(str)
            + "-"
            + df1["Adj_Team"].astype(str)
            + "-"
            + df1["Status"].astype(str)
            + "-"
            + df1["PayPeriodEnd"].astype(str)
        )
        df1.set_index(["KeyField"], inplace=True)

        scoringdata = df1[
            [
                "FRTH_TRTMT_REQR",
                "INCID_RPT_ONLY",
                "INJ_PRMIS",
                "INJ_REG_JOB",
                "ISS_INVOLVE",
                "JURIS_STATE_PA",
                "JURIS_STATE_VA",
                "JURIS_STATE_MD",
                "JURIS_STATE_NY",
                "JURIS_STATE_WV",
                "JURIS_STATE_WI",
                "JURIS_STATE_NC",
                "JURIS_STATE_TN",
                "JURIS_STATE_IL",
                "JURIS_STATE_IN",
                "JURIS_STATE_WASHDC",
                "LEGAL_IND",
                "LOSS_CAUSE_FALLSLIPTRIP",
                "LOSS_CAUSE_CUTSCRAPE",
                "LOSS_CAUSE_STRAIN",
                "LOSS_CAUSE_VEH",
                "CORP_REFL_PRLYS",
                "INSD_PNL_EXST",
                "PRIOR_TRTMT_EXST",
                "NCCI_INJ_TYP_MEDONLY",
                "NCCI_INJ_TYP_TEMPORARYINJ",
                "NCCI_INJ_TYP_PERMPARTIAL",
                "NCCI_INJ_TYP_PERMTOTAL",
                "NCCI_LOSS_TYP_TRAUMA",
                "NCCI_LOSS_TYP_CUMULATIVE",
                "VCTNL_RHAB_INCL_INDEM",
                "MECH_DFCT_INVLV",
                "PHYS_RSTRC",
                "BMI",
                "PRIM_BODY_PART_NECKHEAD",
                "PRIM_BODY_PART_TRUNK",
                "PRIM_BODY_PART_MULTIPLE",
                "MIDDLE_MARKET",
                "AGE_CURR",
                "TOTAL_TOUCHES",
            ]
        ]

        self.logger.log("Loading WCv21 from current location")

        modelh = cb.CatBoostRegressor()
        modelh.load_model(os.path.join(self.sas_scripts_path, "WCv21"))

        self.logger.log("Processing Data using Model")
        # MISSING NUMERICS WILL BE ASSIGNED -1
        scoringdata.fillna(-1, inplace=True)

        # FLAG CATEGORICAL COLUMNS - NECESSARY TO UNLEACH CATBOOST POWER!
        categorical_features_indices = np.where(scoringdata.dtypes != np.float64)[0]

        # make it a test pool, run through model
        scrpl = cb.Pool(scoringdata, cat_features=categorical_features_indices)

        # DEPENDENT VARIABLE
        yCol = ["TOTAL_TOUCHES"]
        # X VARIABLES - start with those that survived boruta
        xCol = [
            "AGE_CURR",
            "BMI",
            "FRTH_TRTMT_REQR",
            "INCID_RPT_ONLY",
            "INJ_PRMIS",
            "INJ_REG_JOB",
            "ISS_INVOLVE",
            "JURIS_STATE_PA",
            "JURIS_STATE_VA",
            "JURIS_STATE_MD",
            "JURIS_STATE_NY",
            "JURIS_STATE_WV",
            "JURIS_STATE_WI",
            "JURIS_STATE_NC",
            "JURIS_STATE_TN",
            "JURIS_STATE_IL",
            "JURIS_STATE_IN",
            "JURIS_STATE_WASHDC",
            "LEGAL_IND",
            "LOSS_CAUSE_FALLSLIPTRIP",
            "LOSS_CAUSE_CUTSCRAPE",
            "LOSS_CAUSE_STRAIN",
            "LOSS_CAUSE_VEH",
            "CORP_REFL_PRLYS",
            "INSD_PNL_EXST",
            "PRIOR_TRTMT_EXST",
            "NCCI_INJ_TYP_MEDONLY",
            "NCCI_INJ_TYP_TEMPORARYINJ",
            "NCCI_INJ_TYP_PERMPARTIAL",
            "NCCI_INJ_TYP_PERMTOTAL",
            "NCCI_LOSS_TYP_TRAUMA",
            "NCCI_LOSS_TYP_CUMULATIVE",
            "VCTNL_RHAB_INCL_INDEM",
            "MECH_DFCT_INVLV",
            "PHYS_RSTRC",
            "PRIM_BODY_PART_TRUNK",
            "PRIM_BODY_PART_MULTIPLE",
            "PRIM_BODY_PART_NECKHEAD",
            "MIDDLE_MARKET",
        ]
        # CREATE X & Y DATA
        x = scoringdata[xCol]
        y = scoringdata[yCol]

        # score model - prob turns 0/1 (predict) to relative probability of 0 and 1
        pred = modelh.predict(scrpl)

        # append second column (likelihood of score) to dataset
        scoringdata["phat"] = pred[:]
        dfs2 = scoringdata[["phat"]]

        # MAKE SURE ALL Xs ARE PREPARED EXACTLY THE SAME WAY AS WHEN THE DATA WAS MODELED
        # THE RECORDS FROM THE ORIGINAL DATASET (df) AND "x series" MUST PRESERVE ORDER INTEGRITY (nth RECORD IN df & x must be the same)
        # CREATE A COPY OF ORIGINAL DATASET
        # MUST CONTAIN ALL RECORDS IN THE SAME ORDER AS THE "x series"
        scored = scoringdata.copy()

        # MAKE A PREDICTION ON ENTIRE Xs
        predAll = modelh.predict(x)

        # APPEND SCORE TO DATASET
        scored["pred"] = predAll[:]

        # make index a column so that can keep in merge below
        scored["drpno"] = scored.index
        scored = scored[["drpno", "pred"]]

        # CREATE A SHAP TREE EXPLAINER FOR THE MODEL
        explainer = shap.TreeExplainer(modelh)

        self.logger.log("Fetching SHAP values")
        # CREATE SHAP VALUES FOR ALL Xs
        sValues = explainer.shap_values(x)

        # OVERALL MEAN PREDICTIONS - ALL SHAP VALUES DEVIATE FROM THIS
        meanPred = explainer.expected_value

        # CONVERT SHAP VALUES TO DATAFRAME
        shapDf = pd.DataFrame(sValues, columns=[x.columns.tolist()])

        # ADD ON MEAN PREDICTION
        shapDf["baseline_mean"] = meanPred
        # shapDf.head()

        # IGNORE INDEX (NEED TO MAINTAIN ROW SORTING INTEGRITY HERE)
        scored.reset_index(drop=True, inplace=True)
        shapDf.reset_index(drop=True, inplace=True)
        # MERGE ON SHAP VALUES
        scoredShap = pd.concat([scored, shapDf], axis=1, sort=False)
        # scoredShap.head(10)

        counter = 0

        shap.force_plot(
            explainer.expected_value, sValues[counter, :], x.iloc[counter, :]
        )

        self.logger.log("Exporting Output: model_shap.csv")

        scoredShap.to_csv(
            os.path.join(self.lob_output_dir, "model_shap.csv"), index=True
        )

        # Checking whether the output generated in the designated folder or not.
        output_file_path = os.path.join(self.lob_output_dir, "model_shap.csv")
        if os.path.isfile(output_file_path):
            self.logger.log(" Model executed successfully")
            self.logger.log("Output file generated: model_shap.csv", color=Fore.YELLOW)

    @calculate_time
    @handle_error
    def step_3(self):
        """
        lob: Workers Comp
        script: 3. Import and Prep Python Output FINAL.sas
        """

        # creating library to be used internally by the SAS script
        self.sas_client.saslib("WC", path=self.WC)

        folder_date = datetime.strptime(self.last_folder, "%m-%d-%Y")

        # passing the values of the different variables that are to be used internally inside the script
        sas_params = {
            "FolderDt": self.last_folder,
            "Month": folder_date.month,
            "Day": folder_date.day,
            "Year": folder_date.year,
            "flag": self.flag,
            "output_path_csv": self.WC,
        }
        self.logger.log(f"Input parameters to the script: {sas_params}")
        for param, val in sas_params.items():
            self.sas_client.symput(param, val)

        # fetching code from the script
        with open(
            os.path.join(
                self.sas_scripts_path, "3. Import and Prep Python Output FINAL.sas"
            )
        ) as file:
            code = file.read()

        # submitting code to SASPY engine
        results_dict = self.sas_client.submit(code)
        sas_log = os.path.abspath(os.path.join(self.lob_output_dir, "Log_SAS3.txt"))
        save_sas_log(sas_log, results_dict["LOG"])

        # Checking whether the output generated in the designated folder or not.
        output_file_paths = [
            os.path.join(self.lob_output_dir, file)
            for file in ["QlikAdjustmentsSAS.xlsx", "QlikSuperfileSAS.xlsx"]
        ]
        if all(map(lambda path: os.path.isfile(path), output_file_paths)):
            self.logger.log("SAS script 3 executed successfully")
            self.logger.log(
                "Output file generated: QlikAdjustmentsSAS.xlsx and QlikSuperfileSAS.xlsx",
                color=Fore.YELLOW,
            )
