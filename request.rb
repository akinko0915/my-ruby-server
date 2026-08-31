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

        req = {
            method: method,
            path: path,
            version: version,
            headers: headers,
            body: body
        }

        puts req
        
        req
    end
end