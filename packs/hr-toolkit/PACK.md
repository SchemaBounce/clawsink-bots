---
apiVersion: clawsink.schemabounce.com/v1
kind: ToolPack
metadata:
  name: hr-toolkit
  displayName: HR Toolkit
  version: 1.0.0
  description: Salary calculations, leave management, scheduling, and workforce planning
  category: HR
  tags: [salary, leave, performance, scheduling, payroll, compensation, overtime]
  icon: people
tools:
  - name: calculate_salary
    description: Calculate net salary from gross pay, deductions, and benefits
    category: payroll
  - name: calculate_leave
    description: Compute leave balances, accruals, and remaining entitlements
    category: leave
  - name: performance_score
    description: Calculate a weighted performance score from multiple review dimensions
    category: performance
  - name: shift_scheduler
    description: Generate shift schedules balancing coverage requirements and employee constraints
    category: scheduling
  - name: headcount_forecast
    description: Project future headcount needs based on growth plans and attrition rates
    category: planning
  - name: compensation_benchmark
    description: Compare compensation against market benchmarks by role, level, and region
    category: compensation
  - name: tax_withholding
    description: Calculate payroll tax withholding amounts based on earnings and filing status
    category: payroll
  - name: overtime_calculator
    description: Calculate overtime hours and pay based on work logs and overtime rules
    category: payroll
---

# HR Toolkit

Salary calculations, leave management, scheduling, and workforce planning. All tools are deterministic Go functions -- fast, zero LLM tokens, fully reproducible.

Essential for any agent handling payroll, workforce management, or HR operations.

## Use Cases

- Calculate net pay from gross salary with all deductions
- Track and forecast leave balances for team planning
- Generate fair shift schedules across employees
- Project headcount needs for quarterly planning
- Compute overtime pay from timesheet data

## Tools

### calculate_salary
Calculate net salary by applying tax withholding, benefits deductions, retirement contributions, and other adjustments to gross pay.

### calculate_leave
Compute current leave balance from accrual rate, days taken, and carryover policy. Supports PTO, sick, and custom leave types.

### performance_score
Calculate a weighted composite performance score from individual dimension ratings (quality, output, collaboration, etc.).

### shift_scheduler
Generate shift schedules given coverage requirements, employee availability, and constraints like max consecutive days.

### headcount_forecast
Project future headcount based on planned growth rate, historical attrition, and upcoming hires in the pipeline.

### compensation_benchmark
Compare an employee's total compensation against market data by job title, level, location, and industry.

### tax_withholding
Compute federal and state tax withholding amounts from earnings, pay frequency, and W-4 filing status.

### overtime_calculator
Calculate overtime hours and premium pay from daily or weekly work logs using configurable overtime thresholds.
