---
name: commit
description: Run when user calls /commit or asks to generate a commit message. Analyzes staged changes and writes a structured commit message.
type: command
---

# Slash Command: /commit

## Core Objective

Analyze staged git modifications and generate a high-quality Semantic Commit message adhering to Conventional Commits and zero AI attribution.

## Steps for the Agent

1. **Verify Git Author Identity**: Confirm `user.name` is `moises-cisneros` and `user.email` is `moisescisnerosdl@gmail.com`.
2. **Analyze Staged Changes**: Run `git diff --cached` to inspect staged modifications.
3. **Determine Conventional Commit Type**:
   - `feat`: New feature or capability.
   - `fix`: Bug fix.
   - `docs`: Documentation updates.
   - `refactor`: Structural improvements without behavioral change.
   - `test`: Adding or updating tests.
   - `chore`: Tooling, formatting, dependencies.
4. **Enforce Zero AI Attribution**: Never include `Co-Authored-By`, `Assisted-by` or AI banners.
5. **Format Subject & Body**:
   - Summary line under 50 characters in lowercase without period.
   - Structured body explaining _what_ and _why_.
6. **Action**: Write the generated message directly to `.git/COMMIT_EDITMSG`.
7. **Output**: Display the commit message for the user to review.
