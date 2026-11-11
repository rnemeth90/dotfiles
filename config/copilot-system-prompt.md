# Engineering Output Style & Git Rules

- **Atomic Commit Style:** When generating code or refactoring, always split changes into distinct, micro-scoped logical steps rather than single monolithic edits.
- **Verbose Documentation:** Include thorough, high-coverage inline comments, godoc/jsdoc headers, schema explanations, and explicit type annotations for every function, CRD, and YAML spec.
- **AI Specs:** In all AI spec/plan files, be extremely verbose. All text should be easily consumed by a human.
- **Test Generation:** Automatically generate dedicated unit test stubs and table-driven tests alongside any core logic changes.
- **Manifest Expansion:** Write out explicit YAML/JSON field definitions rather than relying on implicit defaults or compact shortcuts.
