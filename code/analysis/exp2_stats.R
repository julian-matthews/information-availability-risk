# Stats exp2: information and stake

## PRELIMINARIES ----

library(car)
library(lmerTest)
library(multcomp)
library(optimx)
library(emmeans)
library(dplyr)

# Load the data and preprocess ----
$dat_location <- ''

setwd(dat_location)
exp2 <- read.csv(file = 'data_exp2.csv', na.strings = '99')

# Preprocess
exp2$information <-
  factor(
    exp2$information,
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

exp2$information <- as.ordered(exp2$information)
exp2$stake <- as.ordered(exp2$stake)

# INFO & STAKE MODEL ----

behdat <- exp2

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

# exp2 (included only)
# information         chi-squared(5)=243.074, p<.001 ***
# stake               chi-squared(4)=153.161, p<.001 ***
# information:stake   chi-squared(20)=19.873, p=.466

# exp2 (all participants)
# information         chi-squared(5)=232.362, p<.001 ***
# stake               chi-squared(4)=143.831, p<.001 ***
# information:stake   chi-squared(20)=20.506, p=.427

# Information post-hocs
cht <- glht(int_mod, linfct = mcp(information = "Tukey"))
summary(cht, test = adjusted("holm"))

# Sanity check with emmeans
tests <- emmeans(int_mod, list(pairwise ~ information), 
                 adjust = "Holm", type = "response")
summary(tests)

summarySE(data = behdat,
          measurevar = "decision",
          groupvars = "information",
          na.rm = TRUE)

# Information
# None / One        z=-3.131, p=.007 
# None / Two        z=-2.012, p=.133 
# None / Three      z=3.895, p<.001 
# None / Four       z=8.445, p<.001 
# None / Five       z=7.941, p<.001 
# One / Two         z=1.119, p=.526 
# One / Three       z=6.952, p<.001 
# One / Four        z=11.328, p<.001 
# One / Five        z=10.877, p<.001 
# Two / Three       z=5.860, p<.001 
# Two / Four        z=10.299, p<.001 
# Two / Five        z=9.829, p<.001 
# Three / Four      z=4.677, p<.001
# Three / Five      z=4.116, p<.001 
# Four / Five       z=-0.606, p=.545 

# Means and within-subject SEMS

sumdat <- exp2 %>% group_by(information,subject_num) %>% dplyr::summarise(decision=mean(decision,na.rm=TRUE))
sumdat <- Rmisc::summarySEwithin(data = sumdat, 
                                 measurevar = "decision",
                                 idvar = "subject_num",
                                 withinvars = "information")

# None:   M=.605, SEM=.027
# One:    M=.534, SEM=.031
# Two:    M=.560, SEM=.018
# Three:  M=.689, SEM=.024
# Four:   M=.788, SEM=.022
# Five:   M=.779, SEM=.025

# Sanity check with emmeans
tests <- emmeans(int_mod, list(pairwise ~ stake), 
                 adjust = "Holm", type = "response")
summary(tests)

summarySE(data = behdat,
          measurevar = "decision",
          groupvars = "stake",
          na.rm = TRUE)

# Stake
# 10 cents / 20 cents      z=-1.837, p=.106 
# 10 cents / 30 cents      z=-6.185, p<.001 
# 10 cents / 40 cents      z=-10.209, p<.001 
# 10 cents / 50 cents      z=-8.102, p<.001 
# 20 cents / 30 cents      z=-4.390, p<.001 
# 20 cents / 40 cents      z=-8.490, p<.001 
# 20 cents / 50 cents      z=-6.327, p<.001 
# 30 cents / 40 cents      z=-4.190, p<.001 
# 30 cents / 50 cents      z=-1.935, p=.106 
# 40 cents / 50 cents      z=2.302, p=.064

sumdat <- exp2 %>% group_by(stake,subject_num) %>% dplyr::summarise(decision=mean(decision,na.rm=TRUE))
sumdat <- Rmisc::summarySEwithin(data = sumdat, 
                                 measurevar = "decision",
                                 idvar = "subject_num",
                                 withinvars = "stake")

# Included participants only
# 10 cents:   M=.765, SEM=.051
# 20 cents:   M=.729, SEM=.038
# 30 cents:   M=.640, SEM=.026
# 40 cents:   M=.555, SEM=.040
# 50 cents:   M=.606, SEM=.042
