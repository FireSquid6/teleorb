---
name: excalibur-visuals
description: >
  Use for anything that ends up on the screen in an Excalibur.js game —
  graphics, UI/HUD, and tile maps. Covers the `ex.Graphic` base
  (`width`/`height`/`flipHorizontal`/`flipVertical`/`rotation`/`opacity`/
  `scale`/`origin`/`tint`), `ex.Sprite` (`sourceView`, `destSize`,
  `image.toSprite()`), `ex.SpriteSheet.fromImageSource({ image, grid })` /
  `getSprite(x, y)` / `getTiledSprite`, `ex.Animation` with `frames`/
  `durationPerFrame`/`AnimationStrategy` (`Loop`/`PingPong`/`Freeze`/`End`)
  and `Animation.fromSpriteSheet(sheet, indices, ms)`. Covers the
  `GraphicsComponent` on every `Actor` — `actor.graphics.use`,
  `graphics.add(name, graphic)`, `graphics.show`/`hide`/`current`,
  `graphics.anchor`/`offset`/`opacity`/`material`, `actor.z` for draw
  ordering. Covers `GraphicsGroup` (compose graphics with offsets),
  `Canvas` graphic (`CanvasRenderingContext2D` custom draw), `Material`
  (GLSL ES 300 fragment shaders), `ParallaxComponent` (parallax
  backgrounds), `NineSlice` (scalable UI borders/buttons), `ex.Text` /
  `ex.Font` / `ex.FontSource` / `ex.SpriteFont` (OS, web, and bitmap
  fonts), primitive rasters `ex.Rectangle` / `ex.Circle` / `ex.Polygon` /
  `ex.Line`, tint + opacity + z-index, pixel-art concerns
  (`pixelArt: true`, `ImageFiltering.Pixel`, anti-bleed). Covers UI:
  `ex.ScreenElement` (in-canvas HUD subclass of Actor, `CoordPlane.Screen`,
  auto-captures pointer events), HTML/CSS overlay pattern with
  `pointer-events: none`/`all`, `screen.worldToPageCoordinates`, bridging
  DOM button clicks to engine. Covers tile maps: `ex.TileMap` (orthogonal,
  `tiles`, `Tile.solid`, `tile.addGraphic`, `getTileByPoint`),
  `ex.IsometricMap` / `IsometricTile` / `IsometricEntityComponent` /
  `IsometricEntitySystem`, `worldToTile`/`tileToWorld`, and the three map
  editor plugins — Tiled (`@excaliburjs/plugin-tiled`, `TiledResource`,
  `.tmx`/`.tmj`/`.tsj`, orthogonal + isometric), LDtk
  (`@excaliburjs/plugin-ldtk`, `LdtkResource`, `.ldtk`), and SpriteFusion
  (`@excaliburjs/plugin-spritefusion`, `SpriteFusionResource({ mapPath,
  spritesheetPath })`), all sharing the `resource.addToScene(scene)`
  pattern. Trigger on "draw a sprite", "play animation", "spritesheet",
  "animation strategy", "graphics group", "nineslice button", "parallax
  background", "custom shader", "material", "pixel art", "draw text",
  "bitmap font", "sprite font", "HUD", "health bar", "score label",
  "screen element", "HTML overlay", "DOM UI over canvas", "pointer-events
  none", "tile map", "isometric map", "Tiled plugin", "LDtk", "Sprite
  Fusion", "load tmx", "getTileByPoint". Does NOT cover engine
  construction / `pixelArt` flag on `new ex.Engine` (`excalibur-setup`),
  `Scene`/`Actor`/`Camera`/events (`excalibur-core`), loading the raw
  image/audio files or the Aseprite plugin (`excalibur-resources`),
  physics/colliders/input/actions (`excalibur-simulation`), custom
  components/systems (`excalibur-ecs`), particles/timers/math
  (`excalibur-utilities`).
---

# Excalibur Visuals

Everything you see on the screen once the engine is running: the
`ex.Graphic` hierarchy, the `GraphicsComponent` on every `Actor`, UI
drawn in-canvas (`ScreenElement`) or as an HTML overlay, and tile maps
(orthogonal, isometric, plus the Tiled/LDtk/SpriteFusion editor plugins).
Assumes the engine is running (see `excalibur-setup`), scenes/actors
exist (`excalibur-core`), and raw asset files are already loaded
(`excalibur-resources`).

## When to use this skill

- Rendering an `ImageSource` as a `Sprite` on an `Actor`
- Slicing a sheet with `SpriteSheet.fromImageSource({ image, grid })`
- Playing an `Animation` and switching between named graphics
  (`graphics.add('run', anim)`, `graphics.use('idle')`)
- Composing multiple graphics on one actor with `GraphicsGroup`
- Custom per-frame drawing via `Canvas` or custom WebGL shaders via
  `Material`
- Parallax backgrounds (`ParallaxComponent`)
- Scalable UI borders / buttons via `NineSlice`
- Drawing `Text` / `Label` with `Font`, `FontSource`, or `SpriteFont`
- HUD inside the canvas (`ScreenElement`), or HTML/CSS overlay UI
  positioned over the canvas
- Orthogonal `TileMap`s or `IsometricMap`s hand-built in code
- Loading maps authored in Tiled (`.tmx`/`.tmj`), LDtk (`.ldtk`), or
  Sprite Fusion (`.json` export)
- Pixel-art correctness (`ImageFiltering.Pixel`, anti-bleed, integer
  scaling)
- Z-order / layering via `actor.z`

## When NOT to use (route to another skill)

- Engine construction + engine-level `pixelArt: true` flag →
  `excalibur-setup`
- Scene/actor lifecycle, cameras, events, transitions, `Label` as an
  actor → `excalibur-core` (labels are an actor subclass, but
  `Font`/`SpriteFont`/`Text` details live here)
- Loading the raw image/audio/json/gif files, `ImageSource`,
  `ImageFiltering`, `ImageWrapping`, Aseprite plugin →
  `excalibur-resources`
- Physics/colliders, input, `actor.actions` → `excalibur-simulation`
- Custom ECS `Component`/`System`/`Query` — `excalibur-ecs`
- `Vector` math, `Timer`, `coroutine`, `ParticleEmitter`, easing →
  `excalibur-utilities`

---

## A. Graphics

### Concept map — Graphics

| API | Purpose |
|-----|---------|
| `ex.Graphic` (abstract) | Base class for every drawable unit. Common props: `width`, `height`, `flipHorizontal`, `flipVertical`, `rotation` (radians), `opacity` (0..1), `scale: Vector`, `origin?: Vector`, `tint: Color`. All have `.clone()`. |
| `ex.Sprite` | A view into an `ImageSource`. `sourceView` slices the image; `destSize` resizes the output. `new Sprite({ image, sourceView?, destSize? })` or `image.toSprite()`. |
| `ex.SpriteSheet` | Ordered collection of sprites from one `ImageSource`. Static builders: `SpriteSheet.fromImageSource({ image, grid, spacing? })` and `SpriteSheet.fromImageSourceWithSourceViews({ image, sourceViews })`. Access: `sheet.getSprite(x, y)`, `sheet.sprites[i]`, `sheet.getTiledSprite(x, y, opts)`. |
| `ex.Animation` | Ordered `Frame[]` with durations. `new Animation({ frames, strategy, speed?, frameDuration?, totalDuration? })` or `Animation.fromSpriteSheet(sheet, indices, msPerFrame, strategy?)` or `Animation.fromSpriteSheetCoordinates({ spriteSheet, frameCoordinates, durationPerFrame, strategy })`. |
| `ex.AnimationStrategy` | `Loop` (default), `PingPong`, `Freeze` (stops on last frame), `End` (stops rendering). |
| `ex.Raster` (abstract) | Graphics built on a `CanvasRenderingContext2D` bitmap (`execute(ctx)` implementation). Subclasses below. Call `.flagDirty()` to force a repaint. |
| `ex.Rectangle` | `new ex.Rectangle({ width, height, color, strokeColor?, lineWidth? })`. |
| `ex.Circle` | `new ex.Circle({ radius, color, ... })`. |
| `ex.Polygon` | `new ex.Polygon({ points: Vector[], color })`. |
| `ex.Line` | `new ex.Line({ start, end, color, thickness })` (the graphic — not `Debug.drawLine`). |
| `ex.Text` | Raster-rendered text. `new ex.Text({ text, font?, color?, maxWidth? })`. Supports `\n` for multi-line. |
| `ex.Font` | System / web font. `new ex.Font({ family, size, unit?, color?, bold?, style?, textAlign?, baseAlign?, shadow?, quality? })`. |
| `ex.FontSource` | Loadable `.ttf`/`.otf` font. `new ex.FontSource(path, family, opts?)`; `await fontSource.load()`; `fontSource.toFont(opts?)`. Lives in `excalibur-resources` for loader wiring. |
| `ex.SpriteFont` | Bitmap font built from a `SpriteSheet`. `new ex.SpriteFont({ alphabet, spriteSheet, caseInsensitive?, spacing? })`. |
| `ex.GraphicsComponent` | Attached to every `Actor` as `actor.graphics`. Named-graphic registry + show/hide + per-component `opacity`/`anchor`/`offset`/`material`/`color`. |
| `ex.GraphicsGroup` | `new ex.GraphicsGroup({ members: [{ graphic, offset, useBounds? }], useAnchor? })`. Painter-order composition. |
| `ex.Canvas` | `new ex.Canvas({ width, height, cache?, draw: (ctx: CanvasRenderingContext2D) => void })`. Arbitrary 2D drawing; re-rasters every frame unless `cache: true` + `.flagDirty()`. |
| `ex.NineSlice` | `new ex.NineSlice({ width, height, source, sourceConfig, destinationConfig })`. Scalable bordered texture; `NineSliceStretch.Stretch` / `Tile` / `TileFit`. |
| `ex.ParallaxComponent` | Component (not graphic). `actor.addComponent(new ex.ParallaxComponent(ex.vec(0.5, 0.5)))`. Shifts rendering by `parallaxFactor * cameraPos`. |
| `ex.Material` | Custom GLSL ES 300 fragment shader. `engine.graphicsContext.createMaterial({ name, fragmentSource, color?, images? })`; assign via `actor.graphics.material = material`. WebGL-only. |
| `actor.z: number` | Per-actor draw order within a scene. Higher z draws on top. Also on scene entities that aren't actors. |

### `Graphic` common properties (on every subclass)

```ts
graphic.width;            // number
graphic.height;           // number
graphic.flipHorizontal;   // boolean
graphic.flipVertical;     // boolean
graphic.rotation;         // radians
graphic.opacity;          // 0..1
graphic.scale;            // Vector (mutates width/height reported)
graphic.origin;           // Vector | null (null -> center)
graphic.tint;             // Color — multiplicative; White is no-op
graphic.clone();          // deep copy
```

### `GraphicsComponent` — the API on every `Actor`

```ts
// Register + show
actor.graphics.add(graphic);                     // anonymous -> 'default', shown
actor.graphics.add('run', runAnim);              // named, not shown
actor.graphics.use('run');                       // switch to named
actor.graphics.use(idleSprite);                  // or pass a Graphic directly
actor.graphics.hide();                           // nothing renders
actor.graphics.current;                          // currently displayed Graphic | null

// Query
actor.graphics.getGraphic('run');                // Graphic | undefined
actor.graphics.getNames();                       // string[]
actor.graphics.remove('run');

// Per-component overrides (apply to ALL graphics in the component)
actor.graphics.visible   = true;
actor.graphics.opacity   = 0.5;
actor.graphics.offset    = ex.vec(0, -16);
actor.graphics.anchor    = ex.vec(0.5, 1);       // bottom-center pivot
actor.graphics.color     = ex.Color.Red;         // multiplies the current graphic
actor.graphics.material  = myMaterial;

// Draw hooks — get at the ExcaliburGraphicsContext
actor.graphics.onPreDraw  = (ctx, elapsed) => { /* ... */ };
actor.graphics.onPostDraw = (ctx, elapsed) => { /* ... */ };
```

Default anchor on `GraphicsComponent` is `(0.5, 0.5)` — graphics center
on the actor's `pos`. Override per-actor via `new Actor({ anchor: ex.vec(0, 0) })`
or via `actor.graphics.anchor`.

### Common recipes — Graphics

**1. Draw a sprite from an image**

```ts
const image = new ex.ImageSource('./player.png');
await game.start(new ex.Loader([image]));

const player = new ex.Actor({ pos: ex.vec(100, 100) });
player.graphics.use(image.toSprite());
scene.add(player);
```

**2. Slice a sheet + get a single sprite**

```ts
const sheetImage = new ex.ImageSource('./tiles.png');
await sheetImage.load();

const sheet = ex.SpriteSheet.fromImageSource({
  image: sheetImage,
  grid: { rows: 4, columns: 8, spriteWidth: 16, spriteHeight: 16 },
  spacing: { originOffset: { x: 0, y: 0 }, margin: { x: 0, y: 0 } }, // optional
});

const grass = sheet.getSprite(0, 0);   // top-left tile
const wall  = sheet.getSprite(3, 2);
```

**3. Build an animation from a spritesheet**

```ts
// Indices run row-major across the sheet.
const runAnim = ex.Animation.fromSpriteSheet(
  sheet,
  ex.range(0, 7),                  // ex.range(0, 7) -> [0,1,2,3,4,5,6,7]
  80,                              // ms per frame
  ex.AnimationStrategy.Loop
);

// Or by (x, y) coordinates with per-frame control:
const idleAnim = ex.Animation.fromSpriteSheetCoordinates({
  spriteSheet: sheet,
  frameCoordinates: [
    { x: 0, y: 0, duration: 200 },
    { x: 1, y: 0, duration: 200, options: { flipHorizontal: true } },
  ],
  strategy: ex.AnimationStrategy.PingPong,
});

// Or frame-by-frame with arbitrary graphics mixed in:
const mixed = new ex.Animation({
  frames: [
    { graphic: sheet.getSprite(0, 0), duration: 100 },
    { graphic: new ex.Circle({ radius: 8, color: ex.Color.Red }), duration: 200 },
  ],
  strategy: ex.AnimationStrategy.Loop,
});
```

**4. Switch graphics by state**

```ts
class Player extends ex.Actor {
  onInitialize() {
    this.graphics.add('idle', idleAnim);
    this.graphics.add('run',  runAnim);
    this.graphics.add('jump', jumpSprite);
    this.graphics.use('idle');
  }

  onPreUpdate(engine: ex.Engine) {
    if (engine.input.keyboard.isHeld(ex.Keys.Space)) this.graphics.use('jump');
    else if (this.vel.x !== 0)                      this.graphics.use('run');
    else                                            this.graphics.use('idle');
  }
}
```

Re-calling `use('run')` when it's already current is a no-op; the
animation isn't reset. Call `runAnim.reset()` if you want to restart.

**5. Animation events + control**

```ts
runAnim.events.on('frame', (f) => { /* per-frame */ });
runAnim.events.on('loop',  () => { /* per-loop (Loop strategy only) */ });
runAnim.events.on('end',   () => { /* only fires for Freeze/End */ });

runAnim.pause();
runAnim.play();
runAnim.reset();
runAnim.speed = 2.0;                  // 2x speed
runAnim.currentFrame;                 // Frame | null
runAnim.currentFrameIndex;            // number
```

**6. Primitives (raster graphics)**

```ts
const rect     = new ex.Rectangle({ width: 100, height: 40, color: ex.Color.Green });
const circle   = new ex.Circle({ radius: 8, color: ex.Color.Red });
const triangle = new ex.Polygon({
  points: [ex.vec(0, 0), ex.vec(20, 40), ex.vec(-20, 40)],
  color: ex.Color.Yellow,
});

const lineActor = new ex.Actor({ pos: ex.vec(0, 0) });
lineActor.graphics.anchor = ex.Vector.Zero;   // default center is awkward for lines
lineActor.graphics.use(new ex.Line({
  start: ex.vec(0, 0), end: ex.vec(200, 200),
  color: ex.Color.Green, thickness: 4,
}));
```

**7. GraphicsGroup — compose in painter order**

```ts
const group = new ex.GraphicsGroup({
  useAnchor: false,              // position members from top-left
  members: [
    { graphic: body,     offset: ex.vec(0, 0) },
    { graphic: head,     offset: ex.vec(0, -24) },
    { graphic: hpText,   offset: ex.vec(-20, -40), useBounds: false },
  ],
});
actor.graphics.use(group);
```

Members draw in order (first is "bottom"). `useAnchor: false` positions
the whole group from its top-left so offsets are absolute pixels rather
than centered. Disable `useBounds` on a per-member basis for dynamic
text whose bounds would shift the group's center.

**8. Canvas — arbitrary 2D drawing**

```ts
const canvas = new ex.Canvas({
  width: 200,
  height: 200,
  cache: true,                   // draw once, reuse until flagDirty()
  draw: (ctx: CanvasRenderingContext2D) => {
    ctx.fillStyle = '#f00';
    ctx.fillRect(0, 0, 200, 200);
    ctx.fillStyle = '#fff';
    ctx.font = '20px sans-serif';
    ctx.fillText('hello', 10, 30);
  },
});

actor.graphics.use(canvas);
// later:
canvas.flagDirty();              // force a re-render
```

Always set explicit `width`/`height`. Without `cache: true` every frame
re-rasters — expensive. For constantly-changing text prefer `ex.Text`.

**9. NineSlice — scalable UI border/button**

```ts
import { NineSlice, NineSliceStretch } from 'excalibur';

const button = new NineSlice({
  width: 240, height: 64,
  source: Resources.ButtonPanel,          // ImageSource
  sourceConfig: {
    width: 64, height: 64,                // source tile size
    topMargin: 8, leftMargin: 8, bottomMargin: 8, rightMargin: 8,
  },
  destinationConfig: {
    drawCenter: true,
    horizontalStretch: NineSliceStretch.TileFit,
    verticalStretch:   NineSliceStretch.TileFit,
  },
});

const uiActor = new ex.ScreenElement({ pos: ex.vec(16, 16), width: 240, height: 64 });
uiActor.graphics.use(button);
scene.add(uiActor);
```

`drawCenter: false` makes the 9-slice a frame-only (hollow) border.
Resizing changes the output: create a new `NineSlice` rather than
mutating an existing instance.

**10. Tint and color vs. material**

```ts
sprite.tint = ex.Color.fromHex('#FF000080'); // multiplicative; alpha deepens the tint
sprite.tint = ex.Color.White;                // no-op (identity)

// A per-component color overlay via graphics component:
actor.graphics.color = ex.Color.Red;
```

`Color.White` as tint is a no-op because tint multiplies RGB by
`(1,1,1)`. For flashing a damage effect set and clear the tint on
`collisionstart`.

**11. ParallaxComponent — simple backgrounds**

```ts
const bg = new ex.Actor({ pos: ex.vec(0, 0), anchor: ex.Vector.Zero });
bg.graphics.use(skyImage.toSprite());
bg.addComponent(new ex.ParallaxComponent(ex.vec(0.3, 0.3))); // 30% of camera motion
scene.add(bg);
```

`parallaxFactor: (0, 0)` is locked to camera (HUD-like);
`parallaxFactor: (1, 1)` is identical to a plain actor; values between
are foreshortened. Don't attach colliders to parallax actors — their
visible position is decoupled from their physics position.

**12. Pixel art**

Engine-level `pixelArt: true` is in `excalibur-setup`. Per-image
filtering (`ImageFiltering.Pixel`) is in `excalibur-resources`. For
graphics-side concerns:

- Keep actor and tile positions on integer coordinates (set
  `snapToPixel: true` on the engine or round in `onPreUpdate`).
- Use integer `scale` on graphics (or leave it `(1, 1)` and zoom the
  camera).
- Avoid rotations other than 0/90/180/270 on raw sprites — use
  `Material` with the pixel-art sampler (see the shader in the Materials
  doc) if you need smooth arbitrary rotation.
- Anti-bleed: with a non-`pixelArt` engine, tightly-packed sheets can
  bleed pixels from neighbours at non-integer camera scales. Fixes:
  add 1-px transparent margins to your sheet, use
  `ImageFiltering.Pixel`, or set `pixelArt: true`.

**13. Material — custom fragment shader**

```ts
const material = game.graphicsContext.createMaterial({
  name: 'red-flash',
  fragmentSource: `#version 300 es
  precision mediump float;
  uniform sampler2D u_graphic;
  uniform float u_time_ms;
  in vec2 v_uv;
  out vec4 fragColor;
  void main() {
    vec4 c = texture(u_graphic, v_uv);
    float pulse = 0.5 + 0.5 * sin(u_time_ms / 200.0);
    c.rgb = mix(c.rgb, vec3(1.0, 0.0, 0.0), pulse * c.a);
    c.rgb *= c.a;                // premultiplied alpha
    fragColor = c;
  }`,
});
actor.graphics.material = material;

// Later — push uniforms:
material.update((shader) => {
  shader.trySetUniformFloat('u_intensity', 0.8);
});
```

WebGL-only (2D-canvas fallback silently skips materials). `#version 300
es` must be the very first line. Premultiplied alpha — multiply
`fragColor.rgb *= fragColor.a` before output or colors go wrong.
Full uniform catalogue and screen-texture tricks live in the docs.

**14. Text, Font, SpriteFont**

```ts
// System / web font
const text = new ex.Text({
  text: 'Score: 0',
  font: new ex.Font({
    family: 'sans-serif',
    size: 24,
    unit: ex.FontUnit.Px,
    color: ex.Color.White,
    bold: false,
    shadow: { blur: 4, offset: ex.vec(1, 1), color: ex.Color.Black },
    quality: 2,            // upscale internal bitmap for crisper text
  }),
});
scoreActor.graphics.use(text);
// mutate text.text at any time; it re-rasters automatically

// Loadable TTF
const fontSource = new ex.FontSource('./Pixelated.ttf', 'Pixelated');
loader.addResource(fontSource);
// after load:
const pixelFont = fontSource.toFont({ size: 16, color: ex.Color.White });

// Bitmap font from a spritesheet of glyphs
const glyphImage = new ex.ImageSource('./font.png');
await glyphImage.load();
const glyphSheet = ex.SpriteSheet.fromImageSource({
  image: glyphImage,
  grid: { rows: 3, columns: 16, spriteWidth: 8, spriteHeight: 8 },
});
const spriteFont = new ex.SpriteFont({
  alphabet: "0123456789abcdefghijklmnopqrstuvwxyz,!'&.\"?- ",
  caseInsensitive: true,
  spriteSheet: glyphSheet,
});
const scoreText = new ex.Text({ text: '0', font: spriteFont });
```

For a batteries-included text actor, `ex.Label` wraps Text + Font. See
`excalibur-core`'s Label recipe. `SpriteFont` is ~10x cheaper than
`Font` for low-res games — the browser's `fillText` is the bottleneck
and sprite glyphs skip it entirely.

### Gotchas — Graphics

- **`graphics.use(name)` is idempotent.** Re-switching to the current
  graphic doesn't reset an animation. Call `anim.reset()` explicitly.
- **Default anchor is `(0.5, 0.5)` everywhere.** `actor.anchor`,
  `actor.graphics.anchor`, and the per-graphic origin all default to
  center. Expect to set `anchor: ex.vec(0, 0)` for UI / top-left
  semantics.
- **`graphics.use()` clones graphics by default** when `copyGraphics` is
  truthy in component options, so mutating `anim.speed` after `use` may
  not affect the displayed copy. Keep a reference to the instance you
  want to control, or set `copyGraphics: false` when constructing the
  component.
- **Animation frame durations are per-frame.** A 10-frame animation at
  100 ms is 1 second total; total-duration construction via
  `totalDuration` spreads evenly.
- **`AnimationStrategy.End` stops drawing.** `Freeze` holds the last
  frame. Pick deliberately — `End` looks like the actor disappeared.
- **`Canvas` re-rasters every frame without `cache: true`.** Big canvases
  with dynamic contents will tank FPS. Use `Text` for text.
- **`NineSlice` instances aren't reactive.** Resizing a window? Destroy
  and rebuild the NineSlice, don't mutate properties.
- **`Material` is WebGL-only.** If the engine fell back to 2D canvas
  (WebGL context lost / unsupported), materials are a silent no-op.
- **Tint is multiplicative.** `Color.White` is no-op; use alpha in the
  tint color to dial intensity. Clear by setting tint to white.
- **`quality` on `Font` upscales the internal bitmap.** Default is 2.
  Bump to 3–4 for HiDPI + small text; each step doubles memory.
- **Web fonts need time to load.** If `Font.family` references a CSS
  font that hasn't finished loading, Canvas will substitute a system
  fallback. Poll `document.fonts.check('24px Foo')` or use
  `ex.FontSource` for an asset-loader-integrated path.
- **`actor.z` is per-actor; `graphic.origin` / `order in GraphicsGroup`
  is within one actor.** For cross-actor ordering, set `z`; within an
  actor use `GraphicsGroup` members.
- **Raster caches are lazy.** Changing `Rectangle.color` won't take
  effect until `rect.flagDirty()` (or on next frame for some subclasses).
- **Aseprite isn't here.** `@excaliburjs/plugin-aseprite` lives in
  `excalibur-resources`. It returns `Animation`/`SpriteSheet`/
  `ImageSource` you then use with the graphics APIs above.

---

## B. UI

Two routes: in-canvas (`ScreenElement`) or HTML/CSS overlay.

### Concept map — UI

| API | Purpose |
|-----|---------|
| `ex.ScreenElement` | `extends Actor`. Lives in `CoordPlane.Screen` (ignores camera), auto-captures pointer events, draws above normal world actors, default anchor `(0, 0)`, default `CollisionType.PreventCollision`. Drop-in replacement for HUD actors. |
| `CoordPlane.Screen` | On any actor: `new ex.Actor({ coordPlane: ex.CoordPlane.Screen })`. Same "ignore camera" behavior as `ScreenElement` but without the pointer/anchor defaults. |
| HTML overlay | Absolute-positioned DOM over the canvas. Control routing via `pointer-events: none` (pass through to canvas) / `all` (capture). Use `engine.screen.worldToPageCoordinates` to pin DOM elements to world positions. |
| `engine.screen.worldToPageCoordinates(v)` | World → CSS-pixel page coord. |
| `engine.screen.screenToPageCoordinates(v)` | Screen (game-pixel) → CSS-pixel page coord. |
| `PointerScope.Canvas` | Default. Excalibur only captures pointer events inside the canvas — HTML outside gets them. Set in `EngineOptions.pointerScope`. |

### When to pick which

- **Use `ScreenElement`** for: simple HUDs, score labels, minimap,
  in-canvas buttons that match the game's art style, anything that
  needs to share the game's zoom/scale/filter effects, quick
  prototyping.
- **Use an HTML overlay** for: complex menus, accessibility
  (screen readers, keyboard navigation), form inputs, rich CSS styling,
  long text blocks, anything the browser's layout engine does well.

### Common recipes — UI

**1. ScreenElement button with hover/click**

```ts
class StartButton extends ex.ScreenElement {
  constructor() {
    super({ x: 50, y: 50, width: 200, height: 60 });
  }

  onInitialize() {
    this.graphics.add('idle',  Resources.ButtonIdle.toSprite());
    this.graphics.add('hover', Resources.ButtonHover.toSprite());
    this.graphics.use('idle');

    this.on('pointerenter', () => this.graphics.use('hover'));
    this.on('pointerleave', () => this.graphics.use('idle'));
    this.on('pointerup',    () => game.goToScene('level1'));
  }
}

scene.add(new StartButton());
```

`ScreenElement` sets `pointer.useGraphicsBounds = true`, so the hit-area
matches the displayed graphic (not a collider) even when `width`/
`height` aren't passed.

**2. HUD score label (ScreenElement)**

```ts
class ScoreLabel extends ex.ScreenElement {
  text = new ex.Text({ text: 'Score: 0', font: new ex.Font({ size: 20, color: ex.Color.White }) });

  constructor() {
    super({ x: 10, y: 10 });
    this.graphics.use(this.text);
  }

  setScore(n: number) { this.text.text = `Score: ${n}`; }
}
```

`ex.Label` is the batteries-included alternative (see `excalibur-core`).

**3. Health bar as a GraphicsGroup on the player**

```ts
const bg   = new ex.Rectangle({ width: 40, height: 4, color: ex.Color.Red });
const fill = new ex.Rectangle({ width: 40, height: 4, color: ex.Color.Green });

const hp = new ex.GraphicsGroup({
  useAnchor: false,
  members: [
    { graphic: bg,   offset: ex.vec(-20, -28) },
    { graphic: fill, offset: ex.vec(-20, -28) },
  ],
});

player.graphics.add('hp', hp);
player.graphics.use('hp');            // or combine via a second actor / child

// In update:
fill.width = 40 * (player.health / player.maxHealth);
fill.flagDirty();
```

A child `Actor` that follows the player is another common pattern
(`player.addChild(hpActor)`) when you need the bar to rotate/scale
independently.

**4. HTML overlay — button over the canvas**

```html
<!-- index.html -->
<style>
  html, body { margin: 0; padding: 0; background: #000; }
  #root { position: relative; }
  #game { display: block; }
  #ui   { position: absolute; inset: 0; pointer-events: none; }
  #ui .pane { pointer-events: all; padding: 1rem; background: #0008; color: white; }
</style>
<div id="root">
  <canvas id="game"></canvas>
  <div id="ui"></div>
</div>
```

```ts
// main.ts
import * as ex from 'excalibur';

const game = new ex.Engine({
  canvasElementId: 'game',
  width: 800, height: 600,
  pointerScope: ex.PointerScope.Canvas,     // crucial — don't steal DOM clicks
});

class MainMenu extends ex.Scene {
  onActivate() {
    const ui = document.getElementById('ui')!;
    const pane = document.createElement('div');
    pane.className = 'pane';
    pane.innerHTML = `<h1>Main Menu</h1><button id="start">Start</button>`;
    ui.appendChild(pane);

    pane.querySelector<HTMLButtonElement>('#start')!.onclick = () => {
      game.goToScene('level1');
    };
  }
  onDeactivate() {
    document.getElementById('ui')!.innerHTML = '';
  }
}
```

Outer `#ui` has `pointer-events: none` so canvas receives clicks
everywhere except the `.pane` (which opts back in with `all`). Tear
down DOM in `onDeactivate` or on scene transitions.

**5. Pin a DOM tooltip to a world position**

```ts
const tooltip = document.getElementById('tooltip')!;

game.on('postupdate', () => {
  const page = game.screen.worldToPageCoordinates(player.pos.add(ex.vec(0, -40)));
  tooltip.style.transform = `translate(${page.x}px, ${page.y}px)`;
});
```

Set the tooltip's CSS `position: absolute; top: 0; left: 0;
transform: translate(...)` and update `transform` each frame. Reset on
`engine.screen.events.on('resize', ...)`.

### Gotchas — UI

- **`ScreenElement` default anchor is `(0, 0)`,** not `(0.5, 0.5)` like
  regular actors. Its `pos` is the top-left of its graphic.
- **`ScreenElement` is drawn above regular actors automatically** — it
  forces `CoordPlane.Screen` and disables collisions. Don't also set
  `coordPlane: World` on it.
- **`PointerScope.Canvas` is the default.** With
  `PointerScope.Document`, Excalibur will steal clicks from your HTML
  UI. Leave it at Canvas unless you know you need the opposite.
- **HTML overlays and pixel art fight each other.** Pair
  `pixel-conversion` CSS variable with `transform: scale(...)` on UI
  containers (see `HTML, CSS, and JavaScript` doc snippet), or scale
  to match `engine.screen.worldToPageCoordinates(vec(1,0))`.
- **`pointer-events: none` cascades to children.** If your overlay
  wrapper has `none` and a child has `all`, the child is clickable and
  the wrapper passes through — the usual desired routing.
- **Don't `ui.innerHTML = ''` on every frame.** Clear on scene
  deactivation only. Mutate text nodes for dynamic counters.
- **Web fonts render in HTML instantly but not in `ex.Font`.** Canvas
  text needs the font actually loaded (see Graphics gotchas).
- **`ScreenElement.contains(x, y)` takes world coords by default.**
  Pass `useWorld = false` to check screen coords.
- **Screen-plane positions are in logical game pixels, not CSS pixels.**
  `ScreenElement({ x: 10, y: 10 })` is 10 _game_ pixels in, scaled to
  the viewport.

---

## C. Tile Maps

Two shapes: orthogonal (`TileMap`) and isometric (`IsometricMap`). Plus
three editor plugins that share the `resource.addToScene(scene)` idiom.

### Concept map — Tile Maps

| API | Purpose |
|-----|---------|
| `ex.TileMap` | Flat 2D grid. `new ex.TileMap({ rows, columns, tileWidth, tileHeight, pos?, renderFromTopOfGraphic?, meshingLookBehind? })`. Iterate `tilemap.tiles`. Add to scene like any entity: `scene.add(tilemap)`. |
| `ex.Tile` | Element of `tilemap.tiles`. `tile.x`, `tile.y` (integer coords), `tile.solid`, `tile.addGraphic(graphic, { offset? })`, `tile.removeGraphic`, `tile.clearGraphics`, `tile.addCollider(c)`, `tile.clearColliders()`, `tile.data` (arbitrary). |
| `tilemap.getTile(x, y)` | Tile at integer coord or null. |
| `tilemap.getTileByPoint(worldVec)` | Tile at world coord or null. |
| `ex.IsometricMap` | 2.5D grid. `new ex.IsometricMap({ pos, rows, columns, tileWidth, tileHeight, elevation?, renderFromTopOfGraphic? })`. `tileHeight` is usually _half_ the visible asset height. |
| `ex.IsometricTile` | Like `Tile` but entity-based. `tile.addGraphic`, `tile.solid`, `tile.addCollider`. |
| `isoMap.worldToTile(v) / tileToWorld(v)` | Coord conversion. |
| `ex.IsometricEntityComponent` | Added automatically to `IsometricTile`s; add to any moving actor that should depth-sort against tiles. |
| `ex.IsometricEntitySystem` | Runs z-index calculation from `elevation` + transform Y each frame. |
| `@excaliburjs/plugin-tiled` — `TiledResource(path, opts?)` | Loads `.tmx`/`.tmj`/`.tsx`/`.tsj`. Orthogonal + Isometric. Multi-layer, object layers, entity factories, custom colliders, parallax, cameras. |
| `@excaliburjs/plugin-ldtk` — `LdtkResource(path, opts?)` | Loads `.ldtk`. IntGrid solids, entity identifier factories, level offsets. Strictly version-matched to LDtk. |
| `@excaliburjs/plugin-spritefusion` — `SpriteFusionResource({ mapPath, spritesheetPath })` | Loads Sprite Fusion JSON + spritesheet. Collision layer check-box → solids, entity tile-id factories, object layers with attribute data. |
| `resource.addToScene(scene, opts?)` | Shared pattern across all three plugins. Optional `pos`, `levelFilter`, etc. |

### Common recipes — Tile Maps

**1. Hand-built orthogonal TileMap**

```ts
const tilesImage = new ex.ImageSource('./tiles.png');
await game.start(new ex.Loader([tilesImage]));

const sheet = ex.SpriteSheet.fromImageSource({
  image: tilesImage,
  grid: { rows: 2, columns: 4, spriteWidth: 16, spriteHeight: 16 },
});

const map = new ex.TileMap({
  pos: ex.vec(0, 0),
  rows: 20, columns: 30,
  tileWidth: 16, tileHeight: 16,
});

for (const tile of map.tiles) {
  const grass = sheet.getSprite(0, 0);
  tile.addGraphic(grass);
  // mark the outer ring as solid so actors can't leave:
  if (tile.x === 0 || tile.y === 0 || tile.x === 29 || tile.y === 19) {
    tile.addGraphic(sheet.getSprite(1, 0));
    tile.solid = true;
  }
}

scene.add(map);
```

`tile.solid = true` causes the tile to contribute to the tilemap's
composite collider automatically — no manual `addCollider` needed for
simple rectangular tiles.

**2. Resolve world pointer → tile**

```ts
game.input.pointers.primary.on('down', (evt) => {
  const tile = map.getTileByPoint(evt.worldPos);
  if (tile) {
    tile.solid = !tile.solid;
    tile.clearGraphics();
    tile.addGraphic(sheet.getSprite(tile.solid ? 1 : 0, 0));
  }
});
```

`getTileByPoint` returns `null` outside the map's bounds. Integer
coordinate form: `map.getTile(tileX, tileY)`.

**3. Multiple visual layers on one map**

```ts
for (const tile of map.tiles) {
  tile.addGraphic(sheet.getSprite(0, 0));     // ground
  if (Math.random() < 0.1) {
    tile.addGraphic(sheet.getSprite(2, 0));   // decoration drawn on top
  }
}
```

Graphics render in add-order per tile. For z-order across tilemaps set
`tilemap.z` (it's an entity with a transform).

**4. Isometric map**

```ts
const isoMap = new ex.IsometricMap({
  pos: ex.vec(400, 50),
  rows: 10, columns: 10,
  tileWidth: 32,
  tileHeight: 16,                    // half of the 32-px art asset height
});

for (const tile of isoMap.tiles) {
  tile.addGraphic(grassSprite);
}
scene.add(isoMap);

// Pointer → tile coord:
game.input.pointers.primary.on('move', (evt) => {
  const coord = isoMap.worldToTile(evt.worldPos);
  // coord.x / coord.y are integer tile indices
});

// Depth-sort a moving actor against the map:
player.addComponent(new ex.IsometricEntityComponent(isoMap));
```

`IsometricEntityComponent` on movable actors is what keeps the player
drawn *behind* tiles taller than them and *in front of* shorter ones.
`IsometricEntitySystem` reads `elevation + y` to compute z.

**5. Stacked isometric layers for elevation**

```ts
[floor, wall1, wall2].forEach((layerData, index) => {
  const layer = new ex.IsometricMap({
    pos: ex.vec(300, 184 + index * -16),
    tileWidth: 32, tileHeight: 16,
    rows: 5, columns: 5,
    elevation: index,
  });
  scene.add(layer);
  layer.tiles.forEach((tile, i) => {
    const id = layerData[tile.y]?.[tile.x];
    if (id) tile.addGraphic(sheet.getSprite(id, 0));
  });
});
```

Stack one `IsometricMap` per elevation; bump `elevation` and shift
`pos.y` by `-tileHeight` per layer.

**6. Tiled plugin (`.tmx` / `.tmj`)**

```ts
// npm install --save-exact @excaliburjs/plugin-tiled
import * as ex from 'excalibur';
import { TiledResource } from '@excaliburjs/plugin-tiled';
import mapUrl from './city.tmx';

const map = new TiledResource(mapUrl, {
  strict: true,                      // default; set false for lenient parsing
  useMapBackgroundColor: true,
  useTilemapCameraStrategy: true,    // clamp camera to tilemap bounds
  entityClassNameFactories: {
    'player-start': (props) => new Player({
      pos: props.worldPos,
      collisionType: ex.CollisionType.Active,
    }),
  },
});

const game = new ex.Engine({ width: 800, height: 600 });
await game.start(new ex.Loader([map]));

map.addToScene(game.currentScene);
// optional: map.addToScene(scene, { pos: ex.vec(100, 100) });

// Query tiles by world point
const t = map.getTileByPoint('ground', ex.vec(200, 100));
console.log(t.tiledTile, t.exTile);
```

Orthogonal + isometric-diamond supported; hexagonal + staggered-isometric
are parsed but not rendered. `.tsx` (Tiled tileset) file extension
clashes with TypeScript React — configure your bundler to treat map
`.tsx` as an external asset (see the Tiled plugin doc for Vite/Webpack
snippets). Object layers produce actors via `entityClassNameFactories`,
queried with `map.getObjectsByClassName`/`getObjectsByName`/etc.

**7. LDtk plugin (`.ldtk`)**

```ts
// npm install @excaliburjs/plugin-ldtk
import { LdtkResource } from '@excaliburjs/plugin-ldtk';

const map = new LdtkResource('./world.ldtk', {
  strict: true,
  useMapBackgroundColor: true,
});

await game.start(new ex.Loader([map]));

map.addToScene(game.currentScene, {
  levelFilter: ['Level_1'],           // optional: only load some levels
  useLevelOffsets: true,              // default; preserves LDtk world layout
});

// Register custom entity factories by LDtk identifier:
map.registerEntityIdentifierFactory('PlayerStart', (props) => {
  const p = new Player({
    pos: props.worldPos,
    anchor: ex.vec(props.entity.__pivot[0], props.entity.__pivot[1]),
    width: props.entity.width, height: props.entity.height,
    z: props.layer.order,
  });
  game.currentScene.camera.strategy.lockToActor(p);
  return p;
});
```

IntGrid values drive solidness — value `1` is solid by default (or any
value named `solid`). LDtk plugin is strictly version-matched; it
warns if you're on an older LDtk export.

**8. Sprite Fusion plugin**

```ts
// npm install @excaliburjs/plugin-spritefusion
import { SpriteFusionResource } from '@excaliburjs/plugin-spritefusion';

const map = new SpriteFusionResource({
  mapPath: './map/map.json',               // JSON export — NOT the .sfmap save
  spritesheetPath: './map/spritesheet.png',
  entityTileIdFactories: {
    0: (props) => new ex.Actor({
      pos: props.worldPos,
      width: 16, height: 16,
      color: ex.Color.Red,
      z: props.layer.order + 1,
    }),
  },
  // Optional: attribute-per-tile data (Sprite Fusion >= 2025-10)
  tileAttributeFactory: ({ tileData }) => { /* read tileData.attributes */ },
  objectLayers: ['ObjectLayer'],            // layers parsed but not drawn
});

await game.start(new ex.Loader([map]));
map.addToScene(game.currentScene);

// Helpers
const sprite = map.getSpriteById('3');
const ground = map.getTileMap('Ground');
```

Export **JSON**, not the native save. Collision is driven by Sprite
Fusion's "collision layer" checkbox on each layer. Tile IDs in
factories are numbers matching the exported spritesheet.

### Gotchas — Tile Maps

- **Orthogonal `Tile.solid` is enough for box colliders.** The
  tilemap's internal composite collider meshes solid tiles into
  optimized rectangles. Don't `addCollider` unless the geometry isn't
  a box.
- **Isometric tile colliders are positioned relative to the top-left of
  the tile's art asset bounds** (count pixels from top-left). Forgetting
  this puts the collider in empty space.
- **Isometric `tileHeight` is typically _half_ the asset's visible
  height** because the tile's "floor" plane is the diamond. See the
  doc's diagram.
- **`IsometricEntityComponent` must be added to moving actors** to
  depth-sort against the map. Tiles come with it by default.
- **`renderFromTopOfGraphic: true` flattens tiles** — use only for
  floor-only isometric. Default (bottom) preserves the illusion of
  stacked blocks.
- **`map.getTileByPoint` uses world coords,** and
  `IsometricMap.worldToTile` is the equivalent. Passing screen coords
  gives wrong tiles.
- **Plugin package names:** `@excaliburjs/plugin-tiled`,
  `@excaliburjs/plugin-ldtk`, `@excaliburjs/plugin-spritefusion`. Easy
  to mistype; `plugin-tilemap`/`plugin-sprite-fusion` etc. do not
  exist.
- **All three map plugins implement `Loadable`** and go in any
  `Loader`. Calling `addToScene` before the loader resolves won't work.
- **Tiled `.tsx` (tileset) vs. TypeScript `.tsx` clash.** Bundler
  config needed — see the Tiled plugin doc section on Vite/Webpack.
- **Tiled hexagonal / staggered-isometric render is unsupported.**
  Data parses fine; you'd have to render yourself.
- **LDtk and Sprite Fusion are strictly version-matched.** Upgrading
  the editor without bumping the plugin can break loading; the plugin
  logs a warning and may throw if `strict: true`.
- **Sprite Fusion: JSON export, not "save".** The docs warn explicitly;
  `.sfmap` format isn't supported.
- **Plugins build real Excalibur `TileMap` / `Actor` instances.** You
  can interrogate them via `resource.getTileMap('Ground')` etc. and
  manipulate the actors they produced just like any handmade entity.
- **`addToScene(scene)` adds at `pos` from the Tiled/LDtk/SF map.**
  Override with `{ pos: ex.vec(x, y) }`. Re-calling `addToScene`
  duplicates entities.
- **Meshing is expensive.** `TileMap.meshingLookBehind` (default 10)
  controls how far back the composite collider looks when rebuilding
  after a solid tile changes. If your tilemap doesn't mutate at
  runtime, set it to `Infinity` for max geometry combining.

---

## Doc pointers

- `site/docs/04-graphics/04.1-graphics.mdx` — `Graphic` base + Raster
  overview
- `site/docs/04-graphics/04.1-sprites.mdx` — `Sprite`, `sourceView`,
  `destSize`, `image.toSprite()`
- `site/docs/04-graphics/04.1-spritesheets.mdx` — `SpriteSheet.fromImageSource`,
  sparse/grid spritesheets
- `site/docs/04-graphics/04.2-animation.mdx` — `Animation`, strategies,
  `fromSpriteSheet`
- `site/docs/04-graphics/04.2-graphics-component.mdx` — `actor.graphics`,
  `add`/`use`/`hide`, onPre/PostDraw
- `site/docs/04-graphics/04.2-graphics-group.mdx` — `GraphicsGroup`
  composition + anchor/bounds
- `site/docs/04-graphics/04.2-canvas.mdx` — `Canvas` + caching
- `site/docs/04-graphics/04.2-material.mdx` — GLSL ES 300 shaders,
  built-in uniforms, premultiplied alpha
- `site/docs/04-graphics/04.5-parallax.mdx` — `ParallaxComponent`
- `site/docs/04-graphics/04.6-nineslice.mdx` — `NineSlice`,
  `NineSliceStretch` variants
- `site/docs/04-graphics/04.7-tint.mdx` — tint multiplication,
  damage-flash pattern
- `site/docs/04-graphics/04.1-text.mdx` — `Text`, `Font`, `FontSource`,
  `SpriteFont`, text-quality tips
- `site/docs/04-graphics/06.0-pixel-art.mdx` — `pixelArt: true` flag +
  pixel-art filtering
- `site/docs/04-graphics/04.1-lines.mdx` — `Line` graphic
- `site/docs/04-graphics/04.1-color.mdx` — `ex.Color` constructors,
  `lerp`, constants
- `site/docs/05-user-interface/01-html.mdx` — HTML overlay pattern,
  `worldToPageCoordinates`, CSS `pixel-conversion`
- `site/docs/05-user-interface/02-screen-elements.mdx` — `ScreenElement`
  button sample
- `site/docs/05-user-interface/03-web-fonts.mdx` — `FontSource` for
  preloaded TTF
- `site/docs/12-other/12-ui.mdx` — UI overview, `Label` basics
- `site/docs/08-tile-maps/07-tilemap.mdx` — `TileMap`, `Tile.solid`
- `site/docs/08-tile-maps/07-isometricmap.mdx` — `IsometricMap`,
  elevation layers, collider placement
- `site/docs/13-plugins/15-tiled-plugin.mdx` — `TiledResource`,
  factories, bundler config
- `site/docs/13-plugins/15-ldtk-plugin.mdx` — `LdtkResource`, entity
  identifier factories
- `site/docs/13-plugins/15-spritefusion-plugin.mdx` — `SpriteFusionResource`,
  tile attribute factories, JSON export
- `src/engine/graphics/graphic.ts` — `Graphic` base + `GraphicOptions`
- `src/engine/graphics/sprite.ts` — `Sprite.sourceView`/`destSize`,
  `Sprite.from`
- `src/engine/graphics/sprite-sheet.ts` — `fromImageSource`,
  `fromImageSourceWithSourceViews`, `getSprite`, `getTiledSprite`
- `src/engine/graphics/animation.ts` — `AnimationStrategy`,
  `fromSpriteSheet`, `fromSpriteSheetCoordinates`, `AnimationEvents`
- `src/engine/graphics/graphics-component.ts` — `add`/`use`/`hide`/
  `remove`/`getNames`/`getGraphic` signatures
- `src/engine/graphics/graphics-group.ts` — `GraphicsGroup`,
  `GraphicsGrouping`, `useAnchor`, `useBounds`
- `src/engine/graphics/canvas.ts` — `Canvas` + cache + flagDirty
- `src/engine/graphics/nine-slice.ts` — `NineSliceConfig`,
  `NineSliceStretch`
- `src/engine/graphics/parallax-component.ts` — `ParallaxComponent`
- `src/engine/graphics/text.ts` / `font.ts` / `sprite-font.ts` — Text,
  Font (`FontOptions`), SpriteFont
- `src/engine/graphics/context/material.ts` — `Material`,
  `createMaterial`, `trySetUniform*`
- `src/engine/screen-element.ts` — `ScreenElement` (defaults: anchor
  (0,0), `CoordPlane.Screen`, `useGraphicsBounds`)
- `src/engine/tile-map/tile-map.ts` — `TileMapOptions`, `Tile.solid`,
  `getTile`, `getTileByPoint`, `addGraphic`, meshing
- `src/engine/tile-map/isometric-map.ts` — `IsometricMap`,
  `worldToTile`, `tileToWorld`, `IsometricTile`
- `src/engine/tile-map/isometric-entity-component.ts` /
  `isometric-entity-system.ts` — depth sorting
- GitHub: `excaliburjs/excalibur-tiled`,
  `excaliburjs/excalibur-ldtk`, `excaliburjs/excalibur-spritefusion` —
  plugin source and samples
