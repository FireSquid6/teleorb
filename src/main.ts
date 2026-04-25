import * as ex from "excalibur";
import { loader } from "./resources";
import { MyLevel } from "./scenes/level";

// Goal is to keep main.ts small and just enough to configure the engine

const game = new ex.Engine({
  width: 800, // Logical width and height in game pixels
  height: 600,
  displayMode: ex.DisplayMode.FitScreenAndFill, // Display mode tells excalibur how to fill the window
  pixelArt: true, // pixelArt will turn on the correct settings to render pixel art without jaggies or shimmering artifacts
  pixelRatio: 2,
  scenes: {
    start: MyLevel
  },
  // physics: {
  //   solver: SolverStrategy.Realistic,
  //   substep: 5 // Sub step the physics simulation for more robust simulations
  // },
  // fixedUpdateTimestep: 16 // Turn on fixed update timestep when consistent physic simulation is important
});

game.start('start', { // name of the start scene 'start'
  loader, // Optional loader (but needed for loading images/sounds)
  inTransition: new ex.FadeInOut({
    duration: 1000,
    direction: 'in',
    color: ex.Color.Black,
  })
}).then(() => {
  // Do something after the game starts
});
