from app.schemas.assessment import DimensionMeans, DimensionCutoffMap, BurnoutResult


def classify_dimension(
    value: float,
    dimension: str,
    cutoffs: DimensionCutoffMap,
) -> str:
    c = cutoffs[dimension]

    # Efficacy is reverse-scored: lower = higher burnout risk
    if dimension == "efficacy":
        if value >= c["high"]:
            return "low"
        if value <= c["low"]:
            return "high"
        return "medium"

    if value <= c["low"]:
        return "low"
    if value >= c["high"]:
        return "high"
    return "medium"


def compute_overall_risk(
    means: DimensionMeans,
    cutoffs: DimensionCutoffMap,
) -> str:
    levels = [
        classify_dimension(means.exhaustion, "exhaustion", cutoffs),
        classify_dimension(means.cynicism, "cynicism", cutoffs),
        classify_dimension(means.efficacy, "efficacy", cutoffs),
    ]
    highs = levels.count("high")
    if highs >= 2:
        return "high"
    if highs == 1 or "medium" in levels:
        return "medium"
    return "low"


def compute_dimension_means(
    responses: list[dict],
    item_dimensions: dict[int, str],
) -> DimensionMeans:
    sums = {"exhaustion": 0.0, "cynicism": 0.0, "efficacy": 0.0}
    counts = {"exhaustion": 0, "cynicism": 0, "efficacy": 0}

    for r in responses:
        dim = item_dimensions.get(r["item_number"])
        if not dim:
            continue
        sums[dim] += r["value"]
        counts[dim] += 1

    return DimensionMeans(
        exhaustion=sums["exhaustion"] / counts["exhaustion"] if counts["exhaustion"] else 0,
        cynicism=sums["cynicism"] / counts["cynicism"] if counts["cynicism"] else 0,
        efficacy=sums["efficacy"] / counts["efficacy"] if counts["efficacy"] else 0,
    )


def build_burnout_result(
    means: DimensionMeans,
    cutoffs: DimensionCutoffMap,
) -> BurnoutResult:
    return BurnoutResult(
        exhaustion_mean=means.exhaustion,
        cynicism_mean=means.cynicism,
        efficacy_mean=means.efficacy,
        exhaustion_level=classify_dimension(means.exhaustion, "exhaustion", cutoffs),
        cynicism_level=classify_dimension(means.cynicism, "cynicism", cutoffs),
        efficacy_level=classify_dimension(means.efficacy, "efficacy", cutoffs),
        risk_level=compute_overall_risk(means, cutoffs),
    )
