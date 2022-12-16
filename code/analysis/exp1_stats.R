# Stats exp1: information only

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
library(Rmisc)

# Load the data and preprocess ----
$dat_location <- ''

setwd(dat_location)
exp1 <- read.csv(file = 'data_exp1.csv', na.strings = '99')

# Preprocess
exp1$information <-
  factor(
    exp1$information,
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

exp1$information <- as.ordered(exp1$information)

# INFO MODEL ----

behdat <- exp1

behdat$decision <- factor(behdat$decision,
                          levels = c("0","1"),
                          labels = c("Reject","Accept"))

# Full model
int_mod <- glmer(
  decision ~ information + (1 | subject_num),
  data = behdat,
  family = binomial(link = 'logit'),
  control = glmerControl(optimizer = "optimx", calc.derivs = FALSE,
                         optCtrl = list(method = "nlminb", 
                                        starttests = FALSE, kkt = FALSE))
)

Anova(int_mod, type = "II", test.statistic = "Chisq")

emm <- emmeans(int_mod, "information")
eff_size(emm, sigma = sigma(int_mod), edf = df.residual(int_mod))

# exp1
# information       chi-squared(5)=105.651, p<.001 ***

# Information post-hocs
cht <- glht(int_mod, linfct = mcp(information = "Tukey"))
summary(cht, test = adjusted("holm"))

# Sanity check with emmeans
tests <- emmeans(int_mod, list(pairwise ~ information), 
                 adjust = "Holm", type = "response")
summary(tests)

# None / One        z=-1.218, p=.893
# None / Two        z=-0.008, p=.993
# None / Three      z=3.918, p<.001
# None / Four       z=6.571, p<.001
# None / Five       z=5.503, p<.001
# One / Two         z=1.210, p=.893
# One / Three       z=5.112, p<.001
# One / Four        z=7.713, p<.001
# One / Five        z=6.669, p<.001
# Two / Three       z=3.926, p<.001
# Two / Four        z=6.578, p<.001
# Two / Five        z=5.511, p<.001
# Three / Four      z=2.769, p=.034
# Three / Five      z=1.645, p=.500
# Four / Five       z=-1.132, p=.893

sumdat <- exp1 %>% group_by(information,subject_num) %>% dplyr::summarise(decision=mean(decision,na.rm=TRUE))
sumdat <- Rmisc::summarySEwithin(data = sumdat, 
                                 measurevar = "decision",
                                 idvar = "subject_num",
                                 withinvars = "information")

# None:   M=.672, SEM=.036
# One:    M=.642, SEM=.031
# Two:    M=.671, SEM=.028
# Three:  M=.765, SEM=.030
# Four:   M=.825, SEM=.033
# Five:   M=.801, SEM=.020

# Frequentist tests

behdat <- exp1

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

# information   F(5,105)=6.570, p<.001, ges=.138

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

# information   BF=867.09

