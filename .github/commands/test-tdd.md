---
name: test-tdd
description: Run when user calls /test-tdd. Scans modified files, locates their corresponding test suites, and runs them.
type: command
---

# Slash Command: /test-tdd

## Core Objective

Locate and execute the test suites corresponding to modified files.

## Steps for the Agent

1. **Identify Modified Code**: Run `git status` or `git diff --name-only` to identify changed files.
2. **Find Matching Tests**:
   - Backend Python: `backend/app/services/foo.py` ➔ `backend/tests/test_foo.py`
   - Mobile Flutter: `mobile/lib/.../foo.dart` ➔ `mobile/test/.../foo_test.dart`
   - Web Angular: `web/src/app/.../foo.ts` ➔ `web/src/app/.../foo.spec.ts`
3. **Execute Runner**:
   - Backend: `cd backend && pytest tests/<matching_test>.py -v`
   - Mobile: `cd mobile && flutter test test/<matching_test>.dart`
   - Web: `cd web && pnpm test --run`
4. **Loop Strategy**:
   - If tests fail, diagnose with [agent-debugger](../agents/agent-debugger.md).
