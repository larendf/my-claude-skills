---
name: aem-component
description: Build or edit AEM components the Tourism Australia way — Sling Models, HTL, Granite/Coral 3 dialogs, clientlibs, and component inheritance across australia.com, aussiespecialist, business-events, and corporate. Use when creating or modifying an AEM component, dialog, or Sling Model.
---

# AEM Component Development (Tourism Australia)

Conventions for authoring components in this multi-site AEM 6.5.22 platform. Always check `tourismaustralia-common` first — shared base classes and utilities live there and should be reused rather than duplicated.

## Where things live

| Artifact | Path pattern |
|---|---|
| Sling Model (site) | `{site}/core/src/main/java/com/{site}/www/components/content/{name}/{Name}.java` |
| Sling Model (common) | `tourismaustralia-common/core/src/main/java/com/ta/common/www/components/content/{Name}.java` |
| Component node | `{site}/ui.apps/src/main/content/jcr_root/apps/{site}/components/content/{name}/` |
| Utilities | `tourismaustralia-common/core/src/main/java/com/ta/common/utils/` |

`{site}` packages: `australia` (australia.com), `aussiespecialist`, plus business-events and corporate. Common is `com.ta.common`. Corporate UI module is `ui/` not `ui.apps/`.

## Sling Model

Standard annotation style — always `DefaultInjectionStrategy.OPTIONAL` so missing properties degrade gracefully:

```java
@Model(adaptables = {Resource.class, SlingHttpServletRequest.class},
       defaultInjectionStrategy = DefaultInjectionStrategy.OPTIONAL)
public class ItineraryContainer {
    @ValueMapValue @Default(values = "") private String title;
    @SlingObject   private ResourceResolver resourceResolver;
    @ScriptVariable private Page currentPage;
    @Self          private SlingHttpServletRequest request;

    @PostConstruct
    public void init() { /* derive values for HTL */ }
}
```

- Use `adaptables = Resource.class` alone when no request is needed; add `SlingHttpServletRequest.class` (the dual-adaptable pattern) when you need request, params, or session.
- Injectors in use: `@ValueMapValue`, `@Inject`/`@Via("resource")`, `@SlingObject`, `@ScriptVariable`, `@Self`, `@Default`, `@OSGiService`.
- Initialize in a no-arg `@PostConstruct` method (`init()`).
- Reuse base classes: `ATDWAwareComponent`, `BaseShare`, `Image` (abstract, `getAdaptSuffix()`), `BaseBreadcrumb`. Reuse utils: `PathUtils`, `LinkUtils`, `TextUtils`, `LocaleUtils`, `ServerUtils`, `DataLayerUtils`.

Real example: [ItineraryContainer.java](../../../tourismaustralia/core/src/main/java/com/australia/www/components/content/itinerarycontainer/ItineraryContainer.java)

## HTL template (`{name}.html`)

```html
<sly data-sly-test.mode="${(wcmmode.edit || wcmmode.design)}">
    <p data-emptytext="Itinerary Container" class="cq-placeholder"></p>
</sly>
<sly data-sly-use.cmp="com.australia.www.components.content.itinerarycontainer.ItineraryContainer">
    <div data-ceddl-component-info='{ "componentId": "itineraryContainer", "componentName": "Itinerary Container" }'>
        <h2>${cmp.title @ context='html'}</h2>
        <div data-sly-resource="${'par' @ resourceType='foundation/components/parsys'}"></div>
    </div>
</sly>
```

- Bind the model with `data-sly-use.cmp="<FQCN>"`.
- Always set `@context` for escaping (`html`, `uri`, `attribute`); i18n via `${label @ i18n}`.
- Author placeholder behind `data-sly-test.mode="${wcmmode.edit || wcmmode.design}"`.
- Nested authoring: parsys via `data-sly-resource="${'par' @ resourceType='foundation/components/parsys'}"`.
- Analytics data-layer attributes (`data-ceddl-*`) are standard on most components.

## Component node (`.content.xml`)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<jcr:root xmlns:sling="http://sling.apache.org/jcr/sling/1.0"
    xmlns:cq="http://www.day.com/jcr/cq/1.0" xmlns:jcr="http://www.jcp.org/jcr/1.0"
    cq:isContainer="{Boolean}true"
    jcr:primaryType="cq:Component"
    jcr:title="Itinerary Container"
    componentGroup="Australia.com"/>
```

- `componentGroup` per site (e.g. `Australia.com`).
- Inherit behavior/markup via `sling:resourceSuperType="tourismaustralia/components/page/global"` (common for page templates).
- Optional siblings: `_cq_editConfig.xml`, `clientlibs/`, `datasource-*/`.

## Dialog — Granite/Coral 3 only

New code uses Granite/Coral 3 (`_cq_dialog.xml`), **not** classic UI. Structure is consistent: `tabs → fixedcolumns → container → fields`.

```xml
<jcr:root xmlns:sling="http://sling.apache.org/jcr/sling/1.0"
    xmlns:jcr="http://www.jcp.org/jcr/1.0"
    jcr:primaryType="nt:unstructured" jcr:title="Small Banner"
    sling:resourceType="cq/gui/components/authoring/dialog"
    extraClientlibs="[ta.fileuploadcontrol]">
  <content sling:resourceType="granite/ui/components/coral/foundation/tabs">
    <items jcr:primaryType="nt:unstructured">
      <image jcr:title="Image" sling:resourceType="granite/ui/components/coral/foundation/fixedcolumns">
        <items jcr:primaryType="nt:unstructured">
          <column sling:resourceType="granite/ui/components/coral/foundation/container">
            <items jcr:primaryType="nt:unstructured">
              <!-- fields: granite/ui/components/coral/foundation/form/{textfield|select|checkbox|...} -->
            </items>
          </column>
        </items>
      </image>
    </items>
  </content>
</jcr:root>
```

- Field types: `granite/ui/components/coral/foundation/form/{textfield,select,checkbox,fileupload,...}`; richtext via `cq/gui/components/authoring/dialog/richtext`.
- Asset paths: `fileReferenceParameter="./fieldName"`.
- Attach component clientlibs with `extraClientlibs="[category]"`.

## Client libraries

`cq:ClientLibraryFolder` with a `categories` array; list files in `js.txt`/`css.txt` (supports `#base=` directives).

```xml
<jcr:root xmlns:jcr="http://www.jcp.org/jcr/1.0" jcr:primaryType="cq:ClientLibraryFolder"
    allowProxy="{Boolean}true"
    categories="[ta-footer]"/>
```

- Category convention: `{site}-{feature}` (e.g. `ta-footer`, `philausophy-ta`).
- Language subfolders exist where needed: `ja/`, `ko/`, `zh-cn/`, `zh-tw/`, `vi/`, `latin/`.

## New-component checklist

1. Sling Model in the right `core` package (reuse common base/utils).
2. `.content.xml` with title + `componentGroup`.
3. `{name}.html` HTL binding the model.
4. `_cq_dialog.xml` (Coral 3) if authorable.
5. clientlibs + category if it ships JS/CSS.
6. Unit-test the model (JUnit 5 + AEM Mocks — see the `aem-osgi-service` skill for the test setup).
7. Deploy with `./build.sh {ta|common|...}-install` (see `aem-build-deploy`).

For React-backed components (data passed via `data-cq-model`), see the `aem-react-component` skill.
