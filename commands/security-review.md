# /security-review - Standalone Security Review

Run a focused security review on specified files or recent changes. Use ad-hoc when you want a security assessment outside the `/validate` workflow.

## Process

1. **Determine scope** from `$ARGUMENTS`:
   - If file paths provided: review those specific files
   - If "recent" or no arguments: review uncommitted changes via `git diff` and `git diff --cached`
   - If a PRP path provided: review all files changed by that PRP

2. **Delegate to `reviewer` agent** with security-focused prompt:

   Run a security-focused review on [scope]. Check every item in the security checklist:
   - **Input validation**: Are external inputs (user input, API params, file paths, env vars) validated before use?
   - **Auth**: Are access controls consistent? Unprotected routes? Escalation paths?
   - **Data exposure**: Secrets, tokens, PII leaked in logs, error messages, responses, or URLs?
   - **Injection**: SQL, command, path traversal, XSS - is user data passed unsanitized to interpreters?
   - **Dependencies**: New deps from trusted sources? Known vulnerabilities?
   - **Error handling**: Fail closed, not open? Stack traces hidden from users?
   - **Cryptography**: Proper algorithms? No hardcoded keys? Secure random generation?
   - **Configuration**: Debug mode off in production? CORS properly restricted? Security headers present?

   Also read `.context/patterns/CODE_PATTERNS.md` and `ANTI_PATTERNS.md` for project-specific security conventions.

3. **Present findings** with severity levels:
   ```
   ## Security Review: [scope]
   **Files reviewed**: [N files]

   ### Critical (must fix before merge)
   1. **[file:line]** - [issue] -> [fix]

   ### High (fix soon)
   1. **[file:line]** - [issue] -> [fix]

   ### Medium (address in next cycle)
   1. **[file:line]** - [issue] -> [fix]

   ### Low / Informational
   1. **[file:line]** - [observation]

   ### Passed Checks
   [List security areas that passed review]
   ```

4. **Capture findings**: If critical or high issues found, ask whether to:
   - Append to `.context/errors/INDEX.md` as security error patterns
   - Add to `.context/patterns/ANTI_PATTERNS.md` if they represent recurring bad habits
   - Fix immediately (delegate to implementer or fix inline)

## Rules
- Every finding must include file path, line number, and a suggested fix.
- Don't just flag problems — categorize by severity and actionability.
- Check the `auth-security` skill for project-specific security patterns if it's been populated.
- This is a read-only review by default. Fixes require explicit user approval.

## User Input
$ARGUMENTS
