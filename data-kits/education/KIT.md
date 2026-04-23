---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: education
  displayName: Education Academy
  version: "1.0.0"
  description: "Online training academy data, students, courses, enrollments, instructors, and assessments"
  category: industry
  tags:
    - education
    - e-learning
    - courses
    - students
    - assessments
    - instructors
    - lms
    - training
  author: SchemaBounce
compatibility:
  teams:
    - education-academy
  composableWith:
    - customer-feedback
    - content-marketing
entityPrefix: "edu_"
entityCount: 5
graphEdgeTypes:
  - ENROLLED_IN
  - TEACHES
  - SUBMITTED_BY
vectorCollections:
  - edu_courses
useCases:
  - "Enroll students in courses and track progress through modules and assessments"
  - "Schedule instructors across cohorts and balance load"
  - "Grade assessments and build per-student transcripts"
  - "Identify at-risk students from engagement and assessment scores"
---

# Education Academy

A complete data kit for online training academies and e-learning platforms. Covers the full student lifecycle from enrollment through course completion and assessment.

## What's Included

- **Students** — learner profiles with enrollment status, skill level, and progress tracking
- **Courses** — course catalog with pricing, difficulty levels, duration, and learning objectives
- **Enrollments** — student-course registrations with progress percentage and completion tracking
- **Instructors** — teaching staff with specializations, ratings, and course load
- **Assessments** — graded assignments and exams with scores and submission tracking

## Key KPIs Tracked

| KPI | Target | Why It Matters |
|-----|--------|----------------|
| Course Completion Rate | >80% | Measures content quality and student engagement |
| Student Satisfaction | >4.2/5.0 | Drives word-of-mouth and re-enrollment |
| Avg Assessment Score | >75% | Validates learning effectiveness |
| Enrollment Growth | >10% QoQ | Business health indicator |
| Instructor Rating | >4.0/5.0 | Teaching quality benchmark |
| Re-enrollment Rate | >40% | Measures platform stickiness |

## Graph Relationships

- `ENROLLED_IN` links students to courses via enrollment records
- `TEACHES` links instructors to the courses they deliver
- `SUBMITTED_BY` links assessments back to the students who submitted them

## Composability

Pairs well with **content-marketing** (driving course signups through content) and **customer-feedback** (deeper student satisfaction analysis). The `edu_` prefix ensures clean coexistence with horizontal kits.
