
# PRELIMINARIES ----
# Load packages and data

# Clean the environment
rm(list=ls())

library(ggplot2)
library(ggbeeswarm)
library(Rmisc)
library(dplyr)
library(cowplot)

$dat_location <- ''
$fig_location <- ''

setwd(dat_location)
exp1 <- read.csv(file = 'data_exp1.csv', na.strings = '99') # Information only
exp2 <- read.csv(file = 'data_exp2.csv', na.strings = '99') # Information & stake
exp3 <- read.csv(file = 'data_exp3.csv', na.strings = '99') # Early vs. late
alldata <- read.csv(file = 'all_responses.csv')

# Setup plot hex-colours
info_colour <- "#ffaf7a" # A pleasant orange
stake_colour <- "#59bfff" # A pleasant blue
colour_blind_friendly = c("#225ea8","#dc3535") # Distinctive blue & red

# Setup exp version shapes
exp1_shape <- 2
exp2_shape <- 19
exp3_shape <- 0

# FACTOR NAMING ----

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

exp2$stake <- 
  factor(
    exp2$stake,
    levels = c(
      "10 cents",
      "20 cents",
      "30 cents",
      "40 cents",
      "50 cents"
    ))

exp2$stake <- as.ordered(exp2$stake)

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
    labels = c("Earlier", "Later")
  )

exp3$information <- as.ordered(exp3$information)

exp3$stake <- 
  factor(
    exp3$stake,
    levels = c(
      "10 cents",
      "20 cents",
      "30 cents",
      "40 cents",
      "50 cents"
    ))

exp3$stake <- as.ordered(exp3$stake)

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

alldata$exp_version <-
  factor(
    alldata$exp_version,
    levels = c("EXP1", "EXP2", "EXP3"),
    labels = c("Experiment 1", "Experiment 2", "Experiment 3")
  )

# PREPARE FIGURES & THEME ----
setwd(fig_location)
theme_julian <- function () { 
  theme_classic() %+replace%
    theme(
      axis.line = element_blank(),
      panel.border = element_rect(colour = "grey", fill = NA, size = 0.5),
      axis.ticks = element_line(colour = "grey"),
      panel.grid = element_blank(),
      axis.title = element_text(face = "bold", size = 12),
      axis.text = element_text(face = "plain", size = 12, colour = "black")
    )
}

# GeomSplitViolin plot
GeomSplitViolin <- ggproto("GeomSplitViolin", GeomViolin, 
                           draw_group = function(self, data, ..., draw_quantiles = NULL) {
                             data <- transform(data, xminv = x - violinwidth * (x - xmin) - 0.05, xmaxv = x + violinwidth *(xmax - x) + 0.05)
                             grp <- data[1, "group"]
                             newdata <- plyr::arrange(transform(data, x = if (grp %% 2 == 1) xminv else xmaxv), if (grp %% 2 == 1) y else -y)
                             newdata <- rbind(newdata[1, ], newdata, newdata[nrow(newdata), ], newdata[1, ])
                             newdata[c(1, nrow(newdata) - 1, nrow(newdata)), "x"] <- round(newdata[1, "x"])
                             
                             if (length(draw_quantiles) > 0 & !scales::zero_range(range(data$y))) {
                               stopifnot(all(draw_quantiles >= 0), all(draw_quantiles <=
                                                                         1))
                               quantiles <- ggplot2:::create_quantile_segment_frame(data, draw_quantiles)
                               aesthetics <- data[rep(1, nrow(quantiles)), setdiff(names(data), c("x", "y")), drop = FALSE]
                               aesthetics$alpha <- rep(1, nrow(quantiles))
                               both <- cbind(quantiles, aesthetics)
                               quantile_grob <- GeomPath$draw_panel(both, ...)
                               ggplot2:::ggname("geom_split_violin", grid::grobTree(GeomPolygon$draw_panel(newdata, ...), quantile_grob))
                             }
                             else {
                               ggplot2:::ggname("geom_split_violin", GeomPolygon$draw_panel(newdata, ...))
                             }
                           })

geom_split_violin <- function(mapping = NULL, data = NULL, stat = "ydensity", position = "identity", ..., 
                              draw_quantiles = NULL, trim = TRUE, scale = "area", na.rm = FALSE, 
                              show.legend = NA, inherit.aes = TRUE) {
  layer(data = data, mapping = mapping, stat = stat, geom = GeomSplitViolin, 
        position = position, show.legend = show.legend, inherit.aes = inherit.aes, 
        params = list(trim = trim, scale = scale, draw_quantiles = draw_quantiles, na.rm = na.rm, ...))
}

g_legend<-function(a.gplot){
  tmp <- ggplot_gtable(ggplot_build(a.gplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)}

# EXPERIMENT 1 ----

exp1_group <- exp1 %>% 
  group_by(information,subject_num) %>% 
  summarise(decision = mean(decision, na.rm = TRUE))

# Compute confidence intervals
groupdat <- summarySEwithin(
  data = exp1_group,
  measurevar = "decision",
  idvar = "subject_num",
  withinvars = "information",
  na.rm = TRUE,
  .drop = FALSE
)

# Summarise data for each individual
subjdat <- exp1 %>% group_by(subject_num,information,.drop = TRUE) %>% 
  dplyr::summarise(decision = mean(decision, na.rm = TRUE))

p1 <- ggplot(data = groupdat, aes(x = information, y = decision)) + 
  geom_violin(data = subjdat, fill = info_colour, size = 0, alpha = 0.15, adjust = 0.9) +
  geom_beeswarm(data = subjdat, shape = exp1_shape, size = 0.5, colour = "lightgrey") +
  geom_line(aes(group = "information"), size = 1.5, colour = info_colour, stat = "identity") +
  geom_errorbar(aes(ymin = decision - se, ymax = decision + se), 
                width = 0, size = 1, alpha = 0.85,
                colour = "black")
  # geom_point(size = 2, shape = 15, colour = "black")

info_exp1 <- p1 + theme_julian() + ylim(-0.01,1.01)

# EXPERIMENT 2 ----

## INFORMATION

exp2_group <- exp2 %>% 
  group_by(information,subject_num) %>% 
  summarise(decision = mean(decision, na.rm = TRUE))

# Compute confidence intervals
groupdat <- summarySEwithin(
  data = exp2_group,
  measurevar = "decision",
  idvar = "subject_num",
  withinvars = "information",
  na.rm = TRUE,
  .drop = FALSE
)

# Summarise data for each individual
subjdat <- exp2 %>% group_by(subject_num,information,.drop = TRUE) %>% 
  dplyr::summarise(decision = mean(decision, na.rm = TRUE))

p2 <- ggplot(data = groupdat, aes(x = information, y = decision)) + 
  geom_violin(data = subjdat, fill = info_colour, size = 0, alpha = 0.15, adjust = 0.9) +
  geom_beeswarm(data = subjdat, shape = exp2_shape, size = 0.5, colour = "lightgrey") +
  geom_line(aes(group = "information"), size = 1.5, colour = info_colour, stat = "identity") +
  geom_errorbar(aes(ymin = decision - se, ymax = decision + se), 
                width = 0, size = 1, alpha = 0.85,
                colour = "black")
  # geom_point(size = 2, shape = 15, colour = "black")

info_exp2 <- p2 + theme_julian() + ylim(-0.01,1.01)

# Null interaction of information and stake

exp2_interaction <- exp2 %>% 
  group_by(information,stake,subject_num) %>% 
  summarise(decision = mean(decision, na.rm = TRUE))

groupdat <- summarySEwithin(
  data = exp2_interaction,
  measurevar = "decision",
  idvar = "subject_num",
  withinvars = c("information","stake"),
  na.rm = TRUE,
  .drop = FALSE
)

width_size = 0.25
inter_exp2 <- ggplot(groupdat,aes(x = information, y = decision, colour = stake)) +
  geom_line(aes(group = stake), 
            position = position_dodge(width = width_size)) +
  geom_errorbar(aes(ymin = decision-se, ymax = decision+se),
                width = 0, size = 1.5,
                position = position_dodge(width = width_size)) +
  geom_point(position = position_dodge(width = width_size),
             shape = 22, stroke = 0, fill = "white", size = 1.5, show.legend = FALSE) +
  labs(colour = "Stake",
       x = "Informative windows", y = "Pr(Accept)") +
  scale_y_continuous(limits = c(0.35, 0.95), 
                     breaks = seq(0.4,0.9,0.1)) +
  theme_julian() + theme(
    legend.text = element_text(size=10, face = "plain"),
    legend.title = element_text(size=10, face = "bold")
  )

inter_exp2 <- inter_exp2 + theme(legend.position = c(0.8,0.2))

# EXPERIMENT 3 ----

## INFORMATION

## Early vs. Late split
# Compute confidence intervals for info 1:4
tmp1 <- exp3 %>% dplyr::filter(exp3$information %in% c("One","Two","Three","Four"))
tmp2 <- exp3 %>% dplyr::filter(exp3$information %in% c("None","Five"))

early_late_group <- tmp1 %>% 
  group_by(information,early_late,subject_num) %>% 
  summarise(decision = mean(decision, na.rm = TRUE))

early_late_data <- summarySEwithin(
  data = early_late_group,
  measurevar = "decision", 
  idvar = "subject_num",
  withinvars = c("information","early_late"),
  na.rm = TRUE,
  .drop = FALSE
)

other_group <- tmp2 %>% 
  group_by(information,subject_num) %>% 
  summarise(decision = mean(decision, na.rm = TRUE))

other_data <- summarySEwithin(
  data = other_group,
  measurevar = "decision",
  idvar = "subject_num",
  withinvars = "information",
  na.rm = TRUE,
  .drop = FALSE
)

# Add fake data to tmp2 to adjust size of plot
fake_data_to_make_plot <- data.frame(information = rep(c("One","Two","Three","Four"),600), decision = rep(0.6,600*4),
                                     exp_version = "EL", 
                                     subject_num = as.factor(rep(levels(factor(exp3$subject_num)),30)), 
                                     trial_num = NA, 
                                     stake = NA, reaction_time = NA, outcome = NA, previous_outcome = NA, 
                                     previous = NA, known = NA, could_know = NA, early_late = NA, knowable = NA)

tmp3 <- rbind(tmp2,fake_data_to_make_plot)

# Summarise data for each individual
subjdat <- tmp3 %>% group_by(subject_num,information,.drop = FALSE) %>% 
  dplyr::summarise(decision = mean(decision, na.rm = TRUE))

limitdat <- tmp2 %>% group_by(subject_num,information,.drop = FALSE) %>% 
  dplyr::summarise(decision = mean(decision, na.rm = TRUE))

splitdat <- tmp1 %>% group_by(subject_num,information, early_late,.drop = FALSE) %>% 
  dplyr::summarise(decision = mean(decision, na.rm = TRUE))

p4 <- ggplot(data = early_late_data, aes(x = information, y = decision)) + 
  geom_violin(data = subjdat, fill = info_colour, size = 0, alpha = 0.15, adjust = 1.5, width = 0.8, scale = "area") +
  geom_split_violin(data = splitdat, 
                    aes(x = information, y = decision, fill = early_late, colour = early_late), 
                    size = 0, alpha = 0.35, adjust = 1.5, width = 1.2, scale = "area") +
  geom_tile(data = data.frame(information = c(2,3,4,5), decision = c(0.5,0.5,0.5,0.5)), width = 0.075, fill = "white") +
  geom_beeswarm(data = splitdat, aes(shape = early_late, colour = early_late), 
             size = 0.5,dodge.width = 0.6, cex = 0.7) +
  geom_beeswarm(data = limitdat, shape = exp3_shape, size = 0.5, colour = "lightgrey", cex = 0.7) +
  geom_point(data = other_data, size = 1, shape = 3, stroke = 1.5, colour = info_colour) +
  geom_errorbar(data = other_data, aes(ymin = decision - se, ymax = decision + se),
                width = 0, size = 1, alpha = 0.85,
                colour = "black") +
  geom_errorbar(aes(colour = early_late, ymin = decision - se, ymax = decision + se), 
                width = 0, size = 1.5, alpha = 0.85,
                position = position_dodge(width = 0.15)) +
  geom_point(aes(shape = early_late), size = 2, colour = "black",
             position = position_dodge2(width = 0.15)) +
  scale_color_manual(values = colour_blind_friendly, aesthetics = c("colour","fill"))

info_exp3_EL <- p4 + theme_julian() + ylim(-0.01,1.01) +
  theme(
    legend.position = c(0.75,0.18),
    legend.background = element_blank(),
    legend.title = element_blank(),
    legend.key.size = unit(6, "mm"),
    legend.text = element_text(size = 12)
  )

# Null interaction of information and stake

exp3_interaction <- exp3 %>% 
  group_by(information,stake,subject_num) %>% 
  summarise(decision = mean(decision, na.rm = TRUE))

groupdat <- summarySEwithin(
  data = exp3_interaction,
  measurevar = "decision",
  idvar = "subject_num",
  withinvars = c("information","stake"),
  na.rm = TRUE,
  .drop = FALSE
)

width_size = 0.25
inter_exp3 <- ggplot(groupdat,aes(x = information, y = decision, colour = stake)) +
  geom_line(aes(group = stake), 
            position = position_dodge(width = width_size)) +
  geom_errorbar(aes(ymin = decision-se, ymax = decision+se),
                width = 0, size = 1.5,
                position = position_dodge(width = width_size)) +
  geom_point(position = position_dodge(width = width_size),
             shape = 22, stroke = 0, fill = "white", size = 1.5, show.legend = FALSE) +
  labs(colour = "Stake",
       x = "Informative windows", y = "Pr(Accept)") +
  scale_y_continuous(limits = c(0.35, 0.95), 
                     breaks = seq(0.4,0.9,0.1)) +
  theme_julian() + theme(
    legend.text = element_text(size=10, face = "plain"),
    legend.title = element_text(size=10, face = "bold")
  )

inter_exp3 <- inter_exp3 + theme(legend.position = c(0.8,0.2))

# FIGURE 2 ----

fig2 <- info_exp1 + ylab("Pr(Accept)") + xlab("Informative windows")  + 
  ggtitle("Experiment 1") + 
  theme(plot.title = element_text(size=12,colour="grey", face = "bold", vjust = -0.2))

ggsave("figure2-experiment1.png", plot = fig2, width = 7, height = 7)

## FIGURE 3 ----
information_exp2 <- info_exp2 + ylab("Pr(Accept)") + xlab("Informative windows") +
  ggtitle("Experiment 2") + 
  theme(plot.title = element_text(size=12,colour="grey", face = "bold", vjust = -0.2))

interaction_exp2 <- inter_exp2 + ylab(" ") +
  ggtitle(" ") + 
  scale_colour_manual(
    values = c("#c7e9b4","#7fcdbb","#41b6c4","#1d91c0","#225ea8")) +
  theme(plot.title = element_text(size=12,colour="black",vjust = -0.2),
        legend.background = element_blank())

fig3 <- plot_grid(information_exp2,interaction_exp2, 
                  ncol = 2, 
                  labels = c("a)","b)"), label_size = 15, 
                  label_fontface = "bold", label_fontfamily = "Helvetica")

ggsave("figure3-experiment2.png", plot = fig3, width = 12, height = 6)

## FIGURE 4 ----

information_exp3 <- info_exp3_EL + ylab("Pr(Accept)") + xlab("Informative windows") +
  ggtitle("Experiment 3") + 
  theme(plot.title = element_text(size=12,colour="grey", face = "bold", vjust = -0.2))

interaction_exp3 <- inter_exp3 + ylab("") + 
  ggtitle("") + 
  scale_colour_manual(
    values = c("#c7e9b4","#7fcdbb","#41b6c4","#1d91c0","#225ea8")) +
  theme(plot.title = element_text(size=12,colour="black",vjust = -0.2),
        legend.background = element_blank())

fig4 <- plot_grid(information_exp3,interaction_exp3, 
                  ncol = 2, 
                  labels = c("a)","b)"), label_size = 15, 
                  label_fontface = "bold", label_fontfamily = "Helvetica")

ggsave("figure4-experiment3.png", plot = fig4, width = 12, height = 6)

## FIGURE 5 ----

plot_dat <- alldata

plot_dat_group <- plot_dat %>% 
  group_by(information,subject_num) %>% 
  summarise(decision = mean(decision, na.rm = TRUE))

# Compute confidence intervals
groupdat <- summarySEwithin(
  data = plot_dat_group,
  measurevar = "decision",
  idvar = "subject_num",
  withinvars = "information",
  na.rm = TRUE,
  .drop = FALSE
)

# Summarise data for each experiment
subjdat <- plot_dat %>% group_by(exp_version,subject_num,information) %>% 
  dplyr::summarise(decision = mean(decision, na.rm = TRUE))

p1 <- ggplot(data = groupdat, aes(x = information, y = decision)) + 
  geom_violin(data = subjdat, fill = info_colour, size = 0, alpha = 0.15, adjust = 0.9) +
  geom_beeswarm(data = subjdat, aes(shape = exp_version), dodge.width = 0.8,
              size = 0.5, colour = "lightgrey", priority = "none", cex = 0.8) +
  geom_line(aes(group = "information"), size = 1.5, colour = info_colour, stat = "identity") +
  geom_errorbar(aes(ymin = decision - se, ymax = decision + se), 
                width = 0, size = 1, alpha = 0.85,
                colour = "black")
  # geom_point(size = 2, shape = 15, colour = "black")

two_three_dat <- alldata %>% filter(exp_version %in% c("Experiment 2", "Experiment 3"))

two_three_group <- two_three_dat %>% 
  group_by(information,stake,subject_num) %>% 
  summarise(decision = mean(decision, na.rm = TRUE))

groupdat <- summarySEwithin(
  data = two_three_group,
  measurevar = "decision",
  idvar = "subject_num",
  withinvars = c("information","stake"),
  na.rm = TRUE,
  .drop = FALSE
)

width_size = 0.25
inter_all <- ggplot(groupdat,aes(x = information, y = decision, colour = stake)) +
  geom_line(aes(group = stake),
            position = position_dodge(width = width_size)) +
  geom_errorbar(aes(ymin = decision-se, ymax = decision+se),
                width = 0, size = 1.5,
                position = position_dodge(width = width_size)) +
  geom_point(position = position_dodge(width = width_size),
             shape = 22, stroke = 0, fill = "white", size = 1.5, show.legend = FALSE) +
  labs(colour = "Stake",
       x = "Informative windows", y = "Pr(Accept)") +
  scale_y_continuous(limits = c(0.35, 0.95), 
                     breaks = seq(0.4,0.9,0.1)) +
  theme_julian() + theme(
    legend.text = element_text(size=10, face = "plain"),
    legend.title = element_text(size=10, face = "bold")
  )

inter_all <- inter_all + ylab("") + 
  ggtitle("Experiments 2 and 3") +
  scale_colour_manual(
    values = c("#c7e9b4","#7fcdbb","#41b6c4","#1d91c0","#225ea8")) +
  theme(plot.title = element_text(size=12,colour="grey", face = "bold", vjust = -0.2),
        legend.background = element_blank(),
        legend.position = c(0.8,0.2))

pooled_plot <- p1 + theme_julian() +
  scale_shape_manual(values = c(exp1_shape,exp2_shape,exp3_shape)) +
  theme(
    legend.position = c(0.75,0.12),
    legend.justification = c(0.02,0),
    legend.margin = margin(0,0,0,0),
    legend.box.margin = margin(-10,-30,-10,-10),
    legend.spacing.y = unit(0.001,"cm"),
    legend.spacing.x = unit(0.001,"cm"),
    legend.text = element_text(size=12, colour = "black")
  ) + xlab("Informative windows") + ylab("Pr(Accept)") +
  labs(shape = "")

fig5 <- plot_grid(pooled_plot, inter_all,
                  ncol = 2,
                  labels = c("a)","b)"), label_size = 15, 
                  label_fontface = "bold", label_fontfamily = "Helvetica")

ggsave("figure5-pooled-analysis.png", plot = fig5, width = 12, height = 6)
