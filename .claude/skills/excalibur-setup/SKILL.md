---
name: excalibur-setup
description: >
  Use when starting a new Excalibur.js game project, scaffolding from the CLI
  template (`npm init excalibur`), installing `excalibur` via npm/yarn/pnpm/bun,
  or wiring a bundler (Vite, Webpack, Parcel, Rollup, esbuild) around the engine.
  Also covers constructing the root `ex.Engine` (width/height/viewport, resolution,
  canvasElementId, displayMode, pixelArt, backgroundColor, physics on/off,
  maxFps/fixedUpdateFps), booting the game loop with `engine.start(loader)`,
  baseline TypeScript/tsconfig.json setup for an Excalibur project, and
  picking a `DisplayMode` at construction time. Trigger on "set up excalibur",
  "excalibur main.ts", "new ex.Engine", "engine.start", "excalibur vite template",
  "excalibur hello world", bundler config errors with excalibur, or questions
  about project layout for an Excalibur game. Does NOT cover scene/actor/camera
  authoring, graphics, input, physics tuning, or ECS internals — those are
  separate excalibur-* skills.
---

# Excalibur Setup

Bootstrap for an Excalibur.js 2D HTML5/WebGL game: install, scaffold, bundler wiring,
`ex.Engine` construction, and `engine.start()`. Everything that happens *before* you
have a running game loop with an initial scene. Once the engine is running, hand off
to `excalibur-core` for scenes/actors/cameras.

## When to use this skill
- Creating a fresh Excalibur project (`npm init excalibur@latest` or manual setup)
- Choosing/configuring a bundler (Vite, Webpack, Parcel, Rollup, esbuild) for Excalibur
- Writing the entrypoint `main.ts` / `index.ts` that constructs `new ex.Engine({...})`
- Picking `EngineOptions` at construction time: `width`, `height`, `viewport`, `resolution`, `displayMode`, `pixelArt`, `antialiasing`, `backgroundColor`, `canvasElementId`, `physics`, `maxFps`, `fixedUpdateFps`
- Booting the game loop via `await engine.start(loader)` and the initial loader handoff
- Debugging "canvas not found", blank canvas, blurry pixel art, or wrong aspect ratio caused by engine options

## When NOT to use (route to another skill)
- For scenes/actors/camera/events → use `excalibur-core`
- For rendering/sprites/animations → use `excalibur-visuals`
- For loading assets → use `excalibur-resources`
- For physics/input/actions → use `excalibur-simulation`
- For ECS components/systems → use `excalibur-ecs`
- For math/timers/coroutines/particles → use `excalibur-utilities`

## Concept map

| API | Purpose |
|-----|---------|
| `npm init excalibur@latest` | CLI scaffolder; emits a ready-to-run project (Vite + TS by default). Templates: `template-ts-vite`, `template-ts-parcel-v2`, `template-ts-rollup`, `template-ts-webpack`. |
| `import * as ex from 'excalibur'` | Namespace import. Named imports (`import { Engine, Actor } from 'excalibur'`) are recommended for tree-shaking, though tree-shaking is imperfect as of `0.32.x`. |
| `new ex.Engine(options)` | The root container. One per game. Owns the canvas, screen, director, clock, physics world, and event bus. |
| `EngineOptions` | Construction-time config. Key fields below. |
| `ex.DisplayMode` | How the canvas sizes itself. `Fixed` (default when width/height given), `FitScreen` (default otherwise), `FitContainer`, `FillScreen`, `FillContainer`, `FitScreenAndFill`, `FitScreenAndZoom`, `FitContainerAndFill`, `FitContainerAndZoom`. |
| `engine.start(loader?)` | Async. Boots the clock, runs the loader's play gate, resolves when the user clicks play and initial assets are loaded. Returns `Promise<void>`. |
| `engine.start(sceneName, options?)` | Overload: start on a specific scene when `scenes` was provided in `EngineOptions`. |
| `new ex.Loader([...resources])` | Default preloader; pass to `engine.start()`. Deep dive lives in `excalibur-resources`. |
| `engine.canvas` / `engine.canvasElementId` | The rendering surface. Pass `canvasElementId` or `canvasElement` to attach to an existing `<canvas>`; otherwise Excalibur creates and appends one. |

### Key `EngineOptions` (construction-time)

```ts
interface EngineOptions {
  width?: number;                  // css pixels
  height?: number;                 // css pixels
  viewport?: { width: number; height: number };  // alternative to width+height
  resolution?: ex.Resolution;      // logical pixel resolution; presets on ex.Resolution
  displayMode?: ex.DisplayMode;    // see table above
  canvasElementId?: string;        // id of existing <canvas> to take over
  canvasElement?: HTMLCanvasElement;
  pixelArt?: boolean;              // shorthand: blended pixel-art sampler + antialiasing profile
  antialiasing?: boolean | AntialiasOptions;  // default true
  snapToPixel?: boolean;           // default false
  backgroundColor?: ex.Color;      // default ex.Color.fromHex('#2185d0')
  pixelRatio?: number;             // defaults to devicePixelRatio
  suppressPlayButton?: boolean;    // skips the click-to-start gate (audio may break without gesture)
  suppressHiDPIScaling?: boolean;
  suppressConsoleBootMessage?: boolean;
  physics?: boolean | ex.PhysicsConfig;  // default arcade solver on
  maxFps?: number;                 // cap; default uncapped
  fixedUpdateFps?: number;         // stable physics step; mutually exclusive w/ fixedUpdateTimestep
  fixedUpdateTimestep?: number;    // ms per step; takes precedence over fixedUpdateFps
  pointerScope?: ex.PointerScope;  // default Canvas
  scenes?: SceneMap;               // prewire scenes to the director
}
```

Sizing rules the engine applies in the constructor:
- If `width`+`height` (or `viewport`) are set and `displayMode` is not, displayMode becomes `Fixed`.
- If none of those are set and `displayMode` is not, displayMode becomes `FitScreen`.
- `resolution` is independent of `viewport`: resolution is logical game pixels, viewport is the css box.

## Common recipes

### 1. Minimal entrypoint

```ts
// src/main.ts
import * as ex from 'excalibur';

const game = new ex.Engine({
  width: 800,
  height: 600,
  displayMode: ex.DisplayMode.FitScreen,
});

game.start();
```

```html
<!-- index.html -->
<!doctype html>
<html>
  <body>
    <script type="module" src="/src/main.ts"></script>
  </body>
</html>
```

With no `canvasElementId` or `canvasElement`, Excalibur creates a `<canvas>` and appends it to `document.body`.

### 2. Attach to an existing canvas

```html
<canvas id="game"></canvas>
<script type="module" src="/src/main.ts"></script>
```

```ts
import * as ex from 'excalibur';

const game = new ex.Engine({
  canvasElementId: 'game',
  width: 800,
  height: 600,
});

await game.start();
```

The canvas element must exist in the DOM before `new ex.Engine(...)` runs — otherwise the constructor throws "Cannot find existing element in the DOM".

### 3. Pixel-art game

```ts
import * as ex from 'excalibur';

const game = new ex.Engine({
  width: 320,
  height: 180,
  displayMode: ex.DisplayMode.FitScreenAndZoom, // integer-ish scale, no letterbox
  pixelArt: true,        // hints the sampler and texture filtering
  antialiasing: false,   // crisp edges (pixelArt: true already configures a pixel-art-friendly profile)
  backgroundColor: ex.Color.Black,
});

await game.start();
```

`pixelArt: true` is a shortcut that turns on a blended pixel-art sampler; prefer it over hand-tuning `antialiasing: { pixelArtSampler: true, ... }` unless you know you need the deeper options.

### 4. Start with a loader (assets preloaded before first frame)

```ts
import * as ex from 'excalibur';

const playerImage = new ex.ImageSource('./assets/player.png');

const loader = new ex.Loader([playerImage]);

const game = new ex.Engine({
  width: 800,
  height: 600,
});

await game.start(loader);
// After this await, the user has clicked play and assets are ready.
```

The `start()` promise only resolves *after* the play-button click (required for the WebAudio user-gesture rule). Set `suppressPlayButton: true` if you already have a user gesture, but audio may not autoplay.

### 5. Prewired scenes via the director

```ts
import * as ex from 'excalibur';

class MainMenu extends ex.Scene { /* ... */ }
class Level1 extends ex.Scene { /* ... */ }

const game = new ex.Engine({
  width: 800,
  height: 600,
  scenes: {
    menu: MainMenu,
    level1: Level1,
  },
});

await game.start('menu'); // named-scene overload
```

Deep scene/transition authoring lives in `excalibur-core`.

### 6. Recommended project layout (CLI template style)

```
my-game/
  index.html
  package.json
  tsconfig.json
  vite.config.ts        // or webpack/parcel/rollup config
  src/
    main.ts             // new ex.Engine + game.start()
    scenes/
    actors/
    resources.ts        // ImageSource / Sound / Loader wiring
  public/
    assets/
```

## Gotchas

- **`start()` does not resolve until the play button is clicked.** Do not `await game.start()` and then assume the game is running in the same tick the page loaded — it waits for a user gesture. Use the `start` event or the returned promise for post-play init.
- **Width/height vs. resolution vs. viewport are three different things.** `width`/`height` (or `viewport`) size the css box; `resolution` is the logical pixel grid. If you want a retro 320x180 game scaled up, set `resolution: { width: 320, height: 180 }` and a `displayMode` that scales, *not* just `width: 320`.
- **Default display mode depends on whether you set size.** Omitting `width`+`height` silently switches the default from `Fixed` to `FitScreen`. Always set `displayMode` explicitly if you care.
- **Default background is Excalibur blue (`#2185d0`), not transparent or black.** Set `backgroundColor` explicitly or `enableCanvasTransparency` if you want HTML showing through.
- **`canvasElementId` requires the element to exist before engine construction.** Order your script tags accordingly or use `type="module"` scripts which defer by default.
- **Tree-shaking is partial.** Named imports help but don't assume unused subsystems get dropped — the bundled `excalibur` is ~1 MB gzipped; budget accordingly.
- **Parcel needs `import "regenerator-runtime/runtime"`** at the top of the entry file to handle Excalibur's async/await. Vite/Webpack/Rollup with esbuild don't.
- **Excalibur is client-only.** It touches `window`/`document`/`HTMLCanvasElement` at construction time; do not import it at the top of server-side code paths (SSR, Node scripts). Dynamic-import it in browser-only code.
- **`pixelArt: true` + `antialiasing: true` is not contradictory** — `pixelArt` enables a special blended sampler; it's not "turn off antialiasing". If you want old-school hard pixels, set `pixelArt: false`, `antialiasing: false`, `snapToPixel: true`.
- **`fixedUpdateTimestep` overrides `fixedUpdateFps`** if both are set. Pick one.
- **Hidden default: `pointerScope` was historically `Document`** in older docs, but the current default in source is `PointerScope.Canvas`. Set it explicitly if pointer events outside the canvas matter.
- **One engine per page.** `Engine.InstanceCount` tracks instances; a second `new ex.Engine` on the same page works mechanically but creates a second canvas and input layer and will fight for focus.

## Doc pointers

- `site/docs/00-welcome.mdx` — what Excalibur is, design philosophy
- `site/docs/00-z-quick-start.mdx` — CLI scaffolder + theater metaphor
- `site/docs/01-getting-started/01-installation.mdx` — npm/nuget/CDN/ESM install paths
- `site/docs/01-getting-started/03-bundlers.mdx` — Vite, Parcel, Webpack, Deno, tsconfig baseline
- `site/docs/02-fundamentals/04-architecture.mdx` — engine lifecycle overview
- `site/docs/03-screen-viewport/screens-display.mdx` — viewport vs. resolution vs. displayMode
- `site/docs/03-screen-viewport/screens-display-modes.mdx` — every `DisplayMode` with visual examples
- `src/engine/engine.ts` (line ~120: `EngineOptions` interface; line ~817: constructor; line ~1712: `start()` overloads) — ground-truth API
- `src/engine/screen.ts` (line ~15: `DisplayMode` enum) — authoritative list of display modes
