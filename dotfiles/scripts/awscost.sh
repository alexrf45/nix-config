aws ce get-cost-and-usage \
  --time-period 'Start=2025-10-01,End=2026-02-15' \
  --metrics 'UnblendedCost' \
  --granularity 'MONTHLY' \
  --query 'ResultsByTime[*].Total.[UnblendedCost]' \
  --output 'table'
