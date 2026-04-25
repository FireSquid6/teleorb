import * as ex from "excalibur";
import { Tilesets } from "../tilesets";


export class Grid extends ex.Actor {
  override onInitialize(engine: ex.Engine): void {
    const terrain = new ex.TileMap({
      rows: 12,
      columns: 12,
      tileWidth: 32,
      tileHeight: 32,
    });

    const tilemap = new ex.TileMap({
      rows: 12,
      columns: 12,
      tileWidth: 32,
      tileHeight: 32,
    });


    for (const tile of terrain.tiles) {
      tile.addGraphic(Tilesets.GridTileset.getSprite(1, 1));
    }
    for (const tile of tilemap.tiles) {
      tile.addGraphic(new ex.Rectangle({
        width: 32,
        height: 32,
        color: new ex.Color(255, 0, 0, 0.1),
      }));
    }
    console.log("This is the initialize method of the grid actor");

    this.addChild(tilemap);
  }

  override update(engine: ex.Engine, elapsed: number): void {
    super.update(engine, elapsed);
  }


}
