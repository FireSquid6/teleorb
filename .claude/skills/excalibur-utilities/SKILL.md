---
name: excalibur-utilities
description: >
  Use for math, random, and runtime utility APIs in an Excalibur.js game.
  Covers the math layer: `ex.Vector` / `ex.vec(x, y)` with constants
  (`Vector.Zero`/`One`/`Half`/`Up`/`Down`/`Left`/`Right`), arithmetic
  (`add`/`sub`/`scale`/`negate`/`normalize`/`magnitude`/`size`/`distance`/
  `dot`/`cross` (2D scalar)/`rotate`/`perpendicular`/`normal`/`clone`),
  the `setTo` mutation gotcha (use `clone` before mutating shared
  vectors); `ex.Matrix` (column-major WebGL 4x4, `Matrix.identity`,
  `translate`/`rotate`/`scale`, non-commutative `multiply`,
  `getAffineInverse`, `getPosition`/`getRotation`/`getScale`);
  `ex.Random` seeded RNG (Mersenne Twister — `new ex.Random(seed?)`,
  `integer`/`floating`/`bool`/`pickOne`/`pickSet`/`shuffle`/`range` and
  `d4`/`d6`/`d8`/`d10`/`d12`/`d20`); `ex.Ray` and `ex.LineSegment`
  intersection; `ex.BoundingBox` (`combine`/`contains`/`intersect`/
  `overlaps`/`fromPoints`). Covers runtime utilities: `ex.Timer`
  (`{ action, interval, repeats, numberOfRepeats, randomRange,
  onComplete }`, `scene.addTimer`, `start`/`pause`/`stop`/`reset`),
  `ex.Trigger` (`{ pos, width, height, target?, filter?, repeat?,
  visible?, action }` — an Actor with a Passive collider),
  `ex.coroutine` (generator-based scripted sequences, `yield` void =
  1 frame, `yield number` = ms, `yield Promise` = await, returns
  `CoroutineInstance`), `ex.Clock` (`engine.clock`, `schedule(cb, ms,
  timing)` / `clearSchedule`, `StandardClock` vs `TestClock`),
  `PauseComponent` / `PauseSystem` / `scene.pauseScene` /
  `resumeScene`, `ex.ParticleEmitter` (`{ pos, width, height,
  emitterType, radius, emitRate, particle: { life, minSpeed/maxSpeed,
  minAngle/maxAngle, beginColor/endColor, startSize/endSize, acc,
  fade, opacity, graphic } }`, `emitParticles`, burst vs continuous),
  `ColorBlindnessPostProcessor` with `ColorBlindnessMode.Protanope`/
  `Deuteranope`/`Tritanope` via `engine.graphicsContext.addPostProcessor`,
  `ex.Serializer` (save/load: `Serializer.init`, `registerComponent`,
  `registerCustomActor`, `registerGraphic`, `serializeActor`/
  `deserializeActor`, `entityToJSON`/`entityFromJSON`), and the
  Excalibur option-bag `{ ... }` constructor / `assign` convention.
  Trigger on "seeded random", "vector math", "bounding box", "ray",
  "timer", "trigger zone", "yield", "coroutine", "scripted sequence",
  "cutscene", "pause entities", "particle effect", "explosion",
  "smoke", "fire", "save/load game", "serialize actor", "color blind
  mode", "accessibility". Does NOT cover engine setup
  (`excalibur-setup`), scenes/actors/camera/events (`excalibur-core`),
  rendering/sprites/HUD (`excalibur-visuals`), physics/input/actions
  including `actor.actions.moveTo` (`excalibur-simulation`), asset
  loading (`excalibur-resources`), or custom components/systems
  (`excalibur-ecs`).
---

# Excalibur Utilities

Math primitives and non-domain runtime helpers: vectors, matrices, seeded
random, rays, bounding boxes, timers, triggers, coroutines, the clock,
the pause system, particle emitters, post-processors, and the
serializer. This skill is the catch-all for "little utility" APIs that
don't belong to a specific subsystem.

## When to use this skill

- Vector/matrix math, seeded RNG, raycasts (the geometry helper), bounding-box helpers
- Firing a repeating callback in sync with the game loop (`Timer`)
- Triggering a callback on overlap (`Trigger`) — e.g. pickups, hazards, level exits
- Scripting a cutscene or multi-step sequence with `yield` (`coroutine`)
- Scheduling a one-off callback tied to the engine clock (`engine.clock.schedule`)
- Pausing/resuming groups of entities (`PauseComponent` / `scene.pauseScene()`)
- Smoke/fire/sparks/explosions (`ParticleEmitter`)
- Color-blindness correction or a full-screen post-process effect
- Save/load to JSON (`ex.Serializer`)

## When NOT to use (route to another skill)

- Engine construction, `EngineOptions`, `maxFps` → `excalibur-setup`
- `Scene` / `Actor` / `Camera` / event emitters → `excalibur-core`
- Sprites, animations, materials, tile maps, HUD → `excalibur-visuals`
- Physics, colliders, collision events, input, `actor.actions.moveTo` →
  `excalibur-simulation`
- `ImageSource` / `Sound` / `Loader` → `excalibur-resources`
- Custom `Component` / `System` / `Query` → `excalibur-ecs`

---

## A. Math

### Concept map — Math

| API | Purpose |
|-----|---------|
| `ex.vec(x, y)` | Factory for `ex.Vector`. Equivalent to `new ex.Vector(x, y)` — prefer `vec` for brevity. |
| `new ex.Vector(x, y)` | 2D vector. Used for positions, velocities, accelerations, forces, sizes. |
| `Vector.Zero` / `One` / `Half` | `(0,0)` / `(1,1)` / `(0.5, 0.5)`. Static **getters** — each access returns a fresh instance, safe to mutate. |
| `Vector.Up` / `Down` / `Left` / `Right` | `(0,-1)` / `(0,1)` / `(-1,0)` / `(1,0)`. `Up` is negative-Y because Excalibur's Y grows downward. |
| `Vector.fromAngle(rad)` | Unit vector at angle. |
| `v.add(u)` / `sub(u)` | Return a **new** `Vector`. Optional `dest` arg writes into an existing vector. |
| `v.scale(n)` / `scale(u)` | Scalar or component-wise. Returns new vector. |
| `v.negate()` | `= scale(-1)`. |
| `v.normalize()` | Unit-length. Zero vector returns a zero vector (no throw). |
| `v.magnitude` / `size` | Length. `size` is deprecated; use `magnitude`. Setter **mutates**. |
| `v.distance(u?)` | Euclidean distance. With no arg, returns `magnitude`. |
| `v.dot(u)` | Scalar dot product. |
| `v.cross(u: Vector)` | **2D scalar** cross product (`x1*y2 - y1*x2`). Sign = orientation. |
| `v.cross(n: number)` | Scalar-by-vector cross returns a **vector** `(n*y, -n*x)`. |
| `v.perpendicular()` | `(y, -x)`. 90° clockwise. |
| `v.normal()` | Unit-length perpendicular. |
| `v.rotate(rad, anchor?, dest?)` | Rotate around origin or `anchor`. Positive = clockwise (matches Excalibur's y-down convention). |
| `v.toAngle()` | Atan2; canonicalized to `[0, 2π)`. |
| `v.clone(dest?)` | Copy. Always clone before mutating a vector you got from an actor (e.g. `actor.pos.clone()`). |
| `v.setTo(x, y)` | **MUTATES** in place, returns `void`. Return type is deliberately awkward. See gotchas. |
| `v.addEqual(u)` / `subEqual(u)` / `scaleEqual(n)` | Mutating helpers. |
| `Vector.distance(a, b)` | Static distance. |
| `Vector.min(a, b)` / `max(a, b)` | Component-wise min/max. |
| `ex.Matrix` | 4x4 column-major (WebGL convention). Used for WebGL, nested transforms. |
| `Matrix.identity()` | Identity 4x4. |
| `Matrix.ortho(l, r, b, t, near, far)` | Orthographic projection. |
| `mat.translate(x, y)` / `rotate(rad)` / `scale(sx, sy)` | Mutate + return `this`. Chainable. |
| `mat.multiply(other)` / `multiply(v: Vector)` | Matrix or vector product. `A.multiply(B)` ≠ `B.multiply(A)` — order matters. |
| `mat.getAffineInverse()` / `inverse()` | Inverse. Cache if you reuse. |
| `mat.getPosition()` / `getRotation()` / `getScale()` | Decompose. |
| `mat.setPosition(x, y)` / `setRotation(rad)` / `setScale(v)` | Recompose. |
| `mat.toDOMMatrix()` | For Canvas2D contexts. |
| `new ex.Random(seed?)` | Mersenne Twister (MT19937). Seed → deterministic sequence. No seed → `Date.now()` + increment per construction. |
| `rnd.next()` | `[0, 1)` float. |
| `rnd.nextInt()` | `[0, MAX_SAFE_INT]`. |
| `rnd.floating(min, max)` | Uniform float. |
| `rnd.integer(min, max)` | Inclusive int. |
| `rnd.bool(chance = 0.5)` | `true` with probability `chance`. |
| `rnd.pickOne(array)` | One element. |
| `rnd.pickSet(array, n, allowDuplicates = false)` | `n` elements. |
| `rnd.shuffle(array)` | Fisher–Yates. Returns shuffled copy. |
| `rnd.range(length, min, max)` | Array of `length` integers in `[min, max]`. |
| `rnd.d4()` / `d6()` / `d8()` / `d10()` / `d12()` / `d20()` | Dice rolls. |
| `new ex.Ray(pos, dir)` | `dir` is auto-normalized in the constructor. |
| `ray.intersect(lineSegment)` | Returns `t ≥ 0` on hit, `-1` on miss. Scalar "time" along ray. |
| `ray.intersectPoint(line)` | Returns `Vector` or `null`. |
| `ray.getPoint(t)` | `pos + dir * t`. |
| `new ex.LineSegment(begin, end)` | 2D segment. |
| `line.getLength()` / `getSlope()` / `normal()` / `midpoint` | Geometry helpers. |
| `line.distanceToPoint(p, signed?)` | Perpendicular distance. |
| `new ex.BoundingBox({ left, top, right, bottom })` | AABB. Also constructor `(left, top, right, bottom)`. |
| `BoundingBox.fromPoints(points)` | Fit-to-points. |
| `BoundingBox.fromDimension(w, h, anchor?, pos?)` | Build from size + origin. |
| `bb.combine(other)` | Union. |
| `bb.contains(pointOrBox)` | Point-in-box or box-in-box. |
| `bb.overlaps(other, epsilon?)` | Strict overlap. |
| `bb.intersect(other)` | Minimum translation vector to separate `this` from `other` (or `null`). |
| `bb.translate(v)` / `scale(v, anchor?)` / `rotate(rad, anchor?)` | Return new `BoundingBox`. |
| `bb.rayCast(ray, maxDistance?)` | Bool. |

### Common recipes — Math

**1. Position arithmetic (non-mutating)**

```ts
import * as ex from 'excalibur';

const player = new ex.Actor({ pos: ex.vec(100, 100) });
const target = ex.vec(300, 400);

// Step toward target at 200 px/s — read only, produces fresh vectors:
const toTarget = target.sub(player.pos).normalize();  // new Vector
player.vel = toTarget.scale(200);                     // new Vector
```

**2. Clone before mutate**

```ts
// WRONG — mutates actor.pos, which is a shared reference:
// enemy.pos.setTo(player.pos.x, player.pos.y);  // BAD: writes into enemy.pos
// const snapshot = enemy.pos;                    // BAD: same reference

// RIGHT:
const snapshot = enemy.pos.clone();               // owned copy
snapshot.setTo(0, 0);                              // safe: no one else sees it
```

`setTo` mutates and returns `void` — the awkward return type is deliberate
to discourage chaining. See the Gotchas section.

**3. Cross product — orientation of three points**

```ts
const ab = b.sub(a);
const ac = c.sub(a);
const sign = ab.cross(ac);    // scalar: >0 ccw (in y-up), <0 cw
// Remember Excalibur y is down, so signs are inverted from classic textbooks.
```

**4. Matrix transform stack**

```ts
const mat = ex.Matrix.identity()
  .translate(100, 100)
  .rotate(Math.PI / 4)
  .scale(2, 2);

const worldPoint = mat.multiply(ex.vec(10, 0));  // -> Vector

// Reverse:
const inv = mat.getAffineInverse();
const local = inv.multiply(worldPoint);
```

`A.translate(10,0).rotate(a)` ≠ `A.rotate(a).translate(10,0)`. Order is
"read left-to-right, apply left-to-right to the point."

**5. Seeded random for procedural generation**

```ts
const rnd = new ex.Random(1337);

const room = {
  width:  rnd.integer(8, 16),
  height: rnd.integer(6, 12),
  loot:   rnd.pickSet(['potion', 'coin', 'key', 'gem'], 2),
  boss:   rnd.bool(0.2),
};

// Same seed → same room. Great for "daily seed" or replay.
```

For unseeded per-instance randomness (e.g. particle emitters), a bare
`new ex.Random()` is safe — the base seed advances per construction.

**6. Dice rolls**

```ts
const damage = rnd.d6() + rnd.d6() + 2;    // 2d6+2
const crit   = rnd.d20() === 20;
```

**7. Raycast using `ex.Ray` + segment (pure math, no physics)**

```ts
const ray = new ex.Ray(ex.vec(0, 0), ex.Vector.Right);  // auto-normalized
const wall = new ex.LineSegment(ex.vec(100, -50), ex.vec(100, 50));

const t = ray.intersect(wall);     // -1 on miss
if (t >= 0) {
  const hit = ray.getPoint(t);      // Vector
}
```

For scene-wide raycasts against actors, use `scene.physics.rayCast` —
see `excalibur-simulation`. `ex.Ray` by itself is just geometry.

**8. BoundingBox queries**

```ts
const bounds = ex.BoundingBox.fromPoints([
  ex.vec(0, 0), ex.vec(100, 0), ex.vec(50, 80),
]);

bounds.contains(ex.vec(50, 40));              // true
bounds.overlaps(otherBox);                    // bool
const mtv = bounds.intersect(otherBox);        // Vector | null (push vector)

// Combine many:
const union = actors
  .map(a => a.collider.bounds)
  .reduce((acc, b) => acc.combine(b));
```

### Gotchas — Math

- **`setTo(x, y)` mutates in place and returns `void`.** `const v =
  other.setTo(1, 2)` does not work — `v` is `undefined`. Worse, if
  `other` is `actor.pos` you've silently teleported the actor. Always
  `const v = other.clone(); v.setTo(1, 2);`.
- **`v.magnitude = n` and `v.size = n` mutate `v`.** Hidden setters.
  Prefer `v.normalize().scale(n)` (fresh vector).
- **`Vector.Zero` and friends are *getters*, not shared constants.**
  Each read returns a new `Vector(0,0)`, so `Vector.Zero.setTo(5, 5)`
  is harmless — but don't rely on referential equality.
- **Y grows downward.** `Vector.Up = (0, -1)`. Positive rotation =
  clockwise on screen. Classic math-textbook sign conventions are
  often flipped.
- **`cross` is overloaded**: `vector.cross(Vector)` returns a
  **number**; `vector.cross(number)` returns a **Vector**. The 2D
  cross product is a scalar — there's no 3D cross in Excalibur.
- **`normalize()` on the zero vector returns a fresh zero vector,
  not NaN.** No throw, no divide-by-zero. Check `magnitude` if that
  matters.
- **`rotate(angle)` rotates around origin by default.** Pass an
  `anchor` to rotate around a point.
- **`Matrix` is 4x4, not 3x3.** Column-major, WebGL convention.
  Data laid out as a `Float32Array` of 16. For 2D affine ops without
  the extra column, use `ex.AffineMatrix` (3x3, internally used by
  `TransformComponent`).
- **Matrix multiplication is not commutative.** `A.multiply(B)` applies
  `B` *then* `A` to a point. Build transforms left-to-right as they
  should be *applied*.
- **Unseeded `new ex.Random()` is *not* `Math.random`.** It's a fresh
  Mersenne Twister with a time-based seed + per-instance offset. Two
  `new Random()`s back-to-back produce different sequences.
- **`Random.range(n, min, max)` returns integers, not floats.** Use
  `Array.from({ length: n }, () => rnd.floating(min, max))` if you
  need floats.
- **`ex.Ray` constructor auto-normalizes `dir`.** Passing a length-5
  direction doesn't give you a length-5 ray — it becomes unit length.
- **`BoundingBox.intersect` returns a Vector MTV**, not a bool. Use
  `overlaps()` for a bool.

---

## B. Runtime utilities

### Concept map — Runtime

| API | Purpose |
|-----|---------|
| `new ex.Timer({ action, interval, repeats, numberOfRepeats, randomRange, random, onComplete })` | Scene-owned tick callback. `interval` in **ms**. `repeats: true` + omit `numberOfRepeats` = forever. `randomRange: [a, b]` adds `rnd.integer(a, b)` to each interval. |
| `scene.addTimer(t)` / `engine.add(timer)` | Add to a scene. Unadded timers log a warning and don't tick. |
| `timer.start()` / `pause()` / `resume()` / `stop()` / `reset(newInterval?, newRepeats?)` / `cancel()` | Lifecycle. `start()` starts ticking; `cancel()` removes from scene. `stop()` resets elapsed counter but leaves it in scene. |
| `timer.on('start'\|'stop'\|'pause'\|'resume'\|'cancel'\|'action'\|'complete', fn)` | Events. |
| `timer.complete` / `timesRepeated` / `isRunning` / `timeToNextAction` / `timeElapsedTowardNextAction` | State. |
| `new ex.Trigger({ pos, width, height, target?, filter?, repeat?, visible?, action })` | `Actor` subclass with a `Passive` collider. Fires `action(entity)` on collision. `repeat: -1` = forever (default), `0` = never, `n` = n times. `target` overrides `filter`. `visible` defaults `false`. |
| `trigger.on('enter', fn)` / `on('exit', fn)` | Fires with an `EnterTriggerEvent` / `ExitTriggerEvent` (`.target`). |
| `ex.coroutine(engine, function*() { ... }, options?)` | Generator-based scripted sequence. Runs on the engine clock, preframe by default. |
| `ex.coroutine(thisArg, engine, fn, options?)` / `coroutine(fn, options?)` / `coroutine(engine, fn, options?)` | Overloads. Implicit-engine form requires a default engine context (set by the engine on start). |
| `yield` (void) | Wait 1 frame. Yields elapsed ms back on resume. |
| `yield 500` | Wait 500 ms. |
| `yield fetch('./x')` | Wait for a promise. |
| `CoroutineInstance` | `.start()`, `.cancel()`, `.isRunning()`, `.isComplete()`, `.done` (Promise), `then`-able (`await co`). |
| `CoroutineOptions` | `{ timing?: 'preframe'\|'postframe'\|'preupdate'\|'postupdate'\|'predraw'\|'postdraw', autostart?: boolean }`. |
| `engine.clock` | `StandardClock` by default; `TestClock` via `engine.debug.useTestClock()`. |
| `clock.schedule(cb, ms = 0, timing = 'preframe')` | Returns `ScheduleId`. Callback fires after `ms` of **game** time (pauses when game does). |
| `clock.clearSchedule(id)` | Cancel. |
| `clock.now()` / `elapsed()` / `fpsSampler.fps` | Timing queries. |
| `clock.start()` / `stop()` | Start/stop the loop. Called by `engine.start`. |
| `engine.debug.useTestClock()` / `useStandardClock()` | Hot-swap for deterministic single-step tests. |
| `TestClock.step(ms)` / `run(steps, ms)` | Manual tick. |
| `new ex.PauseComponent({ canPause: true })` | Attach to an entity to opt into scene-pause. Every `Actor` already has one (`canPause: false` by default → opt in per-actor, or pass `canPause: true` in `ActorArgs`). |
| `scene.pauseScene()` / `scene.resumeScene()` | Flip the scene `PauseSystem`. Entities with `canPause: true` stop updating. |
| `scene.on('pause', fn)` / `on('resume', fn)` | React (e.g. show pause menu). |
| `new ex.ParticleEmitter({ pos / x / y / z, width, height, emitterType, radius, emitRate, isEmitting, particle, random })` | CPU particle emitter. Extends `Actor`. `emitterType: ex.EmitterType.Rectangle \| Circle`. `radius` used only for Circle. `emitRate` = particles/sec while `isEmitting`. |
| `emitter.particle: ParticleConfig` | `{ life (ms), opacity, fade, beginColor, endColor, startSize, endSize, minSize, maxSize, minSpeed, maxSpeed, minAngle, maxAngle, acc: Vector, angularVelocity, graphic?: Graphic, focus?, focusAccel?, randomRotation?, transform: ParticleTransform.Global\|Local }`. |
| `emitter.emitParticles(n)` | Burst-emit `n` particles right now (independent of `isEmitting`/`emitRate`). |
| `emitter.clearParticles()` | Remove all live particles. |
| `emitter.isEmitting = false` | Stop continuous emission; `emitParticles(n)` still works. |
| `ex.EmitterType.Rectangle` / `Circle` | Nozzle shape. |
| `ex.ParticleTransform.Global` / `Local` | Global = particles live in world space (default). Local = children of emitter. |
| `engine.graphicsContext.addPostProcessor(pp)` | Register a `PostProcessor`. WebGL only. |
| `new ex.ColorBlindnessPostProcessor(mode, simulate = false)` | Accessibility. `simulate=false` (default) **corrects**; `simulate=true` shows the player what the condition looks like. |
| `ex.ColorBlindnessMode.Protanope` / `Deuteranope` / `Tritanope` | The three forms. |
| `ex.ScreenShader` | Helper for custom fullscreen fragment shaders (GLSL ES 300). `u_image` = screen texture, `v_texcoord` = UV. |
| `ex.PostProcessor` interface | `{ initialize(gl), getShader(), getLayout() }`. Implement for custom post effects. |
| `ex.Serializer.init(autoRegisterCommon = true)` | One-time bootstrap. Registers `TransformComponent`, `MotionComponent`, `GraphicsComponent`, `PointerComponent`, `ActionsComponent`, `BodyComponent`, `ColliderComponent` + custom-type serializers for `Vector`, `Color`, `BoundingBox`. |
| `ex.Serializer.registerComponent(Ctor)` / `registerComponents([...])` | Your custom components must be registered to survive round-trip. |
| `ex.Serializer.registerCustomActor(Ctor)` / `registerCustomActors([...])` | Register your `extends Actor` classes so deserialize rebuilds the right instance. |
| `ex.Serializer.registerGraphic(id, graphic)` / `registerGraphics({...})` | Reference-based graphics: serialize the ID, not the sprite. |
| `ex.Serializer.registerCustomSerializer(name, serialize, deserialize)` | Custom type round-trip. |
| `ex.Serializer.serializeActor(a)` / `deserializeActor(data)` | Actor-aware round-trip (restores `.transform`, `.graphics`, etc. references). |
| `ex.Serializer.serializeEntity(e)` / `deserializeEntity(data)` | Plain `Entity`. |
| `ex.Serializer.entityToJSON(e, pretty?)` / `entityFromJSON(json)` / `actorToJSON(a, pretty?)` / `actorFromJSON(json)` | JSON convenience. |
| `ex.Serializer.validateEntityData(data)` | Shape check. |
| Option-bag convention: `new X({ ... })` | Every constructable in Excalibur takes a single options object. Any public property is settable. |
| `obj.assign({ ... })` | Mass-assign on types that support it (`Actor`, etc.). |

### Common recipes — Runtime

**1. Spawning enemies on a timer**

```ts
import * as ex from 'excalibur';

class Level extends ex.Scene {
  override onInitialize(engine: ex.Engine) {
    const spawner = new ex.Timer({
      action: () => this.add(new Enemy()),
      interval: 2000,           // every 2 seconds
      repeats: true,             // forever (no numberOfRepeats)
      randomRange: [0, 500],     // + up to 500 ms jitter
    });
    this.addTimer(spawner);
    spawner.start();
  }
}
```

`addTimer` alone does not start the timer. Call `.start()` explicitly.
Timer callbacks are unsubscribed by `cancel()`; `stop()` just resets
elapsed.

**2. One-shot delayed action via the clock**

```ts
const id = engine.clock.schedule(() => {
  player.graphics.use('idle');
}, 500);

// Cancel if we change our mind:
engine.clock.clearSchedule(id);
```

Prefer this over `setTimeout` — it pauses when the game pauses (stopped
engine), respects maxFps, and doesn't fire after `engine.stop()`.

**3. Level-exit Trigger**

```ts
const exit = new ex.Trigger({
  pos: ex.vec(800, 400),
  width: 64,
  height: 64,
  target: player,               // only fires for this actor
  visible: false,                // (default)
  repeat: 1,                     // fire once, then self-kill
  action: () => engine.goToScene('nextLevel'),
});
scene.add(exit);
```

Triggers are `Actor` subclasses with `CollisionType.Passive` — they
receive `collisionstart`/`collisionend` but never resolve. `filter` is
a predicate `(entity) => boolean`. `target` overrides `filter`. After
`repeat` fires the trigger `kill()`s itself; pass `-1` (default) for
infinite.

Listen to `'enter'` / `'exit'` for enter/leave semantics:

```ts
exit.on('enter', (e) => console.log('entered by', e.target.name));
exit.on('exit',  (e) => console.log('left by',    e.target.name));
```

**4. Coroutine cutscene**

```ts
await ex.coroutine(engine, function* () {
  hero.vel = ex.vec(0, -100);
  yield 1000;                     // wait 1s of game time
  hero.vel = ex.Vector.Zero;
  yield;                           // wait 1 frame
  hero.graphics.use('wave');
  yield hud.fadeIn();              // await a promise
  yield 500;
  engine.goToScene('credits');
});
// After `await`, the coroutine is done.
```

A coroutine is paused between yields; it only advances on the engine
clock. `yield` forms:

- `yield` (void) → resume next frame, elapsed-ms is yielded back
- `yield 250` (number) → resume after 250 ms of game time
- `yield somePromise` → resume when the promise resolves

Cancel early with `co.cancel()`. Coroutines are `PromiseLike`, so
`await co` works. Options:

```ts
ex.coroutine(engine, gen, { timing: 'postupdate', autostart: false });
```

**5. Pause entities when the scene pauses**

```ts
// Opt the player in at construction:
const player = new ex.Player({ pos: ex.vec(100, 100), canPause: true });

// Or add to an arbitrary Entity:
entity.addComponent(new ex.PauseComponent({ canPause: true }));

// Flip state:
scene.pauseScene();      // entities with canPause:true stop updating
scene.resumeScene();

scene.on('pause', () => pauseMenu.show());
scene.on('resume', () => pauseMenu.hide());
```

By default `PauseComponent.canPause` is `false` — every Actor has the
component but is **opt-in**. The `PauseSystem` is auto-added to every
`Scene`. Paused entities skip their update step; graphics still draw.

**6. Explosion (burst) vs. continuous particles**

```ts
// Burst: one-time explosion
const boom = new ex.ParticleEmitter({
  pos: ex.vec(400, 300),
  emitterType: ex.EmitterType.Circle,
  radius: 4,
  isEmitting: false,              // don't spawn on tick
  particle: {
    life: 800,
    minSpeed: 100,
    maxSpeed: 300,
    minAngle: 0,
    maxAngle: Math.PI * 2,
    minSize: 2,
    maxSize: 4,
    fade: true,
    acc: ex.vec(0, 200),          // gravity
    beginColor: ex.Color.Orange,
    endColor: ex.Color.Red,
  },
});
scene.add(boom);
boom.emitParticles(60);           // burst of 60 right now

// Continuous: smoke trail on an actor
const smoke = new ex.ParticleEmitter({
  emitterType: ex.EmitterType.Rectangle,
  width: 8, height: 8,
  isEmitting: true,
  emitRate: 40,                   // 40 particles / sec
  particle: {
    life: 1500,
    fade: true,
    opacity: 0.5,
    minSpeed: 10, maxSpeed: 30,
    minAngle: -Math.PI * 3/4, maxAngle: -Math.PI / 4,
    startSize: 4, endSize: 12,
    beginColor: ex.Color.Gray,
    endColor: ex.Color.fromRGB(0, 0, 0, 0),
  },
});
rocket.addChild(smoke);
```

`ParticleEmitter` extends `Actor`, so `scene.add(emitter)` or
`actor.addChild(emitter)` both work. `transform: ParticleTransform.Global`
(default) makes particles world-space; `Local` makes them follow the
emitter.

**7. Color-blindness correction**

```ts
const cb = new ex.ColorBlindnessPostProcessor(
  ex.ColorBlindnessMode.Deuteranope,
  false,                            // false = correct, true = simulate
);
engine.graphicsContext.addPostProcessor(cb);
```

`simulate: true` is a testing aid — it shows you what Deuteranope
players see. Ship with `simulate: false` (correction). Post-processors
run WebGL-only; they silently no-op in 2D-canvas fallback mode.

**8. Custom post-processor (gray-scale)**

```ts
class GrayScale implements ex.PostProcessor {
  private _shader!: ex.ScreenShader;
  initialize(gl: WebGL2RenderingContext) {
    this._shader = new ex.ScreenShader(gl, `#version 300 es
      precision mediump float;
      uniform sampler2D u_image;
      in vec2 v_texcoord;
      out vec4 fragColor;
      void main() {
        vec4 tex = texture(u_image, v_texcoord);
        float g = 0.2126 * tex.r + 0.7152 * tex.g + 0.0722 * tex.b;
        fragColor = vec4(g, g, g, 1.0);
      }`);
  }
  getShader() { return this._shader.getShader(); }
  getLayout() { return this._shader.getLayout(); }
}
engine.graphicsContext.addPostProcessor(new GrayScale());
```

GLSL ES 300 only. `u_image` + `v_texcoord` are provided.

**9. Save / load with `Serializer`**

```ts
// ---- Setup (once, at game start) ----
ex.Serializer.init();                              // registers built-ins

class Player extends ex.Actor { /* ... */ }
class HealthComponent extends ex.Component {
  currentHp = 100;
  serialize()   { return { currentHp: this.currentHp }; }
  deserialize(d: any) { this.currentHp = d.currentHp; }
}
ex.Serializer.registerCustomActor(Player);
ex.Serializer.registerComponent(HealthComponent);

// Reference-based graphic:
const sprite = imageSource.toSprite();
ex.Serializer.registerGraphic('player-idle', sprite);

const player = new Player();
player.graphics.add('player-idle', sprite);        // key matters
player.graphics.use('player-idle');
player.addComponent(new HealthComponent());

// ---- Save ----
const json = ex.Serializer.actorToJSON(player, true);
localStorage.setItem('save', json);

// ---- Load ----
const loaded = ex.Serializer.actorFromJSON(localStorage.getItem('save')!);
if (loaded) scene.add(loaded);
```

To participate, a `Component` needs `serialize(): object` and
`deserialize(data): void` methods. Components without these log a
warning and are skipped. Built-in actor components (`TransformComponent`
etc.) already implement them when `Serializer.init()` runs.

**10. Option-bag + `assign`**

```ts
const actor = new ex.Actor({
  pos: ex.vec(1, 2),
  width: 100,
  height: 100,
  color: ex.Color.Red,
});

// Mass-assign later:
actor.assign({
  pos: ex.vec(200, 200),
  color: ex.Color.Blue,
});
```

Anything public is fair game. Not all types expose `assign` — `Actor`
does; primitives do not.

### Gotchas — Runtime

- **Unadded timers log a warning and never tick.** `new ex.Timer({ ... })`
  by itself does nothing. Call `scene.addTimer(t)` (or `scene.add(t)`)
  **and** `t.start()`.
- **`Timer.repeats: true` with `numberOfRepeats` unset = forever.**
  Setting `numberOfRepeats` *without* `repeats: true` throws.
- **`Timer.stop()` vs `cancel()`.** `stop()` resets the elapsed counter
  but leaves the timer attached; `cancel()` also removes it from the
  scene. After `stop()` you must `start()` again to resume.
- **Triggers default to `repeat: -1` (infinite).** If you only want one
  fire, set `repeat: 1`. Note `repeat: 0` means "never fire" — not
  "default."
- **Trigger `target` overrides `filter`.** If you set both, `filter` is
  ignored unless the collider is `target`.
- **Triggers are `Actor`s with `CollisionType.Passive`** — they're in
  the scene graph, receive `preupdate`/`postupdate`, and can have
  graphics (set `visible: true` to see the hitbox). They are not
  sprites.
- **Coroutines run on the *engine* clock, not wall time.** They pause
  when the engine stops and when a scene is deactivated (by default).
  `yield 1000` = 1000 ms of game time.
- **Coroutine overloads are confusing.** The safest form is
  `coroutine(engine, function*() { ... })`. The `coroutine(fn)` short
  form relies on an ambient engine context that may not be set outside
  scene callbacks.
- **`CoroutineInstance` is `PromiseLike`.** You can `await co` or
  `co.then(...)`. It doesn't unwrap to a specific value — it resolves
  to `void`.
- **`engine.clock.schedule` ids aren't reused**, but the callback array
  is scanned linearly — thousands of pending schedules are slow. Prefer
  `Timer` for repeating needs.
- **`PauseComponent.canPause` defaults to `false` on actors.** Every
  actor *has* the component (so `scene.pauseScene()` works uniformly)
  but nothing is paused unless you opt in with
  `canPause: true` in `ActorArgs` or `new PauseComponent({ canPause: true })`.
- **`scene.pauseScene()` does not stop the render loop** — graphics and
  transitions still draw. Only update logic on opted-in entities halts.
- **`ParticleEmitter.emitParticles(n)` is a burst** — it bypasses
  `emitRate` and `isEmitting`. Perfect for explosions; set
  `isEmitting: false` so you don't also get a trickle.
- **Particle colors lerp from `beginColor` → `endColor`.** Set both;
  omitting one leaves the default white. Use `fade: true` to also
  fade opacity independently.
- **Particles use `life` in ms, not seconds.** `life: 1000` = 1 second.
- **Post-processors are WebGL-only.** If `antialiasing` forces 2D
  canvas fallback, they don't run. Excalibur ships WebGL by default.
- **`ColorBlindnessPostProcessor(mode, simulate=true)` simulates**
  (shows what the condition looks like). `simulate=false` (default)
  *corrects* (shifts colors into a differentiable range). Choose
  deliberately — the UX difference is large.
- **`ex.Serializer.init()` is one-shot.** Call it once at game start
  (or reset via `Serializer.reset()` first). It warns if called twice.
- **Serializer only round-trips registered components.** Unregistered
  components are dropped with a warning during serialize. Custom
  component = `registerComponent(MyComp)` + implement
  `serialize`/`deserialize`.
- **Serializer graphics are reference-based** — `registerGraphic(id,
  sprite)` stores the sprite in a module-level map, and serialized
  data keeps the `id` only. If you reload the page and the registry
  is empty, deserialization produces an actor with no visible graphic.
  Re-register graphics during boot **before** loading saves.
- **`setTo` on `actor.pos` teleports the actor.** `actor.pos` is a
  live vector; mutating it is the canonical way to move — but that's
  *intentional motion*, not "update a local copy." Clone first if you
  want a snapshot.
- **`ex.Util.Assign` is not a public API.** The assign convention is
  per-class (`actor.assign(...)`), not a general helper.

---

## Doc pointers

- `site/docs/09-math/07-vector.mdx` — `Vector` basics + clone/mutation warning
- `site/docs/09-math/07-matrix.mdx` — column-major 4x4, transform stack
- `site/docs/09-math/07-random.mdx` — seeded RNG API catalog
- `site/docs/09-math/07-ray.mdx` — `Ray` vs. `scene.physics.rayCast`
- `site/docs/12-other/11-timers.mdx` — basic timer recipes
- `site/docs/12-other/11-coroutines.mdx` — `yield` semantics
- `site/docs/12-other/11-triggers.mdx` — target/filter/repeat patterns
- `site/docs/12-other/12-clock.mdx` — `schedule`, test clock, `maxFps`
- `site/docs/12-other/12-pausing.mdx` — `pauseScene` + `canPause` opt-in
- `site/docs/12-other/12-post-processors/index.mdx` — color blindness + custom shaders
- `site/docs/12-other/13-particles.mdx` — Circle vs Rectangle emitters, full config
- `site/docs/12-other/15-Serialization.mdx` — full Serializer walkthrough
- `site/docs/12-other/99-utilities.mdx` — option-bag + `assign` convention, logger
- `src/engine/math/vector.ts` — `Vector`, `Vector.Zero/One/Half/Up/Down/Left/Right`, `setTo`, `cross` overloads, `clone`
- `src/engine/math/matrix.ts` — `Matrix` column-major, `identity`/`translate`/`rotate`/`scale`/`multiply`/`getAffineInverse`/`getPosition`/`getRotation`/`getScale`
- `src/engine/math/random.ts` — MT19937 `Random`, `integer`/`floating`/`bool`/`pickOne`/`pickSet`/`shuffle`/`range`/`d4..d20`
- `src/engine/math/ray.ts` — `Ray(pos, dir)`, `intersect(line)`, `getPoint(t)`
- `src/engine/math/line-segment.ts` — `LineSegment`, `getLength`/`getSlope`/`normal`/`midpoint`/`distanceToPoint`
- `src/engine/collision/bounding-box.ts` — `BoundingBox`, `fromPoints`/`fromDimension`/`combine`/`contains`/`overlaps`/`intersect`
- `src/engine/timer.ts` — `Timer`, `TimerOptions`, `start`/`pause`/`resume`/`stop`/`reset`/`cancel`, `TimerEvents`
- `src/engine/trigger.ts` — `Trigger`, `TriggerOptions`, enter/exit events (Actor subclass with `CollisionType.Passive`)
- `src/engine/util/coroutine.ts` — `coroutine`, `CoroutineInstance`, `CoroutineOptions`, four overloads
- `src/engine/util/clock.ts` — `Clock`, `StandardClock`, `TestClock`, `schedule`/`clearSchedule`, `ScheduledCallbackTiming`
- `src/engine/util/pause-system.ts` — `PauseSystem` behavior
- `src/engine/entity-component-system/components/pause-component.ts` — `PauseComponent({ canPause })`
- `src/engine/particles/particle-emitter.ts` — `ParticleEmitter`, `emitParticles`, `clearParticles`, `isEmitting`
- `src/engine/particles/particles.ts` — `ParticleConfig`, `ParticleEmitterArgs`, `ParticleTransform`
- `src/engine/particles/emitter-type.ts` — `EmitterType.Circle`/`Rectangle`
- `src/engine/graphics/post-processor/post-processor.ts` — `PostProcessor` interface
- `src/engine/graphics/post-processor/color-blindness-post-processor.ts` — correction vs simulation
- `src/engine/graphics/post-processor/color-blindness-mode.ts` — `Protanope`/`Deuteranope`/`Tritanope`
- `src/engine/graphics/post-processor/screen-shader.ts` — `ScreenShader` helper for custom post
- `src/engine/util/serializer.ts` — full `Serializer` API (init, register*, serialize*, *ToJSON/FromJSON)
