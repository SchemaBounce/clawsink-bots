---
apiVersion: clawsink.schemabounce.com/v1
kind: ToolPack
metadata:
  name: healthcare-toolkit
  displayName: Healthcare Toolkit
  version: 1.0.0
  description: Clinical calculations, ICD lookups, lab ranges, and patient scheduling
  category: Healthcare
  tags: [bmi, dosage, icd-10, lab, appointment, risk]
  icon: health
tools:
  - name: bmi_calculator
    description: Calculate BMI from height and weight with WHO classification
    category: calculation
  - name: dosage_calculator
    description: Calculate medication dosage based on weight, age, and formulation
    category: calculation
  - name: icd_lookup
    description: Look up ICD-10 codes by keyword or code and return descriptions
    category: lookup
  - name: lab_range_check
    description: Check lab values against normal reference ranges and flag abnormalities
    category: validation
  - name: appointment_scheduler
    description: Find available appointment slots given provider schedules and constraints
    category: scheduling
  - name: patient_risk_score
    description: Calculate a composite risk score from clinical indicators and history
    category: scoring
---

# Healthcare Toolkit

Clinical calculations, ICD lookups, lab ranges, and patient scheduling. All tools are deterministic Go functions -- fast, zero LLM tokens, fully reproducible.

Essential for any agent supporting clinical workflows, patient management, or health data analysis.

## Use Cases

- Calculate BMI and classify patients by WHO categories
- Compute weight-based medication dosages
- Look up ICD-10 diagnostic codes for billing
- Flag out-of-range lab results for clinical review
- Schedule patient appointments with provider availability

## Tools

### bmi_calculator
Calculate Body Mass Index from height and weight. Returns BMI value and WHO classification (underweight, normal, overweight, obese).

### dosage_calculator
Compute medication dosage based on patient weight, age, formulation strength, and dosing frequency.

### icd_lookup
Search ICD-10 codes by keyword or code prefix. Returns matching codes with full descriptions and category hierarchy.

### lab_range_check
Compare lab test values against normal reference ranges by test type, age, and sex. Flags values as low, normal, or high.

### appointment_scheduler
Find open appointment slots given provider schedules, appointment duration, and patient constraints.

### patient_risk_score
Calculate a weighted risk score from clinical indicators (vitals, lab results, conditions, demographics) and return risk tier.
