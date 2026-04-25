import * as ex from "excalibur";
import { Grid } from "../actors/grid";

export class MyLevel extends ex.Scene {
  override onInitialize(_engine: ex.Engine): void {
    const grid = new Grid();
    this.add(grid);
  }

  override onPreLoad(_loader: ex.DefaultLoader): void {}

  override onActivate(_context: ex.SceneActivationContext<unknown>): void {}

  override onDeactivate(_context: ex.SceneActivationContext): void {}

  override onPreUpdate(_engine: ex.Engine, _elapsedMs: number): void {}

  override onPostUpdate(_engine: ex.Engine, _elapsedMs: number): void {}

  override onPreDraw(_ctx: ex.ExcaliburGraphicsContext, _elapsedMs: number): void {}

  override onPostDraw(_ctx: ex.ExcaliburGraphicsContext, _elapsedMs: number): void {}
}
