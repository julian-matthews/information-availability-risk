# Stats EXP3: early vs. late

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
exp3 <- read.csv(file = 'data_exp3.csv', na.strings = '99')

# Preprocess
exp3$information <-
  factor(
    exp3$information,
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

exp3$early_late <-
  factor(
    exp3$early_late,
    levels = c("early", "late"),
    labels = c("Early", "Late")
  )

exp3$information <- as.ordered(exp3$information)
exp3$stake <- as.ordered(exp3$stake)

# INFO & STAKE MODEL ----

behdat <- exp3

behdat$decision <- factor(behdat$decision,
                          levels = c("0","1"),
                          labels = c("Reject","Accept"))

# Full model including interaction term
int_mod <- glmer(
  decision ~ information * stake + (1 | subject_num),
  data = behdat,
  family = binomial(link = 'logit'),
  control = glmerControl(optimizer = "optimx", calc.derivs = FALSE,
                         optCtrl = list(method = "nlminb", 
                                        starttests = FALSE, kkt = FALSE))
)

Anova(int_mod, type = "II", test.statistic = "Chisq")

# EXP3 <- included people only
# information         chi-squared(3)=105.254, p<.001 ***
# stake               chi-squared(4)=5.902, p=.207
# information:stake   chi-squared(12)=12.732, p=.389

# all participants
# information         chi-squared(3)=101.381, p<.001 ***
# stake               chi-squared(4)=8.121, p=.087
# information:stake   chi-squared(12)=14.532, p=.268

# all info conditions, included people only
# information         chi-squared(5)=190.733, p<.001 ***
# stake               chi-squared(4)=20.249, p<.001 ***
# information:stake   chi-squared(20)=26.115, p=.162

# all info conditions, all participants
# information         chi-squared(5)=186.811, p<.001 ***
# stake               chi-squared(4)=24.957, p<.001 ***
# information:stake   chi-squared(20)=27.273, p=.128

# Information post-hocs
cht <- glht(int_mod, linfct = mcp(information = "Tukey"))
summary(cht, test = adjusted("holm"))

# Sanity check with emmeans
tests <- emmeans(int_mod, list(pairwise ~ information), 
                 adjust = "Holm", type = "response")
summary(tests)

# restricted info conditions, included people only
# One / Two         z=-0.236, p=.813 
# One / Three       z=5.487, p<.001 
# One / Four        z=8.365, p<.001 
# Two / Three       z=5.716, p<.001 
# Two / Four        z=8.583, p<.001 
# Three / Four      z=3.044, p=.005 

# all info conditions, included people only
# None / One        z=-1.530, p=.252
# None / Two        z=-1.768, p=.231
# None / Three      z=3.962, p<.001
# None / Four       z=6.897, p<.001
# None / Five       z=8.662, p<.001
# One / Two         z=-0.240, p=.810 
# One / Three       z=5.503, p<.001 
# One / Four        z=8.393, p<.001 
# One / Five        z=10.078, p<.001
# Two / Three       z=5.736, p<.001 
# Two / Four        z=8.616, p<.001 
# Two / Five        z=10.287, p<.001
# Three / Four      z=3.054, p=.011 
# Three / Five      z=5.019, p<.001
# Four / Five       z=2.064, p=.156

# Means and within-subject SEMS

sumdat <- exp3 %>% group_by(information,subject_num) %>% dplyr::summarise(decision=mean(decision,na.rm=TRUE))
sumdat <- Rmisc::summarySEwithin(data = sumdat, 
                                 measurevar = "decision",
                                 idvar = "subject_num",
                                 withinvars = "information")

# None:   M=.614, SEM=.031
# One:    M=.576, SEM=.039
# Two:    M=.570, SEM=.034
# Three:  M=.722, SEM=.021
# Four:   M=.798, SEM=.026
# Five:   M=.841, SEM=.022

# Stake post-hocs
cht <- glht(int_mod, linfct = mcp(stake = "Tukey"))
summary(cht, test = adjusted("holm"))

# Sanity check with emmeans
tests <- emmeans(int_mod, list(pairwise ~ stake), 
                 adjust = "Holm", type = "response")
summary(tests)

# Stake (all info conditions, included people only)
# 10 cents / 20 cents      z=1.432, p=.608 
# 10 cents / 30 cents      z=-2.092, p=.255 
# 10 cents / 40 cents      z=-1.969, p=.255
# 10 cents / 50 cents      z=-2.079, p=.255 
# 20 cents / 30 cents      z=-3.456, p=.005 
# 20 cents / 40 cents      z=-3.345, p=.006 
# 20 cents / 50 cents      z=-3.466, p=.005 
# 30 cents / 40 cents      z=0.139, p=1.000
# 30 cents / 50 cents      z=0.054, p=1.000 
# 40 cents / 50 cents      z=-0.088, p=1.000

sumdat <- exp3 %>% group_by(stake,subject_num) %>% dplyr::summarise(decision=mean(decision,na.rm=TRUE))
sumdat <- Rmisc::summarySEwithin(data = sumdat, 
                                 measurevar = "decision",
                                 idvar = "subject_num",
                                 withinvars = "stake")

# All info/stake conditions, included people only
# 10 cents:   M=.714, SEM=.062
# 20 cents:   M=.740, SEM=.039
# 30 cents:   M=.654, SEM=.023
# 40 cents:   M=.662, SEM=.039
# 50 cents:   M=.665, SEM=.046

# EARLY vs. LATE MODEL ----

# Subset to information conditions 1:4 (defined early vs. late)
behdat <- exp3 %>% dplyr::filter(exp3$information %in% c("One","Two","Three","Four")) 

behdat$decision <- factor(behdat$decision,
                          levels = c("0","1"),
                          labels = c("Reject","Accept"))

# Full model including interaction term
int_mod2 <- glmer(
  decision ~ information * early_late * stake + (1 | subject_num),
  data = behdat,
  family = binomial(link = 'logit'),
  control = glmerControl(optimizer = "optimx", calc.derivs = FALSE,
                         optCtrl = list(method = "nlminb", 
                                        starttests = FALSE, kkt = FALSE))
)

Anova(int_mod2, type = "II", test.statistic = "Chisq")

# EXP3 <- included people only
# information             chi-squared(3)=101.619, p<.001 ***
# early_late              chi-squared(1)=2.221, p=.136
# stake                   chi-squared(4)=6.078, p=.193
# information:stake       chi-squared(12)=12.745, p=.388
# information:early_late  chi-squared(3)=4.418, p=.220
# stake:early_late        chi-squared(4)=3.267, p=.514
# three-way               chi-squared(12)=11.757, p=.465

# all participants
# information             chi-squared(3)=99.822, p<.001 ***
# early_late              chi-squared(1)=1.906, p=.167
# stake                   chi-squared(4)=8.089, p=.088
# information:stake       chi-squared(12)=14.551, p=.267
# information:early_late  chi-squared(3)=5.050, p=.168
# stake:early_late        chi-squared(4)=2.913, p=.572
# three-way               chi-squared(12)=11.918, p=.452

# Posthoc via multcomp
cht <- glht(int_mod2, linfct = mcp(information = "Tukey"))
summary(cht, test = adjusted("holm"))

# info:EL interaction posthocs
tests <- emmeans(int_mod2,list(pairwise ~ information:early_late), 
                 adjust = "none", type = "response", na.rm = TRUE)
summary(tests)

# A priori contrasts:
# Three Early / Three Late  z=-1.525, puncorrected=.127, pholm=1.000
# Four Early / Four Late    z=-1.575, puncorrected=.115, pholm=1.000 

summarySE(data = behdat,
          measurevar = "decision",
          groupvars = c("information", "early_late"),
          na.rm = TRUE)

# Frequentist tests

behdat <- exp3 %>% dplyr::filter(exp3$information %in% c("One","Two","Three","Four")) 

behdat$subject_num <- factor(behdat$subject_num)
subjdat <- behdat %>% group_by(subject_num,information,early_late,stake) %>% 
  dplyr::summarise(decision = mean(decision,na.rm = TRUE))

# Missing one cell for subject 802_SM
ezDesign(subjdat, x = information, y = stake, row = early_late)

# To fill design, impute the group mean for info=3, stake=20c, EL=late @ subject 802_SM
this = data.frame(subject_num = "802_SM", information = "Three", stake = "20 cents", 
                  early_late = "Late", decision = 0.7966102)
this = rbind(as.data.frame(subjdat),this)
subjdat = as_tibble(this)

# Perform frequentist repeated measures ANOVA
rm_anova <- ezANOVA(data = subjdat,
                    dv = decision,
                    wid = subject_num,
                    within = .(information,early_late,stake),
                    return_aov = TRUE,
                    type = 2)

rm_anova$ANOVA

# information               F(3,57)=13.39, p<.001, ges=.080
# early_late                F(1,19)=2.754, p=.113, ges=.002
# stake                     F(4,76))=0.248, p=.690, ges=.004 *GG corrected

# information:stake         F(12,228)=1.439, p=.149, ges=.011
# information:early_late    F(3,57)=1.707, p=.180, ges=.004 *GG corrected
# stake:early_late          F(4,76))=0.555, p=.669, ges=.002 *GG corrected

# three-way                 F(12,228)=1.144, p=.326, ges = .001

bf <- anovaBF(
  data = subjdat,
  formula = decision ~ information * early_late * stake  + subject_num,
  whichRandom = "subject_num", 
  rscaleFixed = "wide", 
  rscaleRandom = "nuisance", 
  method = "auto", # tries all methods and settles on smallest error
  iterations = 1000000, # minimise error
  progress = TRUE
)

bayesfactor_inclusion(models = bf, match_models = TRUE)

# included people only
# information             BF=2.351 x 10^12
# early_late              BF=0.141
# stake                   BF=0.002
# information:stake       BF=<.001
# information:early_late  BF=0.022
# stake:early_late        BF=0.003
# three-way               BF=<.001

# all participants
# information             BF=9.32 x 10^11
# early_late              BF=0.119
# stake                   BF=0.004
# information:stake       BF=0.0004
# information:early_late  BF=0.025
# stake:early_late        BF=0.002
# three-way               BF=0.002

# Frequentist tests for all info conditions ----

behdat <- exp3

behdat$subject_num <- factor(behdat$subject_num)
subjdat <- behdat %>% group_by(subject_num,information,stake) %>% 
  dplyr::summarise(decision = mean(decision,na.rm = TRUE))

# Missing one cell for subject 802_SM
ezDesign(subjdat, x = information, y = stake)

# Perform frequentist repeated measures ANOVA
rm_anova <- ezANOVA(data = subjdat,
                    dv = decision,
                    wid = subject_num,
                    within = .(information,stake),
                    return_aov = TRUE,
                    type = 2)

rm_anova$ANOVA

# information               F(5,95)=15.575, p<.001, ges=.136
# stake                     F(4,76))=0.753, p=.559, ges=.015
# information:stake         F(20,380)=1.766, p=.023, ges=.021

bf <- anovaBF(
  data = subjdat,
  formula = decision ~ information * stake  + subject_num,
  whichRandom = "subject_num", 
  rscaleFixed = "wide", 
  rscaleRandom = "nuisance", 
  method = "auto", # tries all methods and settles on smallest error
  iterations = 1000000, # minimise error
  progress = TRUE
)

bayesfactor_inclusion(models = bf, match_models = TRUE)

# included people only
# information             BF=3.06 x 10^16
# stake                   BF=0.105
# information:stake       BF=<.001
