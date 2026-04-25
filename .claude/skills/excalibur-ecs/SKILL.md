---
name: excalibur-ecs
description: >
  Use when building custom components or systems in an Excalibur.js game — i.e.
  dropping below `Actor` to the raw entity-component-system. Covers `ex.Entity`
  (`addComponent`/`removeComponent`/`get`/`has`, tags as `Set<string>`,
  `addChild`/`removeChild`, `onInitialize`/`onPreUpdate`/`onPostUpdate`),
  authoring a custom `ex.Component` (no generic post-0.29, `onAdd`/`onRemove`
  hooks, data-only vs. data+behavior, systemless components), authoring a custom
  `ex.System` (`SystemType.Update` / `SystemType.Draw`, explicit `query = world.query([...])`,
  `static priority` via `SystemPriority.Highest`/`Higher`/`Average`/`Lower`/`Lowest`,
  `preupdate`/`update`/`postupdate`), the ECS `World`
  (`scene.world`, `world.add(system)`, `world.entityManager`, `world.queryManager`,
  `world.systemManager`), component and tag queries (`world.query([CompA, CompB])`,
  `world.queryTags(['enemy'])`, `QueryParams` with `any`/`all`/`not`),
  deferred component removal, and the built-in components on every Actor
  (`TransformComponent`, `MotionComponent`, `GraphicsComponent`, `PointerComponent`,
  `ActionsComponent`, `ColliderComponent`, `BodyComponent`). Trigger on "custom
  component", "custom system", "ECS query", "data-driven entity", "composition
  over inheritance", "Entity vs Actor", "systemless component", "world.query",
  or questions about component/system lifecycle. Does NOT cover engine setup,
  scene/actor authoring, rendering, physics tuning, input, or asset loading —
  those are separate excalibur-* skills.
---

# Excalibur ECS

Excalibur ships with a full entity-component-system. `Actor` is just an `Entity`
with a curated set of built-in components. Drop to raw ECS when you need
orthogonal, reusable behavior across many entity types — otherwise stay on
`Actor` (see `excalibur-core`).

## When to use this skill
- Authoring a custom `ex.Component` (data storage, `onAdd`/`onRemove`)
- Authoring a custom `ex.System` that queries entities by component types
- Adding/removing components at runtime on an existing `Actor` or `Entity`
- Tag-based queries across the scene (`world.queryTags(['enemy'])`)
- Replacing or extending a built-in Excalibur system
- Understanding the built-in components on every Actor
- Deciding between subclassing `Actor` vs. raw `Entity` + custom components

## When NOT to use (route to another skill)
- Engine/bundler setup, `new ex.Engine({...})`, `engine.start()` → `excalibur-setup`
- Scenes, Actor subclassing, cameras, events, transitions → `excalibur-core`
- Sprites, animations, `GraphicsComponent` usage, tilemaps → `excalibur-visuals`
- `CollisionType`, `BodyComponent` physics tuning, input, `ActionsComponent`
  usage (`actor.actions.moveTo(...)`) → `excalibur-simulation`
- `ImageSource`, `Sound`, `Loader` → `excalibur-resources`
- `Vector`, `Timer`, `coroutine`, easing, particles → `excalibur-utilities`

## Do I really need ECS?

Default answer: **no, subclass `Actor`**. Reach for custom components/systems
only when one of these is true:

1. **Many entity types share orthogonal behavior** — e.g. `Damageable`,
   `Poisoned`, `Flammable` applies to players, enemies, barrels, and crates.
   Mixins via inheritance get messy; a component is cleaner.
2. **Behavior must be data-driven** — you want to toggle a capability on/off at
   runtime, or read it out of a config file / Tiled map property.
3. **You need a query across the whole scene** — "every entity with
   `HealthComponent` and tag `enemy` that takes damage this frame."
4. **You're replacing an engine subsystem** — custom AI, a grid-based movement
   system, a deterministic fixed-step simulation.

If you just have a `Player` class with health, velocity, and keybindings, put
it on `Actor`. The ECS is available but not mandatory.

## Concept map

| API | Purpose |
|-----|---------|
| `ex.Entity` | Bare container. Has an `id`, `name`, `components` map, `tags: Set<string>`, parent/children, lifecycle hooks. |
| `ex.Actor extends Entity` | Pre-composed with `TransformComponent`, `MotionComponent`, `GraphicsComponent`, `PointerComponent`, `ActionsComponent`, `ColliderComponent`, `BodyComponent`. |
| `ex.Component` | Abstract base. Zero-arg-constructable. Owner is assigned on `addComponent`. |
| `ex.System` | Abstract base. Has a `systemType`, a `static priority`, and an `update(elapsed)`. You build a `query` in the constructor. |
| `ex.Query` | Live collection of entities matching a component/tag filter. `query.entities` iterable. |
| `ex.World` | Lives on `scene.world`. Owns `entityManager`, `queryManager`, `systemManager`. |
| `ex.SystemType` | `.Update` (physics/game logic) or `.Draw` (rendering). All Update systems run before any Draw system. |
| `ex.SystemPriority` | `Highest` = -Infinity, `Higher` = -5, `Average` = 0, `Lower` = 5, `Lowest` = Infinity. Lower number = runs earlier. |

## Entity API

```ts
// Construction (both forms supported):
const e1 = new ex.Entity();
const e2 = new ex.Entity({ name: 'torch', components: [new LightComponent()] });
const e3 = new ex.Entity([new LightComponent()], 'torch'); // legacy tuple form

// Components:
e1.addComponent(new ex.TransformComponent());
e1.has(ex.TransformComponent);                 // boolean
e1.get(ex.TransformComponent);                 // TransformComponent | undefined
e1.getComponents();                            // Component[]
e1.removeComponent(ex.TransformComponent);     // deferred to end of frame
e1.removeComponent(ex.TransformComponent, true); // force = immediate

// Tags (plain Set<string>):
e1.addTag('enemy');
e1.hasTag('enemy');
e1.removeTag('enemy');
e1.tags;            // Set<string> — read-only use; mutate via add/removeTag
e1.hasAllTags(['enemy', 'boss']);

// Parent/children (transforms follow):
e1.addChild(e2);
e1.removeChild(e2);
e1.removeAllChildren();
e2.parent;          // Entity | null
e2.unparent();

// Lifecycle (override on subclasses):
class MyEntity extends ex.Entity {
  onInitialize(engine: ex.Engine) { /* runs once, before first update */ }
  onPreUpdate(engine: ex.Engine, elapsed: number) { /* every frame, pre-physics */ }
  onPostUpdate(engine: ex.Engine, elapsed: number) { /* every frame, post-physics */ }
}

// Adding to scene:
scene.add(e1);      // same overload that takes Actor
scene.world.add(e1); // equivalent
```

Removing a component is **deferred** by default (removed at end of update)
to prevent systems from seeing a partially-processed entity mid-frame. Pass
`force = true` only if you know the entity is not being iterated.

## Actor's built-in components (reference only)

Every `ex.Actor` comes pre-composed with these. You get at them via
`actor.transform`, `actor.motion`, etc., **or** `actor.get(TransformComponent)`.
Deep usage lives in other skills.

| Component | Exposes | Deep dive |
|-----------|---------|-----------|
| `TransformComponent` | `pos`, `rotation`, `scale`, `z`, `globalZ`, `coordPlane` | `excalibur-core` (scene/camera) |
| `MotionComponent` | `vel`, `maxVel`, `acc`, `angularVelocity`, `torque`, `inertia`, `scaleFactor` | `excalibur-simulation` |
| `GraphicsComponent` | `use(graphic)`, `add(name, g)`, `show`, `hide`, `current`, `anchor`, `offset`, `opacity` | `excalibur-visuals` |
| `PointerComponent` | pointer-event routing config per-entity | `excalibur-core` (events) |
| `ActionsComponent` | `moveTo`, `rotateTo`, `repeatForever`, etc. (scripted motion) | `excalibur-simulation` |
| `ColliderComponent` | `set(collider)`, `bounds`, `collide(other)` | `excalibur-simulation` |
| `BodyComponent` | `mass`, `friction`, `bounciness`, `useGravity`, `applyImpulse`, `canSleep` | `excalibur-simulation` |

On a bare `Entity`, you must add these yourself if you want motion/physics/graphics.

## Authoring a custom component

As of v0.29, `Component` is no longer generic — no string type name. Just
`extends ex.Component`. Keep a zero-arg constructor if you want Excalibur's
component-dependency auto-add to work.

### Data-only component

```ts
import * as ex from 'excalibur';

export class HealthComponent extends ex.Component {
  constructor(public max = 100) {
    super();
    this.current = max;
  }
  current: number;

  damage(n: number) { this.current = Math.max(0, this.current - n); }
  heal(n: number)   { this.current = Math.min(this.max, this.current + n); }
  get dead() { return this.current <= 0; }
}

const player = new ex.Actor({ pos: ex.vec(100, 100), width: 32, height: 32 });
player.addComponent(new HealthComponent(150));

// Later:
const hp = player.get(HealthComponent);
if (hp) hp.damage(10);
```

### Component with dependencies

If your component requires other components, list them in `dependencies`.
Excalibur will auto-add them on `addComponent` if missing.

```ts
export class SeekComponent extends ex.Component {
  readonly dependencies = [ex.TransformComponent, ex.MotionComponent];
  constructor(public target: ex.Vector, public speed = 100) { super(); }
}
```

### Systemless component (self-updating)

Hook the owner's update loop from `onAdd`. Skip the separate system. Good for
simple, entity-local behavior that doesn't need to be queried in bulk.

```ts
export class BlinkComponent extends ex.Component {
  constructor(public hz = 2) { super(); }
  private _t = 0;
  private _visible = true;

  override onAdd(owner: ex.Entity) {
    owner.on('preupdate', this._tick);
  }

  override onRemove(previousOwner: ex.Entity) {
    previousOwner.off('preupdate', this._tick);
  }

  private _tick = (evt: { engine: ex.Engine; elapsed: number }) => {
    const owner = this.owner as ex.Actor | undefined;
    if (!owner) return;
    this._t += evt.elapsed / 1000;
    if (this._t >= 1 / (this.hz * 2)) {
      this._t = 0;
      this._visible = !this._visible;
      owner.graphics.opacity = this._visible ? 1 : 0;
    }
  };
}
```

**Always clean up in `onRemove`** — otherwise you leak event subscriptions. Use
the same arrow-function reference for `on` and `off` (binding `this.update.bind(this)`
twice returns two different function identities; `off` won't match).

## Authoring a custom system

As of v0.29, systems no longer receive entities automatically. You must
**create an explicit `query` in the constructor**, then iterate
`this.query.entities` inside `update`.

```ts
import * as ex from 'excalibur';

class SeekComponent extends ex.Component {
  constructor(public target: ex.Vector, public speed = 100) { super(); }
}

class SeekSystem extends ex.System {
  public readonly systemType = ex.SystemType.Update;
  public static priority = ex.SystemPriority.Average;

  public query: ex.Query<typeof ex.TransformComponent | typeof SeekComponent>;

  constructor(public world: ex.World) {
    super();
    this.query = world.query([ex.TransformComponent, SeekComponent]);
  }

  // Optional — runs once, after construction, before first update.
  initialize(world: ex.World, scene: ex.Scene) {
    // Grab engine refs, wire input handlers, etc.
  }

  // Optional per-frame hook before update.
  preupdate(scene: ex.Scene, elapsed: number) {}

  update(elapsed: number) {
    const dt = elapsed / 1000;
    for (const entity of this.query.entities) {
      const tx = entity.get(ex.TransformComponent)!;
      const seek = entity.get(SeekComponent)!;
      const dir = seek.target.sub(tx.pos).normalize();
      tx.pos = tx.pos.add(dir.scale(seek.speed * dt));
    }
  }

  // Optional per-frame hook after update.
  postupdate(scene: ex.Scene, elapsed: number) {}
}

// Register once per scene:
scene.world.add(new SeekSystem(scene.world));
// Or pass the ctor — the world will instantiate it with itself:
scene.world.add(SeekSystem);
```

Key contract:
- `super()` is required in the constructor.
- `this.query = world.query([...])` — without this, your update loop has
  nothing to iterate.
- `systemType` is a readonly instance property. `SystemType.Update` runs
  before `SystemType.Draw`, always.
- `priority` is a **`static`** property (the sort key). Defaults to
  `SystemPriority.Average` (0). Lower runs first within the same `systemType`.
- `update(elapsed)` receives milliseconds — divide by 1000 for seconds-based
  velocity math.

### System priorities of the built-ins (for ordering reference)

Verified from source:

| System | priority | systemType |
|--------|----------|------------|
| `ActionsSystem` | `Higher` (-5) | Update |
| `MotionSystem` | `Higher` (-5) | Update |
| `CollisionSystem` | `Higher` (-5) | Update |
| `PointerSystem` | `Higher` (-5) | Update |
| `GraphicsSystem` | `Average` (0) | Draw |
| `DebugSystem` | `Lowest` (∞) | Draw |

So if you want your update system to run **after** motion/collision (seeing
final positions), use `SystemPriority.Average` or `Lower`. Before them, use
`SystemPriority.Highest`.

## World, query, and tag query

```ts
// scene.world is the ECS root of each scene.
const world = scene.world;

// Add/remove entities (also done via scene.add):
world.add(entity);
world.remove(entity);

// Add/remove systems:
world.add(new MySystem(world));
world.add(MySystem);          // ctor form — world will `new` it with itself
world.remove(mySystemInstance);

// Get a registered system:
const seek = world.get(SeekSystem);

// Managers (rarely touched directly):
world.entityManager.getById(42);
world.entityManager.getByName('player');
world.systemManager.systems;     // System[]
world.queryManager;
```

### Component query

```ts
const movers = world.query([ex.TransformComponent, ex.MotionComponent]);
for (const e of movers.entities) { /* ... */ }
```

Queries are **live** — they track entities as components are added/removed.
Two calls to `world.query([A, B])` return the *same* query instance, cached by
its component set.

### Query with `any` / `not` filters

```ts
const query = world.query({
  components: {
    all: [ex.TransformComponent],       // must have all of these
    any: [PoisonedComponent, BurningComponent], // must have at least one
    not: [DeadComponent],               // must have none
  },
  tags: {
    all: ['enemy'],
    not: ['invulnerable'],
  },
});
```

### Tag query

```ts
const enemies = world.queryTags(['enemy']);
const frozenEnemies = world.queryTags(['enemy', 'frozen']); // implicit ALL
```

`queryTags` is a convenience over `world.query({ tags: { all: [...] } })`.
Note: marked `@deprecated` in source but still functional; prefer the
`world.query({ tags: ... })` form for new code.

### Observing query changes

Queries expose `entityAdded$` / `entityRemoved$` observables:

```ts
const q = world.query([HealthComponent]);
q.entityAdded$.subscribe(e => console.log('gained hp', e.name));
q.entityRemoved$.subscribe(e => console.log('lost hp', e.name));
```

## Lifecycle ordering (one tick)

```
scene.update(elapsed)
  world.update(SystemType.Update, elapsed)
    entityManager.updateEntities    // per-entity onPreUpdate → onPostUpdate
    systemManager.updateSystems(Update)
      for each Update system in priority order:
        system.preupdate(scene, elapsed)
      for each Update system in priority order:
        system.update(elapsed)
      for each Update system in priority order:
        system.postupdate(scene, elapsed)
    entityManager.findEntitiesForRemoval()
    entityManager.processComponentRemovals()   // deferred removals land here
    entityManager.processEntityRemovals()

scene.draw(...)
  world.update(SystemType.Draw, ...)           // GraphicsSystem, DebugSystem, etc.
```

Two consequences:

- Components removed inside a system update are **not** actually detached
  until after all Update systems finish. A later system that queries for the
  same component will still see the entity this frame.
- Tag changes propagate immediately to query indexes; component changes
  propagate on the next matching operation.

## Common recipes

### 1. Damage system with a component

```ts
class HealthComponent extends ex.Component {
  constructor(public max = 100) { super(); this.current = max; }
  current: number;
  pendingDamage = 0;
}

class DamageSystem extends ex.System {
  public readonly systemType = ex.SystemType.Update;
  public static priority = ex.SystemPriority.Lower; // run after motion/collision
  public query: ex.Query<typeof HealthComponent>;

  constructor(public world: ex.World) {
    super();
    this.query = world.query([HealthComponent]);
  }

  update() {
    for (const e of this.query.entities) {
      const hp = e.get(HealthComponent)!;
      if (hp.pendingDamage > 0) {
        hp.current -= hp.pendingDamage;
        hp.pendingDamage = 0;
        if (hp.current <= 0) e.kill();
      }
    }
  }
}

scene.world.add(DamageSystem);
```

### 2. Replacing a built-in system

Remove Excalibur's default and add your own with the same query.

```ts
const existing = scene.world.systemManager.get(ex.MotionSystem);
if (existing) scene.world.remove(existing);
scene.world.add(new MyDeterministicMotionSystem(scene.world));
```

### 3. Tag-driven AI

```ts
class AiSystem extends ex.System {
  public readonly systemType = ex.SystemType.Update;
  public query: ex.Query<typeof ex.TransformComponent>;

  constructor(public world: ex.World) {
    super();
    this.query = world.query({
      components: { all: [ex.TransformComponent] },
      tags: { all: ['enemy'], not: ['stunned'] },
    });
  }

  update(elapsed: number) {
    for (const e of this.query.entities) {
      // only non-stunned enemies end up here
    }
  }
}
```

Flip behavior by adding/removing a tag:

```ts
enemy.addTag('stunned');
setTimeout(() => enemy.removeTag('stunned'), 2000);
```

### 4. Bare-entity composition (no Actor)

```ts
const e = new ex.Entity({
  name: 'projectile',
  components: [
    new ex.TransformComponent(),
    new ex.MotionComponent(),
    new ex.GraphicsComponent(),
  ],
});
e.get(ex.TransformComponent)!.pos = ex.vec(100, 200);
e.get(ex.MotionComponent)!.vel = ex.vec(200, 0);
scene.add(e);
```

Use this only when you genuinely don't want the rest of Actor's surface area.
In 90% of cases, `class Projectile extends ex.Actor` is simpler.

## Gotchas

- **v0.29 breaking change.** `Component<'name'>` generic and `System<TComp>`
  generic were removed. If you see tutorials using those, they're 0.28. Current
  shape: `class MyComponent extends ex.Component` and systems build their
  own `query = world.query([...])` in the constructor.
- **Systems need `super()` in the constructor.** Missing it throws a TS error
  or a runtime prototype bug.
- **`priority` is `static`**, not an instance field. `public priority = 99` on
  the instance is ignored by the sort. Use `public static priority = 99` or
  assign via `SystemPriority` in class body.
- **Queries are shared and cached.** Two `world.query([A, B])` calls return
  the same `Query` object. Do not mutate `query.filter`. Reuse is the point —
  it's how the ECS stays fast.
- **Component removal is deferred.** `entity.removeComponent(X)` queues it;
  the component is still present for the rest of this frame's systems. Pass
  `true` to force immediate removal (risky mid-update).
- **Entity removal is also deferred.** `scene.remove(entity)` / `entity.kill()`
  schedule removal at the end of the frame.
- **One instance of a component type per entity.** `addComponent` is a no-op
  if the same type is already present. Pass `force = true` as the second arg
  to replace.
- **Components need zero-arg constructors for the `dependencies` feature.**
  If your constructor takes required args, you cannot list it in another
  component's `dependencies` — Excalibur calls `new Ctor()` to auto-add it.
- **Systemless components leak handlers if you forget `onRemove`.** Store the
  handler as an arrow-function property on `this` so you can pass the same
  reference to `on` and `off`.
- **Tag changes propagate immediately; component changes propagate during
  query checks.** `entity.addTag('x')` updates indexes synchronously.
- **`scene.world.add(Ctor)` vs. `new Ctor(world)`.** Both work. If you pass
  the ctor, Excalibur calls `new Ctor(this._world)` — your constructor must
  match that signature (take a `World`).
- **`queryTags` is marked `@deprecated` but still works.** Prefer
  `world.query({ tags: { all: [...] } })` for new code.
- **Update systems always run before Draw systems.** You cannot interleave
  them by tweaking `priority` — `systemType` sorts first.
- **Tags are a plain `Set<string>` on `Entity._tags`.** No more `TagComponent`
  shim. `entity.tags` returns the Set directly (read-only access — always
  mutate via `addTag`/`removeTag`, never by mutating the Set, or observers
  won't fire).
- **`SystemPriority.Highest` is `-Infinity`, `Lowest` is `Infinity`.** Math on
  these is usually fine in sorts, but don't add to them.

## Doc pointers

- `site/docs/05-entity-component-system/05-entity-component-system.mdx` — overview
- `site/docs/05-entity-component-system/05.1-entities.mdx` — Entity API
- `site/docs/05-entity-component-system/05.2-components.mdx` — Component API + built-ins
- `site/docs/05-entity-component-system/05.3-systems.mdx` — System API + priorities
- `site/docs/05-entity-component-system/05.4-queries.mdx` — component/tag queries
- `site/docs/00-tutorials/How-to's/00-ECS Primer/` — end-to-end primer
  (`01-what-is-ECS.mdx`, `02-custom components.mdx`, `03-custom-systems.mdx`,
  `04-systemless-components.mdx`)
- `site/docs/100-migrations.mdx` — v0.28 → v0.29 ECS changes
- `src/engine/entity-component-system/entity.ts` — `Entity` class, `EntityEvents`,
  `addComponent`/`removeComponent`, tags
- `src/engine/entity-component-system/component.ts` — `Component` base, `onAdd`/
  `onRemove`, `dependencies`, `clone`
- `src/engine/entity-component-system/system.ts` — `System`, `SystemType`
- `src/engine/entity-component-system/priority.ts` — `SystemPriority` constants
- `src/engine/entity-component-system/query.ts` — `Query`, `QueryParams` (`all`/
  `any`/`not`)
- `src/engine/entity-component-system/world.ts` — `World.add`/`remove`/`query`/
  `queryTags`
- `src/engine/entity-component-system/system-manager.ts` — sort order +
  update phases
- `src/engine/actor.ts` (line ~627) — which built-in components every Actor gets
