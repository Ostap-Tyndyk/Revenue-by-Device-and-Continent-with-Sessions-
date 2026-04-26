/*| Continent | Revenue | Revenue from Mobile | Revenue from Desktop | % Revenue from Total | Account Count | Verified Account | Session Count | */


WITH revenue_usd AS
(
SELECT continent, SUM(price) as revenue,
SUM(CASE WHEN device = 'mobile' THEN price END) as revenue_mobile,
SUM(CASE WHEN device = 'desktop' THEN price END) as revenue_desktop,
FROM `data-analytics-mate.DA.session_params` sp
INNER JOIN `data-analytics-mate.DA.order` o
ON sp.ga_session_id = o.ga_session_id
INNER JOIN `data-analytics-mate.DA.product` p
ON p.item_id = o.item_id
GROUP BY continent
),
registration AS
(
  SELECT continent,
  COUNT(acs.account_id) as account_count,
  COUNT(CASE WHEN is_verified = 1 THEN acs.account_id END) as verified_count,
  COUNT(sp.ga_session_id) as session_count
  FROM `data-analytics-mate.DA.session_params` sp
  LEFT JOIN `data-analytics-mate.DA.account_session` acs
  ON acs.ga_session_id = sp.ga_session_id
  LEFT JOIN `data-analytics-mate.DA.account` a
  ON a.id = acs.account_id
  GROUP BY continent
)

SELECT r.continent, revenue, revenue_mobile, revenue_desktop,
revenue * 100 /
SUM(revenue) OVER() as revenue_percent_from_total,
account_count, verified_count, session_count
FROM registration r
LEFT JOIN revenue_usd ru
ON r.continent = ru.continent
ORDER BY revenue_percent_from_total DESC
