# RQ5_ggstatsplot_refined - layout/readability only, no analytic changes.
# Same pooled data, same 3-panel structure, same correlation results
# (statsExpressions::corr_test, type="nonparametric" = Spearman).

setwd("~/Survival-XAI")
.libPaths(c("~/R/library", .libPaths()))
suppressMessages({
  library(ggstatsplot)
  library(ggside)
  library(dplyr)
  library(ggplot2)
})

pooled <- read.csv("results/rq5/rq6_censoring_agreement.csv", stringsAsFactors = FALSE)
pooled <- pooled %>% filter(is.finite(value), is.finite(censoring_rate))

fmt_p <- function(p) if (p < 0.001) "p < 0.001" else sprintf("p = %.3f", p)

two_breaks <- function(limits) {
  hi <- floor(limits[2] / 5) * 5
  if (hi <= 0) hi <- round(limits[2] * 0.85)
  c(0, hi)
}

mk <- function(metric_name, ylab, title_lab) {
  d <- pooled %>% filter(metric == metric_name)

  st <- statsExpressions::corr_test(d, censoring_rate, value, type = "nonparametric")
  rho   <- st$estimate
  Sval  <- st$statistic
  pval  <- st$p.value
  ci_lo <- st$conf.low
  ci_hi <- st$conf.high
  n     <- st$n.obs

  subtitle_txt <- sprintf(
    "rho = %.2f  [%.2f, %.2f]   S = %.2e   %s   n = %d",
    rho, ci_lo, ci_hi, Sval, fmt_p(pval), n
  )

  p <- ggscatterstats(
    data = d,
    x = censoring_rate,
    y = value,
    type = "nonparametric",
    marginal = TRUE,
    bf.message = FALSE,
    results.subtitle = FALSE,
    point.args = list(size = 1.8, alpha = 0.35, stroke = 0, color = "grey30"),
    smooth.line.args = list(linewidth = 1.1, color = "#2166ac", method = "lm",
                             formula = y ~ x, alpha = 0.15),
    xsidehistogram.scale = 0.28,
    ysidehistogram.scale = 0.28,
    xlab = "Censoring Rate (%)",
    ylab = ylab,
    title = title_lab,
    subtitle = subtitle_txt,
    ggtheme = ggplot2::theme_bw(base_size = 20),
    ggplot.component = list(
      ggplot2::scale_x_continuous(breaks = scales::pretty_breaks(n = 4)),
      ggplot2::scale_y_continuous(breaks = scales::pretty_breaks(n = 5)),
      ggplot2::theme(
        plot.margin      = ggplot2::margin(t = 10, r = 34, b = 10, l = 14),
        plot.title       = ggplot2::element_text(size = 18, face = "bold"),
        plot.subtitle    = ggplot2::element_text(size = 13, color = "grey20"),
        axis.title.y     = ggplot2::element_text(margin = ggplot2::margin(r = 12)),
        axis.title.x     = ggplot2::element_text(margin = ggplot2::margin(t = 8)),
        ggside.axis.text  = ggplot2::element_text(size = 9, color = "grey30"),
        ggside.panel.grid = ggplot2::element_blank()
      )
    )
  )

  # Marginal histogram scales are attached by ggstatsplot AFTER ggplot.component
  # is applied, so overriding them must happen on the returned object, applied last.
  p <- p +
    ggside::scale_xsidey_continuous(
      breaks = two_breaks
    ) +
    ggside::scale_ysidex_continuous(
      breaks = two_breaks,
      position = "top"
    )
  p
}

p1 <- mk("weighted_tau", "Weighted Kendall's Tau", "A: Weighted Kendall")
p2 <- mk("overlap_at_3", "Top-3 Overlap",           "B: Top-3 Overlap")
p3 <- mk("symmetric_kl", "Symmetric KL Divergence", "C: Symmetric KL")

combined <- combine_plots(
  list(p1, p2, p3),
  plotgrid.args = list(nrow = 1, ncol = 3)
) & ggplot2::theme(plot.margin = ggplot2::margin(l = 10, r = 10))

dir.create("rq5/figures", recursive = TRUE, showWarnings = FALSE)
ggplot2::ggsave("figures/rq5/RQ5_ggstatsplot_refined.pdf", plot = combined,
                 width = 24, height = 8.5, dpi = 300, bg = "white", limitsize = FALSE)
ggplot2::ggsave("figures/rq5/RQ5_ggstatsplot_refined.png", plot = combined,
                 width = 24, height = 8.5, dpi = 300, bg = "white", limitsize = FALSE)

cat("Kaydedildi: rq5/figures/RQ5_ggstatsplot_refined.{png,pdf} (24x8.5in, 300dpi)\n")
