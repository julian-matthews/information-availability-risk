
# PRELIMINARIES ----
# Load packages and data

library(ggplot2)
library(ggbeeswarm)
library(Rmisc)
library(dplyr)
library(cowplot)

$dat_location <- ''
$fig_location <- ''

setwd(dat_location)
exp1 <- read.csv(file = 'data_exp1.csv', na.strings = '99')
exp2 <- read.csv(file = 'data_exp2.csv', na.strings = '99')
exp3 <- read.csv(file = 'data_exp3.csv', na.strings = '99')
alldata <- read.csv(file = "all_experiments.csv")

# Setup plot hex-colours
info_colour <- "#ffaf7a" # A pleasant orange
stake_colour <- "#59bfff" # A pleasant blue
colour_blind_friendly = c("#005ab5","#dc3535") # Distinctive blue & red

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
    ),
    labels = c("10","20","30","40","50")
  )

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
    labels = c("Early", "Late")
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
    ),
    labels = c("10","20","30","40","50")
  )

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

# Compute confidence intervals
groupdat <- summarySE(
  data = exp1,
  measurevar = "decision",
  groupvars = "information",
  na.rm = TRUE,
  .drop = FALSE
)

# Summarise data for each individual
subjdat <- exp1 %>% group_by(subject_num,information,.drop = TRUE) %>% 
  dplyr::summarise(decision = mean(decision, na.rm = TRUE))

p1 <- ggplot(data = groupdat, aes(x = information, y = decision)) + 
  geom_violin(data = subjdat, fill = info_colour, size = 0, alpha = 0.15, adjust = 0.9) +
  geom_beeswarm(data = subjdat, size = 0.5, colour = "lightgrey") +
  geom_errorbar(aes(ymin = decision - ci, ymax = decision + ci), 
                width = 0, size = 2, alpha = 0.85,
                colour = info_colour) +
  geom_line(aes(group = "information"), size = 1, colour = info_colour, stat = "identity") +
  geom_point(size = 2, shape = 15, colour = "black")

info_exp1 <- p1 + theme_julian() + ylim(-0.01,1.01)

# EXPERIMENT 2 ----

## INFORMATION
# Compute confidence intervals
groupdat <- summarySE(
  data = exp2,
  measurevar = "decision",
  groupvars = "information",
  na.rm = TRUE,
  .drop = FALSE
)

# Summarise data for each individual
subjdat <- exp2 %>% group_by(subject_num,information,.drop = TRUE) %>% 
  dplyr::summarise(decision = mean(decision, na.rm = TRUE))

p2 <- ggplot(data = groupdat, aes(x = information, y = decision)) + 
  geom_violin(data = subjdat, fill = info_colour, size = 0, alpha = 0.15, adjust = 0.9) +
  geom_beeswarm(data = subjdat, size = 0.5, colour = "lightgrey") +
  geom_errorbar(aes(ymin = decision - ci, ymax = decision + ci), 
                width = 0, size = 2, alpha = 0.85,
                colour = info_colour) +
  geom_line(aes(group = "information"), size = 1, colour = info_colour, stat = "identity") +
  geom_point(size = 2, shape = 15, colour = "black")

info_exp2 <- p2 + theme_julian() + ylim(-0.01,1.01)

## STAKE
# Compute confidence intervals
groupdat <- summarySE(
  data = exp2,
  measurevar = "decision",
  groupvars = "stake",
  na.rm = TRUE,
  .drop = FALSE
)

# Summarise data for each individual
subjdat <- exp2 %>% group_by(subject_num,stake,.drop = TRUE) %>% 
  dplyr::summarise(decision = mean(decision, na.rm = TRUE))

p3 <- ggplot(data = groupdat, aes(x = stake, y = decision)) + 
  geom_violin(data = subjdat, fill = stake_colour, size = 0, alpha = 0.15, adjust = 0.9) +
  geom_beeswarm(data = subjdat, size = 0.5, colour = "lightgrey") +
  geom_errorbar(aes(ymin = decision - ci, ymax = decision + ci), 
                width = 0, size = 2, alpha = 0.85,
                colour = stake_colour) +
  geom_line(aes(group = "stake"), size = 1, colour = stake_colour, stat = "identity") +
  geom_point(size = 2, shape = 15, colour = "black")

stake_exp2 <- p3 + theme_julian() + ylim(-0.01,1.01)

# Null interaction of information and stake

groupdat <- summarySE(
  data = exp2,
  measurevar = "decision",
  groupvars = c("information","stake"),
  na.rm = TRUE,
  .drop = FALSE
)

groupdat$ci <- as.character(round(groupdat$ci,digits=2))
groupdat$ci <- paste("±",groupdat$ci,sep="")

inter_exp2 <- ggplot(groupdat, aes(x = stake, y = information)) + geom_raster(aes(fill = decision)) +
  scale_fill_gradient(low = "#f7f7f7", high = "#67a9cf", # colorblind/printer friendly
                       limit = c(0.4,0.9)) +
  #theme_linedraw() + 
  geom_text(aes(label = round(decision,digits=2)),colour="grey47",size=3.5) +
  geom_text(aes(label = ci),colour="grey47",size=2.5,nudge_y=-0.25)+
  theme(
    legend.position = "right"
  ) + xlab("Stake") + ylab("Informative windows") +
  labs(fill = "Pr(Accept)") +
  theme_classic() +
  scale_shape_manual(values = c(16,1)) +
  theme(
    axis.line = element_blank(),
    panel.border = element_rect(colour = "grey", fill = NA, size = 0.5),
    axis.ticks = element_line(colour = "grey"),
    panel.grid = element_blank(),
    axis.title = element_text(face = "bold", size = 12),
    axis.text = element_text(face = "plain", size = 12, colour = "black"),
    legend.position = "none",
  )

# EXPERIMENT 3 ----

## INFORMATION

# Compute confidence intervals for info 1:4
tmp1 <- exp3 %>% dplyr::filter(exp3$information %in% c("One","Two","Three","Four"))
tmp2 <- exp3 %>% dplyr::filter(exp3$information %in% c("None","Five"))

early_late_data <- summarySE(
  data = tmp1,
  measurevar = "decision",
  groupvars = c("information","early_late"),
  na.rm = TRUE,
  .drop = FALSE
)

other_data <- summarySE(
  data = tmp2,
  measurevar = "decision",
  groupvars = "information",
  na.rm = TRUE,
  .drop = FALSE
)

# Add fake data to tmp2 to adjust size of plot
fake_data_to_make_plot <- data.frame(information = rep(c("One","Two","Three","Four"),600), decision = rep(0.6,600*4),
                                     exp_version = "EL", 
                                     subject_num = as.factor(rep(levels(exp3$subject_num),30)), 
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
             size = 1,dodge.width = 0.6, cex = 0.7) +
  geom_beeswarm(data = limitdat, size = 0.75, colour = "lightgrey", cex = 0.7) +
  geom_errorbar(data = other_data, aes(ymin = decision - ci, ymax = decision + ci),
                width = 0, size = 2, alpha = 0.85,
                colour = info_colour) +
  geom_point(data = other_data, size = 2, shape = 15, colour = "black") +
  geom_errorbar(aes(colour = early_late, ymin = decision - ci, ymax = decision + ci), 
                width = 0, size = 2, alpha = 0.85,
                position = position_dodge(width = 0.15)) +
  geom_point(aes(shape = early_late), size = 2, colour = "black",
             position = position_dodge2(width = 0.15)) +
  scale_color_manual(values = colour_blind_friendly) +
  scale_fill_manual(values = colour_blind_friendly)

info_exp3 <- p4 + theme_julian() + ylim(-0.01,1.01) +
  theme(
    legend.position = c(0.75,0.18),
    legend.background = element_blank(),
    legend.title = element_blank(),
    legend.key.size = unit(5, "mm"),
    legend.text = element_text(size = 12)
  )

## STAKE
# Compute confidence intervals
groupdat <- summarySE(
  data = exp3,
  measurevar = "decision",
  groupvars = "stake",
  na.rm = TRUE,
  .drop = FALSE
)

# Summarise data for each individual
subjdat <- exp3 %>% group_by(subject_num,stake,.drop = TRUE) %>% 
  dplyr::summarise(decision = mean(decision, na.rm = TRUE))

p5 <- ggplot(data = groupdat, aes(x = stake, y = decision)) + 
  geom_violin(data = subjdat, fill = stake_colour, size = 0, alpha = 0.15, adjust = 0.9) +
  geom_beeswarm(data = subjdat, size = 0.5, colour = "lightgrey") +
  geom_errorbar(aes(ymin = decision - ci, ymax = decision + ci), 
                width = 0, size = 2, alpha = 0.85,
                colour = stake_colour) +
  geom_line(aes(group = "stake"), size = 1, colour = stake_colour, stat = "identity") +
  geom_point(size = 2, shape = 15, colour = "black")

stake_exp3 <- p5 + theme_julian() + ylim(-0.01,1.01)

# Null interaction of information and stake

groupdat <- summarySE(
  data = exp3,
  measurevar = "decision",
  groupvars = c("information","stake"),
  na.rm = TRUE,
  .drop = FALSE
)

groupdat$ci <- as.character(round(groupdat$ci,digits=2))
groupdat$ci <- paste("±",groupdat$ci,sep="")

inter_exp3 <- ggplot(groupdat, aes(x = stake, y = information)) + geom_raster(aes(fill = decision)) +
  scale_fill_gradient(low = "#f7f7f7", high = "#67a9cf", # colorblind/printer friendly
                      limit = c(0.4,0.9)) +
  #theme_linedraw() + 
  geom_text(aes(label = round(decision,digits=2)),colour="grey47",size=3.5) +
  geom_text(aes(label = ci),colour="grey47",size=2.5,nudge_y=-0.25)+
  theme(
    legend.position = "right"
  ) + xlab("Stake") + ylab("") +
  labs(fill = "Pr(Accept)") +
  theme_classic() +
  scale_shape_manual(values = c(16,1)) +
  theme(
    axis.line = element_blank(),
    panel.border = element_rect(colour = "grey", fill = NA, size = 0.5),
    axis.ticks = element_line(colour = "grey"),
    panel.grid = element_blank(),
    axis.title = element_text(face = "bold", size = 12),
    axis.text = element_text(face = "plain", size = 12, colour = "black"),
    legend.position = "right",
    #legend.justification = c(0.02,0),
    # legend.margin = margin(0,2,0,2),
    # legend.box.margin = margin(-10,-10,0,-10),
    # legend.spacing.y = unit(0.1,"cm"),
    # legend.spacing.x = unit(0.4,"cm"),
    # legend.key.height = unit(0.15, "cm"),
    # legend.key.width = unit(0.8, "cm"),
    legend.text = element_text(size=10, face = "plain"),
    legend.title = element_text(size=10, face = "bold")
  )

myLegend<-g_legend(inter_exp3)

inter_exp3 <- inter_exp3 + theme(legend.position = "none")

# FIGURE 2 & 3 ----

a <- info_exp1 + ylab("Pr(Accept)") + xlab("Informative windows")  + 
  ggtitle("Experiment 1") + theme(plot.title = element_text(size=12,colour="black",vjust = -0.2))

b <- info_exp2 + ylab("Pr(Accept)") + xlab("Informative windows") +
  ggtitle("Experiment 2") + theme(plot.title = element_text(size=12,colour="black",vjust = -0.2))
c <- stake_exp2 + ylab("Pr(Accept)") + xlab("Stake (cents)")  +
  ggtitle("") + theme(plot.title = element_text(size=12,colour="black",vjust = -0.2))
supp2 <- inter_exp2 + xlab("Stake (cents)") +
  ggtitle("Experiment 2") + theme(plot.title = element_text(size=12,colour="black",vjust = -0.2))

bottom_row <- plot_grid(b,c, ncol = 2, labels = c("b","c"), 
                        label_size = 15, label_fontface = "bold", label_fontfamily = "Helvetica")

fig2 <- plot_grid(a,bottom_row, ncol = 1, labels = c("a",""), rel_widths = c(1,0.8),
                  label_size = 15, label_fontface = "bold", label_fontfamily = "Helvetica")

d <- info_exp3 + ylab("Pr(Accept)") + xlab("Informative windows") +
  ggtitle("Experiment 3") + theme(plot.title = element_text(size=12,colour="black",vjust = -0.2))
e <- stake_exp3 + ylab("Pr(Accept)") + xlab("Stake (cents)")
supp3 <- inter_exp3 + xlab("Stake (cents)") + theme(legend.position = "none") +
  ggtitle("Experiment 3") + theme(plot.title = element_text(size=12,colour="black",vjust = -0.2))

# another_row <- plot_grid(e,f, ncol = 2, rel_widths = c(1,1.3), labels = c("b","c"),
#                          label_size = 15, label_fontface = "bold", label_fontfamily = "Helvetica")

fig3 <- plot_grid(d, e, ncol = 1, labels = c("a","b"), rel_heights =  c(1.2,0.8),
                  label_size = 15, label_fontface = "bold", label_fontfamily = "Helvetica")

ggsave("figure2-experiment1+2.png", plot = fig2, width = 9, height = 8)
ggsave("figure3-experiment3.png", plot = fig3, width = 9, height = 8)
# ggsave("figure4-experiment3.png", plot = fig4, width = 9, height = 8)

suppfig <- plot_grid(supp2,supp3, myLegend, nrow = 1, labels = c("a","b", ""),
                     rel_widths = c(8/19,8/19,2/19),
                     label_size = 15, label_fontface = "bold", label_fontfamily = "Helvetica")

ggsave("supplementary-figure2-interactions.png", plot=suppfig, width = 9, height = 5)

# POOLED INFORMATION PLOT ----

plot_dat <- alldata

# Compute confidence intervals
groupdat <- summarySE(
  data = plot_dat,
  measurevar = "decision",
  groupvars = "information",
  na.rm = TRUE,
  .drop = FALSE
)

# Summarise data for each experiment
subjdat <- plot_dat %>% group_by(exp_version,subject_num,information) %>% 
  dplyr::summarise(decision = mean(decision, na.rm = TRUE))

p1 <- ggplot(data = groupdat, aes(x = information, y = decision)) + 
  geom_violin(data = subjdat, fill = info_colour, size = 0, alpha = 0.15, adjust = 0.9) +
  geom_beeswarm(data = subjdat, aes(shape = exp_version), dodge.width = 0.8,
              size = 1, colour = "lightgrey", priority = "none", cex = 0.8) +
  geom_errorbar(aes(ymin = decision - ci, ymax = decision + ci), 
                width = 0, size = 2, alpha = 0.85,
                colour = info_colour) +
  geom_line(aes(group = "information"), size = 1.5, colour = info_colour, stat = "identity") +
  geom_point(size = 2, shape = 15, colour = "black")

pooled_plot <- p1 + theme_julian() +
  scale_shape_manual(values = c(2,19,0)) +
  theme(
    # legend.position = "none",
    legend.position = c(0.75,0.12),
    legend.justification = c(0.02,0),
    legend.margin = margin(0,0,0,0),
    legend.box.margin = margin(-10,-30,-10,-10),
    legend.spacing.y = unit(0.001,"cm"),
    legend.spacing.x = unit(0.001,"cm"),
    legend.text = element_text(size=12, colour = "black")
  ) + xlab("Informative windows") + ylab("Pr(Accept)") +
  labs(shape = "")

fig4 <- pooled_plot

setwd(fig_location)
ggsave("figure4-pooled-analysis.png", plot = fig4, width = 8, height = 7)
