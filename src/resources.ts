import * as ex from "excalibur";

export const Resources = {
  Sword: new ex.ImageSource("./images/sword.png"),
  GridTileMapImage: new ex.ImageSource("./art/tilemap.png"),
} as const;


export const loader = new ex.Loader();
for (const res of Object.values(Resources)) {
  loader.addResource(res);
}
