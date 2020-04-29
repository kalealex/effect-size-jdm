# Judgments and Decisions from Visualizations of Effect Size

This repository contains supplemental materials for the IEEE VIS 2020 submission, _Visual Reasoning Strategies and Satisficing: How Uncertainty Visualization Design Impacts Judgments of Effect Size_.

## Contents

Contents include study planning and analysis scripts, drafts of the paper, as well as code used to generate the figures and statistics presented in the paper. Many of the generated files such as images and model fit objects have been intentionally left out of the repo due to file size. The interfaces used to run the experiment are located in private subrepositories in order to protect database credentials. Please contact the first author for more information about the experimental interface.

experiment/ - _files pertaining to the planning, analysis, and presentation of findings from the main experiment_
- analysis/
    * AnonymizeData.R: a script uses to anonymize worker ids in our data set
    * experiment-anonymous.csv: the full data set that we collected for our main experiment
    * ExploratoryVisualization.Rmd: code walking through the exploratory visualizations we looked at immediately following data collection, formatted as markdown (knit file too large to upload to github)
    * InterventionDecisions.html: a markdown document walking through how we built a logistic regression model of intervention decisions
    * InterventionDecisions.Rmd: code used to knit InterventionDecisions.html
    * model-data.csv: the data set that we used for the statistical inferences presented in the paper
    * PSuperiority.html: a markdown document walking through how we built a linear in log odds model of probability of superiority responses
    * remote-model-fitting/ - _private subrepository used to fit models on a server_
    * Results.html: a supplemental markdown document walking through our quantitative results
    * Results.Rmd: code used to knit Results.html
    * strategy/
        - strategies.csv: the data set of strategy responses and qualitative codes presented in the paper
        - Strategies.R: code used to query strategies.csv for the descriptive statistics presented in the paper
- figures/
    * FigureGeneration.R: code used to generate components for the figures presented in the paper; components were composed in Adobe Illustator
- study-planning/
    * StimuliGeneration.Rmd: code used to generate chart stimuli for our experiment, formatted as markdown

interface/ - _code for the experimental interface_
- effect-size-jdm-experiment-interface/ - _private subrepository containing code to run the interface for the main experiment_
- heuristics-experiment-interface/ - _private subrepository containing code to run the interface for an early pilot_

pilot-studies/ - _files pertaining to the planning and analysis of five pilot studies (separate table of contents TK)_ 
