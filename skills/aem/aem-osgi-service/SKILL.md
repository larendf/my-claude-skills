---
name: aem-osgi-service
description: Build backend OSGi services in this AEM platform the project's way — OSGi R6 DS annotations (@Component/@Reference/@Activate), @Designate + @ObjectClassDefinition config, plus servlet/scheduler/workflow/resource-listener patterns and JUnit 5 + AEM Mocks tests. Use when creating or editing a service, servlet, scheduler, workflow process, or event listener in a core/ module.
---

# OSGi Service Development (Tourism Australia)

Backend services live in `*/core/` modules. The repo uses **OSGi R6 Declarative Services annotations** (`org.osgi.service.component.annotations.*`) — never the old Felix SCR annotations, and no XML descriptors.

Packages: site services `com.{site}...` (e.g. `com.australia.servlet...`); shared services `com.ta.common.{feature}`. Check `tourismaustralia-common/core` first for an existing service before writing a new one.

## Service: interface + impl

```java
public interface ServerNameService {
    String getAustraliaURL();
}

@Component(service = ServerNameService.class, immediate = true,
    property = {
        "process.label=Server Name Service",
        Constants.SERVICE_DESCRIPTION + "=External Location for Server"
    })
public class DefaultServerNameService implements ServerNameService { ... }
```

- Naming: `Default{Feature}Service` or `{Feature}ServiceImpl`.
- Always register against the interface: `@Component(service = MyService.class, immediate = true, property = {...})`.
- Inject dependencies with field-level `@Reference` (no setters); use `@Reference(cardinality = ReferenceCardinality.OPTIONAL)` for optional ones. Mark references `transient` in `Serializable`/`Runnable` components.

## OSGi configuration (metatype, inline)

Config is code-driven via a static inner `@ObjectClassDefinition` interface bound with `@Designate`. Read it in `@Activate`/`@Modified`:

```java
@Component(service = MyService.class, immediate = true, property = {...})
@Designate(ocd = MyService.Configuration.class)
public class MyService implements ... {

    @ObjectClassDefinition(name = "My Service", description = "...")
    public static @interface Configuration {
        @AttributeDefinition(name = "Enable Flag") boolean enableFlag() default false;
        @AttributeDefinition(name = "scheduler.expression") String scheduler_expression() default "0 00 9 ? * *";
        @AttributeDefinition(name = "Paths") String[] paths() default {};
    }

    private boolean enabled;

    @Activate @Modified
    protected void activate(Configuration config) { enabled = config.enableFlag(); }
}
```

Note `scheduler_expression()` maps to the OSGi property `scheduler.expression` (`_` → `.`).

## Common patterns

**Servlet** — extend `SlingAllMethodsServlet` / `SlingSafeMethodsServlet`, register as `Servlet.class`:

```java
@Component(service = Servlet.class, immediate = true, property = {
    "sling.servlet.methods=" + HttpConstants.METHOD_GET,
    "sling.servlet.resourceTypes=tourismaustralia/components/content/footer",
    "sling.servlet.extensions=json",
    "sling.servlet.selectors=countries"
})  // or "sling.servlet.paths=/bin/fw/..." for a path-bound servlet
```

**Scheduler / cron** — implement `Runnable`, gate on `ServerUtils.isAuthor(...)`, schedule via config:

```java
@Component(service = {Runnable.class, MyJob.class, Serializable.class}, immediate = true, property = {...})
@Designate(ocd = MyJob.Configuration.class)
public class MyJob implements Runnable, Serializable {
    @Reference private transient SlingSettingsService settingsService;
    @Override public void run() { if (enabled && ServerUtils.isAuthor(settingsService)) { ... } }
}
```

**Workflow process** — implement `com.day.cq.workflow.exec.WorkflowProcess`, register as `WorkflowProcess.class`, set `process.label`.

**Resource change listener** — implement `ResourceChangeListener`, register with `ResourceChangeListener.PATHS`/`.CHANGES` properties.

For service resource resolvers use the sub-service pattern:
```java
Map<String,Object> param = Map.of(ResourceResolverFactory.SUBSERVICE, CommonUtils.COMMON_SERVICES);
try (ResourceResolver rr = resourceResolverFactory.getServiceResourceResolver(param)) { ... }
```

## Logging

```java
private static final Logger LOG = LoggerFactory.getLogger(MyService.class);
```

SLF4J, static final, name = class. Use parameterized messages (`LOG.info("x={}", x)`).

## Unit tests (JUnit 5 + Mockito + AEM Mocks)

```java
@ExtendWith({AemContextExtension.class, MockitoExtension.class})
class AspAuthenticationServiceImplTest {
    private AspAuthenticationServiceImpl svc;
    @Mock SlingHttpServletRequest request;

    @BeforeEach void setUp() { svc = new AspAuthenticationServiceImpl(); }

    @Test void authenticated() {
        Mockito.when(request.getAuthType()).thenReturn("post");
        Mockito.when(request.getRemoteUser()).thenReturn("ta-service-user");
        assertTrue(svc.isAuthenticated(request));
    }
}
```

- `@ExtendWith({AemContextExtension.class, MockitoExtension.class})` for AEM + Mockito.
- Inject private fields without setters using `PrivateAccessor.setField(impl, "field", mock)` (junit-addons).
- Integration tests are tagged `@Tag("com.ta.common.IntegrationTest")` and run in the integration-test phase; plain unit tests run under Surefire.

## New-service checklist

1. Interface + `Default…`/`…Impl` in the right `core` package.
2. `@Component(service = …, immediate = true, property = {...})`; `@Reference` deps.
3. `@Designate` + `@ObjectClassDefinition` if it needs config.
4. SLF4J logger.
5. JUnit 5 + AEM Mocks test under `core/src/test/...`.
6. Deploy: `./build.sh {ta|common|...}-install`, or bundle-only with `-PautoInstallBundle` (see `aem-build-deploy`).
