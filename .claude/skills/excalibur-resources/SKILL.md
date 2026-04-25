---
name: excalibur-resources
description: >
  Use when preloading or loading game assets (images, audio, gifs, JSON, text,
  binary) in an Excalibur.js project. Covers `ex.Loader` / `ex.DefaultLoader`
  (constructing `new ex.Loader([resources])`, passing to `engine.start(loader)`,
  `loader.addResource`, `loader.addResources`, `loader.areResourcesLoaded()`,
  progress bar, play button, custom logo/backgroundColor/playButtonText,
  `suppressPlayButton`, `fullscreenAfterLoad`). Covers `ex.ImageSource`
  (`new ex.ImageSource(path, { filtering, wrapping, bustCache })`,
  `ImageFiltering.Pixel` vs. `ImageFiltering.Blended` for pixel-art assets,
  `ImageWrapping.Clamp`/`Repeat`/`Mirror`, `imageSource.toSprite()`,
  `ImageSource.fromHtmlImageElement`, `fromHtmlCanvasElement`, `fromSvgString`).
  Covers `ex.Sound` with codec-fallback paths (MP3/WAV/OGG — `new ex.Sound('a.mp3',
  'a.wav', 'a.ogg')`), `volume`, `loop`, `playbackRate`, `.play()`/`.pause()`/
  `.stop()`/`.seek()`, `PlayOptions`, instances. Covers `ex.Gif` with
  `.toAnimation()` / `.toSpriteSheet()` / `.toSprite(id)`, `ex.Resource<T>`
  for JSON/text/arraybuffer/blob, the `Loadable<T>` interface for custom
  loadables, and the `@excaliburjs/plugin-aseprite` `AsepriteResource` with
  `.getAnimation(name)` / `.getSpriteSheet()` / `.image`. Also covers per-scene
  loading via `scene.onPreLoad(loader)` or `goToScene(name, { loader })`.
  Trigger on "load image", "load sound", "load assets", "preload", "game loader",
  "play button", "loading bar", "pixel art asset", "image filtering", "Aseprite",
  "asset pipeline", "MP3 OGG fallback", "load JSON", "load gif animation".
  Does NOT cover engine bootstrap (`excalibur-setup`), scene/actor lifecycle or
  per-scene loader wiring details (`excalibur-core`), rendering sprites /
  spritesheets / animations after load (`excalibur-visuals`), tilemap editor
  plugins Tiled/LDtk/SpriteFusion (`excalibur-visuals`), input/physics/actions
  (`excalibur-simulation`), ECS (`excalibur-ecs`), or math/timers
  (`excalibur-utilities`).
---

# Excalibur Resources

Asset preloading: `Loader`, `ImageSource`, `Sound`, `Gif`, generic `Resource<T>`,
`Loadable<T>`, and the Aseprite plugin. Everything between "file on disk" and
"usable in a scene". Assumes the engine is already constructed
(`excalibur-setup`) and you need assets before the first draw.

## When to use this skill
- Wiring a `new ex.Loader([...])` and handing it to `engine.start(loader)`
- Loading `.png`/`.jpg`/`.bmp`/`.svg` images via `ex.ImageSource`
- Loading `.mp3`/`.wav`/`.ogg` audio with codec-fallback order via `ex.Sound`
- Loading animated `.gif` frames via `ex.Gif` (spritesheet/animation)
- Loading JSON / text / binary via `ex.Resource<T>`
- Setting `ImageFiltering.Pixel` for crisp pixel art; `Blended` for smooth art
- Customizing the loader screen (logo, backgroundColor, playButtonText)
- Bypassing the play button (`suppressPlayButton`) — audio will likely break
- Adding the `@excaliburjs/plugin-aseprite` `AsepriteResource`
- Writing a custom `Loadable<T>` for an asset format Excalibur doesn't know about
- Splitting asset loading across scenes via `scene.onPreLoad` or
  `goToScene(name, { loader })`

## When NOT to use (route to another skill)
- Constructing `new ex.Engine({...})`, bundler config, starting the game loop →
  `excalibur-setup`
- `Scene`/`Actor` lifecycle, `onInitialize`/`onActivate`, transitions, passing
  scene data → `excalibur-core`
- Turning a loaded `ImageSource` into `Sprite`, `SpriteSheet`, `Animation`,
  `GraphicsGroup`, `NineSlice`, parallax layers, or UI — `excalibur-visuals`
- Tiled / LDtk / SpriteFusion tilemap plugins — `excalibur-visuals`
- Keyboard / pointer / gamepad / `actor.actions.*` / physics body config —
  `excalibur-simulation`
- Custom `Component`/`System`/`Query` — `excalibur-ecs`
- `Vector`, `Timer`, `coroutine`, easing, `ParticleEmitter` —
  `excalibur-utilities`

## Concept map

| API | Purpose |
|-----|---------|
| `ex.Loadable<T>` | Interface: `data: T`, `load(): Promise<T>`, `isLoaded(): boolean`. Everything preloadable implements it. |
| `ex.DefaultLoader` | Base loader. Headless spinner, no logo/play button. `addResource`/`addResources`/`areResourcesLoaded`/`progress`/`load()`. Overridable hooks: `onBeforeLoad`, `onUserAction`, `onAfterLoad`, `onDraw`, `onUpdate`. |
| `ex.Loader` | `extends DefaultLoader`. The default branded play-button + progress-bar UI. Accepts `LoaderOptions` or `Loadable[]`. Properties: `logo`, `logoWidth`, `logoHeight`, `backgroundColor`, `playButtonText`, `playButtonPosition`, `loadingBarColor`, `suppressPlayButton`, `startButtonFactory`, `fullscreenAfterLoad`. |
| `ex.ImageSource` | Image file → `HTMLImageElement`. Loaded; turn into `Sprite` via `imageSource.toSprite()`. Supports PNG/JPG/BMP/SVG; GIFs should use `ex.Gif`. |
| `ex.ImageFiltering.Pixel` / `Blended` | Sampling mode per-image. `Pixel` = nearest-neighbor (pixel art). `Blended` = smoothed (hi-res art). Defaults from `EngineOptions.antialiasing`/`pixelArt`. |
| `ex.ImageWrapping.Clamp` / `Repeat` / `Mirror` | Texture wrap mode on the U/V axes. Required for scrolling-tile shaders or repeating backgrounds. |
| `ex.Sound` | Audio file(s). Variadic constructor lets you list fallback formats. Implements `Loadable<AudioBuffer>`. `.play()`/`.pause()`/`.stop()`/`.seek()`/`.loop`/`.volume`/`.playbackRate`/`.instances`. |
| `ex.Gif` | Animated GIF → frames as `ImageSource[]`. `.toSprite(id)`, `.toSpriteSheet()`, `.toAnimation(durationPerFrame?)`. |
| `ex.Resource<T>` | Generic XHR. Constructor: `(path, responseType, bustCache?)`. `responseType`: `'' \| 'arraybuffer' \| 'blob' \| 'document' \| 'json' \| 'text'`. |
| `@excaliburjs/plugin-aseprite` `AsepriteResource` | `.aseprite` (binary) or JSON export. `.getAnimation(name)`, `.getSpriteSheet()`, `.image`, `.rawAseprite`. |
| `engine.start(loader)` | Runs the loader: downloads all resources, shows the play button, awaits user click, unlocks WebAudio, resolves. |
| `scene.onPreLoad(loader)` | Per-scene async preload. Runs once before first activation. Deep dive in `excalibur-core`. |
| `goToScene(name, { loader })` | Per-transition ad-hoc loader. Overrides the scene's `onPreLoad` loader for this navigation. |

### `ImageSourceOptions`

```ts
interface ImageSourceOptions {
  filtering?: ex.ImageFiltering;        // Pixel | Blended
  wrapping?: ex.ImageWrapping | { x: ex.ImageWrapping; y: ex.ImageWrapping };
  bustCache?: boolean;                  // adds ?__=<ts> to defeat dev cache
}
```

### `SoundOptions`

```ts
interface SoundOptions {
  paths: string[];        // ordered by preference; first supported codec wins
  bustCache?: boolean;
  volume?: number;        // 0..1, default 1
  loop?: boolean;         // default false
  playbackRate?: number;  // default 1
  duration?: number;      // seconds, default = full clip
  position?: number;      // seek offset on play
}
```

### `LoaderOptions` (verified from `src/engine/director/loader.ts`)

```ts
interface LoaderOptions {
  loadables?: ex.Loadable<any>[];
  fullscreenAfterLoad?: boolean;
  fullscreenContainer?: HTMLElement | string;
}
```

Plus the following mutable properties on a `Loader` instance: `logo` (base64
or URL string), `logoWidth`, `logoHeight`, `logoPosition`, `playButtonText`,
`playButtonPosition`, `loadingBarPosition`, `loadingBarColor`,
`backgroundColor` (CSS string, not `ex.Color`), `suppressPlayButton`,
`startButtonFactory`.

## Common recipes

### 1. Minimal loader

```ts
import * as ex from 'excalibur';

const playerImage = new ex.ImageSource('./assets/player.png');
const jumpSound   = new ex.Sound('./assets/jump.mp3', './assets/jump.wav');

const loader = new ex.Loader([playerImage, jumpSound]);

const game = new ex.Engine({ width: 800, height: 600 });
await game.start(loader);
// After this await: user clicked play, all resources loaded.

const player = new ex.Actor({ pos: ex.vec(100, 100) });
player.graphics.use(playerImage.toSprite());
game.currentScene.add(player);

await jumpSound.play(0.5);
```

### 2. Centralize resources in one module

```ts
// src/resources.ts
import * as ex from 'excalibur';

export const Resources = {
  PlayerImage:  new ex.ImageSource('./assets/player.png'),
  EnemySheet:   new ex.ImageSource('./assets/enemy.png', {
    filtering: ex.ImageFiltering.Pixel,
  }),
  Jump:         new ex.Sound('./assets/jump.mp3', './assets/jump.wav'),
  LevelData:    new ex.Resource<LevelJson>('./assets/level1.json', 'json'),
} as const;

// An array view for the Loader
export const loader = new ex.Loader(Object.values(Resources));
```

```ts
// src/main.ts
import * as ex from 'excalibur';
import { Resources, loader } from './resources';

const game = new ex.Engine({ width: 800, height: 600 });
await game.start(loader);

console.log(Resources.LevelData.data); // typed as LevelJson
```

This is the pattern used by the `npm init excalibur` template.

### 3. Pixel-art image filtering

```ts
const enemy = new ex.ImageSource('./assets/enemy.png', {
  filtering: ex.ImageFiltering.Pixel,   // nearest-neighbor, crisp pixels
  wrapping: ex.ImageWrapping.Clamp,     // default
});
```

Per-image filtering overrides the engine default (set via `EngineOptions.pixelArt`
or `antialiasing`). Mix-and-match on a single project is fine.

### 4. Sound with codec fallback + playback control

```ts
// Variadic: list preferred formats first.
// Chrome/Edge/Safari play MP3, Firefox prefers OGG, so provide both.
const music = new ex.Sound(
  './assets/theme.mp3',
  './assets/theme.ogg',
  './assets/theme.wav',
);

// Options-object form also works:
const sfx = new ex.Sound({
  paths: ['./assets/hit.mp3', './assets/hit.wav'],
  volume: 0.8,
  loop: false,
});

const loader = new ex.Loader([music, sfx]);
await game.start(loader);

music.loop = true;
music.volume = 0.4;
await music.play();

// Multiple overlapping instances of the same SFX
sfx.play();
sfx.play();            // second voice, overlapping
console.log(sfx.instanceCount()); // 2
sfx.stop();            // stops all instances

// Scheduled start (in ms relative to now via the audio context):
const future = ex.AudioContextFactory.create().currentTime * 1000 + 500;
await sfx.play({ volume: 1, scheduledStartTime: future });
```

`Sound` picks the first `path` the browser reports as playable (via
`canPlayFile`). If none is supported it logs a warning and falls back to the
first entry.

### 5. Generic JSON / text / binary

```ts
interface LevelJson { name: string; spawnX: number; spawnY: number; }

const levelJson = new ex.Resource<LevelJson>(
  './data/level1.json',
  'json',       // responseType
);
const storyText = new ex.Resource<string>('./data/intro.txt', 'text');
const saveBlob  = new ex.Resource<ArrayBuffer>('./data/save.bin', 'arraybuffer');

const loader = new ex.Loader([levelJson, storyText, saveBlob]);
await game.start(loader);

console.log(levelJson.data.spawnX);
console.log(storyText.data);
new DataView(saveBlob.data);
```

### 6. Animated Gif as `Animation`

```ts
const explosion = new ex.Gif('./assets/explosion.gif');
const loader = new ex.Loader([explosion]);
await game.start(loader);

const anim = explosion.toAnimation();         // null if the gif was empty
// Override the per-frame duration from the gif metadata:
// explosion.toAnimation(80);                 // 80ms per frame
const sheet = explosion.toSpriteSheet();      // every frame as sprites
const firstFrame = explosion.toSprite(0);

const actor = new ex.Actor({ pos: ex.vec(200, 200) });
if (anim) actor.graphics.use(anim);
scene.add(actor);
```

### 7. Custom loader appearance (logo, color, play button text)

```ts
const loader = new ex.Loader([playerImage, jumpSound]);

loader.backgroundColor = '#1c1c28';                    // CSS color string
loader.playButtonText  = 'Enter the dungeon';
loader.loadingBarColor = ex.Color.fromHex('#f5d142');
loader.logo            = 'data:image/png;base64,iVBORw0KGgoAAA...';
loader.logoWidth       = 256;
loader.logoHeight      = 64;

// Build the button yourself:
loader.startButtonFactory = () => {
  const btn = document.createElement('button');
  btn.id = 'excalibur-play';                            // must keep this id
  btn.textContent = 'Enter the dungeon';
  btn.className = 'my-play-btn';
  return btn;
};

await game.start(loader);
```

`loader.backgroundColor` is a CSS string (not `ex.Color`). If you want to skip
the play button entirely and you already have a user gesture:

```ts
const loader = new ex.Loader({ loadables: [img], fullscreenAfterLoad: true });
loader.suppressPlayButton = true;
await game.start(loader);
// Caveat: WebAudio may not unlock. No audio until the next user click.
```

### 8. `addResource` after construction / dynamic loading

```ts
const loader = new ex.Loader();          // empty
loader.addResource(new ex.ImageSource('./assets/a.png'));
loader.addResources([
  new ex.ImageSource('./assets/b.png'),
  new ex.Sound('./assets/c.mp3', './assets/c.wav'),
]);

// Check status (returns a Promise resolving when resources load, not the play gate):
await loader.areResourcesLoaded();
console.log(loader.progress);            // 0..1

await game.start(loader);
```

Difference between `areResourcesLoaded()` and `start(loader)`: the former
resolves as soon as downloads complete; the latter additionally waits for the
play-button click and WebAudio unlock.

### 9. Out-of-band load (no loader at all)

```ts
const img = new ex.ImageSource('./assets/banner.png');

// Skip the Loader; load directly. Useful for lazy tutorials or deferred assets.
await img.load();
if (img.isLoaded()) {
  const sprite = img.toSprite();
  // ...
}
```

Important: you still need a user gesture to play audio. A bare `await sound.load()`
without `WebAudio.unlock()` (which the `Loader` calls in `onUserAction`) will
load the clip but `.play()` will be silent until the user interacts with the page.

### 10. Per-scene loader (cross-reference)

```ts
class BossLevel extends ex.Scene {
  private bossImg!: ex.ImageSource;
  override onPreLoad(loader: ex.DefaultLoader) {
    this.bossImg = new ex.ImageSource('./assets/boss.png');
    loader.addResource(this.bossImg);
  }
  onInitialize() {
    const boss = new ex.Actor({ pos: ex.vec(400, 300) });
    boss.graphics.use(this.bossImg.toSprite());
    this.add(boss);
  }
}

// Or override the loader at the call site:
await engine.goToScene('boss', {
  loader: new ex.DefaultLoader({ loadables: [new ex.ImageSource('./boss.png')] }),
});
```

Full scene-transition semantics and `GoToOptions` live in `excalibur-core`.

### 11. Aseprite plugin

Install: `npm install @excaliburjs/plugin-aseprite`

```ts
import * as ex from 'excalibur';
import { AsepriteResource } from '@excaliburjs/plugin-aseprite';

// Either native .aseprite or an exported .json (see Aseprite CLI).
const beetle = new AsepriteResource('./assets/beetle.aseprite');
// or: new AsepriteResource('./assets/beetle.json');

const loader = new ex.Loader([beetle]);

const game = new ex.Engine({ width: 600, height: 400 });
await game.start(loader);

const walkAnim = beetle.getAnimation('Walk');       // name from Aseprite tag
const sheet    = beetle.getSpriteSheet();           // every frame as SpriteSheet
const image    = beetle.image;                      // underlying ImageSource
// const raw   = beetle.rawAseprite;                // raw parsed data

const actor = new ex.Actor({ pos: ex.vec(100, 100) });
if (walkAnim) actor.graphics.use(walkAnim);
game.currentScene.add(actor);
```

`AsepriteResource` implements `Loadable`, so it goes in any `Loader`. Downstream
graphics work (playing animations, swapping sprites, parallax layering) is in
`excalibur-visuals`.

### 12. Custom `Loadable<T>`

```ts
class CsvResource implements ex.Loadable<string[][]> {
  data: string[][] = [];
  private _resource: ex.Resource<string>;
  constructor(path: string) {
    this._resource = new ex.Resource<string>(path, 'text');
  }
  async load() {
    const raw = await this._resource.load();
    this.data = raw.trim().split('\n').map(line => line.split(','));
    return this.data;
  }
  isLoaded() { return this.data.length > 0; }
}

const csv = new CsvResource('./assets/waves.csv');
await game.start(new ex.Loader([csv]));
console.log(csv.data);
```

The `Loader` probes each resource's `isLoaded()`, calls `load()` on everything
unloaded, reports progress, and fires `loadresourcestart`/`loadresourceend`
events. Anything obeying the 3-method interface plugs in.

### 13. Loader events (progress HUD, custom UI)

```ts
const loader = new ex.Loader([img1, img2, sfx]);

loader.events.on('loadresourcestart', (res) => console.log('start', res));
loader.events.on('loadresourceend',   (res) => console.log('done',  res));
loader.events.on('beforeload', () => { /* before any XHR */ });
loader.events.on('afterload',  () => { /* after the user click */ });
loader.events.on('useraction', () => { /* user clicked play */ });

await game.start(loader);
```

## Gotchas

- **The loader only works over HTTP(S).** `file://` throws CORS/XHR errors.
  Use the project template's dev server, or `npx serve .`. This is non-negotiable —
  Excalibur uses `XMLHttpRequest`, not `<img src>`, so a plain double-clicked
  HTML file cannot load assets.
- **Asset paths are relative to the HTML document, not the JS file.** If your
  game is at `/public/game.js` and loads `./assets/a.png`, the browser resolves
  relative to `index.html`, not `game.js`. When hosting under a sub-path (e.g.
  GitHub Pages `/my-game/`), prefer relative paths or set a `<base href="/my-game/">`
  tag.
- **Vite serves static files from `public/`.** A path like `./assets/a.png`
  works at build time but fails at runtime if the file lives in `src/assets`.
  Either move to `public/assets` or `import` the asset so Vite fingerprints it:
  `import playerPng from './player.png'; new ex.ImageSource(playerPng);`.
- **`ex.Sound`'s variadic constructor picks the first playable codec.**
  `new ex.Sound('a.mp3', 'a.ogg')` won't download both — only the first one the
  browser reports as playable. Provide MP3 + OGG for maximum coverage
  (Safari/iOS prefers MP3; Firefox historically preferred OGG but now plays both).
- **WebAudio needs a user gesture.** The `Loader`'s play button exists to
  satisfy this. `suppressPlayButton = true` loads fine but `sound.play()` will
  produce no audio until the user clicks/taps. You can drop the button *if*
  your UI has its own "Start" button that triggers `game.start(loader)`.
- **`await game.start(loader)` does not resolve until the play button is clicked.**
  Don't put code you want to run at page-load time after the await — put it after
  the await, or use `loader.events.on('loadresourceend', ...)` for pre-click work.
- **Default anti-aliasing applies to every `ImageSource` unless overridden.**
  If the engine was created with `pixelArt: true`, all images default to pixel
  filtering; otherwise blended. Mix with per-image `filtering:` when needed.
- **Use `ex.Gif` for gifs, not `ex.ImageSource`.** Passing a `.gif` path to
  `ImageSource` logs a warning and will at best load the first frame as a
  static image. `ex.Gif` expands all frames into `ImageSource[]`.
- **`ex.Resource<T>` response type is a string literal, not a generic.** You
  must pass both: `new ex.Resource<MyShape>('...', 'json')`. The generic types
  `resource.data`, the string picks the XHR `responseType`. Mismatched types
  compile but produce garbage at runtime.
- **`bustCache: true` adds `?__=<timestamp>` to the URL.** Useful in development
  to defeat browser caching. Leave it off in production or every reload
  re-downloads the asset and defeats CDN caching.
- **`loader.backgroundColor` is a CSS color string,** not an `ex.Color`
  instance. `loader.backgroundColor = '#1c1c28'` is correct;
  `loader.backgroundColor = ex.Color.Black` is a type error.
- **`loader.logo` accepts a URL or base64 data URI.** If you reference a file
  path, the browser fetches it the normal way (not via the loader itself —
  it's a side-channel).
- **`loader.suppressPlayButton` + `game.start(loader)` still waits ~500 ms**
  (intentional — lets the logo flash). If you need literally no UI, extend
  `DefaultLoader` and override `onUserAction`/`onAfterLoad`.
- **`startButtonFactory` must return an element with `id="excalibur-play"`.**
  The loader positions and hides the element by that id. If you omit the id,
  positioning breaks silently.
- **`Sound.play()` returns `Promise<boolean>` that resolves on clip completion.**
  Awaiting it blocks until the clip ends. Fire-and-forget with
  `void sfx.play()` if you don't care.
- **`sound.stop()` stops *all* instances.** Each call to `.play()` allocates a
  new track; `instances` / `instanceCount()` expose them. `pause()` preserves
  position, `stop()` rewinds.
- **`Sound` is fire-and-forget across scenes.** It isn't tied to a scene; music
  started in scene A keeps playing in scene B. Store references and call
  `.stop()` on `onDeactivate` yourself.
- **One `Loader` is fine for the whole game.** Repeatedly calling
  `game.start(otherLoader)` re-triggers the play gate and UI — generally
  undesired. For post-boot preloads, use per-scene `onPreLoad` or
  `goToScene(name, { loader: new DefaultLoader({...}) })`.
- **`DefaultLoader` has no logo, no play button, no bar** — it's just a
  spinner. Use it for background/incremental loads where you don't want the
  branded gate. Use `Loader` for the first boot.
- **`ImageSource` can also wrap an existing `HTMLImageElement` / `HTMLCanvasElement`
  / SVG string** via the static factories. Handy when integrating with other
  libs that already produced the bitmap.

## Doc pointers

- `site/docs/06-resources/05-resources.mdx` — `Loader`, generic `Resource`,
  web-server requirement, sub-directory hosting
- `site/docs/06-resources/05-image-source.mdx` — `ImageSource` formats + out-of-band load
- `site/docs/06-resources/05-sound.mdx` — `Sound` codec fallback + MDN link
- `site/docs/13-plugins/15-aseprite-plugin.mdx` — `AsepriteResource` API surface
- `src/engine/director/default-loader.ts` — `DefaultLoader` (`addResource`,
  `progress`, lifecycle hooks, `LoaderEvents`)
- `src/engine/director/loader.ts` — `Loader` (logo/bg/button customization,
  `LoaderOptions`, `fullscreenAfterLoad`)
- `src/engine/graphics/image-source.ts` — `ImageSource`, `ImageSourceOptions`,
  static factories, `toSprite`
- `src/engine/graphics/filtering.ts` — `ImageFiltering.Pixel` / `Blended`
- `src/engine/graphics/wrapping.ts` — `ImageWrapping.Clamp` / `Repeat` / `Mirror`
- `src/engine/resources/sound/sound.ts` — `Sound`, `SoundOptions`, `PlayOptions`,
  `SoundEvents`, variadic constructor, codec selection via `canPlayFile`
- `src/engine/resources/gif.ts` — `Gif.toAnimation` / `toSpriteSheet` / `toSprite`
- `src/engine/resources/resource.ts` — `Resource<T>`, XHR response types, `bustCache`
- `src/engine/interfaces/loadable.ts` — the 3-method `Loadable<T>` contract
- GitHub: `excaliburjs/excalibur-aseprite` — plugin source, CLI export flow
