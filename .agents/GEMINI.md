# Quizdy — Gemini Instructions

Welcome! To ensure high-quality contributions to **Quizdy**, please follow these rules:

1. **Read AGENTS.md**: This is the source of truth for architecture and style.
2. **Research First**: Before writing any code, search for existing files and patterns.
3. **Use Workflows**: Check `.agents/workflows/` for tasks like:
   - `check-theme-compliance`: Verifying theme consistency (MANDATORY for UI changes).
   - `implement-pencil-design`: Implementing `.pen` designs with theme-driven typography and light/dark parity.
   - `fix-lint-issues`: Automating code cleanup.
4. **License Header**: Every NEW `.dart` file **MUST** start with the GPL-3.0 header defined in `AGENTS.md`.
5. **Typography Rule**: Avoid hardcoding `fontFamily: 'Inter'` in widgets; rely on `Theme.of(context).textTheme` and existing theme extensions.

**Motto**: "Look twice, code once, analyze always."
