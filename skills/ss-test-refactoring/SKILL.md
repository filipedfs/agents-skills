---
name: ss-test-refactoring
title: "Test Suite Refactoring"
description: "Refactor and improve the test suite for better maintainability,
 readability, and performance."
---
# Test Suite Refactoring

## Rules for writing/improving tests

### Coding rules

- **Never use `var`** — always explicit types. Project convention.
- **Don't touch `@DirtiesContext`** unless explicitly asked.
- **Don't fuss over unused imports** during refactoring — fix later.
- **Don't guess when debugging** — trace root cause systematically before changing code.

### Product and credit policy setup

**Prefer inline setup over helper methods.** Each test configures only what it needs.

For product configuration, use **get → modify → createOrUpdate**:
```java
ProductConfigurationDto product = this.getSimpleProductConfiguration("TopSim", "default", Set.of());
product.getConditionsConfiguration().put("default", new ConditionsConfigurationDto()...);
this.createOrUpdateProductConfiguration(product);
```

For control groups, use `getSimpleCreditPolicyControlGroupWithOneRule` or `WithRules` — unspecified rules are auto-DISABLED:
```java
ControlGroupDto group = this.getSimpleCreditPolicyControlGroupWithOneRule("TopSim", "default", 100, ruleKind, ruleConfig);
this.createOrUpdateCreditPolicyControlGroup(group);
```

Only create the products the test actually needs. Don't set custom group codes unless asserting them.

Avoid deprecated helpers: `getBasicCreditPolicyGroup`, `createCreditPolicyGroup`, `getCustomControlGroup`, `createBasicProductAndCreditPolicy`, `createOrUpdateBasicProductConfiguration`, `getBasicProductConfiguration`.

### Loan creation and caching

- Use `completeLoanUntilInState(person, clear, desiredState, overruleDecline, cacheKeyExtras)` with cache key extras to enable caching.
- Set non-default mocks AFTER loan creation to avoid mock state polluting cache keys.
- Control group codes are deterministic (`test-{product}-{configurationCode}`) — no random values.

### Mock clients instead of Mockito

- Never use `@MockitoSpyBean`, `@SpyBean`, or `@MockBean` in new tests.
- Use mock client classes following the existing pattern (`BoaVistaMockClient`, `ScrMockClient`, `FraudSuspicionServiceMockClient`, etc.):
    - `@Service` / `@Primary` bean extending the real client
    - Static enum-based mock modes (DEFAULT delegates to real implementation)
    - Reset in `setMocksToDefault()` in `AbstractTestHelper`
- For integration beans resolved by name (e.g., disbursement), override the bean name in `test.properties` instead of using `@Primary`.
- For async JMS calls to external services (e.g., `AssetServiceClient.updateProductItemAsync`), use CAPTURE mode to intercept messages instead of querying the external service. Example: `AssetServiceMockClient` with `CAPTURE` mode captures `AssetProductItemUpdateRequestDto` messages for assertion.

### Test structure

- Use `@DisplayName` with a clear description of what the test verifies.
- Use step-based comments (`// Step 1:`, `// Step 2:`, `// Verify:`).
- Use self-explaining method names (e.g., `testChargeOffLateLoan` not `testChargeOff`).
- Use client-layer calls only — avoid direct service/repository injection. Exception: JMS consumers and methods excluded from client generation (`@ServiceClientOperation(ignore = true)`).
- Use `payInstallment()` helper with **positive** amounts (not negated).
- Use `DateTimeHelper.getCurrentLocalDate()` instead of `LocalDate.now()` when clock is manipulated.

### Test organization

- Group tests by domain in `service/` subpackages: `repayments/`, `application/`, `underwriting/`, `formalization/`, `conditions/`, `policy/`.
- Merge tests that share the same loan lifecycle (e.g., CURRENT → LATE → renegotiate → annotate) to reduce loan creation overhead.
- Split large test classes for parallel execution (e.g., `LoanRePaymentServiceClientTest` + `LoanRePaymentNegotiationServiceClientTest`).

### Context and cleanup

- `beforeEachDefault` truncates `loan, product_configuration, control_group, re_payment_control_group, portfolio` tables and re-installs portfolio seed data from `portfolios.json`.
- Don't add/remove `@DirtiesContext` unless explicitly asked.
- Date-specific tests (Christmas, Carnival) should be removed after the date passes or made date-independent.

### Workflow

- **Run `mvn clean install -DskipTests`** (exclude infrastructure if needed) before `surefire:test`. AspectJ LTW requires the full build lifecycle.
- **Commit before running tests** to avoid stale compiled classes. But never push until tests pass.

## TODO

### Remaining `createSimpleProductAndCreditPolicy` callers

- `BaseCustomPartnerFormalizationIntegrationTest`
- `VortxIntegrationTest`, `EzzeIntegrationTest`
- `InsuranceIntegrationTest`, `LoanAccountancyVortxServiceClientTest`
- `LoanDecisionModelTest`, `LoanCreditPolicySimulationServiceClientTest`
- `LoanRePaymentCommunicationServiceClientTest` (seasonal campaign)

### Old test classes to migrate

- `LoanApplicationServiceClientTest` (old) — 6 open-finance tests
- `LoanCreditPolicyControlGroupServiceClientTest` (old) — 2 disabled tests

### Disabled tests to investigate

- `LoanCreditPolicySimulationServiceClientTest` — entire class disabled
- `LoanConditionsServiceClientTest` — 4 disabled tests (payday engine, installment limit, conditions summary, installment overlimit)
- `LoanAccountancyAmFiServiceClientTest` — 1 disabled test

### Future merge candidates

- `testPayBillUsingDeposit` + `testAnticipatedPartialAndLatePayments`
- `testNegotiationSimulationWithResidualBalance` + `testRenegotiationPopulatesConfigAndDecisionModel`
