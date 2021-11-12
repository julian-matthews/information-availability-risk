# PNAS figure 2
# Non-instrumental information availability and decisions under risk for all experiments (3 panels)

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
exp3 <- read.csv(file = 'data_exp3.csv', na.strings = '99') # Earlier and Later

# Setup plot hex-colours
info_colour <- "#fc8d59" # A pleasant orange
colour_blind_friendly = c("#74add1","#4575b4") # Complementary shades of blue

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

## EXPERIMENT 1 ----
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
## EXPERIMENT 2 ----
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

## EXPERIMENT 3 ----

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


# BUILD FIGURE ----

a <- info_exp1 + ylab("Pr(Accept)") + xlab("Informative windows")  + 
  ggtitle("Experiment 1") + theme(plot.title = element_text(size=12,colour="black",vjust = -0.2))

b <- info_exp2 + ylab("") + xlab("Informative windows") +
  ggtitle("Experiment 2") + theme(plot.title = element_text(size=12,colour="black",vjust = -0.2))

c <- info_exp3 + ylab("Pr(Accept)") + xlab("Informative windows") +
  ggtitle("Experiment 3") + theme(plot.title = element_text(size=12,colour="black",vjust = -0.2))

top_row <- plot_grid(a,b, ncol = 2, labels = c("a","b"), 
                        label_size = 15, label_fontface = "bold", label_fontfamily = "Helvetica")

fig2 <- plot_grid(top_row,c, ncol = 1, labels = c("","c"), rel_widths = c(1.2,0.8),
                  label_size = 15, label_fontface = "bold", label_fontfamily = "Helvetica")

ggsave("figure2-information-availability.png", plot = fig2, width = 9, height = 8)
