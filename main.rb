require "socket"
require "uri"
require_relative 'response'
require_relative 'request'

# https://docs.ruby-lang.org/ja/latest/class/TCPServer.html
gs = TCPServer.open("127.0.0.1", 8080);
addr = gs.addr
addr.shift
printf("server is on %s\n", addr.join(":"))

while true
    # https://docs.ruby-lang.org/ja/latest/class/Thread.html
    Thread.start(gs.accept) do |s|
        print(s, " is accepted\n")
        parser = Request.new(s);
        req = parser.parse

        if req
            res = Response.new()
            
            case req[:path]
            when "/"
                res.set_status(200)
                res.set_body("Welcome to my scratch HTTP Server!", "text/plain")
            when "/users"
                res.set_status(200)
                res.set_body('{"message": "user list endpoint"}', "application/json")  
            else
                res.set_status(404)
                res.set_body("404 Page Not Found", "text/plain")
            end

            res.send(s)
        end 

        s.close
    end
end
