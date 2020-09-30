# Judgments and Decisions from Visualizations of Effect Size

This repository contains supplemental materials for the IEEE VIS 2020 paper, _Visual Reasoning Strategies for Effect Size Judgments and Decisions_.

## Contents

Contents include study planning and analysis scripts, drafts of the paper, as well as code used to generate the figures and statistics presented in the paper. Many of the generated files such as images and model fit objects have been intentionally left out of the repo due to file size. The interface code used to run the experiment is located in a private subrepository in order to protect database credentials.

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

## Interface

The interface we used to run the experiment is a custom web application hosted on Heroku. Please follow these instructions to check it out for yourself.

The url for the experiment landing page is https://effect-size-jdm.herokuapp.com/0_landing?workerId=*unique_string*&assignmentId=test&cond=*condition*

In order to access the interface, you'll need to choose a unique string to fill in the 'workerId' url parameter. If you choose the same string as somebody else, you will be redirected to a page that tells you so.

You'll also need to choose which condition you'd like to see. Type one of the following options to fill in the 'cond' url parameter. These will allow you to do the experiment with 95% containment intervals, hypothetical outcome plots, quantile dotplots, or probability densities, respectively.

- intervals
- HOPs
- QDPs
- densities
