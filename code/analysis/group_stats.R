# Stats for all groups together

## PRELIMINARIES ----

library(car)
library(lmerTest)
library(multcomp)
library(optimx)
library(emmeans)
library(ez)
library(BayesFactor)
library(bayestestR)
library(dplyr)

# Load the data and preprocess ----
$dat_location <- ''

setwd(dat_location)
alldata <- read.csv(file = 'all_responses.csv', na.strings = NA)

# Preprocess
alldata$information <-
  factor(
    alldata$information,
    levels = c(
      "slots visible: 0",
      "slots visible: 1",
      "slots visible: 2",
      "slots visible: 3",
      "slots visible: 4",
      "slots visible: 5"
    ),
    labels = c("None", "One",
               "Two", "Three",
               "Four", "Five")
  )

alldata$information <- as.ordered(alldata$information)
alldata$stake <- as.ordered(alldata$stake)

# INFO ONLY ----

behdat <- alldata

behdat$decision <- factor(behdat$decision,
                          levels = c("0","1"),
                          labels = c("Reject","Accept"))

# Full model
int_mod <- glmer(
  decision ~ information + (1 | subject_num),
  data = behdat,
  contrasts = list(information = "contr.treatment"),
  family = binomial(link = 'logit'),
  control = glmerControl(optimizer = "optimx", calc.derivs = FALSE,
                         optCtrl = list(method = "nlminb", 
                                        starttests = FALSE, kkt = FALSE))
)

Anova(int_mod, type = "II", test.statistic = "Chisq")

# exp1
# information       chi-squared(5)=525.16, p<.001 ***

# Information post-hocs
cht <- glht(int_mod, linfct = mcp(information = "Tukey"))
summary(cht, test = adjusted("holm"))

# Sanity check with emmeans
tests <- emmeans(int_mod, list(pairwise ~ information), 
                 adjust = "Holm", type = "response")
summary(tests)

# None / One        z=-3.391, p=.003 
# None / Two        z=-2.160, p=.092 (p-uncorrected=.031)
# None / Three      z=6.745, p<.001 
# None / Four       z=12.853, p<.001 
# None / Five       z=12.940, p<.001 
# One / Two         z=1.232, p=.436 
# One / Three       z=10.066, p<.001 
# One / Four        z=16.000, p<.001 
# One / Five        z=16.081, p<.001 
# Two / Three       z=8.863, p<.001 
# Two / Four        z=14.862, p<.001 
# Two / Five        z=14.945, p<.001 
# Three / Four      z=6.340, p<.001
# Three / Five      z=6.440, p<.001 
# Four / Five       z=0.108, p=.914

sumdat <- alldata %>% group_by(information,subject_num) %>% dplyr::summarise(decision=mean(decision,na.rm=TRUE))
sumdat <- Rmisc::summarySEwithin(data = sumdat, 
                                 measurevar = "decision",
                                 idvar = "subject_num",
                                 withinvars = "information")

# None:   M=.628, SEM=.018
# One:    M=.579, SEM=.019
# Two:    M=.597, SEM=.015
# Three:  M=.722, SEM=.015
# Four:   M=.802, SEM=.015
# Five:   M=.803, SEM=.014

# Frequentist tests

behdat <- alldata

subjdat <- behdat %>% group_by(subject_num,information) %>% 
  dplyr::summarise(decision = mean(decision,na.rm = TRUE))

# Balanced design
table(subjdat$information)

# Perform frequentist repeated measures ANOVA
rm_anova <- ezANOVA(data = subjdat,
                    dv = decision,
                    wid = subject_num,
                    within = information,
                    return_aov = TRUE,
                    type = 2)

rm_anova$ANOVA

# pairwise.t.test(subjdat$decision, subjdat$information,
#                 paired=T, p.adjust.method="holm")

# information   F(5,350)=39.689, p<.001, ges=.223

bf <- anovaBF(
  data = subjdat,
  formula = decision ~ information + subject_num,
  whichRandom = "subject_num", 
  rscaleFixed = "wide", 
  rscaleRandom = "nuisance", 
  method = "auto", # tries all methods and settles on smallest error
  iterations = 1000000, # minimise error
  progress = TRUE
)

options(scipen = 0)
print(bf)

# information   BF=1.519 x 10^29

## INFO AND STAKE ----

alldata <- read.csv(file = 'all_experiments.csv', na.strings = NA)

# Preprocess
alldata$information <-
  factor(
    alldata$information,
    levels = c(
      "slots visible: 0",
      "slots visible: 1",
      "slots visible: 2",
      "slots visible: 3",
      "slots visible: 4",
      "slots visible: 5"
    ),
    labels = c("None", "One",
               "Two", "Three",
               "Four", "Five")
  )

alldata$information <- as.ordered(alldata$information)
alldata$stake <- as.ordered(alldata$stake)

# Model analysis

behdat <- alldata
numdat <- behdat %>% filter(exp_version %in% c("EXP2","EXP3"))
behdat <- behdat %>% filter(exp_version %in% c("EXP2","EXP3"))
behdat$subject_num <- factor(behdat$subject_num)

behdat$decision <- factor(behdat$decision,
                          levels = c("0","1"),
                          labels = c("Reject","Accept"))

# Full model
int_mod <- glmer(
  decision ~ information * stake + (1 | subject_num),
  data = behdat,
  contrasts = list(information = "contr.treatment"),
  family = binomial(link = 'logit'),
  control = glmerControl(optimizer = "optimx", calc.derivs = FALSE,
                         optCtrl = list(method = "nlminb", 
                                        starttests = FALSE, kkt = FALSE))
)

Anova(int_mod, type = "II", test.statistic = "Chisq")

# all exps
# information       chi-squared(5)=525.16, p<.001 ***
# stake             chi-squared(4)=142.79, p<.001 ***
# info:stake        chi-squared(20)=38.58, p=.008 **

# exp2+3
# information       chi-squared(5)=432.08, p<.001 ***
# stake             chi-squared(4)=148.26, p<.001 ***
# info:stake        chi-squared(20)=28.19, p=.105

# Examine effect of stake
tests <- emmeans(int_mod, list(pairwise ~ stake), 
                 adjust = "Holm", type = "response")
summary(tests)

# 10 cents / 20 cents      z=-0.510, p=.610 
# 10 cents / 30 cents      z=-6.091, p<.001 
# 10 cents / 40 cents      z=-9.236, p<.001 
# 10 cents / 50 cents      z=-7.617, p<.001 
# 20 cents / 30 cents      z=-5.560, p<.001 
# 20 cents / 40 cents      z=-8.695, p<.001 
# 20 cents / 50 cents      z=-7.074, p<.001 
# 30 cents / 40 cents      z=-3.162, p=.006 
# 30 cents / 50 cents      z=-1.463, p=.287 
# 40 cents / 50 cents      z=1.740, p=.246

sumdat <- numdat %>% group_by(stake,subject_num) %>% dplyr::summarise(decision=mean(decision,na.rm=TRUE))
sumdat <- Rmisc::summarySEwithin(data = sumdat, 
                                 measurevar = "decision",
                                 idvar = "subject_num",
                                 withinvars = "stake")

# 10 cents:   M=.744, SEM=.039
# 20 cents:   M=.734, SEM=.027
# 30 cents:   M=.646, SEM=.018
# 40 cents:   M=.599, SEM=.029
# 50 cents:   M=.630, SEM=.031

# Frequentist tests

behdat <- alldata

behdat <- behdat %>% filter(exp_version %in% c("EXP2","EXP3"))
behdat$subject_num <- factor(behdat$subject_num,)
subjdat <- behdat %>% group_by(subject_num,information,stake) %>% 
  dplyr::summarise(decision = mean(decision,na.rm = TRUE))

# Balanced design?
table(subjdat$information,subjdat$stake)

# Perform frequentist repeated measures ANOVA
rm_anova <- ezANOVA(data = subjdat,
                    dv = decision,
                    wid = subject_num,
                    within = .(information,stake),
                    return_aov = TRUE,
                    type = 2)

rm_anova$ANOVA

# all exps <- NOT POSSIBLE DUE TO UNBALANCED STAKE

# exp2+3
# information   F(5,240)=35.634, p<.001, ges=.118
# stake         F(4,192)=4.799, p=.001, ges=.041
# info:stake    F(20,960)=2.216, p=.002, ges=.010

bf <- anovaBF(
  data = subjdat,
  formula = decision ~ information * stake + subject_num,
  whichRandom = "subject_num", 
  rscaleFixed = "wide", 
  rscaleRandom = "nuisance", 
  method = "auto", # tries all methods and settles on smallest error
  iterations = 100000, # minimise error
  progress = TRUE
)

bayesfactor_inclusion(bf)

# all exps
# information   BF=2.17 x 10^43
# stake         BF=5.36 x 10^10
# info:stake    BF=1.00 x 10^-4

# exp2+3
# information   BF=3.14 x 10^39
# stake         BF=5.68 x 10^10
# info:stake    BF=7.01 x 10^-5