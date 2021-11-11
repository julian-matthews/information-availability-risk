# The availability of non-instrumental information increases decision-making under risk.

###### [Julian Matthews](https://twitter.com/quined_quales), [Patrick Cooper](https://twitter.com/neurocoops), [Stefan Bode](https://twitter.com/DSHunimelb), [Trevor Chong](https://twitter.com/MonashCogNeuro)

***

> Contemporary models of decision-making under risk focus on estimating the final value of each alternative course of action. According to such frameworks, information that has no capacity to alter a future payoff (i.e., is ‘non-instrumental’) should have little effect on one’s preference for risk. Importantly, however, recent work has shown that information, despite being non-instrumental, may nevertheless exert a striking influence on behavior. Here, we tested whether the opportunity to passively observe the sequence of events following a decision could modulate risky behavior, even if that information could not possibly influence the final result. Across three experiments, 71 individuals chose to accept or reject gambles on a five-window slot machine. If a gamble was accepted, each window was sequentially revealed prior to the outcome being declared. Critically, we informed participants about which windows would subsequently provide veridical information about the gamble outcome, should that gamble be accepted. Our analyses revealed three key findings. First, the opportunity to observe the consequences of one’s choice significantly increased the likelihood of gambling, despite that information being entirely non-instrumental. Second, this effect generalized across different stakes. Finally, choices were driven by the likelihood that the available information could result in an earlier resolution of uncertainty. These findings demonstrate the capacity of non-instrumental information to modulate economic decisions through its anticipatory utility. More broadly, our result provides a counterpoint to current decision-making frameworks, by demonstrating that information that is entirely orthogonal to the value of the final outcome can have substantial effects on risky behavior.

## What is this?
Here we provide R code and complete trial-by-trial data supporting our study of non-instrumental information availability and risky decision-making. 

We used a **five-window slot machine with fixed odds** (50% chance of winning) to study how the opportunity to observe non-instrumental information about outcomes influences the decisions to gamble. Critically, we informed participants about which windows would subsequently provide veridical information about the gamble outcome. 

![methods]

## What did you find?

Across three experiments (n=71), we found that information availability has a striking affect on behaviour; **the opportunity to receive non-instrumental information increases the propensity to gamble**. However, it does not do so in a simple, linear fashion. We used computational modeling to demonstrate that choices were driven by anticipatory utility. When information might provide a definitive outcome participants were more inclined to gamble. However, when only partial information was available, participants were more inclined to reject the gamble (even less than a condition were no information was available at all, a speculative effect of **information avoidance**).

![results]

## You will need: 
1. [**R**](https://www.r-project.org/)

## Data description
Data-sets are arranged in a systematic manner to aid analysis. Here, I will refer to the file `all_responses.csv`
1. `exp_version`: the experiment in our study; EXP1, EXP2, or EXP3
2. `subject_num`: the unique ID for each of 71 participant across out experiments
3. `trial_num`: the trial number from 1 to 180
4. `information`: non-instrumental information availability, reflected in the number of slots with veridical information from 0 to 5
5. `stake`: the amount of money that can be won or lost on the trial. Fixed at 50 cents for EXP1. Varies from 10 to 50 cents (in 10 cent increments) for EXP2 and EXP3.
6. `decision`: whether the gamble was accepted (1) or rejected (0). Coded (NA) if no response was made within the 5 second response window.
7. `reaction_time`: the amount of time it took to make a decision
8. `outcome`: the predetermined outcome of the gamble (if the participants chooses to accept)
9. `early_late`: in EXP3 only, whether information was available at the earliest or latest opportunity (analysed for information levels 1:4)

![alt_text][avatar]

[methods]: /methods-figure.png

[results]: /information-availability.png

[avatar]: https://avatars0.githubusercontent.com/u/18410581?v=3&s=96 "I'm Julian"
