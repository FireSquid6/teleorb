extends HttpServer
class_name TeleorbHttpServer




func _ready():
	server_identifier = "Teleorb Dedicated Server"
	register_router("/", Router.new())
	start()


class Router extends HttpRouter:
	func handle_get(req: HttpRequest, res: HttpResponse):
		pass
	
	func handle_post(req: HttpRequest, res: HttpResponse):
		pass
