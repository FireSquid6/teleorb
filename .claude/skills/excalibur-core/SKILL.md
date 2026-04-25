---
name: excalibur-core
description: >
  Use when authoring scenes, actors, cameras, or the game loop in an Excalibur.js
  project. Covers `ex.Scene` subclassing, `onInitialize`/`onActivate`/`onDeactivate`,
  `Actor` construction (`ActorArgs` with `pos`/`vel`/`rotation`/`scale`/`z`/`width`/
  `height`/`radius`/`color`/`anchor`/`collisionType`), lifecycle hooks (`onPreUpdate`,
  `onPostUpdate`, `onPreKill`, `onPostKill`), parent/child actors via `addChild`/
  `removeChild`, `actor.kill()`, adding to scenes with `scene.add` / `engine.add`, and
  switching scenes with `engine.goToScene(name, GoToOptions)` (`destinationIn`,
  `sourceOut`, `sceneActivationData`, `loader`). Also covers `FadeInOut`/`CrossFade`/
  `Slide`/custom `Transition`s, the `EventEmitter` (`on`/`off`/`once`/`emit`) and the
  strongly-typed `ActorEvents`/`SceneEvents`/`EngineEvents` maps, `scene.camera`
  (`pos`/`zoom`/`rotation`/`shake`) and strategies (`lockToActor`, `lockToActorAxis`,
  `elasticToActor`, `radiusAroundActor`, `limitCameraBounds`, custom `CameraStrategy`),
  `Label` actors, `engine.screen` (viewport vs. resolution vs. HiDPI), `CoordPlane.World`
  vs. `CoordPlane.Screen`, and `engine.toggleDebug()`/`engine.debug`. Trigger on "add
  actor to scene", "listen for event", "camera follow player", "scene lifecycle",
  "fade between scenes", "pass data to scene", "child actor", "player class", "kill
  actor". Does NOT cover engine construction (`excalibur-setup`), graphics/sprites/
  animations/tilemaps (`excalibur-visuals`), asset loading (`excalibur-resources`),
  physics/input/actions (`excalibur-simulation`), custom ECS components/systems
  (`excalibur-ecs`), or math/timers/particles (`excalibur-utilities`).
---

# Excalibur Core

Everything between `engine.start()` and rendering a pixel: scenes, actors, cameras,
the main loop, events, and the screen abstraction. Assumes you already have an
`ex.Engine` wired up (see `excalibur-setup`).

## When to use this skill
- Subclassing `ex.Scene` for levels, menus, loaders
- Subclassing `ex.Actor` for `Player`, `Enemy`, `Bullet`, etc.
- Hooking `onInitialize`, `onPreUpdate`, `onPostUpdate`, `onPreKill`, `onPostKill`
- Nesting actors (`parent.addChild(child)`) for paper-doll / attachment patterns
- Switching scenes via `engine.goToScene('level1', { sceneActivationData, destinationIn, sourceOut, loader })`
- Defining `FadeInOut`, `CrossFade`, `Slide`, or a custom `Transition`
- Wiring a camera with `scene.camera.strategy.lockToActor(player)` or `elasticToActor`
- Listening for events (`actor.on('collisionstart', ...)`, `scene.on('activate', ...)`)
- Understanding viewport vs. resolution, `CoordPlane.World` vs. `CoordPlane.Screen`
- Debug overlay (`engine.toggleDebug()`, `engine.debug.entity.showName = true`)

## When NOT to use (route to another skill)
- Constructing `new ex.Engine({...})`, bundler setup, `engine.start()` → `excalibur-setup`
- Sprites, animations, `GraphicsComponent`, tilemaps, parallax, UI/ScreenElement → `excalibur-visuals`
- `Loader`, `ImageSource`, `Sound`, asset preloading → `excalibur-resources`
- `CollisionType`, `BodyComponent`, keyboard/pointer/gamepad input, `ActionsComponent`
  (e.g. `actor.actions.moveTo(...)`) → `excalibur-simulation`
- Custom `Component`, `System`, `Query` (pure ECS) → `excalibur-ecs`
- `Vector` math, `Timer`, `coroutine`, `ParticleEmitter`, easing → `excalibur-utilities`

## Concept map

| API | Purpose |
|-----|---------|
| `ex.Scene` | Container for actors, one active at a time. `scene.add(actor)`, `scene.remove(actor)`, `scene.camera`, `scene.world`, `scene.physics`. |
| `ex.Actor` | The primary drawable/updatable entity. Owns `transform`, `motion`, `body`, `collider`, `graphics`, `pointer`, `actions`. |
| `ex.Label` | `Actor` subclass that renders `Text` via an internal `Font`/`SpriteFont`. Use for score, HUD text. |
| `engine.add(name, scene)` | Register a named scene with the director. `engine.add(actor)` (overload) adds to `currentScene`. |
| `engine.goToScene(name, options?)` | Switch active scene. `options: GoToOptions` — see below. |
| `engine.currentScene` | The currently active `Scene`. `engine.currentSceneName` is the string key. |
| `engine.rootScene` | Auto-created default scene with key `'root'`. |
| `scene.add(entity)` | Overloaded for `Actor`, `Timer`, `TileMap`, `Trigger`, `ScreenElement`, `Entity`. |
| `actor.addChild(child)` / `actor.removeChild(child)` | Parent/child transforms; child pos/rot/scale are relative to parent. |
| `actor.kill()` | Removes from scene; fires `prekill` → `kill` → `postkill`. Use `actor.unkill()` to re-add. |
| `ex.EventEmitter<TEventMap>` | Strongly-typed pub/sub. `.on`, `.off`, `.once`, `.emit`, `.clear()`. Returns `Subscription` with `.close()`. |
| `scene.camera` | Always exists. `pos: Vector`, `zoom: number`, `rotation: number`, `shake(magX, magY, durationMs)`, `move(target, durationMs, easing?)`. |
| `camera.strategy` | Helper container. `lockToActor`, `lockToActorAxis`, `elasticToActor`, `radiusAroundActor`, `limitCameraBounds`. Advanced: `camera.addStrategy(new MyStrategy())`, `removeStrategy`, `clearAllStrategies`. |
| `engine.screen` | `viewport`, `resolution`, `pixelRatio`, `getWorldBounds()`, `worldToScreenCoordinates`, `screenToWorldCoordinates`. |
| `ex.CoordPlane` | `.World` (default; follows camera) or `.Screen` (HUD; ignores camera). |
| `engine.toggleDebug()` / `engine.showDebug(bool)` / `engine.debug` | Toggle debug overlay. Pair with the Excalibur Dev Tools browser extension. |

### `ActorArgs` — commonly-used fields

```ts
interface ActorArgs {
  name?: string;
  x?: number; y?: number;        // OR pos
  pos?: ex.Vector;
  coordPlane?: ex.CoordPlane;    // World (default) or Screen
  vel?: ex.Vector;
  acc?: ex.Vector;
  rotation?: number;             // radians
  angularVelocity?: number;      // rad/sec
  scale?: ex.Vector;
  z?: number;                    // draw order within scene
  color?: ex.Color;              // used only if no graphic is set
  graphic?: ex.Graphic;
  opacity?: number;
  visible?: boolean;
  anchor?: ex.Vector;            // default (0.5, 0.5) — graphics centered
  offset?: ex.Vector;
  // one of these three collider shapes:
  width?: number; height?: number;           // box collider
  radius?: number;                            // circle collider
  collider?: ex.Collider;                     // custom collider (width/height ignored)
  collisionType?: ex.CollisionType;           // default PreventCollision
  collisionGroup?: ex.CollisionGroup;
  canPause?: boolean;
}
```

### `GoToOptions` (verified from `src/engine/director/director.ts`)

```ts
interface GoToOptions<TActivationData = any> {
  sceneActivationData?: TActivationData;  // delivered to onActivate via ctx.data
  destinationIn?: ex.Transition;          // overrides the scene's configured `in` transition
  sourceOut?: ex.Transition;              // overrides current scene's `out` transition
  loader?: ex.DefaultLoader;              // ad-hoc per-transition loader (overrides the scene's)
}
```

## Lifecycle ordering (one tick)

Verified from `engine.ts::_update` and `scene.ts::update`:

```
Engine.clock tick
  -> engine.emit('preupdate') + engine.onPreUpdate
  -> currentScene.update()
       -> scene.emit('preupdate') + scene.onPreUpdate
       -> ECS world.update (systems in order):
            motion, collisions/physics, actors' onPreUpdate -> onPostUpdate,
            actions, pointer, graphics preparation
       -> scene.emit('postupdate') + scene.onPostUpdate
  -> engine.emit('postupdate') + engine.onPostUpdate
  -> input.update()

Draw pass (separate):
  -> engine predraw -> scene predraw -> graphics draw (ECS) -> scene postdraw -> engine postdraw
```

Practical rules:
- `onPreUpdate` runs on **last frame's state** (transforms not yet applied for this tick).
  Good for: setting `vel`, reading input.
- `onPostUpdate` runs **after** physics/movement this tick. Good for: reacting to the
  new `pos`, checking `health <= 0`, custom game rules.
- If you override `Actor.update(engine, delta)` you **must** call `super.update(engine, delta)`
  or the actor will silently break.
- Camera strategies are applied during the camera's own update — do **not** call
  `addStrategy` every frame; do it once in `onInitialize`.

## Event cheat-sheet

All three emitters use the same `EventEmitter` API: `.on(name, handler)`, `.once(...)`,
`.off(name, handler?)`, `.emit(name, event)`, `.clear()`. `.on` returns a `Subscription`
with `.close()`.

### `ActorEvents` (from `src/engine/actor.ts`)
`initialize`, `preupdate`, `postupdate`, `predraw`, `postdraw`, `pretransformdraw`,
`posttransformdraw`, `predebugdraw`, `postdebugdraw`, `prekill`, `kill`, `postkill`,
`collisionstart`, `collisionend`, `precollision`, `postcollision`, `pointerup`,
`pointerdown`, `pointerenter`, `pointerleave`, `pointermove`, `pointercancel`,
`pointerwheel`, `pointerdragstart`, `pointerdragend`, `pointerdragenter`,
`pointerdragleave`, `pointerdragmove`, `enterviewport`, `exitviewport`,
`actionstart`, `actioncomplete`.

### `SceneEvents` (from `src/engine/scene.ts`)
`initialize`, `activate`, `deactivate`, `preupdate`, `postupdate`, `predraw`,
`postdraw`, `predebugdraw`, `postdebugdraw`, `preload`, `transitionstart`,
`transitionend`, `pause`, `resume`.

### `EngineEvents` (from `src/engine/engine.ts`)
`initialize`, `start`, `stop`, `visible`, `hidden`, `preupdate`, `postupdate`,
`preframe`, `postframe`, `predraw`, `postdraw`, `fallbackgraphicscontext`, plus
director events (scene navigation/transition notifications).

Warning: Excalibur accepts any string for `.on(...)` even if it's not a declared
event (e.g. `'click'` vs. `'pointerdown'`). It won't fire and won't type-error. Prefer
constants: `actor.on(ex.ActorEvents.PointerDown, ...)`, `scene.on(ex.SceneEvents.Activate, ...)`.

## Common recipes

### 1. A custom scene with initialization and activation data

```ts
import * as ex from 'excalibur';

interface LevelData { spawn: ex.Vector; difficulty: number; }

class Level1 extends ex.Scene<LevelData> {
  private player!: Player;

  onInitialize(engine: ex.Engine) {
    // Runs exactly once, before first activate.
    this.player = new Player();
    this.add(this.player);
    this.camera.strategy.elasticToActor(this.player, 0.2, 0.1);
  }

  onActivate(ctx: ex.SceneActivationContext<LevelData>) {
    // May run multiple times (every goToScene into this scene).
    if (ctx.data) {
      this.player.pos = ctx.data.spawn.clone();
    }
  }

  onDeactivate(_ctx: ex.SceneActivationContext) {
    // Save state, stop music, etc.
  }
}

const game = new ex.Engine({ width: 800, height: 600 });
game.add('level1', new Level1());
await game.start();
await game.goToScene('level1', {
  sceneActivationData: { spawn: ex.vec(100, 200), difficulty: 2 }
});
```

### 2. A custom actor with full lifecycle

```ts
import * as ex from 'excalibur';

export class Player extends ex.Actor {
  private health = 100;

  constructor() {
    super({
      name: 'player',
      pos: ex.vec(50, 50),
      width: 32,
      height: 32,
      color: ex.Color.Red,
      collisionType: ex.CollisionType.Active,
    });
  }

  onInitialize(_engine: ex.Engine) {
    this.on('collisionstart', (evt) => {
      // evt.target is the other collider
      this.health -= 10;
    });
  }

  onPreUpdate(_engine: ex.Engine, _elapsed: number) {
    // Read input, set velocity here — runs before physics.
    this.vel = ex.vec(0, 0);
  }

  onPostUpdate(_engine: ex.Engine, _elapsed: number) {
    if (this.health <= 0) this.kill();
  }

  onPreKill(_scene: ex.Scene)  { /* spawn death particles */ }
  onPostKill(_scene: ex.Scene) { /* tell the scene */ }
}
```

### 3. Parent/child actors

```ts
const body = new ex.Actor({ pos: ex.vec(100, 100), width: 32, height: 48 });
const gun  = new ex.Actor({ pos: ex.vec(16, 0), width: 16, height: 4 }); // offset from parent

body.addChild(gun);       // gun's transform is now relative to body
scene.add(body);          // adding parent is enough; children follow
// later: body.removeChild(gun);
```

### 4. Scene transitions (configured up front)

```ts
const game = new ex.Engine({
  width: 800, height: 600,
  scenes: {
    menu: {
      scene: MainMenu,
      transitions: {
        in:  new ex.FadeInOut({ duration: 400, direction: 'in',  color: ex.Color.Black }),
        out: new ex.FadeInOut({ duration: 400, direction: 'out', color: ex.Color.Black }),
      },
    },
    level1: { scene: Level1 },
  },
});

await game.start('menu');
// Later — override transitions at the call site:
await game.goToScene('level1', {
  sourceOut:     new ex.FadeInOut({ duration: 500, direction: 'out' }),
  destinationIn: new ex.CrossFade  ({ duration: 800, direction: 'in', blockInput: true }),
  sceneActivationData: { spawn: ex.vec(0, 0) },
});
```

`CrossFade` can only be used as the destination `in` transition (it screenshots the
previous scene). `Slide` is the third built-in. For anything else, extend `ex.Transition`
and override `onInitialize` / `onStart` / `onUpdate` / `onEnd`.

### 5. Dynamic per-scene transition

```ts
class Level extends ex.Scene {
  override onTransition(direction: 'in' | 'out') {
    return new ex.FadeInOut({ direction, color: ex.Color.Violet, duration: 600 });
  }
}
```

### 6. Camera — follow, clamp, shake

```ts
class World extends ex.Scene {
  onInitialize(engine: ex.Engine) {
    const player = new Player();
    this.add(player);

    // Smooth spring-follow
    this.camera.strategy.elasticToActor(player, 0.2, 0.1);

    // Clamp camera to level bounds (must be >= viewport size)
    const bounds = new ex.BoundingBox(0, 0, 2000, 1200);
    this.camera.strategy.limitCameraBounds(bounds);

    // Zoom in over 500ms
    this.camera.zoomOverTime(1.5, 500);

    // On hit, shake
    player.on('collisionstart', () => {
      this.camera.shake(10, 10, 200);
    });
  }
}
```

Custom strategy:

```ts
class LeadCameraStrategy implements ex.CameraStrategy<ex.Actor> {
  constructor(public target: ex.Actor, public lead = 80) {}
  action = (t: ex.Actor, cam: ex.Camera, _e: ex.Engine, _ms: number) => {
    const dir = t.vel.normalize();
    return t.pos.add(dir.scale(this.lead));
  };
}
scene.camera.addStrategy(new LeadCameraStrategy(player));
```

### 7. Custom typed events on an actor

```ts
type PlayerEvents = { healthdepleted: PlayerHealthDepletedEvent };

class PlayerHealthDepletedEvent extends ex.GameEvent<Player> {
  constructor(public target: Player) { super(); }
}

class Player extends ex.Actor {
  // Intersect custom events with the built-in ActorEvents
  events = new ex.EventEmitter<ex.ActorEvents & PlayerEvents>();
  private health = 100;

  onPostUpdate() {
    if (this.health <= 0) {
      this.events.emit('healthdepleted', new PlayerHealthDepletedEvent(this));
    }
  }
}

const p = new Player();
const sub = p.events.on('healthdepleted', (evt) => console.log('dead', evt.target));
// sub.close(); // unsubscribes
```

A standalone pub/sub bus is just `const vent = new ex.EventEmitter<MyMap>()`.

### 8. HUD that ignores the camera

```ts
const scoreLabel = new ex.Label({
  text: 'Score: 0',
  pos: ex.vec(10, 10),
  coordPlane: ex.CoordPlane.Screen, // stays on screen regardless of camera
  font: new ex.Font({ family: 'sans-serif', size: 20, color: ex.Color.White }),
});
scene.add(scoreLabel);
```

### 9. Scene-local preload

```ts
class BossLevel extends ex.Scene {
  boss!: ex.ImageSource;
  override onPreLoad(loader: ex.DefaultLoader) {
    this.boss = new ex.ImageSource('/assets/boss.png');
    loader.addResource(this.boss);
  }
  onInitialize() {
    const actor = new ex.Actor({ pos: ex.vec(200, 200) });
    actor.graphics.use(this.boss.toSprite());
    this.add(actor);
  }
}
```

Runs once, the first time the scene is navigated to. Deep loader stuff lives in
`excalibur-resources`.

## Gotchas

- **`onInitialize` vs. constructor.** `onInitialize` runs once, right before the actor's
  first update — not at construction. Do asset-dependent setup there. Constructors run
  immediately, before assets are loaded.
- **`onPreUpdate` sees stale transforms.** Physics and transform propagation haven't
  run yet. Read input/set velocity in `onPreUpdate`; react to new position in `onPostUpdate`.
- **Overriding `update()` without `super.update()` silently breaks the actor.** The
  docs are emphatic about this. Prefer `onPreUpdate`/`onPostUpdate` unless you know
  you need to override `update`.
- **Default anchor is `(0.5, 0.5)`.** The actor's `pos` is its center, not its top-left.
  Graphics also center. Use `anchor: ex.vec(0, 0)` if you want top-left semantics.
- **Add camera strategies once, in `onInitialize`.** They run themselves every frame;
  calling `lockToActor` each tick stacks them.
- **`goToScene` is async.** It awaits the source's `out` transition, deactivation,
  scene load, initialization, activation, and `in` transition. Don't forget to `await`
  when ordering matters.
- **`goToScene` can only navigate to scenes added to the director.** Either via
  `EngineOptions.scenes` or `engine.add('key', scene)`. Otherwise it no-ops with a warning.
- **`CrossFade` only works as a destination `in` transition.** It screenshots the
  previous scene, so `sourceOut: new CrossFade(...)` will not behave correctly.
- **Scene data is typed via the `Scene<TActivationData>` generic.** `onActivate`
  receives `SceneActivationContext<T>` where `ctx.data` is your payload and
  `ctx.previousScene`/`ctx.engine` are also available.
- **`actor.kill()` removes from scene but does not null references.** If you stored
  the actor elsewhere, GC won't collect until you drop your refs. `actor.unkill()`
  re-adds to the same scene.
- **`CoordPlane.Screen` ignores the camera but still lives in logical resolution
  pixels,** not CSS pixels. So `(10, 10)` is 10 *game* pixels from the top-left,
  scaled to the viewport.
- **Viewport vs. resolution vs. drawWidth.** `engine.screen.viewport` is CSS pixels
  on the page. `engine.screen.resolution` is the logical pixel grid your game runs in.
  `engine.drawWidth`/`drawHeight` are the actual backing-store pixel dimensions
  (accounts for HiDPI). Input-to-world conversion should always go through
  `engine.screenToWorldCoordinates(point)`.
- **HiDPI auto-scaling can break at large resolutions.** WebGL caps texture/canvas
  dimensions near 4096 on mobile. If you set `resolution: { width: 3000, height: 3000 }`,
  also set `suppressHiDPIScaling: true` or mobile devices will fail to upload textures.
- **`engine.add(actor)` only adds to the current scene.** If you meant to add to a
  specific scene, use `targetScene.add(actor)` directly.
- **String event names are flexible but untyped-safe.** `actor.on('click', ...)` will
  never fire — the correct name is `'pointerdown'`. Use `ex.ActorEvents.PointerDown`
  to avoid typos.
- **Event handlers are synchronous.** Throwing inside one aborts the current emit for
  subsequent handlers. Keep them fast and non-throwing.

## Debugging

```ts
const game = new ex.Engine({ width: 800, height: 600 });
game.toggleDebug();                    // or game.showDebug(true)
game.debug.entity.showName = true;     // annotate actors by name
game.debug.collider.showBounds = true; // draw collider AABBs
game.debug.physics.showContacts = true;
```

Install the Excalibur Dev Tools browser extension (Chrome/Firefox) for a scene-graph
inspector and runtime tweaks; it reads from the global engine instance.

`ex.Debug` (static) provides `drawLine`, `drawPoint`, `drawCircle`, `drawBounds` that
work from anywhere (no graphics context needed); they only render while debug is on.

## Doc pointers

- `site/docs/02-fundamentals/04-architecture.mdx` — engine main loop / scene graph
- `site/docs/02-fundamentals/04-scenes.mdx` — `Scene` lifecycle, static scene map, `onPreLoad`
- `site/docs/02-fundamentals/03-actors.mdx` — `Actor` lifecycle, children, graphics
- `site/docs/02-fundamentals/04-cameras.mdx` — strategies, shake, lerp
- `site/docs/02-fundamentals/04-events.mdx` — `EventEmitter`, typed event maps
- `site/docs/02-fundamentals/05-transitions.mdx` — `FadeInOut`, `CrossFade`, custom transitions
- `site/docs/02-fundamentals/07-debugging.mdx` — debug overlay + extension
- `site/docs/03-screen-viewport/screens-display.mdx` — viewport/resolution/HiDPI
- `site/docs/03-screen-viewport/screens-display-modes.mdx` — `DisplayMode` variants (also in `excalibur-setup`)
- `src/engine/scene.ts` (lifecycle + `SceneEvents` at line ~48)
- `src/engine/actor.ts` (`ActorArgs` at line ~60; `ActorEvents` at line ~201; pos/vel/scale/z getters at ~330+)
- `src/engine/camera.ts` (`StrategyContainer` at line ~45; `CameraStrategy` interface at ~15)
- `src/engine/director/director.ts` (`GoToOptions` at line ~75; `goToScene` at ~422)
- `src/engine/director/{fade-in-out,cross-fade,slide,transition}.ts` — built-in transitions
- `src/engine/events.ts` — every `GameEvent` subclass (`PreUpdateEvent`, `CollisionStartEvent`, etc.)
- `src/engine/label.ts` — `Label extends Actor` with `text`, `font`, `spriteFont`, `maxWidth`, `color`
