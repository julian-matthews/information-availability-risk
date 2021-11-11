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

# INFO MODEL ----

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

summarySE(data = behdat,
          measurevar = "decision",
          groupvars = "information",
          na.rm = TRUE)

# None / One        z=-3.391, p=.003 
# None / Two        z=-2.160, p=.092 
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