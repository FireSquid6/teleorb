import Docker from "dockerode";



export class Gameserver {
  private docker: Docker 

  constructor(port: number) {
    this. docker = new Docker({
      port: port,
    })
  }

  start() {

  }

  kill() {

  }



}
