require "socket"

class Response
    STATUS_CODES = {
        200 => 'OK',
        400 => 'Bad Request',
        404 => 'Not Found',
        500 => 'Internal Server Error'
    }.freeze

    attr_accessor :status, :headers, :body

    def initialize
       @status = 200
       @headers = {
            'Content-Type' => 'text/html; charset=utf-8',
       }
       @body = ''
    end 

    def set_status(code)
        @status = code
        self
    end

    def set_header(key, value)
        @headers[key] = value
        self
    end

    def set_body(content, content_type)
        @body = content.to_s
        @headers['Content-Type'] = content_type
        self
    end

    def send(socket)
        @headers['Content-Length'] = @body.bytesize.to_s

        status_message = STATUS_CODES[@status]
        response = "HTTP/1.1 #{@status} #{status_message}\r\n"

        # 1行ずつヘッダーの情報を組み立てる
        @headers.each do |key, value|
            response << "#{key}: #{value}\r\n"
        end

        # 空行を追加することでヘッダーが終わりであることを伝える
        response << "\r\n"
        response << @body

        puts response
        
        socket.write(response)
    end
end