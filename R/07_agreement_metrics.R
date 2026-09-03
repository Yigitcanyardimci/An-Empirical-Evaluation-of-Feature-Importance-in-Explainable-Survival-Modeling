# 07_agreement_metrics.R
#
# Agreement / disagreement metrics used across the Survival-XAI stability and
# multiplicity analyses (RQ1 model multiplicity "011", RQ2 explanation
# multiplicity "110", RQ3 numerical stability "111").
#
# Each metric operates on a "relative importance profile": a named numeric
# vector (names = feature names, values = R_bar), i.e. exactly the R_bar
# column produced by calculate_vimp_summary_from_long() in
# 05_global_explain.R / 06_shap_analysis.R (non-negative, sums to ~1 within
# a single profile).
#
# Callers are responsible for (a) verifying that the two profiles being
# compared have identical feature-name sets and (b) excluding/flagging
# profiles with invalid (NA) R_bar (e.g. the known penalized/dataDIVAT3,
# penalized/rott2 cases) before calling these functions.

#' Directed weighted Kendall's tau
#'
#' w(i,j) = 1/rank1(i) + 1/rank1(j)   (weight based ONLY on profile1's rank)
#' tau_w  = sum_{i<j} w(i,j) * sign(rank1(j)-rank1(i)) * sign(rank2(j)-rank2(i))
#'          / sum_{i<j} w(i,j)
#'
#' rank1/rank2: average rank of R_bar within each profile, descending
#' (rank 1 = highest R_bar = most important feature; ties -> average rank
#' via rank(ties.method = "average")).
#'
#' NOTE: this is a DIRECTED metric (tau(A,B) != tau(B,A) in general) and is
#' used as-is throughout the project (no stats::cor(method="kendall") or
#' Vigna 2015 / scipy.stats.weightedtau substitution). Ties contribute their
#' weight to the denominator but zero to the numerator (i.e. ties are not
#' excluded from the denominator).
weighted_kendall_tau <- function(profile1, profile2) {
  features <- sort(intersect(names(profile1), names(profile2)))
  p1 <- profile1[features]
  p2 <- profile2[features]

  rank1 <- rank(-p1, ties.method = "average")
  rank2 <- rank(-p2, ties.method = "average")

  pairs <- combn(features, 2, simplify = FALSE)
  num <- 0
  den <- 0
  for (pair in pairs) {
    a <- pair[1]; b <- pair[2]
    w  <- 1 / rank1[a] + 1 / rank1[b]
    s1 <- sign(rank1[b] - rank1[a])
    s2 <- sign(rank2[b] - rank2[a])
    num <- num + w * s1 * s2
    den <- den + w
  }
  if (den == 0) return(NA_real_)
  as.numeric(num / den)
}

#' All admissible top-k feature sets under R_bar ordering, accounting for
#' exact ties at the k-th rank boundary. Internal helper for topk_overlap().
.valid_topk_sets <- function(profile, k) {
  ord         <- order(-profile)
  sorted_vals <- profile[ord]
  boundary_val <- sorted_vals[k]

  certain <- names(sorted_vals)[sorted_vals > boundary_val]
  pool    <- names(sorted_vals)[sorted_vals == boundary_val]
  slots   <- k - length(certain)

  combos <- combn(pool, slots, simplify = FALSE)
  lapply(combos, function(x) union(certain, x))
}

#' Tie-aware Overlap@k
#'
#' O@k = |A_k ∩ B_k| / k
#'
#' When there is an exact tie at the k-th rank boundary in either profile,
#' ALL admissible top-k sets are enumerated and the overlap is averaged over
#' every (A, B) pair of admissible sets - no arbitrary/alphabetical
#' tie-break is used:
#'   O@k = (1 / (|A_sets| * |B_sets|)) * sum_{A,B} |A ∩ B| / k
topk_overlap <- function(profile1, profile2, k) {
  features <- sort(intersect(names(profile1), names(profile2)))
  p1 <- profile1[features]
  p2 <- profile2[features]

  a_sets <- .valid_topk_sets(p1, k)
  b_sets <- .valid_topk_sets(p2, k)

  total <- 0
  for (a in a_sets) {
    for (b in b_sets) {
      total <- total + length(intersect(a, b)) / k
    }
  }
  total / (length(a_sets) * length(b_sets))
}

#' Symmetric KL divergence between two R_bar profiles
#'
#' P_i = (R1_i + eps) / sum_j(R1_j + eps)   <- renormalized AFTER adding eps
#' Q_i = (R2_i + eps) / sum_j(R2_j + eps)
#' D_sym(P,Q) = 0.5 * sum_i P_i*ln(P_i/Q_i) + 0.5 * sum_i Q_i*ln(Q_i/P_i)
#'
#' epsilon = 1e-6 by default. Floating-point artefacts that are
#' mathematically exactly 0 but appear as a tiny negative number
#' (|value| < 1e-12) are snapped to 0; no other negative value is
#' auto-corrected.
symmetric_kl <- function(profile1, profile2, epsilon = 1e-6) {
  features <- sort(intersect(names(profile1), names(profile2)))
  raw1 <- profile1[features]
  raw2 <- profile2[features]

  p <- (raw1 + epsilon) / sum(raw1 + epsilon)
  q <- (raw2 + epsilon) / sum(raw2 + epsilon)

  d_sym <- 0.5 * sum(p * log(p / q)) + 0.5 * sum(q * log(q / p))

  if (d_sym < 0 && abs(d_sym) < 1e-12) d_sym <- 0
  as.numeric(d_sym)
}
