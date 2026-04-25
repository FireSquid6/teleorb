import * as ex from "excalibur";


export interface PlayerArgs {
  x: number;
  y: number;
}

export const PLAYER_WIDTH = 16;
export const PLAYER_HEIGHT = 24;

const MOVE_SPEED = 120;
const ACCELERATION = 600;
const JUMP_SPEED = 260;
const GRAVITY = 700;


// this is its own function so that we can use it later
export function makePlayerCollider() {
  return new ex.PolygonCollider({
    points: [
      ex.vec(-PLAYER_WIDTH / 2, -PLAYER_HEIGHT / 2),
      ex.vec(-PLAYER_WIDTH / 2, PLAYER_HEIGHT / 2),
      ex.vec(PLAYER_WIDTH / 2, -PLAYER_HEIGHT / 2),
      ex.vec(PLAYER_WIDTH / 2, PLAYER_HEIGHT / 2),
    ]
  })
}

export class Player extends ex.Actor {
  private onGround = false;

  constructor({ x, y }: PlayerArgs) {
    super({
      x,
      y,
      collisionType: ex.CollisionType.Active,
      collider: makePlayerCollider(),
    });
  }

  override onInitialize(_engine: ex.Engine): void {
    this.on("postcollision", (evt) => {
      if (evt.side === ex.Side.Bottom) {
        this.onGround = true;
      }
    });
  }

  override update(engine: ex.Engine, elapsed: number): void {
    const seconds = elapsed / 1000;
    const kb = engine.input.keyboard;

    let dx = 0;
    if (kb.isHeld(ex.Keys.Left) || kb.isHeld(ex.Keys.A)) dx -= 1;
    if (kb.isHeld(ex.Keys.Right) || kb.isHeld(ex.Keys.D)) dx += 1;

    const targetVx = dx * MOVE_SPEED;
    const step = ACCELERATION * seconds;
    if (this.vel.x < targetVx) {
      this.vel.x = Math.min(this.vel.x + step, targetVx);
    } else if (this.vel.x > targetVx) {
      this.vel.x = Math.max(this.vel.x - step, targetVx);
    }

    const jumpPressed =
      kb.wasPressed(ex.Keys.Space) ||
      kb.wasPressed(ex.Keys.Up) ||
      kb.wasPressed(ex.Keys.W);
    if (jumpPressed && this.onGround) {
      this.vel.y = -JUMP_SPEED;
      this.onGround = false;
    }

    this.vel.y += GRAVITY * seconds;

    // cleared before physics; postcollision during super.update sets it again if still grounded
    this.onGround = false;
    super.update(engine, elapsed);
  }
}
