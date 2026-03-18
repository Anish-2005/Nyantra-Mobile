# Security Policy

## Reporting a Vulnerability
If you discover a security issue, please report it privately and include:
- A clear description of the issue
- Reproduction steps
- Potential impact

Do not open public issues for security vulnerabilities.

## Sensitive Configuration
- Do not commit secrets or private credentials.
- Use secure runtime configuration (`--dart-define`) for environment-specific endpoints.
- Rotate exposed credentials immediately if accidental leaks occur.
