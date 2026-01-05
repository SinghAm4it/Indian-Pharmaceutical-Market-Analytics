/* =============================================================================
1) Dosage Form Price Landscape
Purpose:
- Understand how pricing differs across dosage forms.
- Helps identify premium vs mass-market formulations.
============================================================================= */
SELECT
    dosage_form,
    COUNT(*) AS product_count,          -- number of products per dosage form
    AVG(price_inr) AS avg_price,         -- average market price
    MIN(price_inr) AS min_price,         -- cheapest product
    MAX(price_inr) AS max_price          -- most expensive product
FROM pharma
GROUP BY dosage_form
ORDER BY avg_price DESC;                -- highest priced forms on top

/* =============================================================================
2) Therapeutic Class Market Size & Pricing Overview
Purpose:
- Understand which therapy segments dominate the market by volume.
- Compare average pricing across therapeutic classes.
============================================================================= */
SELECT
    therapeutic_class,
    COUNT(*) AS product_count,          -- number of products in therapy
    ROUND(AVG(price_inr), 2) AS avg_price,
    MIN(price_inr) AS min_price,
    MAX(price_inr) AS max_price
FROM pharma
GROUP BY therapeutic_class
ORDER BY product_count DESC;

/* =============================================================================
3) Price Inconsistency for Same Drug + Strength + Pack
Purpose:
- Detect price manipulation or branding premium for identical formulations.
- Useful for regulator, procurement, and pricing audits.
============================================================================= */
WITH price_stats AS (
    SELECT
        primary_ingredient,
        primary_strength,
        packaging_raw,
        MIN(price_inr) AS min_price,
        MAX(price_inr) AS max_price
    FROM pharma
    GROUP BY primary_ingredient, primary_strength, packaging_raw
)
SELECT
    primary_ingredient,
    primary_strength,
    packaging_raw,
    min_price,
    max_price,
    (max_price - min_price) AS price_gap,               -- absolute gap
    ROUND((max_price - min_price) * 100.0 / min_price, 2) AS price_gap_pct
FROM price_stats
WHERE max_price > min_price
ORDER BY price_gap_pct DESC, price_gap DESC
LIMIT 10;                                               -- worst offenders

/* =============================================================================
4) Market Share by Active Ingredient
Purpose:
- Identify dominant molecules in the Indian pharma market.
- Helps portfolio planning and demand forecasting.
============================================================================= */
WITH ingredient_counts AS (
    SELECT 
        primary_ingredient,
        COUNT(*) AS product_count
    FROM pharma
    GROUP BY primary_ingredient
),
total_products AS (
    SELECT SUM(product_count) AS total_count
    FROM ingredient_counts
)
SELECT
    ic.primary_ingredient,
    ic.product_count,
    ROUND(ic.product_count * 100.0 / tp.total_count, 2) AS market_share_pct
FROM ingredient_counts ic
CROSS JOIN total_products tp
ORDER BY market_share_pct DESC
LIMIT 10;

/* =============================================================================
5) Brand Price Premium vs Market Average
Purpose:
- Identify brands pricing significantly above the market benchmark.
- Highlights premium branding or potential overpricing.
============================================================================= */
WITH ingredient_avg AS (
    SELECT
        primary_ingredient,
        primary_strength,
        packaging_raw,
        AVG(price_inr) AS avg_market_price
    FROM pharma
    GROUP BY primary_ingredient, primary_strength, packaging_raw
)
SELECT
    p.brand_name,
    p.manufacturer,
    p.primary_ingredient,
    p.primary_strength,
    p.packaging_raw,
    p.price_inr,
    ROUND(i.avg_market_price, 2) AS market_avg_price,
    ROUND(p.price_inr - i.avg_market_price, 2) AS price_premium
FROM pharma p
JOIN ingredient_avg i
  ON p.primary_ingredient = i.primary_ingredient
 AND p.primary_strength = i.primary_strength
 AND p.packaging_raw = i.packaging_raw
WHERE p.price_inr > i.avg_market_price * 1.5   -- 50% above market
ORDER BY price_premium DESC
LIMIT 15;

/* =============================================================================
6) Manufacturer Portfolio Mix (Single vs Combination Drugs)
Purpose:
- Understand manufacturer strategy: simple formulations vs combination drugs.
- Combination drugs usually indicate higher margins and complexity.
============================================================================= */
SELECT
    manufacturer,
    ROUND(
        AVG(CASE WHEN num_active_ingredients = 1 THEN 1 ELSE 0 END) * 100,
        2
    ) AS single_pct,
    ROUND(
        AVG(CASE WHEN num_active_ingredients > 1 THEN 1 ELSE 0 END) * 100,
        2
    ) AS combo_pct
FROM pharma
GROUP BY manufacturer
HAVING COUNT(*) > 20              -- avoid small-sample bias
ORDER BY combo_pct DESC;

/* =============================================================================
7) Therapeutic Class Pricing & Volatility
Purpose:
- Compare therapy segments by price level and instability.
- High volatility often indicates fragmented or competitive markets.
============================================================================= */
SELECT
    therapeutic_class,
    ROUND(AVG(price_inr), 2) AS avg_price,
    COUNT(*) AS product_count,
    ROUND(STDDEV(price_inr), 2) AS price_volatility,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS volume_rank,
    RANK() OVER (ORDER BY AVG(price_inr) DESC) AS price_rank
FROM pharma
GROUP BY therapeutic_class
ORDER BY price_volatility DESC;

/* =============================================================================
8) Therapeutic Portfolio Distribution for Top Diversified Manufacturers
Purpose:
- See how large manufacturers distribute products across therapies.
- Reveals specialization vs diversification strategy.
============================================================================= */
WITH top_diversified AS (
    SELECT
        manufacturer
    FROM pharma
    GROUP BY manufacturer
    ORDER BY COUNT(DISTINCT therapeutic_class) DESC, COUNT(*) DESC
    LIMIT 10
)
SELECT
	manufacturer,
	COUNT(*) AS total_products,
	ROUND(AVG(CASE WHEN therapeutic_class = 'antibiotic' THEN 1 ELSE 0 END) * 100, 2) AS antibiotic_pct,
	ROUND(AVG(CASE WHEN therapeutic_class = 'antidiabetic' THEN 1 ELSE 0 END) * 100, 2) AS antidiabetic_pct,
	ROUND(AVG(CASE WHEN therapeutic_class = 'antihypertensive' THEN 1 ELSE 0 END) * 100, 2) AS antihypertensive_pct,
	ROUND(AVG(CASE WHEN therapeutic_class = 'analgesic' THEN 1 ELSE 0 END) * 100, 2) AS analgesic_pct,
	ROUND(AVG(CASE WHEN therapeutic_class = 'antacid' THEN 1 ELSE 0 END) * 100, 2) AS antacid_pct,
	ROUND(AVG(CASE WHEN therapeutic_class = 'antihistamine' THEN 1 ELSE 0 END) * 100, 2) AS antihistamine_pct,
	ROUND(AVG(CASE WHEN therapeutic_class = 'antidepressant' THEN 1 ELSE 0 END) * 100, 2) AS antidepressant_pct,
	ROUND(AVG(CASE WHEN therapeutic_class = 'bronchodilator' THEN 1 ELSE 0 END) * 100, 2) AS bronchodilator_pct,
	ROUND(AVG(CASE WHEN therapeutic_class = 'corticosteroid' THEN 1 ELSE 0 END) * 100, 2) AS corticosteroid_pct,
	ROUND(AVG(CASE WHEN therapeutic_class = 'diuretic' THEN 1 ELSE 0 END) * 100, 2) AS diuretic_pct,
	ROUND(AVG(CASE WHEN therapeutic_class = 'other' THEN 1 ELSE 0 END) * 100, 2) AS other_pct
FROM pharma
WHERE manufacturer IN (SELECT manufacturer FROM top_diversified)
GROUP BY manufacturer;

/* =============================================================================
9) Dosage Form Diversification for Top Manufacturers
Purpose:
- Analyze formulation diversity (tablets, syrups, injectables, etc.).
- Indicates manufacturing capability and market reach.
============================================================================= */
WITH top_diversified AS (
    SELECT
        manufacturer
    FROM pharma
    GROUP BY manufacturer
    ORDER BY COUNT(DISTINCT dosage_form) DESC, COUNT(*) DESC
    LIMIT 10
)
SELECT
	manufacturer,
	COUNT(*) AS total_products,
	ROUND(AVG(CASE WHEN dosage_form = 'tablet' THEN 1 ELSE 0 END) * 100, 2) AS tablet_pct,
	ROUND(AVG(CASE WHEN dosage_form = 'capsule' THEN 1 ELSE 0 END) * 100, 2) AS capsule_pct,
	ROUND(AVG(CASE WHEN dosage_form = 'syrup' THEN 1 ELSE 0 END) * 100, 2) AS syrup_pct,
	ROUND(AVG(CASE WHEN dosage_form = 'suspension' THEN 1 ELSE 0 END) * 100, 2) AS suspension_pct,
	ROUND(AVG(CASE WHEN dosage_form = 'injection' THEN 1 ELSE 0 END) * 100, 2) AS injection_pct,
	ROUND(AVG(CASE WHEN dosage_form = 'inhaler' THEN 1 ELSE 0 END) * 100, 2) AS inhaler_pct,
	ROUND(AVG(CASE WHEN dosage_form = 'respules' THEN 1 ELSE 0 END) * 100, 2) AS respules_pct,
	ROUND(AVG(CASE WHEN dosage_form = 'drops' THEN 1 ELSE 0 END) * 100, 2) AS drops_pct,
	ROUND(AVG(CASE WHEN dosage_form = 'spray' THEN 1 ELSE 0 END) * 100, 2) AS spray_pct,
	ROUND(AVG(CASE WHEN dosage_form = 'solution' THEN 1 ELSE 0 END) * 100, 2) AS solution_pct,
	ROUND(AVG(CASE WHEN dosage_form = 'cream' THEN 1 ELSE 0 END) * 100, 2) AS cream_pct,
	ROUND(AVG(CASE WHEN dosage_form = 'gel' THEN 1 ELSE 0 END) * 100, 2) AS gel_pct,
	ROUND(AVG(CASE WHEN dosage_form = 'ointment' THEN 1 ELSE 0 END) * 100, 2) AS ointment_pct,
	ROUND(AVG(CASE WHEN dosage_form = 'powder' THEN 1 ELSE 0 END) * 100, 2) AS powder_pct,
	ROUND(AVG(CASE WHEN dosage_form = 'other' THEN 1 ELSE 0 END) * 100, 2) AS other_pct
FROM pharma
WHERE manufacturer IN (SELECT manufacturer FROM top_diversified)
GROUP BY manufacturer;

/* =============================================================================
10) Top Therapeutic Focus per Manufacturer
Purpose:
- Identify which therapy dominates each manufacturer’s portfolio.
- Helps understand core competency areas.
============================================================================= */
SELECT
    manufacturer,
    therapeutic_class,
    COUNT(*) AS product_count,
    RANK() OVER (
        PARTITION BY manufacturer
        ORDER BY COUNT(*) DESC
    ) AS therapy_rank
FROM pharma
GROUP BY manufacturer, therapeutic_class;

/* =============================================================================
11) Top Dosage Form per Manufacturer
Purpose:
- Identify formulation strength for each manufacturer.
- Useful for operational and production insights.
============================================================================= */
SELECT
	manufacturer,
	dosage_form,
	COUNT(*) AS product_count,
	RANK() OVER (
		PARTITION BY manufacturer
		ORDER BY COUNT(*) DESC
	) AS t_rank
FROM pharma
GROUP BY manufacturer, dosage_form;

/* =============================================================================
12) Dosage Form Preference Within Each Therapeutic Class
Purpose:
- Understand how drugs are delivered within each therapeutic class.
- Helps formulation and R&D strategy.
============================================================================= */
SELECT
    therapeutic_class,
    dosage_form,
    COUNT(*) AS product_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY therapeutic_class),
        2
    ) AS dosage_share_pct
FROM pharma
GROUP BY therapeutic_class, dosage_form
ORDER BY therapeutic_class, dosage_share_pct DESC;

/* =============================================================================
13) Internal Brand-Level Price Variation
Purpose:
- Detect inconsistent pricing within the same brand for identical products.
- Strong indicator of data quality issues or channel-based pricing.
============================================================================= */
SELECT
    brand_name,
    manufacturer,
    primary_ingredient,
    primary_strength,
    packaging_raw,
    ROUND(MAX(price_inr) - MIN(price_inr), 2) AS internal_price_gap,
    COUNT(*) AS record_count
FROM pharma
GROUP BY brand_name, manufacturer, primary_ingredient, primary_strength, packaging_raw
HAVING internal_price_gap > 50
ORDER BY internal_price_gap DESC;

/* =============================================================================
13) Top Manufacturers by Therapeutic Class (Top 3)
Purpose:
- Identify key players controlling each therapy segment.
- Helps sales strategy and competitor benchmarking.
============================================================================= */
WITH ranked_mfr AS (
    SELECT
        therapeutic_class,
        manufacturer,
        COUNT(*) AS product_count,
        RANK() OVER (
            PARTITION BY therapeutic_class
            ORDER BY COUNT(*) DESC
        ) AS rnk
    FROM pharma
    GROUP BY therapeutic_class, manufacturer
)
SELECT
    therapeutic_class,
    manufacturer,
    product_count
FROM ranked_mfr
WHERE rnk <= 3
ORDER BY therapeutic_class, product_count DESC;

/* =============================================================================
14) Top Manufacturers by Dosage Form (Top 3)
Purpose:
- Identify key manufacturers dominating each dosage form.
- Helps understand formulation strength and production capability.
============================================================================= */
WITH ranked_mfr AS (
    SELECT
        dosage_form,
        manufacturer,
        COUNT(*) AS product_count,
        RANK() OVER (
            PARTITION BY dosage_form
            ORDER BY COUNT(*) DESC
        ) AS rnk
    FROM pharma
    GROUP BY dosage_form, manufacturer
)
SELECT
    dosage_form,
    manufacturer,
    product_count
FROM ranked_mfr
WHERE rnk <= 3
ORDER BY dosage_form, product_count DESC;
