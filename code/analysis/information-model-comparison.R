## MODEL COMPARISON

dat_location <- ''

setwd(dat_location)
alldata <- read.csv(file = "information_value_complete.csv")

# BUILD MODELS ----

library(lmerTest)

tmp <- alldata

tmp$decision <- factor(tmp$decision,
                       levels = c("0","1"),
                       labels = c("Reject","Accept"))

tmp$subject_num <- factor(tmp$subject_num)

# Baseline model
model1 <- glmer(
  decision ~ 1 + (1 | subject_num),
  data = tmp,
  family = binomial(link = 'logit'),
  control = glmerControl(optimizer = "optimx", calc.derivs = FALSE,
                         optCtrl = list(method = "nlminb", 
                                        starttests = FALSE, kkt = FALSE))
)

# Linear model
model2 <- glmer(
  decision ~ mod2_linear + (1 | subject_num),
  data = tmp,
  family = binomial(link = 'logit'),
  control = glmerControl(optimizer = "optimx", calc.derivs = FALSE,
                         optCtrl = list(method = "nlminb", 
                                        starttests = FALSE, kkt = FALSE))
)

# Entropy model
model3 <- glmer(
  decision ~ mod3_entropy + (1 | subject_num),
  data = tmp,
  family = binomial(link = 'logit'),
  control = glmerControl(optimizer = "optimx", calc.derivs = FALSE,
                         optCtrl = list(method = "nlminb", 
                                        starttests = FALSE, kkt = FALSE))
)

# Probability of early resolution of uncertainty model
model4 <- glmer(
  decision ~ mod4_res_uncertainty + (1 | subject_num),
  data = tmp,
  family = binomial(link = 'logit'),
  control = glmerControl(optimizer = "optimx", calc.derivs = FALSE,
                         optCtrl = list(method = "nlminb", 
                                        starttests = FALSE, kkt = FALSE))
)

# Early resolution model
winning_mod <- glm(
  decision ~ mod4_res_uncertainty + 1,
  data = tmp,
  family = binomial(link = 'logit')
)

tmp1 <- AIC(model1,model2,model3,model4)
tmp2 <- BIC(model1,model2,model3,model4)

tmp1$labels <- factor(c("model1","model2","model3","model4"),
                      levels = c("model1","model2","model3","model4"),
                      labels = c("1","2","3","4"))

tmp2$labels <- factor(c("model1","model2","model3","model4"),
                      levels = c("model1","model2","model3","model4"),
                      labels = c("1","2","3","4"))

model_fits <- tmp1[order(-tmp1$AIC),]
#model_fits <- tmp2[order(-tmp2$BIC),]

# TEST GOODNESS OF FIT ----

library(boot)

# Takes ~8 minutes to perform 1000 simulations: CI [1.065,1.384]
# model4_boots <- bootMer(model4, FUN = fixef, nsim = 1000, verbose = TRUE)
# boot.ci(conf = 0.99, model4_boots, index = 2, type = "perc")

# MAXIMAL APPROACH ----

max_model <- glmer(
  decision ~ mod2_linear +  mod3_entropy + mod4_res_uncertainty + (1 | subject_num),
  data = tmp,
  family = binomial(link = 'logit'),
  control = glmerControl(optimizer = "optimx", calc.derivs = FALSE,
                         optCtrl = list(method = "nlminb", 
                                        starttests = FALSE, kkt = FALSE))
)

drop1(max_model, test = "Chisq")