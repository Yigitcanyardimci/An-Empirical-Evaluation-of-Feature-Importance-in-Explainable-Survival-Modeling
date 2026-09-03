"""
Agreement / disagreement metrics used across the Survival-XAI stability and
multiplicity analyses (RQ1 model multiplicity "011", RQ2 explanation
multiplicity "110", RQ3 numerical stability "111").

All three metrics operate on a "relative importance profile": a
dict[str, float] mapping feature name -> R_bar (relative FI-AUC, as produced
by R/05_global_explain.R / R/06_shap_analysis.R, always non-negative and
summing to ~1 within a single profile).

Metrics
-------
weighted_kendall_tau(profile1, profile2)
    Custom directed weighted Kendall's tau. Weight of a feature pair is
    based only on the FIRST profile's rank (rank 1 = highest R_bar), so
    tau(A, B) != tau(B, A) in general. This is used exactly as-is (no
    scipy.stats.weightedtau / Vigna 2015 substitution) throughout the
    project; ties are handled via average rank (pandas .rank(method="average")),
    which means tied pairs contribute their weight to the denominator but
    zero to the numerator (i.e. ties are not excluded from the denominator).

topk_overlap(profile1, profile2, k)
    Tie-aware Overlap@k: O@k = |A_k ∩ B_k| / k, where A_k/B_k are the
    top-k feature sets by R_bar. When there is an exact tie at the k-th
    rank boundary in either profile, ALL admissible top-k sets are
    enumerated and the overlap is averaged over every (A, B) pair of
    admissible sets - no arbitrary/alphabetical tie-break is used.

symmetric_kl(profile1, profile2, epsilon=1e-6)
    Symmetric KL divergence between the two profiles, treated as discrete
    probability distributions over features. epsilon is added to every
    R_bar value and the profile is renormalized (so it remains a valid
    probability distribution) before taking the natural log. Values with
    |value| < 1e-12 that are negative only due to floating-point rounding
    (mathematically exactly 0) are snapped to 0.0; no other negative value
    is auto-corrected.

Usage
-----
Each function expects two dicts with IDENTICAL key sets (same feature
names) and no NaN values - callers are responsible for (a) verifying
feature-name alignment and (b) excluding/flagging profiles with invalid
(NaN) R_bar (e.g. the known penalized/dataDIVAT3, penalized/rott2 cases)
before calling these functions.
"""

import itertools
import numpy as np
import pandas as pd


def weighted_kendall_tau(profile1: dict, profile2: dict) -> float:
    """Directed weighted Kendall's tau, weighted by profile1's rank.

    w(i,j)  = 1/rank1(i) + 1/rank1(j)
    tau_w   = sum_{i<j} w(i,j) * sign(rank1(j)-rank1(i)) * sign(rank2(j)-rank2(i))
              / sum_{i<j} w(i,j)

    rank1, rank2: average rank of R_bar within each profile, descending
    (rank 1 = highest R_bar = most important feature).

    Returns NaN if the two profiles have fewer than 2 shared features.
    """
    features = sorted(profile1.keys())
    s1 = pd.Series(profile1).reindex(features)
    s2 = pd.Series(profile2).reindex(features)
    rank1 = s1.rank(method="average", ascending=False).to_dict()
    rank2 = s2.rank(method="average", ascending=False).to_dict()

    num, den = 0.0, 0.0
    for a, b in itertools.combinations(features, 2):
        w = 1.0 / rank1[a] + 1.0 / rank1[b]
        sign1 = np.sign(rank1[b] - rank1[a])
        sign2 = np.sign(rank2[b] - rank2[a])
        num += w * sign1 * sign2
        den += w
    return num / den if den != 0 else np.nan


def _valid_topk_sets(profile: dict, k: int):
    """All feature sets of size k that are admissible under R_bar ordering,
    accounting for exact ties at the k-th rank boundary."""
    sorted_items = sorted(profile.items(), key=lambda kv: -kv[1])
    boundary_val = sorted_items[k - 1][1]
    certain = frozenset(name for name, v in sorted_items if v > boundary_val)
    pool = [name for name, v in sorted_items if v == boundary_val]
    slots = k - len(certain)
    return [certain | set(combo) for combo in itertools.combinations(pool, slots)]


def topk_overlap(profile1: dict, profile2: dict, k: int) -> float:
    """Tie-aware Overlap@k, averaged over all admissible top-k set pairs.

    O@k = (1/|A||B|) * sum_{A in A_sets, B in B_sets} |A ∩ B| / k
    """
    a_sets = _valid_topk_sets(profile1, k)
    b_sets = _valid_topk_sets(profile2, k)
    total = sum(len(a & b) / k for a in a_sets for b in b_sets)
    return total / (len(a_sets) * len(b_sets))


def symmetric_kl(profile1: dict, profile2: dict, epsilon: float = 1e-6) -> float:
    """Symmetric KL divergence between two R_bar profiles.

    P_i = (R1_i + eps) / sum_j(R1_j + eps)      (renormalized after adding eps)
    Q_i = (R2_i + eps) / sum_j(R2_j + eps)
    D_sym(P, Q) = 0.5 * sum_i P_i*ln(P_i/Q_i) + 0.5 * sum_i Q_i*ln(Q_i/P_i)
    """
    features = sorted(profile1.keys())
    raw1 = np.array([profile1[f] for f in features], dtype=float)
    raw2 = np.array([profile2[f] for f in features], dtype=float)

    p = (raw1 + epsilon) / (raw1 + epsilon).sum()
    q = (raw2 + epsilon) / (raw2 + epsilon).sum()

    d_sym = 0.5 * np.sum(p * np.log(p / q) + q * np.log(q / p))

    # snap floating-point artefacts (mathematically exact 0, |value|<1e-12) to 0
    if d_sym < 0 and abs(d_sym) < 1e-12:
        d_sym = 0.0
    return d_sym
