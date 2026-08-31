require "socket"
require "uri"
require_relative 'response'

class Request
    attr_reader :socket

    def initialize(socket)
        @socket = socket
    end

    def parse
        # 1. ストリーム処理でsocketからデータを読み込む

        # １行ずつ読み込んでその文字列を返す
        # gets : https://docs.ruby-lang.org/ja/latest/method/IO/i/gets.html
        request_line = socket.gets
        return nil unless request_line

        # 2. 生バイトのSocket通信をHTTP形式に解析する（リクエストを解析する）

        # リクエストラインのパース（最初の1行）
        # 例: "GET /search?q=ruby HTTP/1.1\r\n" 
        method, path, version, = request_line.split(' ')
        uri = URI.parse(path)

        # ヘッダー行のパース（空行が来るまで1行ずつ読み込む）
        # 例: "Host: localhost:8080\r\n"
        headers = {}
        while (line = socket.gets)
            # chomp = 改行を抜いた文字列だけを返す
            line = line.chomp
            break if line.empty?

            key, value = line.split(':', 2)
            headers[key.strip.downcase] = value.strip if key && value
        end

        # ボディの読み込み(Content-Lengthが指定されている場合のみ)
        body = nil
        if headers['content-length']
            length = headers['content-length'].to_i
            body = socket.read(length)
        end

        {
            method: method,
            path: path,
            version: version,
            headers: headers,
            body: body
        }
    end
end

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
