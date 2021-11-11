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

# Subset to information conditions 1:4 (defined early vs. late)
behdat <- exp3 %>% dplyr::filter(exp3$information %in% c("One","Two","Three","Four")) 

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

# EXP3
# information chi-squared(3)=105.254, p<.001 ***
# stake chi-squared(4)=5.902, p=.207
# information:stake chi-squared(12)=12.732, p=.389

# Information post-hocs
cht <- glht(int_mod, linfct = mcp(information = "Tukey"))
summary(cht, test = adjusted("holm"))

# Sanity check with emmeans
tests <- emmeans(int_mod, list(pairwise ~ information), 
                 adjust = "Holm", type = "response")
summary(tests)

# One / Two         z=-0.236, p=.813 
# One / Three       z=5.487, p<.001 
# One / Four        z=8.365, p<.001 
# Two / Three       z=5.716, p<.001 
# Two / Four        z=8.583, p<.001 
# Three / Four      z=3.044, p=.005 

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

# EXP3
# information             chi-squared(3)=101.619, p<.001 ***
# early_late              chi-squared(1)=2.221, p=.136
# stake                   chi-squared(4)=6.078, p=.193

# information:stake       chi-squared(12)=12.745, p=.388
# information:early_late  chi-squared(3)=4.418, p=.220
# stake:early_late        chi-squared(4)=3.267, p=.514

# three-way               chi-squared(12)=11.757, p=.465

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

# information             BF=2.351 x 10^12
# early_late              BF=0.141
# stake                   BF=0.002

# information:stake       BF=
# information:early_late  BF=0.022
# stake:early_late        BF=0.003

# three-way               BF=