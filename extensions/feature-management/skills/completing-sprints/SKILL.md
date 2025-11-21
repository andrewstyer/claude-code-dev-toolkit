---
name: completing-sprints
description: Systematic sprint completion with flexible handling of incomplete work and optional retrospectives
---

# Completing Sprints

## Overview

Systematic process for ending sprints, reviewing completion, handling incomplete work, and maintaining data consistency. Supports both interactive (human-led) and autonomous (Claude-led) modes for completing sprints.

**Announce at start:** "I'm using the completing-sprints skill to systematically complete your sprint."

**Key Capabilities:**
- Complete active or planned sprints with review of all work items
- Mark bugs as resolved/unresolved (binary completion)
- Mark features as completed/partial/incomplete (with percentage for partial)
- Handle incomplete work flexibly (return to backlog, move to next sprint, or keep in current sprint)
- Auto-detect completion status from project state (yaml files, git commits, implementation plans)
- Generate optional sprint retrospectives with statistics and notes
- Maintain data consistency across bugs.yaml, features.yaml, sprint documents, and ROADMAP.md
- Create structured git commits with detailed changelogs

## When to Use

**Interactive Mode (Default):**
- User says "complete sprint" or similar
- Want human review and approval at each decision point
- Need flexibility to override auto-detected statuses
- Prefer manual input for retrospective notes
- Estimated time: 5-10 minutes per sprint

**Autonomous Mode:**
- User says "auto-complete sprint" or invokes in autonomous context
- Want fast, automated completion based on current project state
- Trust auto-detection from yaml files and implementation plans
- Accept conservative defaults for ambiguous cases
- Estimated time: 2-3 minutes per sprint

**Use this skill when:**
- Sprint timeline has ended and you want to formally close it
- Need to review what was accomplished during a sprint
- Have incomplete work that needs disposition (backlog vs next sprint)
- Want to generate a retrospective for learning and planning
- Need to ensure data consistency across project files

**Don't use this skill if:**
- Sprint is still in progress and you just want a status update
- You want to cancel/abandon a sprint (not the same as completing)
- You're looking for sprint metrics across multiple sprints (use analytics tools)

## Process

[Process documentation will be added in subsequent tasks]
