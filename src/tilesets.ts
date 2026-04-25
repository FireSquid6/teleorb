import * as ex from "excalibur"
import { Resources } from "./resources";


export const Tilesets = {
  GridTileset: ex.SpriteSheet.fromImageSource({
    image: Resources.GridTileMapImage,
    grid: {
      rows: 8,
      columns: 8,
      spriteHeight: 32,
      spriteWidth: 32,
    }
  })
} as const;
