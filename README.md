# The availability of non-instrumental information increases decision-making under risk.

###### [Julian Matthews](https://twitter.com/quined_quales), [Patrick Cooper](https://twitter.com/neurocoops), [Stefan Bode](https://dlab.unimelb.edu.au/), [Trevor Chong](http://cogneuro.com.au/)

***

> Contemporary models of decision-making under risk focus on estimating the final value of each alternative course of action. According to such frameworks, information that has no capacity to alter a future payoff (i.e., is ‘non-instrumental’) should have little effect on one’s preference for risk. Importantly, however, recent work has shown that information, despite being non-instrumental, may nevertheless exert a striking influence on behavior. Here, we tested whether the opportunity to passively observe the sequence of events following a decision could modulate risky behavior, even if that information could not possibly influence the final result. Across three experiments, 71 individuals chose to accept or reject gambles on a five-window slot machine. If a gamble was accepted, each window was sequentially revealed prior to the outcome being declared. Critically, we informed participants about which windows would subsequently provide veridical information about the gamble outcome, should that gamble be accepted. Our analyses revealed three key findings. First, the opportunity to observe the consequences of one’s choice significantly increased the likelihood of gambling, despite that information being entirely non-instrumental. Second, this effect generalized across different stakes. Finally, choices were driven by the likelihood that the available information could result in an earlier resolution of uncertainty. These findings demonstrate the capacity of non-instrumental information to modulate economic decisions through its anticipatory utility. More broadly, our result provides a counterpoint to current decision-making frameworks, by demonstrating that information that is entirely orthogonal to the value of the final outcome can have substantial effects on risky behavior.

## What is this?
Here we provide **R code and complete trial-by-trial data** supporting our study of non-instrumental information availability and risky decision-making. 

We used a **five-window slot machine with fixed odds** (50% chance of winning) to study how the opportunity to observe non-instrumental information about outcomes influences decisions to gamble. Critically, we informed participants about which slots would subsequently provide veridical information about the gamble outcome. 

![methods]

## What did you find?

Across three experiments (n=71), we found that information availability has a striking affect on behaviour; **the opportunity to receive non-instrumental information increases the propensity to gamble**. 

However, information availability does not drive behaviour in a simple, linear fashion. We used computational modeling to demonstrate that choices were driven by anticipatory utility. When information might provide a definitive outcome, participants were more inclined to gamble. However, when only partial information was available, participants were more inclined to reject the gamble. In fact, participants were less likely to accept gambles with partial information than a condition where no information was available at all, an effect that can be interpreted as **information avoidance**.

The following plot illustrates the proportion of gambles accepted (**Pr(Accept)**) as a function of non-instrumental information availability (**Informative windows**). Group means for each information condition are plotted as black squares. Errorbars reflect 95% confidence intervals. Individual subject means are plotted in grey for each information condition and experiment. 

![results]

***

## You will need: 
1. [**R**](https://www.r-project.org/)

## Code description
* `exp1_stats.R`: statistics for Experiment 1
* `exp2_stats.R`: statistics for Experiment 2
* `exp3_stats.R`: statistics for Experiment 3
* `group_stats.R`: pooled statistics including data from all experiments
* `information-model-comparison.R`: model comparison and boostrap simulations
* `PNAS_figure.R`: code to produce Figure 2 from our submission to PNAS

## Data description

### Behavioural data
Behavioural datasets (.csv files) are arranged in a systematic manner to aid analysis:
1. `exp_version`: the experiment in our study; EXP1, EXP2, or EXP3
2. `subject_num`: the unique ID for each of 71 participant across our experiments
3. `trial_num`: the trial number from 1 to 180
4. `information`: non-instrumental information availability, reflected in the number of slots with veridical information from 0 to 5
5. `stake`: the amount of money that can be won or lost on the trial. Fixed at 50 cents for EXP1. Varies from 10 to 50 cents (in 10 cent increments) for EXP2 and EXP3.
6. `decision`: whether the gamble was accepted (1) or rejected (0). Coded (NA) if no response was made within the 5 second response window.
7. `reaction_time`: the amount of time it took to make a decision
8. `outcome`: the predetermined outcome of the gamble (assuming the participant chooses to accept)
9. `early_late`: EXP3 only, whether information was available at the earliest or latest opportunity (analysed for information levels 1:4)

> Informative windows (black) display non-instrumental information that signals the outcome of the trial. Non-informative windows (white) display a random cue. All experiments had identical numbers of trials per information condition, the difference between Experiments 1 and 2 vs. Experiment 3 was the arrangement of informative windows. In Experiments 1 and 2, arrangements were randomly selected from the options in the top panel. In Experiment 3, window arrangements were composed of the options in the bottom panel. Importantly, for the partial information conditions in Experiment 3 (1 to 4 informative windows), informative windows appeared relatively early or relatively late in the trial. An equal proportion of earlier and later arrangements were used.

![arrangement]

### Modeling data
For behavioural modeling, We compared four different generalised mixed models to test how the availability of information influenced risky choice. We computed information value according to the formulas in our paper. Tabulated are the ‘Information Values’ for every level of Information Availability, as assumed by each of the four models. 

| **Model**                             | Zero |  One  |  Two  | Three |  Four | Five |
|---------------------------------------|:----:|:-----:|:-----:|:-----:|:-----:|:----:|
| 1. Baseline                           | 0    | 0     | 0     | 0     | 0     | 0    |
| 2. Linear                             | 0    | 0.2   | 0.4   | 0.6   | 0.8   | 1.0  |
| 3. Entropy Reduction                  | 0    | 0.104 | 0.228 | 0.392 | 0.625 | 1.0  |
| 4. Early Resolution of Uncertainty    | 0    | 0     | 0     | 0.25  | 0.625 | 1.0  |

See `information_value_complete.csv`. Note, model 1 is a fixed model including subject-specific intercepts only. Consequently, it is not included in this file. See values below:
1. `exp_version`: as above
2. `subject_num`: as above
3. `trial_num`: as above
4. `information`: as above
5. `decision`: as above
6. `mod2_linear`: information value in model 2
7. `mod3_entropy`: information value in model 3
8. `mod4_res_uncertainty`: information value in model 4

![alt_text][avatar]

[methods]: /figures/methods-figure.png
[results]: /figures/information-availability.png
[arrangement]: /figures/information-arrangement.png

[avatar]: https://avatars0.githubusercontent.com/u/18410581?v=3&s=96 "I'm Julian"
