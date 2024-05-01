extends HttpServer
class_name TeleorbHttpServer

signal start_on_level(level: String)


func startup():
	server_identifier = "Teleorb Dedicated Server"
	register_router("/", RootRouter.new())
	register_router("/level", LevelRouter.new())
	start()


class RootRouter extends HttpRouter:
	func handle_get(req: HttpRequest, res: HttpResponse):
		var status = {
			"level": World.curret_level.level_string,
			"player_count": len(Server.peers)
		}
		res.send(200, JSON.stringify(status))


class LevelRouter extends HttpRouter:
	func handle_post(req: HttpRequest, res: HttpResponse):
		var body = JSON.parse_string(req.body)  # see? No promises. Suck my dick javascript
		
		if not Server.validate_secret(body["secret"]):
			res.send(401)
		
		var new_level = body["level"]
		
		# tell the server to start the level
		Server.stop_server()
		Server.start_server(new_level)
