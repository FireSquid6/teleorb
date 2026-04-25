---
name: excalibur-simulation
description: >
  Use when adding physics, actions (scripted movement), or input handling to
  an Excalibur.js game. Covers the two physics solvers
  (`SolverStrategy.Arcade` for fast AABB/no-rotation, `SolverStrategy.Realistic`
  for rigid-body with rotation/friction/bounciness/torque), selected via
  `Engine({ physics: { solver, gravity } })` or `scene.physics.config.solver`.
  Covers `CollisionType.Active`/`Fixed`/`Passive`/`PreventCollision` and the
  behavior matrix. Covers `BodyComponent` (`mass`, `inertia`, `bounciness`,
  `friction`, `useGravity`, `canSleep`, `sleepMotion`, `limitDegreeOfFreedom`
  with `DegreeOfFreedom.Rotation`/`X`/`Y`, `applyImpulse`/`applyLinearImpulse`/
  `applyAngularImpulse`, `enableFixedUpdateInterpolate`, `setSleeping`/`wake`/
  `sleep`) and `ColliderComponent` (`CircleCollider`, `PolygonCollider` —
  convex only — `EdgeCollider`, `CompositeCollider`, `Shape.Box(w,h)`,
  `Shape.Circle(r)`, `Shape.Polygon(points)`, `Shape.Edge(a,b)`,
  `Shape.Capsule(w,h)`, `actor.collider.set(c)`). Covers collision events
  `collisionstart` / `collisionend` / `precollision` / `postcollision` with
  `CollisionContact` (`mtv`, `normal`, `cancel()`), `Side` enum. Covers
  `CollisionGroup` / `CollisionGroupManager.create(name)` bitmask filtering
  and `CollisionGroup.collidesWith([...])` helper. Covers
  `engine.fixedUpdateFps`, `scene.physics.rayCast(ray, opts)`,
  `scene.physics.query(pointOrBounds)`, `collider.collide(other)`. Covers
  `actor.actions` fluent chain — `moveTo(pos, speed)` / `moveTo({ pos,
  duration, easing })` / `moveBy`, `rotateTo`/`rotateBy` with `RotationType`,
  `scaleTo`/`scaleBy`, `fade(opacity, ms)`, `delay(ms)`, `blink`, `easeTo`/
  `easeBy`, `follow`, `meet`, `die`, `callMethod`, `repeat`, `repeatForever`,
  `clearActions`, `runAction`, `.toPromise()`, `ex.ActionSequence` +
  `ex.ParallelActions`, `ex.EasingFunctions`, and the `ex.Action` interface
  (`update`/`isComplete`/`reset`/`stop`). Covers input:
  `engine.input.keyboard` (`isHeld` / `wasPressed` / `wasReleased`, `press`/
  `release`/`hold` events, `ex.Keys` — `Keys.Space`, `Keys.ArrowLeft`, `Keys.W`),
  `engine.input.pointers.primary` / `pointers.at(n)` / `pointers.on('down'|
  'up'|'move'|'wheel'|'cancel')`, `WheelEvent`, `PointerComponent` with
  `useGraphicsBounds`, actor events `pointerenter`/`pointerleave`/
  `pointerdown`/`pointerup`/`pointerdrag*`, and `engine.input.gamepads`
  (`enabled`, `at(n)`, `connect`/`disconnect`/`button`/`axis` events,
  `ex.Buttons.Face1`/`DpadLeft`/..., `ex.Axes.LeftStickX`/...,
  `isButtonHeld`/`wasButtonPressed`/`wasButtonReleased`/`getButton`/`getAxes`).
  Trigger on "player movement", "patrol", "follow the player", "tween",
  "easing", "key press", "WASD movement", "space to jump", "click on actor",
  "drag and drop", "multi-touch", "gamepad", "joystick", "controller",
  "collision", "hitbox", "bounce", "damage on touch", "platformer physics",
  "raycast", "line of sight", "gravity", "friction", "rigid body",
  "fixed update", "collision group", "collision filter". Does NOT cover
  engine construction (`excalibur-setup`), scene/actor/camera (`excalibur-core`),
  rendering/HUD (`excalibur-visuals`), asset loading (`excalibur-resources`),
  custom components/systems (`excalibur-ecs`), timers/coroutines/math
  (`excalibur-utilities`).
---

# Excalibur Simulation

Anything that makes an actor move, react, or respond to the player: the
physics world (`BodyComponent` + `ColliderComponent` + `PhysicsWorld`), the
scripted-action chain (`actor.actions`), and the three input backends
(`keyboard`, `pointers`, `gamepads`). Assumes the engine is running
(`excalibur-setup`) and scenes/actors exist (`excalibur-core`).

## When to use this skill

- Picking Arcade vs. Realistic physics; setting gravity
- Setting `CollisionType`, swapping an actor's collider, filtering with
  `CollisionGroup`s
- Listening for `collisionstart` / `collisionend` / `precollision` /
  `postcollision` and resolving hits
- Raycasts for line-of-sight / aim; spatial queries
- Scripted actor movement via chained `actor.actions.moveTo(...).delay(...)`
- Tweening (`fade`, `blink`, `rotateTo`, `scaleTo`, `easeTo`) and
  `follow`/`meet`/`repeatForever` patrols
- Keyboard polling (WASD, arrows) or `press`/`release`/`hold` events
- Mouse/touch globally (`pointers.primary`) or per-actor (`pointerenter`,
  drag events)
- Gamepad axis/button input with connect events

## When NOT to use (route to another skill)

- Engine construction and the `physics:` block on `new ex.Engine({...})` →
  `excalibur-setup`
- Scene / Actor lifecycle, cameras, generic events → `excalibur-core`
- Sprites, animation, HUD, ScreenElement pointer routing → `excalibur-visuals`
- Loading images/audio/JSON → `excalibur-resources`
- Custom `Component` / `System` / `Query` → `excalibur-ecs`
- `Timer`, `coroutine`, `Vector` math, `ParticleEmitter` →
  `excalibur-utilities`

---

## A. Physics

### Concept map — Physics

| API | Purpose |
|-----|---------|
| `SolverStrategy.Arcade` | Default. AABB resolution, no rotation, no friction. Fast, predictable. Platformers, top-down, tile-based. |
| `SolverStrategy.Realistic` | Rigid-body solver with rotation, friction, bounciness, torque. Stacking, angry-birds, billiards. |
| `Engine({ physics: { solver, gravity, enabled, continuous, ... } })` | Engine-wide config (see `excalibur-setup`). |
| `scene.physics.config.solver` | Per-scene override. `scene.physics` is the `PhysicsWorld`. |
| `CollisionType.PreventCollision` | No events, no resolution. Default for bare `BodyComponent` and `ScreenElement`. |
| `CollisionType.Passive` | Events only — never moves, never moved. Triggers/sensors. |
| `CollisionType.Active` | Moves, is moved, fires events. |
| `CollisionType.Fixed` | Immovable solid. Resolves against Active. Walls, ground, platforms. |
| `BodyComponent` | `actor.body`. `mass`, `inertia` (from collider), `bounciness` (0..1), `friction` (0..1, Realistic only), `useGravity`, `canSleep`, `sleepMotion`, `collisionType`, `group`, `vel`/`acc`/`angularVelocity`, `limitDegreeOfFreedom: DegreeOfFreedom[]`. |
| `DegreeOfFreedom` | `Rotation`, `X`, `Y`. Push to `body.limitDegreeOfFreedom` to lock. |
| `body.applyImpulse(point, impulse)` | Instant velocity + torque change (Active only, Realistic). `applyLinearImpulse(v)` for no torque. `applyAngularImpulse(point, v)` for torque only. |
| `body.setSleeping(bool)` / `wake()` / `sleep()` | Manual sleep control. |
| `ColliderComponent` | `actor.collider`. `.get()` / `.set(c)` / `.clear()`. Piped events to the actor. |
| `CircleCollider({ radius, offset? })` / `Shape.Circle(r, offset?)` | Disk. |
| `PolygonCollider({ points, offset? })` / `Shape.Polygon(points)` | **Convex only!** Points clockwise. |
| `EdgeCollider({ begin, end })` / `Shape.Edge(a, b)` | Line segment. |
| `CompositeCollider([colliders])` | Multiple colliders on one entity. |
| `Shape.Box(w, h, anchor?, offset?)` | Axis-aligned box (a 4-point `PolygonCollider`). |
| `Shape.Capsule(w, h, offset?)` | Two circles + a box. Great for platformer players. |
| `CollisionGroup` / `CollisionGroupManager.create(name)` | 32-bit bitmask. A `create`d group does **not** collide with itself; `CollisionGroup.All` collides with everything. |
| `CollisionGroup.collidesWith([g1, g2, ...])` | Helper: build a group whose mask is exactly these groups. |
| `new ex.Actor({ collisionGroup: group })` | Assign at construction. |
| `scene.physics.rayCast(ray, opts)` | Returns `RayCastHit[]`. Opts: `maxDistance`, `collisionGroup`/`collisionMask`, `filter(hit)`, `searchAllColliders`, `ignoreCollisionGroupAll`. |
| `scene.physics.query(point \| BoundingBox)` | Colliders at a point or inside a box. |
| `colliderA.collide(colliderB)` | Direct overlap test, returns `CollisionContact[]`. |
| `Engine({ fixedUpdateFps })` | Stable physics at a decoupled FPS. Graphics interpolate automatically. |
| `body.enableFixedUpdateInterpolate = false` | Disable per-actor interpolation. |
| `ex.Physics.gravity` | Deprecated global setter. Prefer the per-engine `physics.gravity`. |
| Collision events on `actor` or `actor.collider` | `'collisionstart'`, `'collisionend'`, `'precollision'`, `'postcollision'` — payload has `self`, `other` (both `Collider`), `side: Side`, `contact: CollisionContact`. |
| `Side` enum | `Top`, `Bottom`, `Left`, `Right`, `None`. |
| `CollisionContact` | `.mtv` (min-translation vector), `.normal`, `.cancel()` (in `precollision` only). |

### Collision-type matrix

| self \ other | Prevent | Passive | Active | Fixed |
|---|:-:|:-:|:-:|:-:|
| Prevent | — | — | — | — |
| Passive | — | events | events | events |
| Active  | — | events | resolve + events | resolve + events |
| Fixed   | — | events | resolve + events | — |

"resolve" ⇒ `postcollision` also fires. "events" ⇒ `precollision`,
`collisionstart`, `collisionend` but no motion change and no `postcollision`.

Per-frame ordering for a contacting pair: `precollision` → solver runs →
`postcollision` (if it resolved). `collisionstart` fires once the first
frame, `collisionend` once the frame they separate.

### Common recipes — Physics

**1. Realistic physics with gravity**

```ts
const game = new ex.Engine({
  width: 800, height: 600,
  physics: { solver: ex.SolverStrategy.Realistic, gravity: ex.vec(0, 800) },
});
```

Arcade is default and silently ignores `body.friction`.

**2. Collider construction**

```ts
const box   = new ex.Actor({ pos: ex.vec(0, 0), width: 32, height: 32,
                             collisionType: ex.CollisionType.Active });
const ball  = new ex.Actor({ pos: ex.vec(0, 0), radius: 16,
                             collisionType: ex.CollisionType.Active });

// Explicit shape:
const tri = new ex.Actor({
  pos: ex.vec(100, 100),
  collider: ex.Shape.Polygon([ex.vec(-10, 10), ex.vec(0, -10), ex.vec(10, 10)]),
  collisionType: ex.CollisionType.Active,
});

// Capsule for a platformer player:
const player = new ex.Actor({
  pos: ex.vec(0, 0),
  collider: ex.Shape.Capsule(16, 40),
  collisionType: ex.CollisionType.Active,
});

// Swap at runtime:
player.collider.set(ex.Shape.Box(16, 20));
```

**3. Collision events — grounding, triggers, cancelling**

```ts
player.on('collisionstart', (e: ex.CollisionStartEvent) => {
  if (e.side === ex.Side.Bottom) player.isGrounded = true;
});
player.on('collisionend', (e) => {
  if (e.side === ex.Side.Bottom) player.isGrounded = false;
});
player.on('precollision', (e) => {
  // cancel per-pair resolution this frame (e.g. one-way platforms):
  if (e.other.owner.name === 'oneway' && player.vel.y < 0) e.contact.cancel();
});
player.on('postcollision', (e) => { /* resolution happened */ });
```

`e.other` is a `Collider`; `e.other.owner` is the `Actor`. `contact.cancel()`
only meaningful inside `precollision`.

**4. BodyComponent tuning**

```ts
ball.body.mass       = 2;
ball.body.bounciness = 0.9;                // elastic
ball.body.friction   = 0.3;                // Realistic only
ball.body.useGravity = true;
ball.body.limitDegreeOfFreedom.push(ex.DegreeOfFreedom.Rotation);  // lock spin

// Impulses (Active + Realistic):
ball.body.applyLinearImpulse(ex.vec(0, -500));             // jump
ball.body.applyImpulse(ball.pos.add(ex.vec(10, 0)),         // off-center kick
                       ex.vec(0, -300));                    // adds torque
```

There is no `applyForce` — use `vel`/`acc` directly or impulses.

**5. Collision groups — filter bullets, players, enemies**

```ts
export const PlayerGroup = ex.CollisionGroupManager.create('player');
export const EnemyGroup  = ex.CollisionGroupManager.create('enemy');
export const FloorGroup  = ex.CollisionGroupManager.create('floor');

const bulletGroup = ex.CollisionGroup.collidesWith([EnemyGroup]);

const bullet = new ex.Actor({
  collisionType: ex.CollisionType.Active,
  collisionGroup: bulletGroup,      // hits enemies only
});
```

Manager-created groups don't collide with themselves by default
(two bullets pass through each other). Use `CollisionGroup.All` for
"collide with everything including self." 32 groups maximum.

**6. Raycast for line-of-sight**

```ts
const ray = new ex.Ray(enemy.pos, player.pos.sub(enemy.pos).normalize());
const [hit] = scene.physics.rayCast(ray, {
  maxDistance: 400,
  filter: (h) => h.collider.owner !== enemy,
});
enemy.canSeePlayer = hit?.collider.owner === player;
```

`RayCastHit` has `.collider`, `.body`, `.point`, `.normal`, `.distance`.
`direction` must be a unit vector for `maxDistance` to be meaningful.

**7. Fixed-timestep physics**

```ts
const game = new ex.Engine({
  fixedUpdateFps: 60,
  physics: { solver: ex.SolverStrategy.Realistic, gravity: ex.vec(0, 800) },
});
```

Update runs at a guaranteed 60Hz; graphics auto-interpolate for smoothness
at higher render FPS. Turn off per actor with
`actor.body.enableFixedUpdateInterpolate = false`.

### Gotchas — Physics

- **Polygons must be convex.** Non-convex arrays warn and misbehave. Use
  `CompositeCollider` or `Shape.Capsule` for complex shapes.
- **Polygon winding.** `PolygonCollider` expects clockwise points;
  `Shape.Polygon` is tolerant but consistency matters.
- **Default `BodyComponent.collisionType` is `PreventCollision`.** The
  most common "collision not firing" bug. Set
  `collisionType: CollisionType.Active` on `new Actor({...})`.
- **Arcade ignores `friction`** and can't rotate; switch to Realistic if
  you need either.
- **`collisionstart` fires once per pair.** Use `precollision` for
  per-frame work during contact.
- **`postcollision` only fires when resolution ran** (Active-Active or
  Active-Fixed). Passive pairs get `collisionstart`/`end` but no
  `postcollision`.
- **Manager-created groups don't collide with themselves.** Share a group
  → objects pass through. Use `CollisionGroup.All` or a custom mask.
- **32 groups maximum** — each `create` consumes a bit. Reuse groups
  across actor categories.
- **`applyImpulse` needs Active + Realistic.** No-op elsewhere; Arcade
  ignores torque.
- **`ex.Physics.gravity` is deprecated** — use
  `new Engine({ physics: { gravity } })`.
- **`useGravity: true` is a no-op on non-Active bodies** (Fixed never
  moves).
- **Colliders have no independent world position** — they follow their
  owner's `TransformComponent`.

---

## B. Actions

### Concept map — Actions

| API | Purpose |
|-----|---------|
| `actor.actions` | Fluent `ActionContext`. Each method enqueues and returns `this`. |
| `.moveTo(pos, speed)` / `.moveTo(x, y, speed)` | Speed in **px/s**. `moveTo(ex.vec(100, 0), 200)` = travel at 200 px/s. |
| `.moveTo({ pos, duration, easing? })` | Duration form in **ms**. Prefer for tweens. |
| `.moveBy(offset, speed)` / `.moveBy({ offset, duration, easing? })` | Relative. |
| `.easeTo(pos, ms, easing?)` / `.easeBy(offset, ms, easing?)` | Alias/deprecated; duration-form `moveTo` is the replacement. |
| `.rotateTo(angleRad, speedRadPerSec, RotationType?)` / object form | `RotationType.ShortestPath` (default), `LongestPath`, `Clockwise`, `CounterClockwise`. |
| `.rotateBy(offsetRad, speedRadPerSec, RotationType?)` / object form | Relative. |
| `.scaleTo(size, speed)` / `.scaleTo(sx, sy, spx, spy)` / object form | Scale per second in speed form. |
| `.scaleBy(offset, speed)` / object form | Relative. |
| `.fade(opacity, duration)` | Tween `actor.graphics.opacity`. |
| `.blink(timeVisible, timeNotVisible, n = 1)` | Toggle visibility. |
| `.delay(ms)` | Wait. |
| `.flash(color, duration = 1000)` | Flash via tint. |
| `.callMethod(fn)` | Run a function as the next step. |
| `.follow(target, followDistance?)` | Stay at a distance. **Never completes.** |
| `.meet(target, speed?, tolerance?)` | Move until within `tolerance` (default 1 px). **May never complete.** |
| `.die()` | Queues `actor.kill()`; later actions are dropped. |
| `.repeat(builder, n)` / `.repeatForever(builder)` | Sub-chains. `.repeat(.., 0)` is forever. |
| `.clearActions()` | Wipe the queue. Calls `stop()` on current. |
| `.runAction(action)` | Push a custom `Action` instance. |
| `.toPromise()` | Resolves when the queue *up to this call* drains. |
| `ex.ActionSequence(actor, ctx => { ... })` | Reusable sequence. |
| `ex.ParallelActions([a, b, ...])` | Run children concurrently; completes when all complete. Queue via `runAction`. |
| `ex.EasingFunctions` | `Linear`, `EaseInQuad`, `EaseOutQuad`, `EaseInOutQuad`, `EaseInCubic`, `EaseOutCubic`, `EaseInOutCubic`. Custom: `(t, start, end, dur) => number`. |
| `ex.Action` interface | Custom: `update(elapsed)`, `isComplete()`, `reset()`, `stop()`. |
| `actor.actionQueue` | Low-level queue; usually use `runAction`. |

### Common recipes — Actions

**1. Patrol (repeatForever chain)**

```ts
class Enemy extends ex.Actor {
  patrol() {
    this.actions.clearActions();
    this.actions.repeatForever((ctx) => {
      ctx.moveTo(ex.vec(300, 100), 80)      // speed 80 px/s
         .delay(500)
         .moveTo(ex.vec(100, 100), 80)
         .delay(500);
    });
  }
}
```

**2. Duration + easing**

```ts
actor.actions.moveTo({
  pos: ex.vec(400, 300),
  duration: 1500,
  easing: ex.EasingFunctions.EaseInOutCubic,
});
```

Duration form is usually right for UI/cutscenes; speed form for
constant-velocity movement.

**3. Await a chain**

```ts
enemy.actions.moveTo(ex.vec(200, 200), 100).delay(500);
await enemy.actions.toPromise();
enemy.onReachedTarget();
```

`toPromise()` snapshots the queue at call time.

**4. Parallel tweens**

```ts
const move = new ex.ActionSequence(actor, (c) => {
  c.easeBy(ex.vec(200, 0), 1000, ex.EasingFunctions.EaseInOutCubic);
  c.easeBy(ex.vec(-200, 0), 1000, ex.EasingFunctions.EaseInOutCubic);
});
const spin = new ex.ActionSequence(actor, (c) => {
  c.rotateBy(Math.PI * 2, Math.PI, ex.RotationType.Clockwise);
});
actor.actions.runAction(new ex.ParallelActions([move, spin]));
```

**5. Follow / Meet**

```ts
minion.actions.follow(player, 40);                     // never completes
missile.actions.meet(target, 300).callMethod(() => missile.kill());
```

Break out with `clearActions()`.

**6. Custom `Action`**

```ts
class WaitUntilGrounded implements ex.Action {
  private _done = false;
  constructor(private actor: Player) {}
  update() { if (this.actor.isGrounded) this._done = true; }
  isComplete() { return this._done; }
  reset() { this._done = false; }
  stop()  { this._done = true; }
}
player.actions.runAction(new WaitUntilGrounded(player))
              .callMethod(() => player.playLandSfx());
```

**7. Damage flash**

```ts
enemy.on('collisionstart', (e) => {
  if (e.other.owner.name === 'bullet') {
    enemy.actions.clearActions();
    enemy.actions.blink(100, 100, 3);
  }
});
```

### Gotchas — Actions

- **Two `moveTo` overloads, different units.** Positional =
  **speed px/s**; object = **duration ms**. Passing `1000` as speed
  launches the actor off-screen. Passing `200` as duration looks like
  teleportation.
- **`rotateTo` speed is rad/s,** not deg/s. Convert with `* Math.PI/180`.
- **`follow`/`meet` don't reliably complete** — anything chained after
  may never run. Use `clearActions()` to interrupt.
- **`.die()` ends the chain.** Later actions are dropped.
- **`repeat(builder, 0)` becomes `repeatForever`.** Pass a positive `n`
  or call `repeatForever` explicitly.
- **`.toPromise()` captures the queue *now*.** Adding actions afterward
  doesn't delay it.
- **`ParallelActions` waits for *every* child.** Including `follow`/
  `meet` inside makes the whole parallel never complete.
- **Actions mutate `actor.pos`/`rotation` directly** — they bypass
  velocity-based integration. `CollisionType.Active` + `moveTo` through
  a wall can jitter or tunnel. For physics-driven motion set `vel`; for
  scripted motion use actions.
- **Easing only applies in object-form overloads** and `easeTo`/`easeBy`.
  The speed-form `moveTo(pos, speed)` is always linear.
- **`clearActions()` fires `stop()` on the current action.** Custom
  actions should clean up there.

---

## C. Input

### Concept map — Input

| API | Purpose |
|-----|---------|
| `engine.input.keyboard` | Always enabled. |
| `keyboard.isHeld(Keys.W)` | True while the key is down. |
| `keyboard.wasPressed(Keys.Space)` | True only the frame of press. |
| `keyboard.wasReleased(Keys.Space)` | True only the frame of release. |
| `keyboard.on('press'\|'release'\|'hold', fn)` | `KeyEvent` with `.key`. |
| `ex.Keys` | W3C codes. `Space`, `Enter`, `Escape` (alias `Esc`), `ArrowLeft`/`ArrowRight`/`ArrowUp`/`ArrowDown` (aliases `Left`/`Right`/`Up`/`Down`), `W`/`A`/`S`/`D` (aliases for `KeyW`/`KeyA`/...), `F1..F12`, `Digit0..9`, `Numpad0..9`. |
| `engine.input.pointers` | Mouse + touch + pen. |
| `pointers.primary` | Default pointer. |
| `pointers.at(n)` | nth pointer (multi-touch). Lazy-created. |
| `pointers.on('down'\|'up'\|'move'\|'wheel'\|'cancel', fn)` | Global across all pointers. |
| `pointers.primary.on(...)` / `pointers.at(n).on(...)` | Per-pointer. |
| `PointerEvent` | `.worldPos`, `.screenPos`, `.pagePos`, `.pointerType` (`Mouse`/`Touch`/`Pen`), `.button` (`PointerButton.Left`/`Right`/`Middle`/`NoButton`). |
| `WheelEvent` | `.deltaX`, `.deltaY`, `.deltaZ`, `.deltaMode` (`Pixel`/`Line`/`Page`), inherits `worldPos`/`screenPos`. |
| `pointers.primary.lastWorldPos` / `lastScreenPos` / `lastPagePos` | Poll position; `null` if idle. |
| `actor.on('pointerenter'\|'pointerleave'\|'pointerdown'\|'pointerup'\|'pointerdragstart'\|'pointerdragmove'\|'pointerdragend', fn)` | Per-actor. Hit-test on collider. |
| `actor.pointer.useGraphicsBounds = true` | Hit-test by graphic bounds (required for graphics-only actors). |
| `EngineOptions.pointerScope` | `PointerScope.Canvas` (default) / `PointerScope.Document` (page-wide, beware stealing DOM clicks). |
| `engine.input.gamepads` | Polling-based; opt-in. |
| `gamepads.enabled = true` | Start polling (attaching any handler also enables). |
| `gamepads.setMinimumGamepadConfiguration({ axis, buttons })` | Filter out touchpads/webcams. |
| `gamepads.at(n)` | `Gamepad` (0-3). Never null — returns an inert one if no pad connected. |
| `gamepads.on('connect'\|'disconnect', fn)` | `GamepadConnectEvent.gamepad` is the ref. |
| `gamepad.on('button'\|'axis', fn)` | `GamepadButtonEvent` / `GamepadAxisEvent`. |
| `gamepad.isButtonHeld(Buttons.Face1, threshold = 1)` | Held. |
| `gamepad.wasButtonPressed(btn)` / `wasButtonReleased(btn)` | Frame transitions. |
| `gamepad.getButton(Buttons.LeftTrigger)` | 0..1 (analog). |
| `gamepad.getAxes(Axes.LeftStickX)` | -1..1. |
| `ex.Buttons` | `Face1`/`Face2`/`Face3`/`Face4`, `LeftBumper`/`RightBumper`, `LeftTrigger`/`RightTrigger`, `Select`, `Start`, `LeftStick`/`RightStick` (click), `DpadUp`/`DpadDown`/`DpadLeft`/`DpadRight`. |
| `ex.Axes` | `LeftStickX`, `LeftStickY`, `RightStickX`, `RightStickY`. |

### Common recipes — Input

**1. WASD + arrow-key movement (poll)**

```ts
class Player extends ex.Actor {
  onPreUpdate(engine: ex.Engine) {
    const kb = engine.input.keyboard;
    const s = 200;
    this.vel = ex.vec(0, 0);
    if (kb.isHeld(ex.Keys.W) || kb.isHeld(ex.Keys.ArrowUp))    this.vel.y = -s;
    if (kb.isHeld(ex.Keys.S) || kb.isHeld(ex.Keys.ArrowDown))  this.vel.y =  s;
    if (kb.isHeld(ex.Keys.A) || kb.isHeld(ex.Keys.ArrowLeft))  this.vel.x = -s;
    if (kb.isHeld(ex.Keys.D) || kb.isHeld(ex.Keys.ArrowRight)) this.vel.x =  s;
    if (kb.wasPressed(ex.Keys.Space)) this.jump();
  }
}
```

Polling is the recommended default. `Keys.W` and `Keys.KeyW` both resolve
to the W3C code `'KeyW'`.

**2. Keyboard events**

```ts
engine.input.keyboard.on('press', (e: ex.KeyEvent) => {
  if (e.key === ex.Keys.Escape) engine.goToScene('pause');
});
```

`'hold'` fires every frame the key is down.

**3. Click to shoot**

```ts
engine.input.pointers.primary.on('down', (e: ex.PointerEvent) => {
  if (e.button === ex.PointerButton.Left) spawnBullet(player.pos, e.worldPos);
});
```

`worldPos` already accounts for camera; `screenPos` is game-pixels;
`pagePos` is CSS pixels.

**4. Per-actor pointer events + drag**

```ts
token.on('pointerenter', () => token.graphics.use('hover'));
token.on('pointerleave', () => token.graphics.use('idle'));
token.on('pointerdragstart', () => token.dragging = true);
token.on('pointerdragmove',  (e) => { if (token.dragging) token.pos = e.worldPos; });
token.on('pointerdragend',   () => token.dragging = false);
```

Graphics-only actors (no collider) need
`actor.pointer.useGraphicsBounds = true` in `onInitialize`.

**5. Multi-touch**

```ts
engine.input.pointers.at(0).on('move', (e) => drawAt(e.worldPos, ex.Color.Red));
engine.input.pointers.at(1).on('move', (e) => drawAt(e.worldPos, ex.Color.Blue));
```

`at(n)` lazy-creates. No stable per-finger identity across sessions.

**6. Mouse wheel**

```ts
engine.input.pointers.primary.on('wheel', (we: ex.WheelEvent) => {
  const factor = we.deltaY > 0 ? 0.9 : 1.1;
  scene.camera.zoom *= factor;
});
```

Trackpads emit `deltaMode: Pixel`; wheels emit `Line`.

**7. Gamepad (poll + events)**

```ts
engine.input.gamepads.enabled = true;
engine.input.gamepads.setMinimumGamepadConfiguration({ axis: 2, buttons: 4 });

engine.input.gamepads.on('connect', (ce) => {
  ce.gamepad.on('button', (be) => {
    if (be.button === ex.Buttons.Face1 && be.value > 0.5) player.jump();
  });
});

class Player extends ex.Actor {
  onPreUpdate(engine: ex.Engine) {
    const pad = engine.input.gamepads.at(0);
    const x = pad.getAxes(ex.Axes.LeftStickX);
    const y = pad.getAxes(ex.Axes.LeftStickY);
    if (Math.abs(x) > 0.2 || Math.abs(y) > 0.2) this.vel = ex.vec(x * 200, y * 200);
    else this.vel = ex.Vector.Zero;
    if (pad.wasButtonPressed(ex.Buttons.Face1)) this.jump();
  }
}
```

HTML5 Gamepad API caps at 4 pads. `at(n)` never returns null — attach a
`connect` handler for reliable detection.

### Gotchas — Input

- **`Keys` are W3C codes, not characters.** `Keys.A === 'KeyA'`; digit
  key `1` is `Keys.Digit1`, not `Keys.1`.
- **`wasPressed`/`wasReleased` are one-frame flags.** Don't read them
  from async handlers — they'll be stale. Read in `onPreUpdate` /
  `'update'` listeners.
- **`pointerScope: Document` captures page-wide clicks,** stealing
  clicks from HTML overlays. `Canvas` (default) is usually right.
- **Actor pointer events need a collider *or* `useGraphicsBounds`.**
  Graphics-only actors won't receive `pointerdown` unless you set
  `actor.pointer.useGraphicsBounds = true`. `ScreenElement` sets this
  automatically.
- **`'move'` pointer events fire constantly.** Don't allocate vectors in
  the handler; prefer polling `pointers.primary.lastWorldPos` in
  `onPreUpdate` for continuous tracking.
- **Touch events don't have a `button`.** `e.button` is `Left` or
  `NoButton`.
- **Gamepads are opt-in.** `gamepads.enabled = true` (or attach any
  handler). `at(0)` before opt-in is inert.
- **`gamepads.at(n)` never returns null** — you get a zero-valued
  placeholder when no pad is connected. Use `connect` events.
- **`isButtonPressed` is deprecated** — use `isButtonHeld`.
- **Analog triggers are buttons, not axes.** `Buttons.LeftTrigger`
  via `getButton`, range 0..1.
- **Button layout varies by OS/controller.** `Buttons.Face1` = A/Cross/B
  depending on vendor. Label UI generically or detect via `gamepad.id`.
- **Browser Gamepad API often requires a user gesture first.** Show a
  "Press any button" prompt on `connect` so the OS hands the pad to the
  page.

---

## Doc pointers

- `site/docs/10-physics/08-a-physics.mdx` — solvers, `PhysicsConfig`,
  broad/narrow phase
- `site/docs/10-physics/08-b-fixed-update.mdx` — `fixedUpdateFps`,
  `enableFixedUpdateInterpolate`
- `site/docs/10-physics/08-body.mdx` — `BodyComponent`, `DegreeOfFreedom`,
  sleep, `applyImpulse`
- `site/docs/10-physics/08-colliders.mdx` — `Circle/Polygon/Edge/Composite`,
  `Shape.*`, convex-only
- `site/docs/10-physics/08-collision-events.mdx` — event lifecycle and
  diagram
- `site/docs/10-physics/08-collision-types.mdx` — `Active`/`Fixed`/
  `Passive`/`Prevent` matrix
- `site/docs/10-physics/08-collision-groups.mdx` — bitmask filtering,
  `collidesWith`
- `site/docs/00-tutorials/How-to's/03-Colliders Primer` — walkthrough
- `site/docs/07-actions/06.1-actions.mdx` — chaining overview
- `site/docs/07-actions/06.2-a-actions-parallel.mdx` — `ParallelActions`,
  `ActionSequence`
- `site/docs/07-actions/06.2-actions-move.mdx` — `moveTo`/`moveBy`
  overloads
- `site/docs/07-actions/06.2-actions-ease.mdx`,
  `06.2-actions-delay.mdx`, `06.3-actions-fade.mdx`,
  `06.3-actions-rotate.mdx`, `06.4-actions-repeat.mdx`,
  `06.5-actions-die.mdx`, `06.5-actions-follow.mdx`,
  `06.5-actions-meet.mdx`, `06.5-actions-scale.mdx`,
  `06.10-actions-blink.mdx`, `06.11-actions-callmethod.mdx` — per-action
  refs
- `site/docs/00-tutorials/How-to's/02-Actions Primer` — actions walkthrough
- `site/docs/11-input/10.1-input.mdx` — `engine.input` overview
- `site/docs/11-input/10.2-keyboard.mdx` — `isHeld`/`wasPressed`/
  `wasReleased`, press/release/hold
- `site/docs/11-input/10.3-pointer.mdx` — primary/`at(n)`, events,
  `PointerScope`, `useGraphicsBounds`, multi-touch, drag
- `site/docs/11-input/10.4-gamepad.mdx` — `Buttons`/`Axes`, filtering,
  thresholds
- `src/engine/collision/solver-strategy.ts` — `SolverStrategy` enum
- `src/engine/collision/physics-config.ts` — `PhysicsConfig`
  (`enabled`/`gravity`/`solver`/`continuous`/`realistic`)
- `src/engine/collision/physics-world.ts` — `rayCast`, `query`
- `src/engine/collision/body-component.ts` — `BodyComponent`,
  `DegreeOfFreedom`, `applyImpulse`/`applyLinearImpulse`/
  `applyAngularImpulse`, sleep API
- `src/engine/collision/collider-component.ts` — `ColliderComponent.get`/
  `set`/`clear`
- `src/engine/collision/colliders/shape.ts` —
  `Shape.Box`/`Circle`/`Polygon`/`Edge`/`Capsule`
- `src/engine/collision/colliders/*.ts` — collider internals +
  `rayCast(ray, maxDistance)`
- `src/engine/collision/collision-type.ts` — `CollisionType` enum
- `src/engine/collision/group/collision-group-manager.ts` —
  `CollisionGroupManager.create`
- `src/engine/collision/group/collision-group.ts` — `CollisionGroup.All`,
  `collidesWith`, `canCollide`
- `src/engine/collision/side.ts` — `Side` enum + helpers
- `src/engine/collision/detection/collision-contact.ts` — `mtv`,
  `normal`, `cancel()`
- `src/engine/events.ts` — `PreCollisionEvent`, `PostCollisionEvent`,
  `CollisionStartEvent`, `CollisionEndEvent`
- `src/engine/actions/action-context.ts` — all `actor.actions.*`
  signatures + overloads
- `src/engine/actions/action.ts` — `Action` interface
- `src/engine/actions/action-queue.ts` — `ActionQueue`, `runAction`,
  `clearActions`
- `src/engine/actions/action/*.ts` — per-action classes (`MoveTo`,
  `Repeat`, `Follow`, `Meet`, `ParallelActions`, `ActionSequence`, ...)
- `src/engine/util/easing-functions.ts` — `EasingFunctions` catalogue,
  custom signature
- `src/engine/input/keyboard.ts` — `Keys` enum, `Keyboard`, `KeyEvent`
- `src/engine/input/pointer-event-receiver.ts` — `on`, `primary`, `at`
- `src/engine/input/pointer-abstraction.ts` — `lastWorldPos` / etc.
- `src/engine/input/pointer-event.ts` / `wheel-event.ts` — shapes
- `src/engine/input/pointer-component.ts` — `PointerComponent`,
  `useGraphicsBounds`
- `src/engine/input/gamepad.ts` — `Gamepads`, `Gamepad`, `Buttons`,
  `Axes`
