## Pipeline Monitoring

When monitoring pipelines:
1. Query pipeline_status records for all active pipelines
2. Read baselines from memory (namespace="thresholds")
3. Check: throughput drop >50%, latency spike >3x baseline, error rate >5%, DLQ depth growing
4. Update baselines with exponential moving average (alpha=0.1)
5. Write deviations as sre_findings, severity based on magnitude and duration
