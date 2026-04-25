import * as ex from "excalibur";
import { LevelTilemap } from "../actors/level-tilemap";
import { Player } from "../actors/player";

export class MyLevel extends ex.Scene {
  override onInitialize(_engine: ex.Engine): void {
    this.add(new LevelTilemap());
    this.add(new Player({ x: 128, y: 128 }));
  }

  override onPreLoad(_loader: ex.DefaultLoader): void {}

  override onActivate(_context: ex.SceneActivationContext<unknown>): void {}

  override onDeactivate(_context: ex.SceneActivationContext): void {}

  override onPreUpdate(_engine: ex.Engine, _elapsedMs: number): void {}

  override onPostUpdate(_engine: ex.Engine, _elapsedMs: number): void {}

  override onPreDraw(_ctx: ex.ExcaliburGraphicsContext, _elapsedMs: number): void {}

  override onPostDraw(_ctx: ex.ExcaliburGraphicsContext, _elapsedMs: number): void {}
}
