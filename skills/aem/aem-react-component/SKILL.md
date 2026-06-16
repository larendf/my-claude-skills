---
name: aem-react-component
description: Build a React editable component in tourismaustralia-react the project's way — feature folder layout, features.js registration, the AEM-side HTL/Sling Model that feeds data via data-cq-model, i18next i18n, Jest/RTL tests, and the yarn sync build pipeline. Use when adding or editing a React feature that mounts inside an AEM component.
---

# React Editable Components (tourismaustralia-react)

React 16.14 features that mount into AEM components. Data flows **AEM Sling Model → JSON in `data-cq-model` attribute → React**. Module root: `tourismaustralia-react/`. Node ≥ 20.11.0, Yarn.

## Data flow (how it fits together)

1. AEM Sling Model (in `tourismaustralia-common/core`) serializes a JSON model via `getJson()`.
2. HTL renders a container `<div id="{htmlContainer}-${model.id}" data-cq-model="${model.json}">`.
3. `src/index.js` `render()` finds all `[id^="{htmlContainer}"]`, parses `data-cq-model`, and `ReactDOM.render`s the feature with `cqModel` prop.
4. The feature's `App.jsx` extends `Page` (from `@adobe/aem-react-editable-components`) and reads `props.cqModel`.

## Feature folder layout

```
src/features/{kebab-name}/
├── App.jsx            # container; `class App extends Page`, reads props.cqModel
├── {Name}.jsx         # primary component (React.memo)
├── index.js           # imports App + render helper, calls render(htmlContainer, App, "production")
├── {Name}.scss        # co-located styles
├── components/        # child .jsx + co-located .scss
├── utils/             # helpers, data-layer.js (analytics), async-data.js (API)
└── tests/             # {Name}.test.jsx (Jest + RTL)
```

`.jsx` for components, `.js` for utils, `.scss` co-located. Webpack auto-discovers every `src/features/*/index.js` as an entry point → bundles to `build/static/js|css/`.

## index.js (registration + mount)

```javascript
import MyFeatureApp from "./App";
import render from "../../index";

const myFeature = {
  component: MyFeatureApp,
  htmlContainer: "my-feature-app",      // MUST match the AEM container id prefix
  jsonFixtures: "myFeature.model.json",
};
render(myFeature.htmlContainer, myFeature.component, "production");
```

Also add the feature to the central registry `src/features.js` (same `{component, htmlContainer, jsonFixtures}` shape).

## App.jsx

```jsx
import { Page } from "@adobe/aem-react-editable-components";
import MyFeature from "./MyFeature.jsx";

class App extends Page {
  constructor(props) {
    super(props);
    this.model = props.cqModel;        // JSON from the AEM Sling Model
    this.labels = { ctaLabel: this.model.ctaLabel || "Learn More" };
  }
  render() {
    return <MyFeature {...this.model} labels={this.labels} />;
  }
}
export default App;
```

## AEM-side counterpart

HTL (`html.html`) in the AEM component — the container `id` prefix must equal `htmlContainer`:

```html
<sly data-sly-use.model="com.ta.common.www.components.content.<path>.<Model>"
     data-sly-test="${model.resourceExists}">
  <div id="my-feature-app-${model.id}" data-mode="production" data-cq-model="${model.json}"></div>
</sly>
```

The Sling Model lives in `tourismaustralia-common/core` and exposes `getJson()`. See the `aem-component` skill for Sling Model conventions, and add a `_cq_editConfig.xml` so the author UI refreshes on edit.

## i18n (i18next + react-i18next)

Setup: `src/i18.js`; translation tables: `src/locales/{en,de,fr,id,it,ja,ko,vi,zh,cn}.js`. Language detected from cookie, fallback `en`.

```jsx
import { useTranslation } from "react-i18next";
const { t } = useTranslation();
t("destination_list_pagination_text", { currentCount, totalData });
```

Add new keys to every locale file under `src/locales/`.

## Build & sync

```bash
yarn sync          # concurrently: aem:watch (aemfed) + webpack:watch + clientlib:watch
yarn build         # production webpack + clientlib generation
yarn build:dev     # dev-mode build
yarn test          # jest
yarn test:coverage
yarn test:watch
```

- `aem:watch` uses `aemfed` against `http://admin:admin@localhost:4502`.
- Webpack output → `build/static/js|css/` as `{feature}.{hash}.js`.
- `clientlib.config.js` generates AEM clientlibs into `ui.apps/src/main/content/jcr_root/apps/tourismaustralia-react/clientlibs/{group}/` with categories like `tourismaustralia-react-{group}`.
- Deploy the React UI package with `./build.sh react-install` (see `aem-build-deploy`).

## Tests (Jest + React Testing Library)

Live in the feature's `tests/`, named `{Name}.test.jsx`. Test behavior, not implementation; mock i18n and data-layer utils.

```jsx
import { render, screen, fireEvent } from "@testing-library/react";
import CarouselCard from "../components/CarouselCard";

jest.mock("../utils/atdw-data-layer", () => ({ DL_cardClick: jest.fn() }));

it("renders and tracks click", () => {
  render(<CarouselCard data={{ title: "Sample" }} />);
  expect(screen.getByText("Sample")).toBeInTheDocument();
});
```

Jest config + `config/jest/setupTests.js` (polyfills IntersectionObserver, matchMedia) are in `package.json`. SCSS is mocked via `config/jest/styleMock.js`.

## New-feature checklist

1. `src/features/{kebab-name}/` with `App.jsx`, `{Name}.jsx`, `index.js`, `.scss`.
2. Register in `index.js` (`render(...)`) and `src/features.js`.
3. AEM component: HTL container with matching `id` prefix + Sling Model `getJson()` in `tourismaustralia-common/core`.
4. i18n keys in `src/locales/*`.
5. Tests in `tests/`.
6. `yarn sync` to develop; `./build.sh react-install` to deploy.
